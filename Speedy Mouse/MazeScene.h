//
//  MazeScene.h
//  Ghost Maze
//
//  Created by Scott Lassen on 10/26/14.
//  Copyright (c) 2014 Scott Lassen. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <GameKit/GameKit.h>
#import "Settings.h"
#import "GameViewController.h"

enum ColliderTypes {
    ColliderTypePlayer = 1,
    ColliderTypeBlock = 4,
    ColliderTypeCheese = 8,
};

enum LayerLevel {
    LayerLevelBackground = 1,
    LayerLevelBelowPlayer = 2,
    LayerLevelPlayer = 4,
    LayerLevelAbovePlayer = 8,
    LayerLevelTop = 16,
};

@class MazeScene, SELRandomMaze, SELMaze;

@interface MazeScene : SKScene <SKPhysicsContactDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) GameViewController *vc;
@property (nonatomic) SELRandomMaze *bgLayer; //This is background layer node.
@property (nonatomic) BOOL canRestart;
@property (nonatomic) BOOL newGame;
@property (nonatomic) BOOL startAutomatically;
@property (nonatomic) BOOL continuing;
@property (nonatomic) BOOL inConfig;
@property (nonatomic) int cheeseCollected;

-(void)setPlayerPosition:(CGPoint)position;

@end

