//
//  Settings.m
//  Ghost Maze
//
//  Created by Scott Lassen on 11/12/14.
//  Copyright (c) 2014 Scott Lassen. All rights reserved.
//

#import "Settings.h"
#import "SELPlayer.h"
@import GameKit;

@implementation Settings

-(instancetype) init {
    self = [super init];
    if (self) {
        _ay = GLKVector3Make(0.63f, 0.0f, -0.92f);
        _savedLevelMaps = [NSMutableArray array];
    }
    return self;
}

-(instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _ay = GLKVector3Make([aDecoder decodeFloatForKey:@"ay1"], [aDecoder decodeFloatForKey:@"ay2"], [aDecoder decodeFloatForKey:@"ay3"]);
        _soundOff = [aDecoder decodeBoolForKey:@"soundOff"];
        _playerHasPlayedTutorial = [aDecoder decodeBoolForKey:@"pPlayTutorial"];
        _savedLevelMaps = [aDecoder decodeObjectForKey:@"savedLevelMaps"];
        _levelsOpen = [aDecoder decodeIntForKey:@"levelsOpen"];
    }
    return self;
}

-(void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeFloat:_ay.v[0] forKey:@"ay1"];
    [aCoder encodeFloat:_ay.v[1] forKey:@"ay2"];
    [aCoder encodeFloat:_ay.v[2] forKey:@"ay3"];
    [aCoder encodeBool:_soundOff forKey:@"soundOff"];
    [aCoder encodeBool:_playerHasPlayedTutorial forKey:@"pPlayTutorial"];
    [aCoder encodeObject:_savedLevelMaps forKey:@"savedLevelMaps"];
    [aCoder encodeInt:_levelsOpen forKey:@"levelsOpen"];
}

-(NSString*)settingsArchivePath {
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [filePath stringByAppendingPathComponent:@"settings"];
}

-(void)saveSettings {
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [filePath stringByAppendingPathComponent:@"settings"];
    [NSKeyedArchiver archiveRootObject:self toFile:path];
}

+(instancetype)settings {;
    static Settings *settings = nil;
    if (!settings) {
        NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *path = [filePath stringByAppendingPathComponent:@"settings"];
        settings = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (!settings) settings = [[Settings alloc] init];
    }
    return settings;
}

#pragma mark Accelerometer manager

+(CMMotionManager*)motionManager {
    static CMMotionManager *manager = nil;
    if (!manager) {
        manager = [[CMMotionManager alloc] init];
        manager.accelerometerUpdateInterval = 0.05;
        [manager startAccelerometerUpdates];
    }
    return manager;
}

#pragma mark Music and sound effect managers

+(AVAudioPlayer*)backgroundMusicPlayer {
    static AVAudioPlayer *player = nil;
    if (!player) {
        NSError *error;
        NSURL *backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"bgMusic" withExtension:@"mp3"];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
        player.numberOfLoops = -1;
        [player prepareToPlay];
        [player setVolume:0.01];
    }
    return player;
}

+(AVAudioPlayer*)FU3 {
    static AVAudioPlayer *player = nil;
    if (!player) {
        NSError *error;
        NSURL *backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"FU3" withExtension:@"wav"];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
        player.numberOfLoops = -1;
        [player prepareToPlay];
        [player setVolume:0.01];
    }
    return player;
}

+(AVAudioPlayer*)FU4 {
    static AVAudioPlayer *player = nil;
    if (!player) {
        NSError *error;
        NSURL *backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"FU4" withExtension:@"wav"];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
        player.numberOfLoops = -1;
        [player prepareToPlay];
        [player setVolume:0.01];
    }
    return player;
}

+(AVAudioPlayer*)FU5 {
    static AVAudioPlayer *player = nil;
    if (!player) {
        NSError *error;
        NSURL *backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"FU5" withExtension:@"wav"];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
        player.numberOfLoops = -1;
        [player prepareToPlay];
        [player setVolume:0.01];
    }
    return player;
}

