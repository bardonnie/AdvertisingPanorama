//
//  WizAudioManager.h
//  WizNote
//
//  Created by dzpqzb on 13-2-25.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    WizAudioStatusRecordStart,
    WizAudioStatusRecordEnd,
    WizAudioStatusRecordFaild,
    WizAudioStatusRecordUpdateDatas,
    WizAudioStatusPlayStart,
    WizAudioStatusPlayEnd,
    WizAudioStatusPlayUpdateDatas
}WizAudioStatus;

@interface NSMutableDictionary (WizAudioDatas)
- (void) addAudioFilePath:(NSString*)filePath;
- (void) addAudioPower:(float)power channel:(int)channel;
- (void) addAudioPlayTotalTime:(float)timeInterval;
- (void) addAudioPlayCurrentTime:(float)timeInterval;
- (void) addRecordTotalTime:(float)timeInterval;
@end

@interface NSDictionary (WizAudioDatasParse)
- (NSString*) audioFilePath;
- (float) audioPowerOfChannel:(int)channel;
- (float) audioPlayTotalTime;
- (float) aduioPlayCurrentTime;
- (float) recordTotalTime;
@end
@protocol WizAudioRecodDelegate
- (void) recordDidStart;
- (void) recordProcess:(float)timeInterval audioPower:(float)power;
- (void) recordDidEnd:(NSString*)audioFilePath;
@end
@interface WizAudioManager : NSObject
@property (nonatomic, weak) id<WizAudioRecodDelegate> recodDelegate;
@property (nonatomic, strong, readonly) NSString* currentPlayFilePath;
+ (WizAudioManager*) shareInstance;
- (BOOL) startRecord;
- (void) stopRecord;
- (BOOL) isRecording;
- (BOOL) startPlay:(NSString*)filePath;
- (void) stopPlay:(NSString*)filePath;
- (void) pausePlay;
- (BOOL) isPlaying;
- (BOOL) record;
- (void) pauseRecord;
- (void) setRecordPaused;
@end
