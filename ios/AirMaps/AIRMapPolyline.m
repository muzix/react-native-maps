//
// Created by Leland Richardson on 12/27/15.
// Copyright (c) 2015 Facebook. All rights reserved.
//

#import "AIRMapPolyline.h"
#import "UIView+React.h"
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import "WildcardGestureRecognizer.h"

@implementation AIRMapPolyline {

}

- (void)setFillColor:(UIColor *)fillColor {
    _fillColor = fillColor;
    [self update];
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    _strokeColor = strokeColor;
    [self update];
}

- (void)setStrokeWidth:(CGFloat)strokeWidth {
    _strokeWidth = strokeWidth;
    [self update];
}

- (void)setLineJoin:(CGLineJoin)lineJoin {
    _lineJoin = lineJoin;
    [self update];
}

- (void)setLineCap:(CGLineCap)lineCap {
    _lineCap = lineCap;
    [self update];
}

- (void)setMiterLimit:(CGFloat)miterLimit {
    _miterLimit = miterLimit;
    [self update];
}

- (void)setLineDashPhase:(CGFloat)lineDashPhase {
    _lineDashPhase = lineDashPhase;
    [self update];
}

- (void)setLineDashPattern:(NSArray <NSNumber *> *)lineDashPattern {
    _lineDashPattern = lineDashPattern;
    [self update];
}

- (void)setCoordinates:(NSArray<AIRMapCoordinate *> *)coordinates {
    _coordinates = coordinates;
    CLLocationCoordinate2D coords[coordinates.count];
    for(int i = 0; i < coordinates.count; i++)
    {
        coords[i] = coordinates[i].coordinate;
    }
    self.polyline = [MKPolyline polylineWithCoordinates:coords count:coordinates.count];
    self.renderer = [[MKPolylineRenderer alloc] initWithPolyline:self.polyline];
    [self update];
}

- (void)setZIndex:(NSInteger)zIndex
{
    _zIndex = zIndex;
    if (zIndex != 1) {
        // self.tag = 0;
        // NOTHING
        // self.layer.zPosition = 0;
    } else {
        // self.tag = 10;
        [self addGesture];
        // self.layer.zPosition = 1;
        
    }
    [self update];
}

- (void)setMap:(AIRMap *)map
{
    _map = map;
    [self addGesture];
}

- (void) update
{
    if (!_renderer) return;
    _renderer.fillColor = _fillColor;
    _renderer.strokeColor = _strokeColor;
    _renderer.lineWidth = _strokeWidth;
    _renderer.lineCap = _lineCap;
    _renderer.lineJoin = _lineJoin;
    _renderer.miterLimit = _miterLimit;
    _renderer.lineDashPhase = _lineDashPhase;
    _renderer.lineDashPattern = _lineDashPattern;

    if (_map == nil) return;
    // [_map removeOverlay:self];
    // [_map addOverlay:self];
    
    if (self.zIndex == 1) {
        [_map removeOverlay:self];
        [_map addOverlay:self];
    }
}

- (void)addGesture
{
    if (_map.tapInterceptor == nil) {
        _map.tapInterceptor = [[WildcardGestureRecognizer alloc] init];
        __weak AIRMapPolyline *weakSelf = self;
        _map.tapInterceptor.touchesEndCallback = ^(NSSet * touches, UIEvent * event) {
            // Get map coordinate from touch point
            UITouch *touch = [touches anyObject];
            CGPoint touchPt = [touch locationInView:weakSelf.map];
            CLLocationCoordinate2D coord = [weakSelf.map convertPoint:touchPt toCoordinateFromView:weakSelf.map];
            
            double maxMeters = [weakSelf metersFromPixel:MAX_DISTANCE_PX atPoint:touchPt];
            
            float nearestDistance = MAXFLOAT;
            AIRMapPolyline *nearestPoly = nil;
            
            // for every overlay ...
            for (id <MKOverlay> overlay in weakSelf.map.overlays) {
                
                // .. if MKPolyline ...
                if ([overlay isKindOfClass:[AIRMapPolyline class]]) {
                    AIRMapPolyline *polyView = (AIRMapPolyline*)overlay;
                    // ... get the distance ...
                    float distance = [weakSelf distanceOfPoint:MKMapPointForCoordinate(coord)
                                                    toPoly:polyView.polyline];
                    
                    if (distance <= maxMeters && polyView.zIndex == 1) {
                        nearestDistance = distance;
                        nearestPoly = overlay;
                        break;
                    }
                    
                    // ... and find the nearest one
                    if (distance < nearestDistance) {
                        nearestDistance = distance;
                        nearestPoly = overlay;
                    }
                }
            }
            
            if (nearestDistance <= maxMeters) {
                
                NSLog(@"Touched poly: %@\n"
                      "    distance: %f", nearestPoly, nearestDistance);
                nearestPoly.onPress(@{ @"latitude": [NSNumber numberWithDouble:coord.latitude], @"longitude": [NSNumber numberWithDouble:coord.longitude] });
            }
            
        };
        [self.map addGestureRecognizer:_map.tapInterceptor];
    }
}

