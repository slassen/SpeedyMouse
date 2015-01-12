//
//  SELWallLayer.m
//  Ghost Maze
//
//  Created by Scott Lassen on 11/17/14.
//  Copyright (c) 2014 Scott Lassen. All rights reserved.
//

#import "SELRandomMaze.h"
#import "SELPlayer.h"

@implementation SELRandomMaze

{
    SKSpriteNode *_background;
    SKTexture *_backgroundTexture;
    CGFloat _xTileCount, _yTileCount;
    float _tileSize;
    NSMutableArray *_walkableTiles;
    BOOL _canMoveNorth, _canMoveSouth, _canMoveEast, _canMoveWest;
}

-(void) addGates {
    // Add gates between cones that kart could squeeze through normally.
    for (SKSpriteNode *cone in _wallTiles) {
        if ([self coneNorthWestOfCone:cone]) {
            [self addGateToPosition:CGPointMake(cone.position.x - (_tileSize /2), cone.position.y + ((_tileSize /2) - (_tileSize / 8))) withRotation:2.34]; //-.8
        }
        
        if ([self coneNorthEastOfCone:cone]) {
            [self addGateToPosition:CGPointMake(cone.position.x + (_tileSize /2), cone.position.y + ((_tileSize /2)) - (_tileSize / 8)) withRotation:.8]; //.8
        }
    }
}

-(void) addGateToPosition:(CGPoint)position withRotation:(CGFloat)rotation {
//    SKSpriteNode *gate;
//    if (rotation > 0) {
//        gate = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"Roadblock"] size:CGSizeMake(_tileSize / 2, _tileSize / 4)]; // west
//    }
//    else {
//        gate = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"Roadblock"] size:CGSizeMake(_tileSize / 2, _tileSize / 4)]; // east
//    }
    
    SKSpriteNode *gate = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"Roadblock"] size:CGSizeMake(_tileSize / 2, _tileSize / 4)];
    gate.name = @"wallTile";
    gate.position = position;
    gate.zPosition = LayerLevelBackground;
    gate.zRotation = rotation;
    gate.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:gate.size];
//    gate.physicsBody = [self coneTileWithSize:_tileSize / 2];
    gate.physicsBody.categoryBitMask = ColliderTypeBlock;
    gate.physicsBody.collisionBitMask = ColliderTypePlayer;
    gate.physicsBody.contactTestBitMask = ColliderTypePlayer;
    gate.physicsBody.dynamic = NO;
    [self addChild:gate];
}

-(BOOL)coneNorthWestOfCone:(SKSpriteNode*)cone {
    SKSpriteNode *checkNode = (SKSpriteNode*)[self nodeAtPoint:CGPointMake(cone.position.x - _tileSize, cone.position.y + _tileSize)];
    SKSpriteNode *northCheck = (SKSpriteNode*)[self nodeAtPoint:CGPointMake(cone.position.x, cone.position.y + _tileSize)];
    SKSpriteNode *westCheck = (SKSpriteNode*)[self nodeAtPoint:CGPointMake(cone.position.x - _tileSize, cone.position.y)];
    if ([checkNode.name isEqualToString:@"wallTile"] && ![northCheck.name isEqualToString:@"wallTile"] && ![westCheck.name isEqualToString:@"wallTile"]) {
        return true;
    }
    return false;
}

-(BOOL)coneNorthEastOfCone:(SKSpriteNode*)cone {
    SKSpriteNode *checkNode = (SKSpriteNode*)[self nodeAtPoint:CGPointMake(cone.position.x + _tileSize, cone.position.y + _tileSize)];
    SKSpriteNode *northCheck = (SKSpriteNode*)[self nodeAtPoint:CGPointMake(cone.position.x, cone.position.y + _tileSize)];
    SKSpriteNode *eastCheck = (SKSpriteNode*)[self nodeAtPoint:CGPointMake(cone.position.x + _tileSize, cone.position.y)];
    if ([checkNode.name isEqualToString:@"wallTile"] && ![northCheck.name isEqualToString:@"wallTile"] && ![eastCheck.name isEqualToString:@"wallTile"]) {
        return true;
    }
    return false;
}

