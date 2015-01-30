//
//  MazeScene.m
//  Ghost Maze
//
//  Created by Scott Lassen on 10/26/14.
//  Copyright (c) 2014 Scott Lassen. All rights reserved.
//

#import "SELPlayer.h"
#import "SELRandomMaze.h"
#import "GameViewController.h"
#import "GCHelper.h"
#import "MazeScene.h"
#import "SELRootController.h"
#import "HelpScene.h"
#import "Flurry.h"

#pragma mark Maze Scene

static const float maxPlayerSpeed = 300.0f; // the maximum speed the player can move
static const float playerScaleMod = .15f; // how big is the player is compared to a normal tile
static const float jumpInterval = 0.1f; // minimum interval cones can jump


@implementation MazeScene

{
    MazeScene *_newScene; // Hold a class scope variable for presenting new scene seemlessly.
    CGFloat tileSize; // How big the tiles are.
    CGSize mazeSize; // Size of the maze.
    
    //Properties from Zombie Conga
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    
    NSTimeInterval _lastJump; // When was the last jump by a cone?
    
    BOOL _cheeseFound;
    int _tileCount;
    BOOL _paused;
    BOOL _crashed;
    BOOL _gameOver;
    SKLabelNode *startLabel;
    SKLabelNode *cheeseLabel;
    SKLabelNode *livesLabel;
    UISwipeGestureRecognizer *_swipeUp;
    
    SKLabelNode *levelLabel;
    SKLabelNode *cheeseCountLabel;
    SKSpriteNode *cheeseImage;
    
    SKSpriteNode *gameCenterNode;
    SKSpriteNode *helpCenterNode;
    
    CGPoint _lastCheesePosition;
}

-(void)update:(NSTimeInterval)currentTime {
    
//    NSLog(@"x: %f, y: %f, z: %f", [Settings motionManager].accelerometerData.acceleration.x, [Settings motionManager].accelerometerData.acceleration.y, [Settings motionManager].accelerometerData.acceleration.z);
    
    // Smooth out jumpy movements by calulating update intervals.
    if (_lastUpdateTime) {
        _dt = currentTime - _lastUpdateTime;
    } else _dt = 0;
    _lastUpdateTime = currentTime;
    
    // Move the player.
    if ((!_gameOver && [SELPlayer player].stopped && !_crashed) || (![SELPlayer player].stopped)) {
        [[SELPlayer player] updateWithTimeInterval:_dt];
    }
    
    // Make the cones jump.
    if (currentTime >= _lastJump + jumpInterval && !_paused) {
        _lastJump = currentTime;
        [self randomConeJump];
    }
}

-(instancetype) initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        [self beginGame];
    }
    return self;
}

-(void)setPlayerPosition:(CGPoint)position {
    [SELPlayer player].position = position;
}

-(SKEmitterNode*)nodeWithFileNamed:(NSString*)name { // iOS8 method overwritten to allow compatibility with iOS7
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:name ofType:nil]];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_inConfig) return;
    
    SKNode *node = [self nodeAtPoint:[[touches anyObject] locationInNode:self ]];
    if ([node.name isEqualToString:@"gameCenter"]) {
        [self enterAchievements:nil];
        return;
    }
    else if ([node.name isEqualToString:@"helpCenter"]) {
        _inConfig = true;
        [GameViewController gameView].configurationView.hidden = false;
        [GameViewController gameView].maze = self;
        return;
    }
    
    if (_gameOver && _canRestart) {
        [startLabel removeAllActions];
        [startLabel runAction:[SKAction fadeInWithDuration:0]];
        _gameOver = NO;
        _canRestart = NO;
        [SELPlayer player].speed = 150;
        [SELPlayer player].cheese = 0;
        [SELPlayer player].currentLevel = 1;
        MazeScene *newScene = [[MazeScene alloc] initWithSize:self.size];
        newScene.startAutomatically = YES;
        [Settings restartBackgroundMusic];
        newScene.scaleMode = SKSceneScaleModeAspectFill;
        SKTransition *transition = [SKTransition pushWithDirection:SKTransitionDirectionUp duration:0.5];
        [self.view presentScene:newScene transition:transition];
        [Flurry logEvent:@"GameStarted" timed:true];
    }
    if (_canRestart) {
        [startLabel removeAllActions];
        [startLabel runAction:[SKAction fadeInWithDuration:0]];
//        [Settings restartBackgroundMusic];
        [self startGame];
        _canRestart = NO;
    }
    if (_newGame) {
        [startLabel removeAllActions];
        [startLabel runAction:[SKAction fadeInWithDuration:0]];
        _newGame = NO;
        [self startGame];
        [Settings restartBackgroundMusic];
    }
}

