//
//  SELPlayer.m
//  Ghost Maze
//
//  Created by Scott Lassen on 11/16/14.
//  Copyright (c) 2014 Scott Lassen. All rights reserved.
//

#import "SELPlayer.h"

@import CoreMotion;

static const float ZOMBIE_ROTATE_RADIANS_PER_SECOND = 4 * M_PI;

@interface SELPlayer() 

@property (nonatomic) CGFloat tileSize;
@property (nonatomic) CGFloat speedModifier;
@property (nonatomic) CGPoint accel2D; // velocity

@end

@implementation SELPlayer

static inline CGFloat CGPointLength(const CGPoint a) {
    return sqrtf(a.x * a.x + a.y * a.y);
}

static inline CGPoint CGPointNormalize(const CGPoint a) {
    CGFloat length = CGPointLength(a);
    return CGPointMake(a.x / length, a.y / length);
}

static inline CGFloat CGPointToAngle(const CGPoint a) {
    return atan2f(a.y, a.x);
}

static inline CGFloat ScalarSign(CGFloat a) {
    return a >= 0 ? 1 : -1;
}

static inline CGFloat ScalarShortestAngleBetween(const CGFloat a, const CGFloat b) {
    CGFloat difference = b - a;
    CGFloat angle = fmodf(difference, M_PI * 2);
    
    if (angle >= M_PI) angle -= M_PI * 2;
    else if (angle <= -M_PI) angle += M_PI * 2;
    
    return angle;
}

-(GLKVector3)lowPassWithVector: (GLKVector3)vector {
    static GLKVector3 lastVector;
    static CGFloat blend = 0.2;
    vector.x = vector.x * blend + lastVector.x * (1.0 - blend);
    vector.y = vector.y * blend + lastVector.x * (1.0 - blend);
    vector.z = vector.z * blend + lastVector.x * (1.0 - blend);
    lastVector = vector;
    return vector;
}

-(void)launchPlayerGradually {
    _speedModifier = 0;
    float speedInterval = 1.0f / 12;
    
    SKAction *increaseSpeedAction = [SKAction sequence:@[[SKAction runBlock:^{
        _speedModifier += speedInterval;
    }], [SKAction waitForDuration:0.25f]]];
    
    SKAction *repeatIncrease = [SKAction repeatAction:increaseSpeedAction count:12];
    
    [self runAction:repeatIncrease completion:^{
        _speedModifier = 1;
    }];
}

-(void)parseAccelerometerData {
    // Move mouse
    GLKVector3 raw = GLKVector3Make([Settings motionManager].accelerometerData.acceleration.x, [Settings motionManager].accelerometerData.acceleration.y, [Settings motionManager].accelerometerData.acceleration.z);
    if (GLKVector3AllEqualToScalar(raw, 0)) {
        return;
    }
//    raw = [self lowPassWithVector:raw];
    
    static GLKVector3 ax, ay, az;
    ay = [Settings settings].ay;
    az = GLKVector3Make(0.0f, 1.0f, 0.0f);
    ax = GLKVector3Normalize(GLKVector3CrossProduct(az, ay));
    
    CGPoint accel2D = CGPointZero;
    accel2D.x = GLKVector3DotProduct(raw, az);
    accel2D.y = GLKVector3DotProduct(raw, ax);
    //.62 -.75
    accel2D = CGPointNormalize(accel2D);
    
    float steerDeadZone = [Settings settings].tiltSensitivity; //tiltSensitivity;
    if (fabsf(accel2D.x) < steerDeadZone) accel2D.x = 0;
    if (fabsf(accel2D.y) < steerDeadZone) accel2D.y = 0;
    if (accel2D.x == 0 && accel2D.y == 0) {
        return;
    }
    _accel2D = CGPointMake(accel2D.x, accel2D.y);
}

-(void)moveWithDT:(NSTimeInterval)dt {
    float accelerationPerSecond = _playerSpeed;
    
    // modified to gradually increase speed
    float accelerationPerSecondMod = accelerationPerSecond - 100;
    accelerationPerSecondMod *= _speedModifier;
    accelerationPerSecond = 100 + accelerationPerSecondMod;
    
    self.physicsBody.velocity = CGVectorMake(_accel2D.x * accelerationPerSecond, _accel2D.y * accelerationPerSecond);
}

-(void)changeRotationWithDT:(NSTimeInterval)dt {
    float accelerationPerSecond = _playerSpeed;
    CGFloat newAngle = CGPointToAngle(CGPointMake(_accel2D.x * accelerationPerSecond, _accel2D.y * accelerationPerSecond));
//    CGFloat newAngle = CGPointToAngle(CGPointMake(self.physicsBody.velocity.dx, self.physicsBody.velocity.dy));
    CGFloat shortest = ScalarShortestAngleBetween(self.zRotation, newAngle);
    CGFloat amtToRotateVar = ZOMBIE_ROTATE_RADIANS_PER_SECOND;
    if (_playerSpeed >= 200 && _playerSpeed < 250) amtToRotateVar = 6 * M_PI;
    else if (_playerSpeed >= 250) amtToRotateVar = 8 * M_PI;
    CGFloat amtToRotate = amtToRotateVar * dt;
    if (fabsf(shortest) < amtToRotate) self.zRotation += shortest;
    else self.zRotation += (amtToRotate * ScalarSign(shortest));
}

-(void) resetLives {
    _lives = 3;
    _cheeseToLives = 25;
    _playerSpeed = 100.0f;
}

-(void)updateWithTimeInterval:(NSTimeInterval)dt {
    [self parseAccelerometerData];
    
    // If player is stopped only rotate, don't move.
    if (!_stopped) [self moveWithDT:dt];
    [self changeRotationWithDT:dt];
}

#pragma mark Singleton Methods

+(instancetype)player {
    static SELPlayer *player = nil;
    if (!player) player = [[SELPlayer alloc] initSingleton];
    return player;
}

-(instancetype)initSingleton {
    self = [super initWithTexture:[SKTexture textureWithImageNamed:@"kart"]];
    if (self) {
        self.name = @"mouse";
        _playerSpeed = 100.0f;
        _stopped = YES;
        _currentLevel = 1;
        self.zPosition = LayerLevelPlayer;
    }
    return self;
}

@end