-(void)outputVisualPattern {
    // This method runs the pattern in reverse for visual aide debugging and pattern saving only.
//    self.name = nil;
    NSString *pattern = [NSString string];
    for (int y = _yTileCount - 1; y >= 0; y--) {
        for (int x = 0; x < _xTileCount; x++) {
            SKSpriteNode *currentNode = (SKSpriteNode*)[self nodeAtPoint:
                                                        CGPointMake((_tileSize / 2) + (x * _tileSize),
                                                                    (_tileSize / 2) + (y * _tileSize))];
            if ([currentNode.name isEqualToString:@"cheese"]) {
                pattern = [pattern stringByAppendingString:@"C"];
            }
            else if (currentNode.position.x == _playerStartingPosition.x && currentNode.position.y == _playerStartingPosition.y) {
                pattern = [pattern stringByAppendingString:@"P"];
            }
            else if ([currentNode.name isEqualToString:@"wallTile"]){
                pattern = [pattern stringByAppendingString:@"T"];
            }
            else {
                pattern = [pattern stringByAppendingString:@"X"];
            }
        }
        pattern = [pattern stringByAppendingString:@"\n"];
    }
    NSLog(@"Visual Maze Pattern:\n%@", pattern);
    
    NSString *copyPattern = [NSString string];
    for (int i = 0; i < pattern.length - 1; i++) {
        if (![[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:[pattern characterAtIndex:i]]) copyPattern = [copyPattern stringByAppendingString:[NSString stringWithFormat:@"%c", [pattern characterAtIndex:i]]];
        else copyPattern = [copyPattern stringByAppendingString:@"\\n"];
    }
    NSLog(@"Copy Maze Pattern:\nscene.levelString = @\"%@\";", copyPattern);
    if (![Settings settings].savedLevelMaps) [Settings settings].savedLevelMaps = [NSMutableArray array];
    [[Settings settings].savedLevelMaps addObject:pattern];
    [[Settings settings] saveSettings];
//    self.name = @"wallTile";
}

-(NSString*)getOutputMessage {
    return [NSString stringWithFormat:@"xTiles = %i\nyTiles = %i\ncheese = %i", (int)_xTileCount, (int)_yTileCount, _cheeseCount];
}

-(BOOL)canMoveNorthFromPoint:(CGPoint)point {
    // Can new tile in maze path move this direction?
    CGPoint pointCheck = CGPointMake(point.x, point.y + _tileSize);
    CGPoint pointCheck1 = CGPointMake(pointCheck.x, pointCheck.y + _tileSize);
    CGPoint pointCheck2 = CGPointMake(pointCheck.x + _tileSize, pointCheck.y);
    CGPoint pointCheck3 = CGPointMake(pointCheck.x - _tileSize, pointCheck.y);
    
    // If the following positions are all wall tiles then maze path can continue this direction.
    if ([[self nodeAtPoint:pointCheck].name isEqualToString:@"wallTile"] &&
        [[self nodeAtPoint:pointCheck1].name isEqualToString:@"wallTile"] &&
        [[self nodeAtPoint:pointCheck2].name isEqualToString:@"wallTile"] &&
        [[self nodeAtPoint:pointCheck3].name isEqualToString:@"wallTile"]) return YES;
    return NO;
}

-(BOOL)canMoveSouthFromPoint:(CGPoint)point {
    // Can new tile in maze path move this direction?
    CGPoint pointCheck = CGPointMake(point.x, point.y - _tileSize);
    CGPoint pointCheck1 = CGPointMake(pointCheck.x, pointCheck.y - _tileSize);
    CGPoint pointCheck2 = CGPointMake(pointCheck.x + _tileSize, pointCheck.y);
    CGPoint pointCheck3 = CGPointMake(pointCheck.x - _tileSize, pointCheck.y);
    
    // If the following positions are all wall tiles then maze path can continue this direction.
    if ([[self nodeAtPoint:pointCheck].name isEqualToString:@"wallTile"] &&
        [[self nodeAtPoint:pointCheck1].name isEqualToString:@"wallTile"] &&
        [[self nodeAtPoint:pointCheck2].name isEqualToString:@"wallTile"] &&
        [[self nodeAtPoint:pointCheck3].name isEqualToString:@"wallTile"]) return YES;
    return NO;
}

-(BOOL)canMoveEastFromPoint:(CGPoint)point {
    // Can new tile in maze path move this direction?
    CGPoint pointCheck = CGPointMake(point.x + _tileSize, point.y);
    CGPoint pointCheck1 = CGPointMake(pointCheck.x, pointCheck.y - _tileSize);
    CGPoint pointCheck2 = CGPointMake(pointCheck.x + _tileSize, pointCheck.y);
    CGPoint pointCheck3 = CGPointMake(pointCheck.x, pointCheck.y + _tileSize);
    
    // If the following positions are all wall tiles then maze path can continue this direction.
    if ([[self nodeAtPoint:pointCheck].name isEqualToString:@"wallTile"] &&
        [[self nodeAtPoint:pointCheck1].name isEqualToString:@"wallTile"] &&
        [[self nodeAtPoint:pointCheck2].name isEqualToString:@"wallTile"] &&
        [[self nodeAtPoint:pointCheck3].name isEqualToString:@"wallTile"]) return YES;
    return NO;
}

-(BOOL)canMoveWestFromPoint:(CGPoint)point {
    // Can new tile in maze path move this direction?
    CGPoint pointCheck = CGPointMake(point.x - _tileSize, point.y);
    CGPoint pointCheck1 = CGPointMake(pointCheck.x, pointCheck.y - _tileSize);
    CGPoint pointCheck2 = CGPointMake(pointCheck.x - _tileSize, pointCheck.y);
    CGPoint pointCheck3 = CGPointMake(pointCheck.x, pointCheck.y + _tileSize);
    
    // If the following positions are all wall tiles then maze path can continue this direction.
    if ([[self nodeAtPoint:pointCheck].name isEqualToString:@"wallTile"] &&
        [[self nodeAtPoint:pointCheck1].name isEqualToString:@"wallTile"] &&
        [[self nodeAtPoint:pointCheck2].name isEqualToString:@"wallTile"] &&
        [[self nodeAtPoint:pointCheck3].name isEqualToString:@"wallTile"]) return YES;
    return NO;
}

-(BOOL) canPathAdvanceFromPoint:(CGPoint)point {
    
    // Can new tile move North?
    _canMoveNorth = [self canMoveNorthFromPoint:point];
    
    // Can new tile move South?
    _canMoveSouth = [self canMoveSouthFromPoint:point];
    
    // Can new tile move East?
    _canMoveEast = [self canMoveEastFromPoint:point];
    
    // Can new tile move West?
    _canMoveWest = [self canMoveWestFromPoint:point];
    
    if (_canMoveNorth || _canMoveSouth || _canMoveEast || _canMoveWest) return YES;
    return NO;
}

-(CGPoint) randomizePlayerStartingPosition {
    
    // Chose random number from available X tiles.
    int mouseRandomTileSpawn = 1 + arc4random() % (int)(_xTileCount - 2);
    CGPoint starting = CGPointMake((_tileSize / 2) + (_tileSize * mouseRandomTileSpawn), _tileSize / 2);
    
    // Remove tile from the mouse position first.
    // This guarantees that there is a space for the mouse to move from.
    SKSpriteNode *removeNode = (SKSpriteNode*)[self nodeAtPoint:starting];
    [_walkableTiles addObject:[NSValue valueWithCGPoint:removeNode.position]];
    [removeNode removeFromParent];
    
    // Add the race flag to starting position.
//    [self addRaceFlagToPoint:starting];
    
    // Add player to starting position.
    [SELPlayer player].position = starting;
    
    // Return the starting position value.
    return starting;
}

-(instancetype)initWithTileSize:(CGFloat)tileSize fromString:(NSString *)string {
    NSMutableArray *yTiles = [NSMutableArray array];
    NSString *xTiles = [NSString string];
    for (int i = 0; i < string.length; i++) { // allocate y tiles array with x tile strings
        
        //need to implement conversion from string
        if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:[string characterAtIndex:i]]) {
            [yTiles addObject:xTiles];
            xTiles = [NSString string];
            continue;
        }
        xTiles = [xTiles stringByAppendingString:[NSString stringWithFormat:@"%c", [string characterAtIndex:i]]];
    }
    [yTiles addObject:xTiles]; // add last object
    
    self = [super init];
    if (self) {
        _tileSize = tileSize;
        [self addBackgroundLayerWithImageNamed:@"asphalt512" ofSize:CGSizeMake(tileSize * [[yTiles firstObject] length], tileSize * yTiles.count)];
        [self addWallTilesFromArray:yTiles]; //need to implement this method
        [self addGates];
    }
    return self;
}

