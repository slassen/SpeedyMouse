//
//  GCHelper.m
//  Ghost Maze
//
//  Created by Scott Lassen on 11/2/14.
//  Copyright (c) 2014 Scott Lassen. All rights reserved.
//

#import "GCHelper.h"
#import "SELPlayer.h"
#import "SELRootController.h"

@implementation GCHelper

@synthesize gameCenterAvailable;
//@synthesize userAuthenticated;

#pragma mark Initialization

static GCHelper *sharedHelper = nil;
+ (GCHelper *) sharedInstance {
    if (!sharedHelper) {
        sharedHelper = [[GCHelper alloc] init];
    }
    return sharedHelper;
}

- (BOOL)isGameCenterAvailable {
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer
                                           options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

- (id)init {
    if ((self = [super init])) {
        gameCenterAvailable = [self isGameCenterAvailable];
        if (gameCenterAvailable) {
            NSNotificationCenter *nc =
            [NSNotificationCenter defaultCenter];
            [nc addObserver:self
                   selector:@selector(authenticationChanged)
                       name:GKPlayerAuthenticationDidChangeNotificationName
                     object:nil];
        }
    }
    return self;
}

+(void)showAchievements {
    SELRootController *rc = (SELRootController*)[UIApplication sharedApplication].keyWindow.rootViewController;
    GameViewController *gvc = rc.gameViewController;
    
    GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
    gcViewController.gameCenterDelegate = gvc;
    gcViewController.viewState = GKGameCenterViewControllerStateAchievements;
//    gcViewController.leaderboardIdentifier = @"com.slgames.cheeseLeaderboard";

    [gvc presentViewController:gcViewController animated:YES completion:nil];
}

- (void)authenticationChanged {
    
    if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated) {
        NSLog(@"Authentication changed: player authenticated.");
        _signedIn = true;
        [[GameViewController gameView].gameCenterTimer invalidate];
        userAuthenticated = TRUE;
    } else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated) {
        NSLog(@"Authentication changed: player not authenticated");
        userAuthenticated = FALSE;
    }
    
}

+(void)reportAchievementsNamed:(NSArray*)achievementNames {
    NSMutableArray *achievementsToReport = [NSMutableArray array];
    for (NSString* name in achievementNames) {
        GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:name];
        achievement.percentComplete = 100;
        achievement.showsCompletionBanner = YES;
        [achievementsToReport addObject:achievement];
    }
    [GKAchievement reportAchievements:achievementsToReport withCompletionHandler:^(NSError *error) {
        NSLog(@"Error in reporting achievements: %@", error);
    }];
}

+(void)recordAchievements {
    GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:@"com.slgames.cheeseLeaderboard"];
    scoreReporter.value = [SELPlayer player].cheese;
    scoreReporter.context = 0;
    
    GKScore *levelReporter = [[GKScore alloc] initWithLeaderboardIdentifier:@"com.slgames.levelLeaderboard"];
    levelReporter.value = [SELPlayer player].currentLevel;
    levelReporter.context = 0;
    [GKScore reportScores:@[scoreReporter, levelReporter] withCompletionHandler:^(NSError *error) {}];
    
    // Allocate an array for achievement names.
    NSMutableArray *achievementNames = [NSMutableArray array];
    // Add achievements for cheese collected.
    if (scoreReporter.value >= 1000) [achievementNames addObject:@"com.slgames.collect1000"];
    if (scoreReporter.value >= 500) [achievementNames addObject:@"com.slgames.collect500"];
    if (scoreReporter.value >= 300) [achievementNames addObject:@"com.slgames.collect300"];
    if (scoreReporter.value >= 100) [achievementNames addObject:@"com.slgames.collect100"];
    if (scoreReporter.value >= 50) [achievementNames addObject:@"com.slgames.collect50"];
    if (scoreReporter.value >= 25) [achievementNames addObject:@"com.slgames.collect25"];

    // Add achievements for level.
    if ([SELPlayer player].currentLevel >=25) [achievementNames addObject:@"com.slgames.level25"];
    if ([SELPlayer player].currentLevel >=10) [achievementNames addObject:@"com.slgames.level10"];
    if ([SELPlayer player].currentLevel >=5) [achievementNames addObject:@"com.slgames.level5"];
    if ([SELPlayer player].currentLevel >=2) [achievementNames addObject:@"com.slgames.level2"];
    
    // Add achievement for max speed.
    // Max speed = 300 and base speed = 200 and cheese collecting = +1 so at 200 cheese max speed is reached.
    if (scoreReporter.value >= 200) [achievementNames addObject:@"com.slgames.maxSpeed"];
    
    // Add achievement for failing levels.
    if ([Settings settings].failCount >= 10) [achievementNames addObject:@"com.slgames.fail10"];
    if ([Settings settings].failCount >= 5) [achievementNames addObject:@"com.slgames.fail5"];
    
    // Report the achievements in a block.
    [GCHelper reportAchievementsNamed:achievementNames];
}

#pragma mark User functions

- (void)authenticateLocalUser {
    
    if (!gameCenterAvailable) return;
    
    NSLog(@"Authenticating local user...");
    if ([GKLocalPlayer localPlayer].authenticated == NO) {
//        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:nil];
        [[GKLocalPlayer localPlayer] setAuthenticateHandler:^(UIViewController *vc, NSError *error){
        }];
    }
    else NSLog(@"Already authenticated!");
}

@end
