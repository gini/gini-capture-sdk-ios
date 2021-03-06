//
//  AppDelegate.m
//  GiniCaptureExampleObjC
//
//  Created by Peter Pult on 21/06/16.
//  Copyright © 2016 Gini. All rights reserved.
//

#import "AppDelegate.h"
#import "CredentialsManager.h"
#import <GiniCapture/GiniCapture-Swift.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

NSString *kClientId = @"client_id";
NSString *kClientPassword = @"client_password";
NSString *kClientDomain = @"client_domain";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSLog(@"Gini Capture SDK for iOS (%@)", [GiniCapture versionString]);
    
    NSDictionary<NSString*, NSString*> *credentials = [[[CredentialsManager alloc] init]
                                                       getCredentials];
    
    GINISDKBuilder *builder = [GINISDKBuilder anonymousUserWithClientID:credentials[kClientId]
                                                           clientSecret:credentials[kClientPassword]
                                                        userEmailDomain:credentials[kClientPassword]];
    self.giniSDK = [builder build];
    
    return YES;
}

@end
