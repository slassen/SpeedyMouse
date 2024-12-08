//
//  HelpScene.m
//  Speedy Mouse
//
//  Created by Scott Lassen on 1/9/15.
//  Copyright (c) 2015 Scott Lassen. All rights reserved.
//

#import "HelpScene.h"
#import "SELRandomMaze.h"
#import "SELPlayer.h"
#import "GCHelper.h"

@implementation HelpScene

{
    MazeScene *_returnMaze;
    SELRandomMaze *_bgLayer;
    int _cheeseCount;
    SKLabelNode *startLabel;
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    BOOL _starting;
    CGSize mazeSize; // Size of the maze.
    BOOL _showTutorial;
    
    SKNode *_tiltNode;
    SKNode *_steerNode;
    CGSize _helpNodeSize;
}

-(void)update:(NSTimeInterval)currentTime {
    
    // Smooth out jumpy movements by calulating update intervals.
    if (_lastUpdateTime) {
        _dt = currentTime - _lastUpdateTime;
    } else _dt = 0;
    _lastUpdateTime = currentTime;
    
    // Move the player.
    if ((![SELPlayer player].stopped) || (_starting && [SELPlayer player].stopped)) {
        [[SELPlayer player] updateWithTimeInterval:_dt];
    }
}

-(void)didSimulatePhysics {
//    return;
    // Check limits and set player position.
    CGSize size = self.size;
    CGFloat playerHeight = [SELPlayer player].position.y;
    if (playerHeight < size.height / 2) playerHeight = 0.0f;
    else if (playerHeight > mazeSize.height - (size.height / 2)) playerHeight = mazeSize.height - size.height;
    else playerHeight -= (size.height / 2);
    
    CGFloat playerWidth = [SELPlayer player].position.x;
    if (playerWidth < size.width / 2) playerWidth = 0.0f;
    else if (playerWidth > mazeSize.width - (size.width / 2)) playerWidth = mazeSize.width - size.width;
    else playerWidth -= (size.width / 2);
    
    _bgLayer.position = CGPointMake(-playerWidth, -playerHeight);
}

-(instancetype) initWithSize:(CGSize)size returnMaze:(MazeScene*)maze tutorial:(BOOL)tutorial {
    if (self = [super initWithSize:size]) {
        [SELPlayer player].playerSpeed = 150.0f;
        _returnMaze = maze;
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        _showTutorial = tutorial;
    }
    return self;
}

