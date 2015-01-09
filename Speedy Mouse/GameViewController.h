//
//  GameViewController.h
//  Ghost Maze
//

//  Copyright (c) 2014 Scott Lassen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <iAd/iAd.h>
#import "Settings.h"
@import GameKit;

@class MazeScene, SELLoadScene;

@interface GameViewController : UIViewController <GKGameCenterControllerDelegate, UIAlertViewDelegate>

@property (nonatomic) SELLoadScene *maze;
@property (nonatomic) NSTimer *gameCenterTimer;

+(GameViewController*) gameView;
-(void) gameCenterAlert;

@end
