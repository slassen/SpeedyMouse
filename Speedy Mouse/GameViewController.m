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
#import "FlurryAds.h"
//#import <AdColony/AdColony.h>
@import SpriteKit;

@implementation GameViewController

+(GameViewController*) gameView {
    static GameViewController *view = nil;
    if (!view) {
        view =[[GameViewController alloc] initWithNibName:@"GameViewController" bundle:nil];
    }
    return view;
}

- (IBAction)watchAd:(id)sender {
//    [AdColony playVideoAdForZone:@"vz9eb3ffb90f3f4ba29c" withDelegate:nil];
}

-(void) alertGameCenter: (id)sender {
    
    
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
        SKTransition *transition = [SKTransition pushWithDirection:SKTransitionDirectionLeft duration:0.5];
        [skView presentScene:scene transition:transition];
    }
    
    if (![GCHelper sharedInstance].signedIn) {
        [[[UIAlertView alloc] initWithTitle:@"Game Center Unavailable" message:@"You aren't connected to the internet or game center isn't signed in.\nYou are unable to earn achievements without Game Center." delegate:self cancelButtonTitle:@"I want trophies!" otherButtonTitles:@"Who Cares?", nil] show];
    }
}

-(void) gameCenterAlert {
    [[[UIAlertView alloc] initWithTitle:@"Game Center Unavailable" message:@"You aren't connected to the internet or game center isn't signed in.\n\nYou are unable to earn achievements without Game Center." delegate:self cancelButtonTitle:@"I want trophies!" otherButtonTitles:@"Who Cares?", nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"gamecenter:"]];
    }
}

-(void)viewDidLoad {
//    _gameCenterTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(alertGameCenter:) userInfo:nil repeats:NO];
    
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

+(void)showAd {
    if ([FlurryAds adReadyForSpace:@"INTERSTITIAL_MAIN_VIEW"]) {
//        [FlurryAds displayAdForSpace:@"INTERSTITIAL_MAIN_VIEW" onView:nil viewControllerForPresentation:self];
    }
    else {
    // Fetch an ad (note: optimize ad // serving by fetching early)
//    [FlurryAds fetchAdForSpace:@"INTERSTITIAL_MAIN_VIEW" frame:self.view size:FULLSCREEN];
    }
}


- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

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
        SKTransition *transition = [SKTransition pushWithDirection:SKTransitionDirectionLeft duration:0.5];
        [skView presentScene:scene transition:transition];
    }
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