-(void) enterAchievements: (id)sender {
    if (![GKLocalPlayer localPlayer].isAuthenticated) return;
    if (_newGame || _canRestart) {
        [[Settings backgroundMusicPlayer] pause];
        [GCHelper showAchievements];
    }
}

-(void)gameOver {
    [Flurry endTimedEvent:@"GameStarted" withParameters:nil];

    [[SELPlayer player] resetLives];
//    _gameOver = YES;
    _crashed = true;
    [SELPlayer player].physicsBody.contactTestBitMask = 0;
    [SELPlayer player].stopped = YES;
    
    SKEmitterNode *crashEmitter = [self nodeWithFileNamed:@"CrashEmitter.sks"];
    crashEmitter.zPosition = -1;
    [[SELPlayer player] addChild:crashEmitter];
    SKAction *waitAction = [SKAction waitForDuration:0.5];
    [self runAction:waitAction completion:^{
        [crashEmitter removeFromParent];
    }];
    [Settings pauseFU];
    [Settings gameOverSoundEffect];
    [self runAction:[SKAction waitForDuration:1.0] completion:^{
        if ([GKLocalPlayer localPlayer].isAuthenticated) {
            [self addChild:gameCenterNode];
        }
        [self addChild:helpCenterNode];
        
        [GCHelper recordAchievements];
        if (!startLabel.parent) [self addChild:startLabel];
        startLabel.position = CGPointMake(self.size.width /2, self.size.height /2);
        startLabel.text = @"Game Over";
        [startLabel runAction:[SKAction fadeInWithDuration:0]];
        [self addChild:levelLabel];
        levelLabel.text = [NSString stringWithFormat:@"Level: %i", [SELPlayer player].currentLevel];
        [self addChild:cheeseCountLabel];
        cheeseCountLabel.text = [NSString stringWithFormat:@"Cheese: %i", [SELPlayer player].cheese];
        [self runAction:[SKAction waitForDuration:2.0] completion:^{
            startLabel.text = @"Try again?";
            [startLabel runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction fadeOutWithDuration:0.0], [SKAction waitForDuration:0.2], [SKAction fadeInWithDuration:0.0], [SKAction waitForDuration:1.0]]]]];
            _canRestart = YES;
            _gameOver = true;
            _crashed = false;
            _startAutomatically = YES;
        }];
    }];
}

- (void) resetAchievements
{
    // Clear all progress saved on Game Center
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error){
        
    }];
}

-(void)beginGame {
    
    _paused = NO;
    self.paused = NO;
    
//    _gameOver = YES;
    _canRestart = NO;
    
    // Reset cheese count and level count.
    _cheeseCollected = 0;
    
    //Clean up old maze.
    [self removeAllChildren];
    [self removeAllActions];
    [[SELPlayer player] removeFromParent];
    
    //Create settings if not already created
    [Settings settings];
    
    // Create parts of world.
    [self setupWorld];
    
    [SELPlayer player].position = _bgLayer.playerStartingPosition;
    [SELPlayer player].zRotation = 1.575;
    
    [self syncAllObjectsToMaze];
    
    // Setup level label.
    levelLabel = [SKLabelNode labelNodeWithFontNamed:@"Super Mario 256"];
    levelLabel.fontColor = [UIColor whiteColor];
    levelLabel.fontSize = 48;
    levelLabel.zPosition = LayerLevelTop;
    levelLabel.text = [NSString stringWithFormat:@"Level: %i", [SELPlayer player].currentLevel];
    [levelLabel removeFromParent];
    levelLabel.position = CGPointMake(self.size.width / 2, levelLabel.frame.size.height / 2);
    
    // Setup cheese count label.
    cheeseCountLabel = [SKLabelNode labelNodeWithFontNamed:@"Super Mario 256"];
    cheeseCountLabel.fontColor = [UIColor whiteColor];
    cheeseCountLabel.fontSize = 48;
    cheeseCountLabel.zPosition = LayerLevelTop;
    cheeseCountLabel.text = [NSString stringWithFormat:@"Cheese: %i", [SELPlayer player].cheese];
    [cheeseCountLabel removeFromParent];
    cheeseCountLabel.position = CGPointMake(self.size.width / 2,
                                       self.size.height - cheeseCountLabel.frame.size.height - cheeseCountLabel.frame.size.height / 2);
    
    // Setup Game Center Node
    gameCenterNode = [SKSpriteNode spriteNodeWithTexture:[[SKTextureAtlas atlasNamed:@"Art"] textureNamed:@"gameCenter"] size:CGSizeMake(60, 60)];
    gameCenterNode.position = CGPointMake(gameCenterNode.frame.size.width /2 + 10, self.size.height - gameCenterNode.frame.size.height / 2 + - 10);
    gameCenterNode.name = @"gameCenter";
    gameCenterNode.zPosition = LayerLevelTop;
    
    // Setup Help Center Node
    helpCenterNode = [SKSpriteNode spriteNodeWithTexture:[[SKTextureAtlas atlasNamed:@"Art"] textureNamed:@"help"] size:CGSizeMake(60, 60)];
    helpCenterNode.position = CGPointMake(self.size.width - gameCenterNode.frame.size.width /2 - 10, self.size.height - gameCenterNode.frame.size.height / 2 + - 10);
    helpCenterNode.name = @"helpCenter";
    helpCenterNode.zPosition = LayerLevelTop;
    
    if ([SELPlayer player].currentLevel >= 2) {
        [self addChild:livesLabel];
        [self addChild:cheeseImage];
        [self addChild:cheeseLabel];
    }
    
    _lastCheesePosition = _bgLayer.playerStartingPosition;
}

