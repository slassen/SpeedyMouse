//
//  HelpScene.m
//  Speedy Mouse
//
//  Created by Scott Lassen on 1/9/15.
//  Copyright (c) 2015 Scott Lassen. All rights reserved.
//

#import "HelpScene.h"
#import "SELRandomMaze.h"

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
    _bgLayer = [[SELRandomMaze alloc] initWithTileSize:(self.frame.size.width / 6) fromString:@"XXXXXX\nX--C-X\nX----X\nX----X\nX----X\nXXXXXX"];
    [self addChild:_bgLayer];
}

@end
