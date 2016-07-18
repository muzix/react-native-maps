//
//  GMSAIRMapManager.m
//  Pods
//
//  Created by Hoang Pham Huu on 7/19/16.
//
//

#import "GMSAIRMapManager.h"

#import "GMSAIRMap.h"
#import <GoogleMaps/GoogleMaps.h>

@implementation GMSAIRMapManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:6];
    GMSAIRMap *map = [GMSAIRMap mapWithFrame:CGRectZero camera:camera];
    map.myLocationEnabled = YES;
    
    
    return map;
}

@end