+(AVAudioPlayer*)FU6 {
    static AVAudioPlayer *player = nil;
    if (!player) {
        NSError *error;
        NSURL *backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"FU6" withExtension:@"wav"];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
        player.numberOfLoops = -1;
        [player prepareToPlay];
        [player setVolume:0.01];
    }
    return player;
}

+(AVAudioPlayer*)FU7 {
    static AVAudioPlayer *player = nil;
    if (!player) {
        NSError *error;
        NSURL *backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"FU7" withExtension:@"wav"];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
        player.numberOfLoops = -1;
        [player prepareToPlay];
        [player setVolume:0.01];
    }
    return player;
}

+(void) restartBackgroundMusic {
    int level = [SELPlayer player].currentLevel;
    if (level == 1) { //0-25 1
        [[Settings FU3] setCurrentTime:0.0f];
        [[Settings FU3] play];
    }
    
    else if (level == 3) {//55 2
        [[Settings FU4] setCurrentTime:0.0f];
        [[Settings FU4] play];
        [[Settings FU3] pause];
    }
    else if (level == 5) { //88 4
        [[Settings FU5] setCurrentTime:0.0f];
        [[Settings FU5] play];
        [[Settings FU4] pause];
    }
    else if (level == 7) { //160 6
        [[Settings FU6] setCurrentTime:0.0f];
        [[Settings FU6] play];
        [[Settings FU5] pause];
    }
    else if (level == 9) { //200 7
        [[Settings FU7] setCurrentTime:0.0f];
        [[Settings FU7] play];
        [[Settings FU6] pause];
    }
    
//    [[Settings backgroundMusicPlayer] setCurrentTime:0.0f];
//    [[Settings backgroundMusicPlayer] play];
}

+(void) pauseFU {
    [[Settings FU3] pause];
    [[Settings FU4] pause];
    [[Settings FU5] pause];
    [[Settings FU6] pause];
    [[Settings FU7] pause];
}

+(AVAudioPlayer*)gameOverSoundEffect {
    [[Settings backgroundMusicPlayer] stop];
    static AVAudioPlayer *player = nil;
    if (!player) {
        NSError *error;
        NSURL *backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"gameOver" withExtension:@"mp3"];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
        player.numberOfLoops = 0;
        [player prepareToPlay];
        [player setVolume:0.01];
    }
    player.currentTime = 0.0f;
    [player play];
    return player;
}

+(AVAudioPlayer*)burnoutSoundEffect {
    static AVAudioPlayer *player = nil;
    if (!player) {
        NSError *error;
        NSURL *backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"burnout" withExtension:@"mp3"];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
        player.numberOfLoops = 0;
        [player prepareToPlay];
        [player setVolume:0.01];
    }
    [player pause];
    player.currentTime = 0.0f;
    [player play];
    return player;
}

+(AVAudioPlayer*)crashSoundEffect {
    static AVAudioPlayer *player = nil;
    if (!player) {
        NSError *error;
        NSURL *backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"crash" withExtension:@"mp3"];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
        player.numberOfLoops = 0;
        [player prepareToPlay];
        [player setVolume:0.01];
    }
    [player pause];
    player.currentTime = 0.0f;
    [player play];
    return player;
}

-(void) restartCrash {
    if ([Settings crashSoundEffect]) [[Settings crashSoundEffect] stop];
    [[Settings crashSoundEffect] setCurrentTime:0.0f];
    [[Settings crashSoundEffect] play];
}

-(void) restartBurnout {
    if ([Settings burnoutSoundEffect]) [[Settings burnoutSoundEffect] stop];
    [[Settings burnoutSoundEffect] setCurrentTime:0.0f];
    [[Settings burnoutSoundEffect] play];
}

+(void) setTiltPosition {
    // x, y, z GLKVector3Make(0.63f, 0.0f, -0.92f);
    //[Settings motionManager].accelerometerData.acceleration
    
    [Settings settings].ay = GLKVector3Make(0.63f, 0.0f, -0.92f);
    [[Settings settings] saveSettings];
}


@end