-(void)startGame {
    
    if (gameCenterNode.parent) [gameCenterNode removeFromParent];
    if (helpCenterNode.parent) [helpCenterNode removeFromParent];
    if (!livesLabel.parent) [self addChild:livesLabel];
    if (!cheeseImage.parent) [self addChild:cheeseImage];
    if (!cheeseLabel.parent) [self addChild:cheeseLabel];

    // Unpause the game and pause the players physics body.
    [SELPlayer player].physicsBody.resting = YES;
    self.paused = NO;
//    [self resetAchievements]; // to reset game center server stored achievements
    // Create and load a label that displays a count down at start of level.
    CGFloat durationBetweenNumbers = 1.0f;
    
startLabel.fontSize = 72;
    startLabel.text = [NSString stringWithFormat:@"Level: %i", [SELPlayer player].currentLevel];

    [startLabel runAction:[SKAction waitForDuration:durationBetweenNumbers] completion:^{
        
        // Set the default position of the game to how the player is holding the device now.
//        [Settings setTiltPosition];
        [startLabel runAction:[SKAction moveTo:CGPointMake(self.size.width /2, self.size.height - self.size.height /4) duration:0.25]];
        
        startLabel.text =  @"READY";
        [startLabel runAction:[SKAction waitForDuration:durationBetweenNumbers] completion:^{
            [startLabel runAction:[SKAction moveTo:CGPointMake(self.size.width /2, self.size.height + self.size.height /4) duration:2.0]];
            startLabel.text = @"GO!";
            
            //        _gameOver = NO;
            
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
            [[SELPlayer player] launchPlayerGradually]; // added to launch player gradually
            [startLabel runAction:[SKAction waitForDuration:0.25] completion:^{
                SKAction *fade = [SKAction fadeOutWithDuration:0.0];
                SKAction *blink = [SKAction sequence:@[fade, [SKAction waitForDuration:0.25], fade.reversedAction, [SKAction waitForDuration:0.25]]];
                [startLabel runAction:[SKAction repeatAction:blink count:3] completion:^{
                    [startLabel removeFromParent];
                }];
            }];
        }];
    }];
}

