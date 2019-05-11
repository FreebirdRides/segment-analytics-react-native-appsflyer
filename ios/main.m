//
//  main.m
//  RNAnalyticsIntegration
//
//  Created by fathy on 05/08/2018.
//  Copyright © 2018 Segment.io, Inc. All rights reserved.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <RNAnalytics/RNAnalytics.h>
//#import <segment-appsflyer-ios/SEGAppsFlyerIntegrationFactory.h>
#import "SEGAppsFlyerIntegrationFactory.h"

@interface RNAnalyticsIntegration_AppsFlyer: RCTEventEmitter<RCTBridgeModule, SEGAppsFlyerTrackerDelegate>
@end

@implementation RNAnalyticsIntegration_AppsFlyer

RCT_EXPORT_MODULE()

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"onInstallConversionData"];
}

// RCT_EXPORT_METHOD(setup) {
RCT_REMAP_METHOD(setup,
                setupWithResolver:(RCTPromiseResolveBlock)resolve
                rejecter:(RCTPromiseRejectBlock)reject)
{
  NSLog(@"RNAnalyticsIntegration_AppsFlyer setup");
  [RNAnalytics addIntegration:SEGAppsFlyerIntegrationFactory.instance];
  SEGAppsFlyerIntegrationFactory.instance.delegate = self;
  resolve(@{});
}

RCT_REMAP_METHOD(appsFlyerId,
                 appsFlyerIdWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
  NSString *appsflyerId = [[AppsFlyerTracker sharedTracker] getAppsFlyerUID];
  resolve(appsflyerId);
}

-(void)onConversionDataReceived:(NSDictionary*) installData {
    NSLog(@"RNAnalyticsIntegration_AppsFlyer onConversionDataReceived %@", installData);
    id status = [installData objectForKey:@"af_status"];
    if ([status isEqualToString:@"Non-organic"]) {
        id sourceID = [installData objectForKey:@"media_source"];
        id campaign = [installData objectForKey:@"campaign"];
        NSLog(@"This is a none organic install. Media source: %@  Campaign: %@",sourceID,campaign);
    } else if([status isEqualToString:@"Organic"]) {
        NSLog(@"This is an organic install.");
    }

    NSDictionary* message = @{
                              @"status": @"success",
                              @"type": @"onInstallConversionDataLoaded",
                              @"data": installData
                              };
    [self performSelectorOnMainThread:@selector(handleCallback:) withObject:message waitUntilDone:NO];
}

-(void)onConversionDataRequestFailure:(NSError *) _errorMessage {
    NSLog(@"RNAnalyticsIntegration_AppsFlyer onConversionDataRequestFailure %@",_errorMessage);
    NSDictionary* errorMessage = @{
                                   @"status": @"failure",
                                   @"type": @"onInstallConversionFailure",
                                   @"data": _errorMessage.localizedDescription
                                   };
    
    [self performSelectorOnMainThread:@selector(handleCallback:) withObject:errorMessage waitUntilDone:NO];
}

- (void) onAppOpenAttribution:(NSDictionary*) attributionData {
    NSLog(@"onAppOpenAttribution %@", attributionData);
    NSDictionary* message = @{
                                @"status": @"success",
                                @"type": @"onAppOpenAttribution",
                                @"data": attributionData
                            };
    
    [self performSelectorOnMainThread:@selector(handleCallback:) withObject:message waitUntilDone:NO];
}

- (void) onAppOpenAttributionFailure:(NSError *)_errorMessage {
    NSLog(@"RNAnalyticsIntegration_AppsFlyer onAppOpenAttributionFailure %@",_errorMessage);
    NSDictionary* errorMessage = @{
                                   @"status": @"failure",
                                   @"type": @"onAttributionFailure",
                                   @"data": _errorMessage.localizedDescription
                                 };

    [self performSelectorOnMainThread:@selector(handleCallback:) withObject:errorMessage waitUntilDone:NO];
}

-(void) handleCallback:(NSDictionary *) message {
    NSError *error;

    if ([NSJSONSerialization isValidJSONObject:message]) {
        NSData *jsonMessage = [NSJSONSerialization dataWithJSONObject:message
                                                              options:0
                                                                error:&error];
        if (jsonMessage) {
            NSString *jsonMessageStr = [[NSString alloc] initWithBytes:[jsonMessage bytes] length:[jsonMessage length] encoding:NSUTF8StringEncoding];
            NSString* status = (NSString*)[message objectForKey: @"status"];
            
            if ([status isEqualToString:@"success"]) {
                [self reportOnSuccess:jsonMessageStr];
            } else {
                [self reportOnFailure:jsonMessageStr];
            }
            
            NSLog(@"jsonMessageStr = %@", jsonMessageStr);
        } else {
            NSLog(@"%@", error);
        }
    } else {
       [self reportOnFailure:@"failed to parse response"];
    }
}

-(void) reportOnFailure:(NSString *) errorMessage {
  NSLog(@"RNAnalyticsIntegration_AppsFlyer reportOnFailure %@", errorMessage);
  [self sendEventWithName:@"onInstallConversionData" body:errorMessage];
}

-(void) reportOnSuccess:(NSString *) data {
  NSLog(@"RNAnalyticsIntegration_AppsFlyer reportOnSuccess %@", data);
  [self sendEventWithName:@"onInstallConversionData" body:data];
}

@end
