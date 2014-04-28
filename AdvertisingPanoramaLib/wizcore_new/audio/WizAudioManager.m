//
//  WizAudioManager.m
//  WizNote
//
//  Created by dzpqzb on 13-2-25.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizAudioManager.h"
#import "WizGlobalData.h"
#import "WizLogger.h"
#import "WizFileManager.h"
#import <AVFoundation/AVFoundation.h>

static NSString* const KeyOfAudioFilePath = @"KeyOfAudioFilePath";
static NSString* const KeyOfAudioChannel= @"KeyOfAudioChannel";
static NSString* const KeyOfAudioPower = @"KeyOfAudioPower";
static NSString* const KeyOfAudioPlayTotalTime = @"KeyOfAudioPlayTotalTime";
static NSString* const KeyOfAudioPlayCurrentTime = @"KeyOfAudioPlayCurrentTime";
static NSString* const KeyOfAudioRecordTotalTime = @"KeyOfAudioRecordTotalTime";



@implementation NSMutableDictionary (WizAudioDatas)
- (void) addRecordTotalTime:(float)timeInterval
{
    [self setObject:@(timeInterval) forKey:KeyOfAudioRecordTotalTime];
}
- (void) addAudioFilePath:(NSString *)filePath
{
    if (filePath) {
        [self setObject:filePath forKey:KeyOfAudioFilePath];
    }
}

NSString*(^AudioChannelKey)(int) = ^(int channel) {
    return [NSString stringWithFormat:@"%@-%d",KeyOfAudioChannel,channel];
};

- (void) addAudioPower:(float)power channel:(int)channel
{
    [self setObject:@(power) forKey:AudioChannelKey(channel)];
}

- (void) addAudioPlayCurrentTime:(float)timeInterval
{
    if (timeInterval != timeInterval || timeInterval < 0 || timeInterval > INT_MAX) {
        timeInterval = 0;
    }
    [self setObject:@(timeInterval) forKey:KeyOfAudioPlayCurrentTime];
}

- (void) addAudioPlayTotalTime:(float)timeInterval
{
    if (timeInterval < 0 || timeInterval > INT_MAX) {
        timeInterval = 0;
    }
    [self setObject:@(timeInterval) forKey:KeyOfAudioPlayTotalTime];
}

@end

@implementation NSDictionary (WizAudioDatasParse)

- (float) recordTotalTime
{
   return [[self objectForKey:KeyOfAudioRecordTotalTime] floatValue];
}
- (float) aduioPlayCurrentTime
{
    return [[self objectForKey:KeyOfAudioPlayCurrentTime] floatValue];
}

- (float) audioPlayTotalTime
{
    return [[self objectForKey:KeyOfAudioPlayTotalTime] floatValue];
}

- (NSString*) audioFilePath
{
    return self[KeyOfAudioFilePath];
}

- (float) audioPowerOfChannel:(int)channel
{
    return [self[AudioChannelKey(channel)] floatValue];
}

@end


@interface WizAudioManager() <AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    float recordTotalTimeInterval;
    BOOL recorderPaused;
}
@property (nonatomic, strong) AVAudioRecorder* audioRecorder;
@property (nonatomic, strong) NSTimer* audioTimer;
@property (nonatomic, strong, readonly) NSString* recordFilePath;
@property (nonatomic, strong) AVAudioPlayer* audioPlayer;
@property (nonatomic, strong, readonly) NSString* audioPlayFilePath;
@end
@implementation WizAudioManager
@synthesize audioRecorder;
@synthesize audioTimer;
@synthesize recodDelegate;
@synthesize audioPlayer;
@synthesize audioPlayFilePath;
+ (WizAudioManager*) shareInstance
{
    static WizAudioManager* audioManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       audioManager = [WizGlobalData shareInstanceFor:[WizAudioManager class]];
    });
    return audioManager;
}