-(void)didMoveToView:(SKView *)view {
    
//    _swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(enterAchievements:)];
//    _swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
//    _swipeUp.numberOfTouchesRequired = 1;
//    _swipeUp.delaysTouchesBegan = YES;
//    _swipeUp.delegate = self;
//    
//    [self.view addGestureRecognizer:_swipeUp];
    [self removeAllActions];
    
    if (![GCHelper sharedInstance].signedIn && [SELPlayer player].currentLevel >=5) {
        // Show game center alert if not signed in.
        [[GameViewController gameView] gameCenterAlert];
    }

    if (_newGame) {
        [Flurry logEvent:@"GameStarted" timed:true];
        if ([GKLocalPlayer localPlayer].isAuthenticated) {
            if (!gameCenterNode.parent) [self addChild:gameCenterNode];
        }
        if (!helpCenterNode.parent) [self addChild:helpCenterNode];
        [[SELPlayer player] resetLives];
        startLabel = [SKLabelNode labelNodeWithFontNamed:@"Super Mario 256"];
        startLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        startLabel.fontSize = 48;
        startLabel.fontColor = [UIColor whiteColor];
        startLabel.zPosition = LayerLevelTop;
        startLabel.text = @"Tap to start";
        [self addChild:startLabel];
        startLabel.position = CGPointMake(self.size.width /2, self.size.height /2);
        [startLabel runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction fadeOutWithDuration:0.0],[SKAction waitForDuration:0.2], [SKAction fadeInWithDuration:0.0], [SKAction waitForDuration:1.0]]]]];
    }
    else {
        _canRestart = YES;
        startLabel = [SKLabelNode labelNodeWithFontNamed:@"Super Mario 256"];
        startLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        startLabel.text = @"Tap to start";
                startLabel.fontSize = 48;
//        startLabel.text = [NSString stringWithFormat:@"Level: %i", [SELPlayer player].currentLevel];
        startLabel.position = CGPointMake(self.size.width /2, self.size.height /2);
        startLabel.zPosition = LayerLevelTop;
        [self addChild:startLabel];
        [startLabel runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction fadeOutWithDuration:0.0], [SKAction waitForDuration:0.2], [SKAction fadeInWithDuration:0.0], [SKAction waitForDuration:1.0]]]]];
        if (_startAutomatically) {
            _startAutomatically = NO;
            [self startGame];
        }
    }
    
    if (![Settings settings].playerHasPlayedTutorial) {
        HelpScene *help = [[HelpScene alloc] initWithSize:self.size returnMaze:nil tutorial:true];
        [self.view presentScene:help];
    }
}

-(void)createStartLabel {
    [startLabel removeAllActions];
    [startLabel runAction:[SKAction fadeInWithDuration:0]];
//    startLabel = [SKLabelNode labelNodeWithFontNamed:@"MisterVampire"];
//    startLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    startLabel.position = CGPointMake(self.size.width /2, self.size.height /2);
    startLabel.text = @"Tap to start";
            startLabel.fontSize = 48;
//    startLabel.fontSize = 72;
//    startLabel.zPosition = LayerLevelTop;
    [self addChild:startLabel];
    [startLabel runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction fadeOutWithDuration:0.0], [SKAction waitForDuration:0.2], [SKAction fadeInWithDuration:0.0], [SKAction waitForDuration:1.0]]]]];
//    startLabel.position = [self centerLabelOnBackground: startLabel];
}

-(void) collectCheeseAtPoint:(CGPoint)point {
    _lastCheesePosition = point;
    
    // Increase the score.
    [SELPlayer player].cheese++;
    cheeseLabel.text = [NSString stringWithFormat:@"%i", [SELPlayer player].cheese];
    cheeseLabel.position = CGPointMake(cheeseImage.position.x - cheeseImage.frame.size.width / 2 - cheeseLabel.frame.size.width / 2, cheeseImage.position.y - (cheeseImage.frame.size.height /2));
    // Increase player speed if it hasn't reached maximum speed.
    if ([SELPlayer player].playerSpeed < maxPlayerSpeed && [SELPlayer player].cheese %2 ==0) [SELPlayer player].playerSpeed += 1;
    
    // Increase cheeseCollected count
    _cheeseCollected++;
    
    if ([SELPlayer player].cheese % [SELPlayer player].cheeseToLives == 0) {
        [SELPlayer player].cheeseToLives *= 2;
        SKLabelNode *bonus = [SKLabelNode labelNodeWithFontNamed:@"Super Mario 256"];
        bonus.zPosition = LayerLevelTop;
        bonus.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        bonus.position = CGPointMake(self.size.width / 2, self.size.height / 2);
        bonus.text = @"+1 Life";
        [SELPlayer player].lives++;
        livesLabel.text = [NSString stringWithFormat:@"❤%i", [SELPlayer player].lives];
//        cheeseLabel.text = [NSString stringWithFormat:@"%i", [SELPlayer player].cheese];
        [self addChild:bonus];
        [bonus runAction:[SKAction waitForDuration:0] completion:^{
            [bonus runAction:[SKAction moveTo:CGPointMake(self.size.width /2, self.size.height + self.size.height /4) duration:3.0] completion:^{
                [bonus removeFromParent];
            }];
        }];
    }
}