-(instancetype)initWithTileSize:(CGFloat)tileSize {
    self = [super init];
    if (self) {
        _tileSize = tileSize;
        int yTiles = ([SELPlayer player].currentLevel + 11);
        int xTiles = (([SELPlayer player].currentLevel / 10) * 2) + 6; //last # needs to be 6.
        [self addBackgroundLayerWithImageNamed:@"asphalt512" ofSize:CGSizeMake(tileSize * xTiles, tileSize * yTiles)];
        [self addWallTiles];
        [self createMazePath];
        [self addGates];
//        self.name = @"wallTile";
    }
    return self;
}

-(void)addBackgroundLayerWithImageNamed:(NSString*)image ofSize:(CGSize)size {
    
    _background = [[SKSpriteNode alloc] initWithColor:[UIColor blackColor] size:size];
    _backgroundTexture = [SKTexture textureWithImageNamed:image];
    
    self.anchorPoint = CGPointZero;
    
    //Adjust bg size from tile size.
    _xTileCount = round(size.width / _tileSize);
    _yTileCount = round(size.height / _tileSize);
    size.width = _xTileCount * _tileSize;
    size.height = _yTileCount * _tileSize;
    
    //Create the background layer image, and add image to the node.
    _background.anchorPoint = CGPointZero;
    [self addChild:_background];
    
    //Add the world's physics body based on the size provided and subtract tileSize from edges.
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:_background.frame];
    self.physicsBody.contactTestBitMask = ColliderTypePlayer;
    
    // Add the level size to _tileSize so that didSimulatePhysics can determine it.
    _mazeSize = size;
}

