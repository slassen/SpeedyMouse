//
//  AppDelegate.m
//  Speedy Mouse
//
//  Created by Scott Lassen on 1/7/15.
//  Copyright (c) 2015 Scott Lassen. All rights reserved.
//

#import "AppDelegate.h"
#import "GCHelper.h"
#import "Settings.h"
#import "MazeScene.h"
#import "SELRootController.h"
#import "Flurry.h"
#import "Appirater.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//     Override point for customization after application launch.

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    SELRootController *root = [[SELRootController alloc] init];
    self.window.rootViewController = root;
    [self.window makeKeyAndVisible];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [[GCHelper sharedInstance] authenticateLocalUser];
    
    // Setup Flurry
//    [Flurry startSession:@"F99SH9ZSFGQQZX3XRWY3"];
//    [Flurry setSessionReportsOnCloseEnabled:YES];
//    [Flurry setSessionReportsOnPauseEnabled:YES];

    // Setup Appirator
    [Appirater setAppId:@"936513414"];
    [Appirater setDaysUntilPrompt:7];
    [Appirater setUsesUntilPrompt:5];
    [Appirater setTimeBeforeReminding:3];
//    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater  setCustomAlertTitle:@"Enjoying yourself?"];
    [Appirater  setCustomAlertMessage:@"If you like the game using one minute of your time to rate it would help the developer out a lot!"];
    [Appirater  setCustomAlertCancelButtonTitle:@"I only care about myself."];
    [Appirater  setCustomAlertRateButtonTitle:@"Um, yeah! 5 stars!"];
    [Appirater  setCustomAlertRateLaterButtonTitle:@"I'll do it later... I swear!"];
//    [Appirater setDebug:YES];
    [Appirater appLaunched:YES];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