-(void) placeStartingPosition {
    _bgLayer.playerStartingPosition = _lastCheesePosition;
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
        [SELPlayer player].stopped = true;
        [self placeStartingPosition];
//        return;
        
        if ([SELPlayer player].lives > 1) { // if player has lives
            [SELPlayer player].lives--;
            livesLabel.text = [NSString stringWithFormat:@"❤%i", [SELPlayer player].lives];
//            _gameOver = YES;
            [SELPlayer player].physicsBody.contactTestBitMask = 0;
            _crashed = true;
            [SELPlayer player].stopped = YES;
            
            //play crash
            [[Settings crashSoundEffect] play];
            
            SKEmitterNode *crashEmitter = [self nodeWithFileNamed:@"CrashEmitter.sks"];
            crashEmitter.zPosition = -1;
            [[SELPlayer player] addChild:crashEmitter];
            SKAction *waitAction = [SKAction waitForDuration:0.2];
            [self runAction:waitAction completion:^{
                [crashEmitter removeFromParent];
            }];
            
            //move player and restart current level
            
            [self runAction:[SKAction sequence:@[[SKAction waitForDuration:3.0], [SKAction runBlock:^{
                [SELPlayer player].position = _bgLayer.playerStartingPosition;
                [SELPlayer player].zRotation = 1.575;
                _crashed = false;
                [SELPlayer player].physicsBody.resting = YES;
                [self createStartLabel];
                _canRestart = YES;
//                [self startGame];
            }]]]];
        }
        else {
            [livesLabel removeFromParent];
            [cheeseLabel removeFromParent];
            [cheeseImage removeFromParent];
            [startLabel removeAllActions];
            
            [Settings settings].failCount++;
            [self gameOver];
        }
    }
    
    else if ([object.name isEqualToString:@"cheese"]) {
        [object removeFromParent];
        [self collectCheeseAtPoint:object.position];
    }
    
    if (_cheeseCollected >= _bgLayer.cheeseCount) {
        if (startLabel.parent) [startLabel removeFromParent];
        [Settings settings].failCount = 0;
        
        [SELPlayer player].currentLevel++;
        
        // Create, and present the next level.
        [SELPlayer player].stopped = YES;
        _crashed = true;
        [SELPlayer player].physicsBody.resting = YES;
        
        SKSpriteNode *blackScreen = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:self.size];
        blackScreen.alpha = .8;
        blackScreen.name = @"blackScreen";
        blackScreen.zPosition = LayerLevelPlayer;
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"MisterVampire"];
        blackScreen.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        label.text = [self randomCompliment];
        label.zPosition = LayerLevelTop;
        label.fontSize = 48;
        label.position = CGPointZero;
        [blackScreen addChild:label];
        [self addChild:blackScreen];
        
        [self newScene];
        SKAction *fadeIn = [SKAction sequence:@[[SKAction colorizeWithColor:[UIColor blackColor] colorBlendFactor:1 duration:0.5], [SKAction fadeInWithDuration:0.5]]];
        [blackScreen runAction:fadeIn completion:^{
            [self runAction:[SKAction waitForDuration:1.0] completion:^{
                SKTransition *transition = [SKTransition pushWithDirection:SKTransitionDirectionUp duration:0.5];
                    [self.view presentScene:_newScene transition:transition];
                    [Settings restartBackgroundMusic];
            }];
        }];
    }
}

-(void) newScene {
    _newScene = [[MazeScene alloc] initWithSize:self.size];
    _newScene.scaleMode = SKSceneScaleModeAspectFill;
}

-(NSString*)randomCompliment {
    int choice = arc4random() % 7;
    switch (choice) {
        case 0:
            return @"Gnarly!";
            break;
        case 1:
            return @"Tubular.";
            break;
        case 2:
            return @"Way Cool!";
            break;
        case 3:
            return @"Awesome.";
            break;
        case 4:
            return @"Groovy!";
            break;
        case 5:
            return @"Mondo.";
            break;
        case 6:
            return @"Outrageous!";
            break;
        case 7:
            return @"Funky.";
            break;
        default:
            break;
    }
    return @"Nice!";
}