- (NSString*) currentPlayFilePath
{
    return [self.audioPlayer.url path];
}
- (BOOL) startRecord
{
    @try {
        NSError* sessionError;
        AVAudioSession* session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryRecord error:&sessionError];
        if (self.audioRecorder)
        {
            if ([self.audioRecorder isRecording]) {
                return YES;
            }
            else
            {
                [self.audioRecorder stop];
                self.audioRecorder = nil;
            }
        }
        NSError* error = nil;
        NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  [NSNumber numberWithFloat: 1000.0],AVSampleRateKey,
                                  [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                  [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                  [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                  [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                                  [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,nil];
        NSString* audioFileName = [WizFileManager recordTempPath];
        if ([[WizFileManager defaultManager ] fileExistsAtPath:audioFileName]) {
            [[WizFileManager defaultManager] removeItemAtPath:audioFileName error:nil];
        }
        NSURL* url = [NSURL fileURLWithPath:audioFileName];
       
        self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error ] ;
        if(!self.audioRecorder)
        {
            return NO;
        }
        self.audioRecorder.delegate = self;
        self.audioRecorder.meteringEnabled = YES;
        if(![self.audioRecorder prepareToRecord])
        {
            return NO;
        }
        if(![self.audioRecorder record])
        {
            DDLogError(@"start record error !");
        }
        self.audioTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(showRecoderProcess:) userInfo:nil repeats:YES];
        

        
        if (sessionError) {
            DDLogError(@"record error %@",sessionError);
//            self.recodDelegate reco
        }
        else
        {
            [session setActive:YES error:&sessionError];
            [self.recodDelegate recordDidStart];
            [self postNofiticationMessage:WizAudioStatusRecordStart filePath:self.recordFilePath datas:nil];
        }
        recordTotalTimeInterval = 0;
        return YES;
    }
    @catch (NSException *exception) {
        [WizGlobals reportWarningWithString:exception.description];
        return NO;
    }
    @finally {
        return YES;
    }
}
- (NSString*) recordFilePath
{
    return [self.audioRecorder.url path];
}
- (void) showRecoderProcess:(NSTimer*)timer
{
    [self.audioRecorder updateMeters];
    recordTotalTimeInterval += timer.timeInterval;
    float power = [self.audioRecorder peakPowerForChannel:0];
    [self.recodDelegate recordProcess:self.audioRecorder.currentTime audioPower:power];
    NSMutableDictionary* datas = [NSMutableDictionary new];
    
    [datas addRecordTotalTime:recordTotalTimeInterval];
    [datas addAudioPower:power channel:0];
    [self postNofiticationMessage:WizAudioStatusRecordUpdateDatas filePath:self.recordFilePath datas:datas];
}

- (void) postNofiticationMessage:(WizAudioStatus)status filePath:(NSString*)filePath datas:(NSDictionary*)datas
{
    NSMutableDictionary* userInfo = [NSMutableDictionary new];
    [userInfo addAudioFilePath:filePath];
    [userInfo addAudioStatus:status];
    [userInfo addMessageDatas:datas];
    [[NSNotificationCenter defaultCenter] postNotificationName:WizNotificationMessageAudioChanged object:nil userInfo:userInfo];
}


- (void) postNotificationError:(NSError*)error filePath:(NSString*)filePath
{
    NSMutableDictionary* userInfo = [NSMutableDictionary new];
    [userInfo addAudioStatus:WizAudioStatusRecordFaild];
    [userInfo addAudioFilePath:filePath];
    [userInfo addErrorData:error];
    [[NSNotificationCenter defaultCenter] postNotificationName:WizNotificationMessageAudioChanged object:nil userInfo:userInfo];
}
- (void) stopRecord
{
    if (self.audioRecorder.isRecording || recorderPaused) {
        NSError* error = nil;
        [self.audioRecorder stop];
        [self.audioTimer invalidate];
        AVAudioSession* session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategorySoloAmbient error:&error];
        [session setActive:YES error:&error];
        recorderPaused = NO;
    }
}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    [self.recodDelegate recordDidEnd:[self.audioRecorder.url relativePath]];
    [self postNofiticationMessage:WizAudioStatusRecordEnd filePath:self.recordFilePath datas:nil];
    self.audioRecorder = nil;
}
- (BOOL) isRecording
{
    if (self.audioRecorder) {
        return self.audioRecorder.isRecording;
    }
    return NO;
}

- (void) updatePlayMeters
{
    [self.audioTimer invalidate];
    self.audioTimer = nil;
        self.audioTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(showPlayProgress:) userInfo:nil repeats:YES];
    
}


- (BOOL) startPlay:(NSString *)filePath
{
    NSError* error = nil;
    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    [session setActive:YES error:&error];
    if ([self.audioPlayFilePath isEqualToString:filePath]) {
        if ([self.audioPlayer play]) {
            [self postNofiticationMessage:WizAudioStatusPlayStart filePath:filePath datas:nil];
            [self updatePlayMeters];
            return YES;
        }
    }
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] error:&error];
    self.audioPlayer.delegate = self;
    [self.audioPlayer play];
    [self updatePlayMeters];
    [self postNofiticationMessage:WizAudioStatusPlayStart filePath:filePath datas:nil];

    return YES;
}


- (void) showPlayProgress:(NSTimer*)timer
{
    [self.audioPlayer updateMeters];
    float power = [self.audioPlayer peakPowerForChannel:0];
    
    NSMutableDictionary* datas = [NSMutableDictionary new];
    [datas addAudioPower:power channel:0];
    [datas addAudioPlayTotalTime:self.audioPlayer.duration];
    [datas addAudioPlayCurrentTime:self.audioPlayer.currentTime];
    [self postNofiticationMessage:WizAudioStatusPlayUpdateDatas filePath:self.audioPlayFilePath datas:datas];
}
- (NSString*) audioPlayFilePath
{
    return [self.audioPlayer.url path];
}

- (void) audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    
}

- (BOOL)record{
    recorderPaused = NO;
    [self resumeAudioTimer];
    return [self.audioRecorder record];
}

- (void) pauseRecord{
    [self.audioRecorder pause];
    [self pauseAudioTimer];
    recorderPaused = YES;
}

- (void) setRecordPaused{
    recorderPaused = NO;
}

- (void) pausePlay
{
    [self.audioPlayer pause];
    [self.audioTimer invalidate];
}

-(void)resumeAudioTimer{
    if (![self.audioTimer isValid]) {
        return ;
    }
    [self.audioTimer setFireDate:[NSDate date]];
}

-(void)pauseAudioTimer{
    if (![self.audioTimer isValid]) {
        return ;
    }
    [self.audioTimer setFireDate:[NSDate distantFuture]];
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self postNofiticationMessage:WizAudioStatusPlayEnd filePath:self.audioPlayFilePath datas:nil];
}

- (void) stopPlay:(NSString *)filePath
{
    [self.audioTimer invalidate];
    [self.audioPlayer stop];
    self.audioPlayer = nil;
    [self postNofiticationMessage:WizAudioStatusPlayEnd filePath:self.audioPlayFilePath datas:nil];
}

- (BOOL) isPlaying
{
    return [self.audioPlayer isPlaying];
}
@end
