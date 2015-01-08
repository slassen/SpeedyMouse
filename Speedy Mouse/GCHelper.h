//
//  GCHelper.h
//  Ghost Maze
//
//  Created by Scott Lassen on 11/2/14.
//  Copyright (c) 2014 Scott Lassen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface GCHelper : NSObject {
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
}

@property (assign, readonly) BOOL gameCenterAvailable;
@property (assign, readonly) BOOL signedIn;

+ (GCHelper *)sharedInstance;
- (void)authenticateLocalUser;
+(void)recordAchievements;
+(void)reportAchievementsNamed:(NSArray*)achievementNames;
+(void)showAchievements;

@end