-(void)addWallTilesFromArray:(NSMutableArray*)array {
    // Insert a wall tile for each space on the map.
    _wallTiles = [[NSMutableArray alloc] init];
    CGFloat yPos = _tileSize / 2;
    CGFloat xPos = _tileSize / 2;
    for (int y = 0; y < array.count; y++) {
        NSString *xString = array[y];
        for (int x = 0; x < xString.length; x++) {
            if ([xString characterAtIndex:x] == 'X') { //cone
                SKSpriteNode *wallTile = [self addTileAtPosition:CGPointMake(xPos, yPos)];
                [_wallTiles addObject:wallTile];
            }
            else if ([xString characterAtIndex:x] == 'C') { //cheese
                [self addBGTileAtPostion:CGPointMake(xPos, yPos)];
                [self addCheeseOnlyToPosition:CGPointMake(xPos, yPos)];
            }
            else if ([xString characterAtIndex:x] == 'P') { //player
                if ([SELPlayer player].parent) {
                    [[SELPlayer player] removeFromParent];
                }
                [self addBGTileAtPostion:CGPointMake(xPos, yPos)];
                _playerStartingPosition = CGPointMake(xPos, yPos);
                //add player too
                [self addChild:[SELPlayer player]];
                [SELPlayer player].position = CGPointMake(xPos, yPos);
                [SELPlayer player].zRotation = 1.575;
                [SELPlayer player].physicsBody.resting = YES;
            }
            else { //blank
                [self addBGTileAtPostion:CGPointMake(xPos, yPos)];
            }
            xPos += _tileSize;
        }
        xPos = _tileSize / 2;
        yPos += _tileSize;
    }
}

-(void)addWallTiles {
    // Insert a wall tile for each space on the map.
    _wallTiles = [[NSMutableArray alloc] init];
    CGFloat yPos = _tileSize / 2;
    CGFloat xPos = _tileSize / 2;
    for (int i = 0; i < _xTileCount; i++) {
        for (int i = 0; i < _yTileCount; i++) {
            SKSpriteNode *wallTile = [self addTileAtPosition:CGPointMake(xPos, yPos)];
            [_wallTiles addObject:wallTile];
            yPos += _tileSize;
        }
        yPos = _tileSize / 2;
        xPos += _tileSize;
    }
}

