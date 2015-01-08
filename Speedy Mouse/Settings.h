//
//  Settings.h
//  Ghost Maze
//
//  Created by Scott Lassen on 11/12/14.
//  Copyright (c) 2014 Scott Lassen. All rights reserved.
//

#import <Foundation/Foundation.h>
@import SpriteKit;
@import CoreMotion;
@import AVFoundation;

@interface Settings : NSObject <NSCoding>

@property (nonatomic) GLKVector3 ay;
@property (nonatomic) BOOL soundOff;
@property (nonatomic) BOOL playerHasPlayedTutorial;
@property (nonatomic) int failCount;

+(instancetype)settings;
-(void)saveSettings;

@property (nonatomic) NSMutableArray *savedLevelMaps;

@property (nonatomic) int levelsOpen;

+(CMMotionManager*)motionManager;

+(AVAudioPlayer*)backgroundMusicPlayer;
+(void) restartBackgroundMusic;
+(AVAudioPlayer*)gameOverSoundEffect;
+(AVAudioPlayer*)burnoutSoundEffect;
-(void) restartBurnout;
+(AVAudioPlayer*)crashSoundEffect;
-(void) restartCrash;
+(void)setTiltPosition;
+(AVAudioPlayer*)FU3;
+(AVAudioPlayer*)FU4;
+(AVAudioPlayer*)FU5;
+(AVAudioPlayer*)FU6;
+(AVAudioPlayer*)FU7;
+(void) pauseFU;

@end
