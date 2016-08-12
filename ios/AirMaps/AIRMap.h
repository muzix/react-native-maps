/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>
#import <React/RCTComponent.h>

#import "RCTConvert+MapKit.h"
#import "RCTComponent.h"
#import "SMCalloutView.h"

#import "WildcardGestureRecognizer.h"

extern const CLLocationDegrees AIRMapDefaultSpan;
extern const NSTimeInterval AIRMapRegionChangeObserveInterval;
extern const CGFloat AIRMapZoomBoundBuffer;

@interface AIRMap: MKMapView<SMCalloutViewDelegate>

@property (nonatomic, strong) SMCalloutView *calloutView;
@property (nonatomic, strong) UIImageView *cacheImageView;
@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, strong) id<MKOverlay> topOverlay;
@property (nonatomic, strong) NSMutableArray *bottomOverlay;

@property (nonatomic, assign) BOOL followUserLocation;
@property (nonatomic, assign) BOOL hasStartedRendering;
@property (nonatomic, assign) BOOL cacheEnabled;
@property (nonatomic, assign) BOOL loadingEnabled;
@property (nonatomic, strong) UIColor *loadingBackgroundColor;
@property (nonatomic, strong) UIColor *loadingIndicatorColor;
@property (nonatomic, assign) BOOL hasShownInitialLoading;
@property (nonatomic, assign) CGFloat minDelta;
@property (nonatomic, assign) CGFloat maxDelta;
@property (nonatomic, assign) UIEdgeInsets legalLabelInsets;
@property (nonatomic, strong) NSTimer *regionChangeObserveTimer;
@property (nonatomic, assign) MKCoordinateRegion initialRegion;

@property (nonatomic, assign) CLLocationCoordinate2D pendingCenter;
@property (nonatomic, assign) MKCoordinateSpan pendingSpan;


@property (nonatomic, assign) BOOL ignoreRegionChanges;

@property (nonatomic, strong) WildcardGestureRecognizer * tapInterceptor;

@property (nonatomic, copy) RCTBubblingEventBlock onChange;
@property (nonatomic, copy) RCTBubblingEventBlock onPress;
@property (nonatomic, copy) RCTBubblingEventBlock onPanDrag;
@property (nonatomic, copy) RCTBubblingEventBlock onLongPress;
@property (nonatomic, copy) RCTDirectEventBlock onMarkerPress;
@property (nonatomic, copy) RCTDirectEventBlock onMarkerSelect;
@property (nonatomic, copy) RCTDirectEventBlock onMarkerDeselect;
@property (nonatomic, copy) RCTDirectEventBlock onMarkerDragStart;
@property (nonatomic, copy) RCTDirectEventBlock onMarkerDrag;
@property (nonatomic, copy) RCTDirectEventBlock onMarkerDragEnd;
@property (nonatomic, copy) RCTDirectEventBlock onCalloutPress;
@property (nonatomic, copy) RCTDirectEventBlock onRegionChange;

- (void)cacheViewIfNeeded;
- (void)beginLoading;
- (void)finishLoading;

@end