-(void)didMoveToView:(SKView *)view {
    _bgLayer = [[SELRandomMaze alloc] initWithTileSize:(self.frame.size.width / 6) fromString:@"XXXXXX\nXCCCCX\nXCCPCX\nXCCCCX\nXCCCCX\nXXXXXX"];
    mazeSize = _bgLayer.mazeSize; //So didSimulatePhysics can calculate size
    _starting = true;
    [self addChild:_bgLayer];
    [SELPlayer player].stopped = true;
    [SELPlayer player].physicsBody.resting = true;
    if (_showTutorial) {
        UIAlertView *av1 = [[UIAlertView alloc] initWithTitle:@"Speedy Mouse" message:@"Speedy loves cheese. Collect all of the cheese you can by tilting, not steering." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        av1.tag = 1;
        [av1 show];
    }
    
    // Create steering and tilting help nodes.
    SKAction *scaleNil =  [SKAction scaleTo:0 duration:0];
    _tiltNode = [SKSpriteNode node];
    _steerNode = [SKSpriteNode node];
    _helpNodeSize = CGSizeMake(self.view.frame.size.width /2.5, self.view.frame.size.width /2.5);
    SKSpriteNode *tiltHelpNode = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"tilt1"] color:nil size:_helpNodeSize];
    SKSpriteNode *noHelpNode = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"noSign"] color:nil size:_helpNodeSize];
    CGPoint steerNodePosition = CGPointMake(tiltHelpNode.size.width/2 + 15, tiltHelpNode.size.height);
    CGPoint tiltNodePosition = CGPointMake(self.view.frame.size.width - tiltHelpNode.size.width/2 - 15, tiltHelpNode.size.height);
    tiltHelpNode.zPosition = 10;
    tiltHelpNode.anchorPoint = CGPointMake(0.5, 0.5); //CGPointZero;
    tiltHelpNode.position = tiltNodePosition;
    [_tiltNode addChild:tiltHelpNode];
    [tiltHelpNode runAction:scaleNil];
    NSMutableArray *animationArray = [NSMutableArray array];
    for (int i = 1; i < 11; i++) {
        [animationArray addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"tilt%i", i]]];
    }
    SKAction *tiltLeft = [SKAction animateWithTextures:animationArray timePerFrame:0.1];
    SKAction *tiltRight = [tiltLeft reversedAction];
    [tiltHelpNode runAction:[SKAction repeatActionForever:[SKAction sequence:@[tiltLeft, tiltRight]]]];
    SKSpriteNode *goHelpNode = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"goSign"] color:nil size:_helpNodeSize];
    goHelpNode.zPosition = 11;
    goHelpNode.anchorPoint = CGPointMake(0.5, 0.5); //CGPointZero;
    goHelpNode.position = tiltNodePosition;
    [_tiltNode addChild:goHelpNode];
    [goHelpNode runAction:scaleNil];
    [_bgLayer addChild:_tiltNode];
    noHelpNode.zPosition = 11;
    noHelpNode.anchorPoint = CGPointMake(0.5, 0.5); //CGPointZero;
    noHelpNode.position = steerNodePosition;
    [_steerNode addChild:noHelpNode];
    [noHelpNode runAction:scaleNil];
    SKSpriteNode *deviceHelpNode = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"deviceWithHands"] color:nil size:_helpNodeSize];
    deviceHelpNode.zPosition = 10;
    deviceHelpNode.anchorPoint = CGPointMake(0.5, 0.5); //CGPointZero;
    deviceHelpNode.position = steerNodePosition;
    [_steerNode addChild:deviceHelpNode];
    [deviceHelpNode runAction:scaleNil];
    [_bgLayer addChild:_steerNode];
    SKAction *firstRotate = [SKAction rotateByAngle:-.5 duration:.5];
    SKAction *rotateLeft = [SKAction rotateByAngle:-1 duration:1];
    SKAction *rotateRight = [SKAction rotateByAngle:1 duration:1];
    SKAction *rotate = [SKAction repeatActionForever:[SKAction sequence:@[rotateRight, rotateLeft]]];
    [deviceHelpNode runAction:[SKAction sequence:@[firstRotate, rotate]]];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    //Skipping several AV's since I added animations.
    
    if (alertView.tag == 1) {
//        UIAlertView *av2 = [[UIAlertView alloc] initWithTitle:@"Speedy Mouse" message:@"When you collect all of the cheese in a level the next level begins." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        av2.tag = 2;
//        [av2 show];
        for (SKNode *node in _steerNode.children) {
//            [node runAction:[SKAction sequence:@[[SKAction scaleTo:1 duration:0.5], [SKAction waitForDuration:10], [SKAction group:@[[SKAction scaleTo:0.5 duration:3], [SKAction moveTo:CGPointMake(_helpNodeSize.width /2 , _helpNodeSize.height /2) duration:3]]]]]];
            [node runAction:[SKAction sequence:@[[SKAction scaleTo:1 duration:0.5], [SKAction waitForDuration:10], [SKAction group:@[[SKAction scaleTo:0 duration:3], [SKAction sequence:@[[SKAction waitForDuration:3], [SKAction runBlock:^{
                [node removeFromParent];
            }]]]]]]]];
        }
        for (SKNode *node in _tiltNode.children) {
//            [node runAction:[SKAction sequence:@[[SKAction scaleTo:1 duration:0.5], [SKAction waitForDuration:10], [SKAction group:@[[SKAction scaleTo:0.5 duration:3], [SKAction moveTo:CGPointMake(self.view.frame.size.width - _helpNodeSize.width /2 , _helpNodeSize.height /2) duration:3]]]]]];
            [node runAction:[SKAction sequence:@[[SKAction scaleTo:1 duration:0.5], [SKAction waitForDuration:10], [SKAction group:@[[SKAction scaleTo:0 duration:3], [SKAction sequence:@[[SKAction waitForDuration:3], [SKAction runBlock:^{
                [node removeFromParent];
            }]]]]]]]];
        }
        [self runAction:[SKAction waitForDuration:10.5] completion:^{
            UIAlertView *av10 = [[UIAlertView alloc] initWithTitle:@"Speedy Mouse" message:@"On the next screen you'll adjust your position and the movement sensitivity.\n\nYou can do this in the future when between games through the settings menu." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            av10.tag = 10;
            [av10 show];
        }];
    }
    else if (alertView.tag == 2) {
        UIAlertView *av3 = [[UIAlertView alloc] initWithTitle:@"Speedy Mouse" message:@"Each new level is larger and Speedy's kart speeds up as you collect more cheese.." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        av3.tag = 3;
        [av3 show];
    }
    else if (alertView.tag == 3) {
        UIAlertView *av4 = [[UIAlertView alloc] initWithTitle:@"Speedy Mouse" message:@"Speedy starts off with three lives and he earns his first extra life at 25 cheese, second at 50, third at 100, and so on.\n\nThe amount of cheese needed to earn a new life doubles each time." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        av4.tag = 4;
        [av4 show];
    }
    else if (alertView.tag == 4) {
        UIAlertView *av5 = [[UIAlertView alloc] initWithTitle:@"Speedy Mouse" message:@"You guide Speedy through the levels by tilting your device in the way you think he should move." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        av5.tag = 5;
        [av5 show];
    }
    else if (alertView.tag == 5) {
        UIAlertView *av10 = [[UIAlertView alloc] initWithTitle:@"Speedy Mouse" message:@"On the next screen you'll adjust your position and the movement sensitivity.\n\nYou can do this in the future when inbetween games through the settings menu." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        av10.tag = 10;
        [av10 show];
    }
    else if (alertView.tag == 10) {
        [GameViewController gameView].configurationView.hidden = false;
        [GameViewController gameView].maze = (MazeScene*)self;
        [GameViewController gameView].tutorialButton.enabled = false;
    }
    else if (alertView.tag == 6) {
        UIAlertView *av7 = [[UIAlertView alloc] initWithTitle:@"Speedy Mouse" message:@"Collect all of the cheese in the tutorial to go back to the game.\n\nNow try moving around the maze." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        av7.tag = 7;
        [av7 show];
    }
    else if (alertView.tag == 7) {
        [self startGame];
    }
    else if (alertView.tag == 8) {
        [SELPlayer player].position = _bgLayer.playerStartingPosition;
        [SELPlayer player].zRotation = 1.575;
        [SELPlayer player].physicsBody.resting = YES;
        _starting = YES;
        [self startGame];
    }
    else if (alertView.tag == 9) {
        if (![Settings settings].playerHasPlayedTutorial) {
            [Settings settings].playerHasPlayedTutorial = true;
            [[Settings settings] saveSettings];
        }
    }
}

-(void)didBeginContact:(SKPhysicsContact *)contact {
    if ([SELPlayer player].stopped) return; // To disable multiple calls when game is over.
    
    SKSpriteNode *player;
    if ([contact.bodyA.node.name isEqualToString:@"mouse"]) player = (SKSpriteNode*)contact.bodyA.node;
    else if ([contact.bodyB.node.name isEqualToString:@"mouse"]) player = (SKSpriteNode*)contact.bodyA.node;
    if (!player) return;
    
    SKSpriteNode *object;
    if (![contact.bodyA.node.name isEqualToString:@"mouse"]) object = (SKSpriteNode*)contact.bodyA.node;
    else if (![contact.bodyB.node.name isEqualToString:@"mouse"]) object = (SKSpriteNode*)contact.bodyB.node;
    
    if ([object.name isEqualToString:@"wallTile"]) {
        [SELPlayer player].physicsBody.contactTestBitMask = 0;
        [SELPlayer player].stopped = YES;
            
        //play crash
        [[Settings crashSoundEffect] play];
            
        SKEmitterNode *crashEmitter = [self nodeWithFileNamed:@"CrashEmitter.sks"];
        crashEmitter.zPosition = -1;
        [[SELPlayer player] addChild:crashEmitter];
        SKAction *waitAction = [SKAction waitForDuration:0.5];
        [self runAction:waitAction completion:^{
            [crashEmitter removeFromParent];
        }];
            
        //move player and restart current level
        UIAlertView *av8 = [[UIAlertView alloc] initWithTitle:@"Speedy Mouse" message:@"Speedy Mouse works best by tilting the device, not steering.\n\nWatch out for road cones and blocks. In the game you'll lose a life each time you hit one." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        av8.tag = 8;
        [av8 show];
    }
    
    else if ([object.name isEqualToString:@"cheese"]) {
        [object removeFromParent];
        _cheeseCount++;
        if (_cheeseCount >= _bgLayer.cheeseCount) {
            [SELPlayer player].stopped = YES;
            [SELPlayer player].physicsBody.resting = YES;
            UIAlertView *av9 = [[UIAlertView alloc] initWithTitle:@"Speedy Mouse" message:@"You've completed the tutorial. You can enter this tutorial at any time by pressing the \"Tutorial\" button in the settings menu.\n\nNow go out and help Speedy get fat!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            av9.tag = 9;
            [av9 show];
        }
    }
}

-(void)startGame {
    // Unpause the game and pause the players physics body.
    [SELPlayer player].physicsBody.resting = YES;
    self.paused = NO;
    
    // Create and load a label that displays a count down at start of level.
    CGFloat durationBetweenNumbers = 1.0f;
    startLabel = [SKLabelNode labelNodeWithFontNamed:@"Super Mario 256"];
    startLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    startLabel.fontColor = [UIColor whiteColor];
    startLabel.position = CGPointMake(self.size.width /2, self.size.height - self.size.height /4);
    startLabel.zPosition = LayerLevelTop;
    startLabel.fontSize = 72;
    startLabel.text =  @"READY";
    [self addChild:startLabel];
    [startLabel runAction:[SKAction waitForDuration:durationBetweenNumbers] completion:^{
        
        // Set the default position of the game to how the player is holding the device now.
//        [Settings setTiltPosition];
        
        startLabel.text = @"GO!";
        
        // Make the player start.
        [Settings burnoutSoundEffect];
        SKEmitterNode *burnoutEmitter = [self nodeWithFileNamed:@"BurnoutEmitter.sks"];
        burnoutEmitter.zPosition = -1;
        [[SELPlayer player] addChild:burnoutEmitter];
        SKAction *waitAction = [SKAction waitForDuration:0.5];
        //        burnoutEmitter.position = [SELPlayer player].position;
        [self runAction:waitAction completion:^{
            [burnoutEmitter removeFromParent];
        }];
        [SELPlayer player].stopped = NO;
        _starting = NO;
        [[SELPlayer player] launchPlayerGradually];
        [startLabel runAction:[SKAction waitForDuration:0.25] completion:^{
            SKAction *fade = [SKAction fadeOutWithDuration:0.0];
            SKAction *blink = [SKAction sequence:@[fade, [SKAction waitForDuration:0.25], fade.reversedAction, [SKAction waitForDuration:0.25]]];
            [startLabel runAction:[SKAction repeatAction:blink count:3] completion:^{
                [startLabel removeFromParent];
            }];
        }];
    }];
}


-(SKEmitterNode*)nodeWithFileNamed:(NSString*)name { // iOS8 method overwritten to allow compatibility with iOS7
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:name ofType:nil]];
}

-(void)returnToMaze {
    
    if ([SELPlayer player].parent) {
        [[SELPlayer player] removeFromParent];
    }
    [SELPlayer player].currentLevel = 1;
    [[SELPlayer player] resetLives];
    [SELPlayer player].stopped = YES;
    MazeScene *scene = [[MazeScene alloc] initWithSize:self.size];
    scene.newGame = true;
    [Settings backgroundMusicPlayer];
    scene.scaleMode = SKSceneScaleModeAspectFill;
//    SKTransition *transition = [SKTransition pushWithDirection:SKTransitionDirectionLeft duration:0.5];
//    [self.view presentScene:scene transition:transition];
    [self.view presentScene:scene];
    
//    [_returnMaze.bgLayer addChild:[SELPlayer player]];
//    [SELPlayer player].position = _returnMaze.bgLayer.playerStartingPosition;
    [SELPlayer player].zRotation = 1.575;
    [SELPlayer player].physicsBody.resting = YES;
    
//    [self.view presentScene:_returnMaze];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    [self returnToMaze];
}

@end
