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
#import "Crittercism.h"
@import GameKit;

@class MazeScene;

@interface GameViewController : UIViewController <GKGameCenterControllerDelegate, UIAlertViewDelegate, CrittercismDelegate>

@property (nonatomic) MazeScene *maze;
@property (nonatomic) NSTimer *gameCenterTimer;
@property (nonatomic) IBOutlet UIView *loaderView;
@property (nonatomic) IBOutlet UIActivityIndicatorView *loaderIndicator;

@property (weak, nonatomic) IBOutlet UIView *configurationView;
@property (weak, nonatomic) IBOutlet UISlider *tiltSensitivity;


+(GameViewController*) gameView;
-(void) gameCenterAlert;

@end
