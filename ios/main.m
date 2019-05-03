//
//  main.m
//  RNAnalyticsIntegration
//
//  Created by fathy on 05/08/2018.
//  Copyright © 2018 Segment.io, Inc. All rights reserved.
//

#import <React/RCTBridgeModule.h>
#import <RNAnalytics/RNAnalytics.h>
//#import <segment-appsflyer-ios/SEGAppsFlyerIntegrationFactory.h>
#import "SEGAppsFlyerIntegrationFactory.h"

@interface RNAnalyticsIntegration_AppsFlyer: NSObject<RCTBridgeModule>
@end

@implementation RNAnalyticsIntegration_AppsFlyer

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(setup) {
    [RNAnalytics addIntegration:SEGAppsFlyerIntegrationFactory.instance];
}

@end