-(SKPhysicsBody*)coneTileWithSize:(CGFloat)size {
    CGFloat scaleSize = size / 512;
    CGMutablePathRef pathRef = CGPathCreateMutable();
//    CGPathMoveToPoint(pathRef, nil, -31 * scaleSize, 105 * scaleSize);
//    CGPathAddLineToPoint(pathRef, nil, 25 * scaleSize, 102 * scaleSize);
//    CGPathAddLineToPoint(pathRef, nil, 67 * scaleSize, -49 * scaleSize);
//    CGPathAddLineToPoint(pathRef, nil, 95 * scaleSize, -57 * scaleSize);
//    CGPathAddLineToPoint(pathRef, nil, 115 * scaleSize, -87 * scaleSize);
//    CGPathAddLineToPoint(pathRef, nil, 87 * scaleSize, -114 * scaleSize);
//    CGPathAddLineToPoint(pathRef, nil, -18 * scaleSize, -126 * scaleSize);
//    CGPathAddLineToPoint(pathRef, nil, -93 * scaleSize, -103 * scaleSize);
//    CGPathAddLineToPoint(pathRef, nil, -104 * scaleSize, -63 * scaleSize);
//    CGPathAddLineToPoint(pathRef, nil, -68 * scaleSize, -45 * scaleSize);
//    CGPathAddLineToPoint(pathRef, nil, -31 * scaleSize, 105 * scaleSize);
    CGPathMoveToPoint(pathRef, nil, -50 * scaleSize, 226 * scaleSize);
    CGPathAddLineToPoint(pathRef, nil, -15 * scaleSize, 238 * scaleSize);
    CGPathAddLineToPoint(pathRef, nil, 22 * scaleSize, 222 * scaleSize);
    CGPathAddLineToPoint(pathRef, nil, 119 * scaleSize, -38 * scaleSize);
    CGPathAddLineToPoint(pathRef, nil, 187 * scaleSize, -106 * scaleSize);
    CGPathAddLineToPoint(pathRef, nil, 120 * scaleSize, -225 * scaleSize);
    CGPathAddLineToPoint(pathRef, nil, -121 * scaleSize, -232 * scaleSize);
    CGPathAddLineToPoint(pathRef, nil, -215 * scaleSize, -116 * scaleSize);
    CGPathAddLineToPoint(pathRef, nil, -150 * scaleSize, -41 * scaleSize);
    CGPathAddLineToPoint(pathRef, nil, -50 * scaleSize, 226 * scaleSize);
    
    SKPhysicsBody *body = [SKPhysicsBody bodyWithPolygonFromPath:pathRef];
    CGPathRelease(pathRef);
    return body;
}

-(SKSpriteNode*)addConeAtPosition:(CGPoint)position {
    // do normal stuff now
    SKSpriteNode *tile = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"cone"] size:CGSizeMake(_tileSize, _tileSize)];
    tile.name = @"wallTile";
    tile.position = position;
    tile.zPosition = LayerLevelBelowPlayer;
    /*if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f) {
     tile.physicsBody = [SKPhysicsBody bodyWithTexture:[SKTexture textureWithImageNamed:@"roadCone"] size:CGSizeMake(_tileSize, _tileSize)];
     }
     else*/ tile.physicsBody = [self coneTileWithSize:_tileSize];
    tile.physicsBody.categoryBitMask = ColliderTypeBlock;
    tile.physicsBody.collisionBitMask = ColliderTypePlayer;
    tile.physicsBody.contactTestBitMask = ColliderTypePlayer;
    tile.physicsBody.dynamic = NO;
    [_wallTiles addObject:tile];
    [self addChild:tile];
    return tile;
}

-(void)addBGTileAtPostion:(CGPoint)position {
    // make sure to add bg tile to background
    SKSpriteNode *bgTile = [SKSpriteNode spriteNodeWithTexture:_backgroundTexture size:CGSizeMake(_tileSize, _tileSize)];
    bgTile.name = @"bgTile";
    bgTile.position = position;
    bgTile.zPosition = LayerLevelBackground;
    [_background addChild:bgTile];
}

-(SKSpriteNode* )addTileAtPosition:(CGPoint)position { //path tiles
    // make sure to add bg tile to background
    SKSpriteNode *bgTile = [SKSpriteNode spriteNodeWithTexture:_backgroundTexture size:CGSizeMake(_tileSize, _tileSize)];
    bgTile.name = @"bgTile";
    bgTile.position = position;
    bgTile.zPosition = LayerLevelBackground;
    [_background addChild:bgTile];
    
    // add cone
    SKSpriteNode *tile = [self addConeAtPosition:position];
    return tile;
}

