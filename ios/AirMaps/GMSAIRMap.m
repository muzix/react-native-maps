//
//  GMSAIRMap.m
//  Pods
//
//  Created by Hoang Pham Huu on 7/19/16.
//
//

#import "GMSAIRMap.h"

#import "RCTEventDispatcher.h"
#import "AIRMapMarker.h"
#import "UIView+React.h"
#import "AIRMapPolyline.h"
#import "AIRMapPolygon.h"
#import "AIRMapCircle.h"
#import <QuartzCore/QuartzCore.h>

const CLLocationDegrees GMS_AIRMapDefaultSpan = 0.005;
const NSTimeInterval GMS_AIRMapRegionChangeObserveInterval = 0.1;
const CGFloat GMS_AIRMapZoomBoundBuffer = 0.01;

@interface GMSAIRMap ()

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, assign) NSNumber *shouldZoomEnabled;
@property (nonatomic, assign) NSNumber *shouldScrollEnabled;

- (void)updateScrollEnabled;
- (void)updateZoomEnabled;

@end

@implementation GMSAIRMap
{
    UIView *_legalLabel;
    CLLocationManager *_locationManager;
    BOOL _initialRegionSet;
    
    // Array to manually track RN subviews
    //
    // AIRMap implicitly creates subviews that aren't regular RN children
    // (SMCalloutView injects an overlay subview), which otherwise confuses RN
    // during component re-renders:
    // https://github.com/facebook/react-native/blob/v0.16.0/React/Modules/RCTUIManager.m#L657
    //
    // Implementation based on RCTTextField, another component with indirect children
    // https://github.com/facebook/react-native/blob/v0.16.0/Libraries/Text/RCTTextField.m#L20
    NSMutableArray<UIView *> *_reactSubviews;
}

- (instancetype)init
{
    if ((self = [super init])) {
        _hasStartedRendering = NO;
        _reactSubviews = [NSMutableArray new];
        
        // Find Apple link label
        for (UIView *subview in self.subviews) {
            if ([NSStringFromClass(subview.class) isEqualToString:@"MKAttributionLabel"]) {
                // This check is super hacky, but the whole premise of moving around
                // Apple's internal subviews is super hacky
                _legalLabel = subview;
                break;
            }
        }
        
        // 3rd-party callout view for MapKit that has more options than the built-in. It's painstakingly built to
        // be identical to the built-in callout view (which has a private API)
        self.calloutView = [SMCalloutView platformCalloutView];
        self.calloutView.delegate = self;
    }
    return self;
}

@end
