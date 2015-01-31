//
//  SELPlayer.h
//  Ghost Maze
//
//  Created by Scott Lassen on 11/16/14.
//  Copyright (c) 2014 Scott Lassen. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "MazeScene.h"
#import "Settings.h"

@class MazeScene;

@interface SELPlayer : SKSpriteNode

@property (nonatomic) MazeScene *playerScene;
@property (nonatomic) CGFloat playerSpeed;
@property (nonatomic) BOOL stopped;
@property (nonatomic) int currentLevel;
@property (nonatomic) int cheese;
@property (nonatomic) int lives;
@property (nonatomic) int cheeseToLives;

// For touches
@property (nonatomic) CGPoint touchVelocity;

-(void)updateWithTimeInterval:(NSTimeInterval)dt;

-(void)resetLives;

+(instancetype)player;
-(void)launchPlayerGradually;

@end