-(CGPoint)addCheeseOnlyToPosition:(CGPoint)position {
    // Add the cheese.
    _cheeseCount++;
    SKSpriteNode *cheese = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"cheeseDeface"] size:CGSizeMake(_tileSize / 2, _tileSize / 2)];
    cheese.name = @"cheese";
    //    cheese.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:cheese.size.width / 2];
    cheese.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(_tileSize /1.5, _tileSize /1.5)];
    cheese.physicsBody.dynamic = NO;
    cheese.physicsBody.categoryBitMask = ColliderTypeCheese;
    cheese.physicsBody.contactTestBitMask = ColliderTypePlayer;
    cheese.position = position;
    cheese.zPosition = LayerLevelBelowPlayer;
    [self addChild:cheese];
    return cheese.position;
}


-(CGPoint)addCheeseToPosition:(CGPoint)position {
    // Remove wall tile since new available position is chosen.
    SKSpriteNode *removeNode = (SKSpriteNode*)[self nodeAtPoint:position];
    [removeNode removeFromParent];
    [_wallTiles removeObject:removeNode];
    [_walkableTiles addObject:[NSValue valueWithCGPoint:removeNode.position]];
    
    // Add the cheese.
    _cheeseCount++;
    SKSpriteNode *cheese = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"cheeseDeface"] size:CGSizeMake(_tileSize / 2, _tileSize / 2)];
    cheese.name = @"cheese";
//    cheese.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:cheese.size.width / 2];
    cheese.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(_tileSize /1.5, _tileSize /1.5)];
    cheese.physicsBody.dynamic = NO;
    cheese.physicsBody.categoryBitMask = ColliderTypeCheese;
    cheese.physicsBody.contactTestBitMask = ColliderTypePlayer;
    cheese.position = position;
    cheese.zPosition = LayerLevelBelowPlayer;
    [self addChild:cheese];
    return cheese.position;
}

-(void)addRaceFlagToPoint:(CGPoint)point {
    SKSpriteNode *flag = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"raceFlag"] size:CGSizeMake(_tileSize / 1.25, _tileSize / 1.25)];
    flag.name = @"starting";
    flag.zPosition = LayerLevelBelowPlayer;
    flag.position = point;
    [self addChild:flag];
}

-(void)createMazePath {
    
    static int currentTileNumber;
    static int previousIterationNumber;
    
    // If the tile is not initiated make the position where the mouse spawns.
    _walkableTiles = [NSMutableArray array];
    
    // Randomize the player starting position from available X Tiles.
    _playerStartingPosition = [self randomizePlayerStartingPosition];
    
    currentTileNumber = 0;
    previousIterationNumber = 0;
    
    // Run the loop for as many tiles as directed for.
    while (1) {
        // Load the previous position.
        previousIterationNumber = 0;
        CGPoint previousPosition = [[_walkableTiles objectAtIndex:currentTileNumber - previousIterationNumber] CGPointValue];
        
        // If no tiles are available to move to; iterate through previous tiles until position is available.
        while (![self canPathAdvanceFromPoint:previousPosition]) {
            // If there are no more walkable tiles or there were no previous iterations stop creating paths.
            if ((_walkableTiles.count <= (currentTileNumber - previousIterationNumber)) ||
                (previousIterationNumber == currentTileNumber && _walkableTiles.count > 1)) return;
            
            // Is the path not able to advance from this position?
            // Iterate to the previous object in array for next loop execution.
            previousIterationNumber++;
            previousPosition = [[_walkableTiles objectAtIndex:currentTileNumber - previousIterationNumber] CGPointValue];
        }
        
        // If at least 1 direction is available to move to; choose a random direction.
        [self advancePathFromPoint:previousPosition];
        
        // Advance the tile number and reset previousIteration.
        currentTileNumber++;
        previousIterationNumber = 0;
    }
}

-(CGPoint) advancePathFromPoint:(CGPoint)point {
    while (1) {
        int direction = arc4random() % 4;
        switch (direction) {
            case 0:  // West
                if (_canMoveWest) return [self addCheeseToPosition:CGPointMake(point.x - _tileSize, point.y)];
                break;
            case 1: // East
                if (_canMoveEast) return [self addCheeseToPosition:CGPointMake(point.x + _tileSize, point.y)];
                break;
            case 2: // North
                if (_canMoveNorth) return [self addCheeseToPosition:CGPointMake(point.x, point.y + _tileSize)];
                break;
            case 3: // South
                if (_canMoveSouth) return [self addCheeseToPosition:CGPointMake(point.x, point.y - _tileSize)];
                break;
            default:
                break;
        }
    }
}

@end
