//
//  HelpScene.h
//  Speedy Mouse
//
//  Created by Scott Lassen on 1/9/15.
//  Copyright (c) 2015 Scott Lassen. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "MazeScene.h"

@interface HelpScene : SKScene <SKPhysicsContactDelegate>

-(instancetype) initWithSize:(CGSize)size returnMaze:(MazeScene*)maze;

@end
