//
//  GameViewController.m
//  Ghost Maze
//
//  Created by Scott Lassen on 10/26/14.
//  Copyright (c) 2014 Scott Lassen. All rights reserved.
//

#import "GameViewController.h"
#import "MazeScene.h"
#import "SELPlayer.h"
#import "GCHelper.h"
#import "Flurry.h"
#import "HelpScene.h"


//#import <AdColony/AdColony.h>
@import SpriteKit;

@interface GameViewController ()

@end


@implementation GameViewController

+(GameViewController*) gameView {
    static GameViewController *view = nil;
    if (!view) {
        view =[[GameViewController alloc] initWithNibName:@"GameViewController" bundle:nil];
    }
    return view;
}

-(void)viewDidLayoutSubviews {
    [self loadMazeScene];
}

-(void)loadMazeScene {
    //Setup the rest of the view.
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    
    // Debug Options
    //    skView.showsFPS = YES;
    //    skView.showsNodeCount = YES;
    //    skView.showsPhysics = YES;
    
    // Create and configure the maze scene.
    CGSize sceneSize = skView.bounds.size;
    
    // On iPhone/iPod touch we want to see a similar amount of the scene as on iPad.
    // So, we set the size of the scene to be double the size of the view, which is
    // the whole screen, 3.5- or 4- inch. This effectively scales the scene to 50%.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        sceneSize.height /= 2;
        sceneSize.width /= 2;
    }
    
    skView.ignoresSiblingOrder = YES;
    static MazeScene *scene;
    if (!scene) {
        scene = [[MazeScene alloc] initWithSize:sceneSize];
        scene.newGame = YES;
        [Settings backgroundMusicPlayer];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        _loaderView.hidden = true;
        [_loaderIndicator stopAnimating];
        _loaderIndicator.hidden = true;
        SKTransition *transition = [SKTransition pushWithDirection:SKTransitionDirectionLeft duration:0.5];
        [skView presentScene:scene transition:transition];
    }
}

-(void) alertGameCenter: (id)sender {
    

    if ([GKLocalPlayer localPlayer].authenticated == NO && [Settings settings].playerHasPlayedTutorial) {
        [self gameCenterAlert];
    }
}

-(void)launchGameCenterApp {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"gamecenter:"]];
}
- (IBAction)tiltNormalSelected:(id)sender {
    NSLog(@"normal");
    [_normalButton setImage:[UIImage imageNamed:@"normalSelected"] forState:UIControlStateNormal];
    [_topDownButton setImage:[UIImage imageNamed:@"topDown"] forState:UIControlStateNormal];
    [Settings settings].ay = GLKVector3Make(0.82f, 0.0f, -0.58f);
    [[Settings settings] saveSettings];
}

- (IBAction)tiltTopdownSelected:(id)sender {
    NSLog(@"top down");
    [_topDownButton setImage:[UIImage imageNamed:@"topDownSelected"] forState:UIControlStateNormal];
    [_normalButton setImage:[UIImage imageNamed:@"normal"] forState:UIControlStateNormal];
//    [Settings settings].ay = GLKVector3Make(0.39f, 0.0f, -0.92f);
    [Settings settings].ay = GLKVector3Make(0.63f, 0.0f, -0.92f);
    [[Settings settings] saveSettings];
}

- (IBAction)configurationDoneSelected:(id)sender {
    _configurationView.hidden = true;
    
    [Settings settings].tiltSensitivity = 0.45f - _tiltSensitivity.value;
    [[Settings settings] saveSettings];
    
    if ([SELPlayer player].playerSpeed == 150.0f) {
        [GameViewController gameView].tutorialButton.enabled = true;
//        UIAlertView *av6 = [[UIAlertView alloc] initWithTitle:@"Speedy Mouse" message:@"Stay away from the road cones and road blocks. If you hit one of them you lose a life!" delegate:self.maze cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        av6.tag = 6;
//        [av6 show];
        UIAlertView *av7 = [[UIAlertView alloc] initWithTitle:@"Speedy Mouse" message:@"Collect all of the cheese in the tutorial to go back to the game.\n\nNow try moving around the maze by tilting the device, not steering." delegate:self.maze cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        av7.tag = 7;
        [av7 show];
    }
    else _maze.inConfig = false;
}

- (IBAction)tutorialButtonSelected:(id)sender {
    _configurationView.hidden = true;
    _maze.inConfig = false;
    
    SKView *skView = (SKView*)self.view;
    // Create and configure the maze scene.
    CGSize sceneSize = skView.bounds.size;
    
    // On iPhone/iPod touch we want to see a similar amount of the scene as on iPad.
    // So, we set the size of the scene to be double the size of the view, which is
    // the whole screen, 3.5- or 4- inch. This effectively scales the scene to 50%.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        sceneSize.height /= 2;
        sceneSize.width /= 2;
    }
    
    skView.ignoresSiblingOrder = YES;
    HelpScene *help = [[HelpScene alloc] initWithSize:sceneSize returnMaze:nil tutorial:true];
    
    [skView presentScene:help];
}

-(void) gameCenterAlert {
    if ([GCHelper sharedInstance].authenticationViewController) {
        [[GameViewController gameView] presentViewController:[GCHelper sharedInstance].authenticationViewController animated:true completion:nil];
    }
    else {
        NSLog(@"no authentication controller or controller pointer is nil. launching app instead");
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"gamecenter:"]];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"gamecenter:"]];
    }
}

-(void)viewDidLoad {
    if ([Settings settings].ay.z == -0.92f) [_topDownButton setImage:[UIImage imageNamed:@"topDownSelected"] forState:UIControlStateNormal];
    else [_normalButton setImage:[UIImage imageNamed:@"normalSelected"] forState:UIControlStateNormal];
    

    // Curve configuration view
    _configurationView.layer.cornerRadius = 15;
    _configurationView.layer.masksToBounds = YES;
    [_tiltSensitivity setValue:0.45f - [Settings settings].tiltSensitivity];
    
    // Setup Crittercism
//    [Crittercism enableWithAppID:@"yourRegisteredOnCrittercismAppId" andDelegate:self];
    
    [_loaderIndicator startAnimating];
    
    // Start the motion manager
    [Settings motionManager];
    
    [[SELPlayer player] resetLives];
    
    //load the bg music
    [Settings FU3];
    [Settings FU4];
    [Settings FU5];
    [Settings FU6];
    [Settings FU7];
}

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
    [self dismissViewControllerAnimated:gameCenterViewController completion:nil];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeLeft;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
