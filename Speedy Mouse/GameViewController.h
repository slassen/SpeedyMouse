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

@class MazeScene;

@interface GameViewController : UIViewController <GKGameCenterControllerDelegate, UIAlertViewDelegate>

@property (nonatomic) MazeScene *maze;
@property (nonatomic) NSTimer *gameCenterTimer;
@property (nonatomic) IBOutlet UIView *loaderView;
@property (nonatomic) IBOutlet UIActivityIndicatorView *loaderIndicator;

@property (weak, nonatomic) IBOutlet UIView *configurationView;
@property (weak, nonatomic) IBOutlet UISlider *tiltSensitivity;
- (IBAction)tutorialButtonSelected:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *tutorialButton;
@property (weak, nonatomic) IBOutlet UIButton *topDownButton;
@property (weak, nonatomic) IBOutlet UIButton *normalButton;


+(GameViewController*) gameView;
-(void) gameCenterAlert;
-(void) alertGameCenter: (id)sender;

@end