/** Returns the distance of |pt| to |poly| in meters
 *
 * from http://paulbourke.net/geometry/pointlineplane/DistancePoint.java
 *
 */
- (double)distanceOfPoint:(MKMapPoint)pt toPoly:(MKPolyline *)poly
{
    double distance = MAXFLOAT;
    for (int n = 0; n < poly.pointCount - 1; n++) {
        
        MKMapPoint ptA = poly.points[n];
        MKMapPoint ptB = poly.points[n + 1];
        
        double xDelta = ptB.x - ptA.x;
        double yDelta = ptB.y - ptA.y;
        
        if (xDelta == 0.0 && yDelta == 0.0) {
            
            // Points must not be equal
            continue;
        }
        
        double u = ((pt.x - ptA.x) * xDelta + (pt.y - ptA.y) * yDelta) / (xDelta * xDelta + yDelta * yDelta);
        MKMapPoint ptClosest;
        if (u < 0.0) {
            
            ptClosest = ptA;
        }
        else if (u > 1.0) {
            
            ptClosest = ptB;
        }
        else {
            
            ptClosest = MKMapPointMake(ptA.x + u * xDelta, ptA.y + u * yDelta);
        }
        
        distance = MIN(distance, MKMetersBetweenMapPoints(ptClosest, pt));
    }
    
    return distance;
}


/** Converts |px| to meters at location |pt| */
- (double)metersFromPixel:(NSUInteger)px atPoint:(CGPoint)pt
{
    CGPoint ptB = CGPointMake(pt.x + px, pt.y);
    
    CLLocationCoordinate2D coordA = [self.map convertPoint:pt toCoordinateFromView:self.map];
    CLLocationCoordinate2D coordB = [self.map convertPoint:ptB toCoordinateFromView:self.map];
    
    return MKMetersBetweenMapPoints(MKMapPointForCoordinate(coordA), MKMapPointForCoordinate(coordB));
}


#pragma mark MKOverlay implementation

- (CLLocationCoordinate2D) coordinate
{
    return self.polyline.coordinate;
}

- (MKMapRect) boundingMapRect
{
    return self.polyline.boundingMapRect;
}

- (BOOL)intersectsMapRect:(MKMapRect)mapRect
{
    BOOL answer = [self.polyline intersectsMapRect:mapRect];
    return answer;
}

- (BOOL)canReplaceMapContent
{
    return NO;
}


#pragma mark AIRMapSnapshot implementation

- (void) drawToSnapshot:(MKMapSnapshot *) snapshot context:(CGContextRef) context
{
    // Prepare context
    CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor);
    CGContextSetLineWidth(context, self.strokeWidth);
    CGContextSetLineCap(context, self.lineCap);
    CGContextSetLineJoin(context, self.lineJoin);
    CGContextSetMiterLimit(context, self.miterLimit);
    CGFloat dashes[self.lineDashPattern.count];
    for (NSUInteger i = 0; i < self.lineDashPattern.count; i++) {
        dashes[i] = self.lineDashPattern[i].floatValue;
    }
    CGContextSetLineDash(context, self.lineDashPhase, dashes, self.lineDashPattern.count);
    
    // Begin path
    CGContextBeginPath(context);
    
    // Get coordinates
    CLLocationCoordinate2D coordinates[[self.polyline pointCount]];
    [self.polyline getCoordinates:coordinates range:NSMakeRange(0, [self.polyline pointCount])];
    
    // Draw line segments
    for(int i = 0; i < [self.polyline pointCount]; i++) {
        CGPoint point = [snapshot pointForCoordinate:coordinates[i]];
        if (i == 0) {
            CGContextMoveToPoint(context,point.x, point.y);
        }
        else{
            CGContextAddLineToPoint(context,point.x, point.y);
        }
    }
    
    // Finish path
    CGContextStrokePath(context);
}

@end