-(void)setupWorld {
    
    // Make the tileSize the size of a 1/6th of the screen.
    tileSize = self.frame.size.width / 6;
    
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsWorld.contactDelegate = self;
    
    [self addBackgroundLayer];
    
    // Add HUD.
    // Add the lives label.
    livesLabel = [SKLabelNode labelNodeWithFontNamed:@"Super Mario 256"];
    livesLabel.fontSize = 42;
    livesLabel.fontColor = [UIColor whiteColor];
    livesLabel.text = [NSString stringWithFormat:@"❤%i", [SELPlayer player].lives];
    livesLabel.zPosition = LayerLevelTop;
    
    livesLabel.position = CGPointMake(livesLabel.frame.size.width / 2,
                                      self.size.height - livesLabel.frame.size.height + 10);
    
    // Add the cheese image and level.
    cheeseImage = [SKSpriteNode spriteNodeWithTexture:
                                 [SKTexture textureWithImageNamed:@"cheese"] size:CGSizeMake(40, 40)];
    cheeseImage.zPosition = LayerLevelTop;
    cheeseImage.position = CGPointMake(self.size.width - cheeseImage.frame.size.width / 2,
                                       self.size.height - cheeseImage.frame.size.height / 2);
    
    cheeseLabel = [SKLabelNode labelNodeWithFontNamed:@"Super Mario 256"];
    cheeseLabel.fontColor = [UIColor whiteColor];
    cheeseLabel.zPosition = LayerLevelTop;
    cheeseLabel.fontSize = 48;
    cheeseLabel.text = [NSString stringWithFormat:@"%i", [SELPlayer player].cheese];
    cheeseLabel.position = CGPointMake(cheeseImage.position.x - cheeseImage.frame.size.width / 2 - cheeseLabel.frame.size.width / 2, cheeseImage.position.y  - cheeseLabel.frame.size.height /2);//self.size.height - cheeseLabel.frame.size.height);
    
    
    mazeSize = _bgLayer.mazeSize; //So didSimulatePhysics can calculate size
}

-(void) addBackgroundLayer {
    //Add the background layer with provided image and scale image to size provided.
    _bgLayer = [[SELRandomMaze alloc] initWithTileSize:tileSize];
    [self addChild:_bgLayer];
}

//Final Zombie conga methods

-(CGPoint)centerLabelOnBackground:(SKLabelNode*)label { // only for centering start label node
    CGSize size = self.size;
    
    // need to set _bgLayer position first
    CGFloat playerHeight = [SELPlayer player].position.y;
    if (playerHeight < size.height / 2) playerHeight = 0.0f;
    else if (playerHeight > mazeSize.height - (size.height / 2)) playerHeight = mazeSize.height - size.height;
    else playerHeight -= (size.height / 2);
    
    CGFloat playerWidth = [SELPlayer player].position.x;
    if (playerWidth < size.width / 2) playerWidth = 0.0f;
    else if (playerWidth > mazeSize.width - (size.width / 2)) playerWidth = mazeSize.width - size.width;
    else playerWidth -= (size.width / 2);

    return CGPointMake(size.width / 2 + _bgLayer.position.x, size.height / 2);
}

-(void)didSimulatePhysics {
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

-(void)randomConeJump {
    SKSpriteNode *jumpingNode = _bgLayer.wallTiles[(arc4random() % (_bgLayer.wallTiles.count - 1))];
    int amountToJump = 5;
    SKAction *jump = [SKAction moveByX:0 y:amountToJump duration:.05];
    SKAction *fall = [SKAction moveByX:0 y:-amountToJump duration:.1];
    [jumpingNode runAction:[SKAction sequence:@[jump, fall]]];
}

#pragma mark Singleton Methods

-(void) syncAllObjectsToMaze {
    // Clean up old player and enemy nodes.
    [[SELPlayer player] removeFromParent];
    
    // Create and sync player.
    [SELPlayer player].playerScene = self;
    [SELPlayer player].size = CGSizeMake(tileSize / (playerScaleMod * 15), tileSize / (playerScaleMod * 20));
    [SELPlayer player].physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(tileSize / (playerScaleMod * 18), tileSize / (playerScaleMod * 25))];
    [SELPlayer player].physicsBody.categoryBitMask = ColliderTypePlayer;
    [SELPlayer player].physicsBody.collisionBitMask =  ColliderTypeBlock;
    [SELPlayer player].physicsBody.contactTestBitMask = ColliderTypePlayer | ColliderTypeBlock | ColliderTypeCheese;
    [SELPlayer player].zPosition = LayerLevelPlayer;
    [SELPlayer player].position = _bgLayer.playerStartingPosition;
    [_bgLayer addChild:[SELPlayer player]];
}

@end
