//
//  SELRandomMaze.h
//  Ghost Maze
//
//  Created by Scott Lassen on 11/17/14.
//  Copyright (c) 2014 Scott Lassen. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "MazeScene.h"

@interface SELRandomMaze : SKSpriteNode

-(instancetype)initWithTileSize:(CGFloat)tileSize;
-(instancetype)initWithTileSize:(CGFloat)tileSize fromString:(NSString*)string;

-(CGPoint)playerStartingPosition;
-(CGSize)mazeSize;
@property (nonatomic) int cheeseCount;
@property (nonatomic) NSMutableArray *wallTiles;
@property (nonatomic) CGPoint playerStartingPosition;
@property (nonatomic) CGSize mazeSize;

-(void)outputVisualPattern;
-(NSString*)getOutputMessage;

@end
