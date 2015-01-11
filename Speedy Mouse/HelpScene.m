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

@implementation HelpScene

{
    MazeScene *_returnMaze;
    SELRandomMaze *_bgLayer;
}

-(instancetype) initWithSize:(CGSize)size returnMaze:(MazeScene*)maze {
    if (self = [super initWithSize:size]) {
        _returnMaze = maze;
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
    }
    return self;
}

-(void)didMoveToView:(SKView *)view {
    _bgLayer = [[SELRandomMaze alloc] initWithTileSize:(self.frame.size.width / 6) fromString:@"XXXPXX\nX--C-X\nX----X\nX----X\nX----X\nXXXXXX"];
    [self addChild:_bgLayer];
}

-(void)returnToMaze {
    if ([SELPlayer player].parent) {
        [[SELPlayer player] removeFromParent];
    }
    
    MazeScene *scene = [[MazeScene alloc] initWithSize:self.size];
    scene.newGame = YES;
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
    [self returnToMaze];
}

@end
