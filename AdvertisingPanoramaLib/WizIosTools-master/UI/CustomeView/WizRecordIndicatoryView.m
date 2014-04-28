//
//  WizRecordIndicatoryView.m
//  WizNote
//
//  Created by dzpqzb on 13-6-25.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizRecordIndicatoryView.h"
#import "WizAudioView.h"

@interface WizRecordIndicatoryView ()
{
    UILabel* timeLabel;
    WizAudioView* audioView;
    UIButton* stopBtn;
    UIButton* pauseBtn;
    BOOL isPause;
}
@end

@implementation WizRecordIndicatoryView
@synthesize delegate = _delegate;
@synthesize currentPower = _currentPower;
@synthesize maxPower = _maxPower;
@synthesize recordTimeInterval = _recordTimeInterval;
- (void) commitInit
{
    self.userInteractionEnabled = YES;
    timeLabel = [UILabel new];
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.textColor = [UIColor colorWithHexHex:0xB8B9B7];
    [self addSubview:timeLabel];
    
    stopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [stopBtn setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    stopBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [stopBtn setTitleColor:[UIColor colorWithHexHex:0x359BDD] forState:UIControlStateNormal];
    [stopBtn addTarget:self action:@selector(tapStopBtn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:stopBtn];
    
    pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [pauseBtn setImage:WizImageByKind(ImageOfPlayIpadIconPause) forState:UIControlStateNormal];
    [pauseBtn addTarget:self action:@selector(tapPauseBtn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:pauseBtn];
    
    audioView = [[WizAudioView alloc] init];
    audioView.maxProcess = 100;
    audioView.currentProcess = 0;
    [self addSubview:audioView];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commitInit];
        // Initialization code
    }
    return self;
}

- (void)tapPauseBtn{
    if (!isPause) {
        [pauseBtn setImage:WizImageByKind(ImageOfPlayIpadIconContinue) forState:UIControlStateNormal];
        isPause = YES;
        if ([_delegate  respondsToSelector:@selector(recordIndicatoryViewPause)]) {
            [_delegate recordIndicatoryViewPause];
        }
    }else{
        [pauseBtn setImage:WizImageByKind(ImageOfPlayIpadIconPause) forState:UIControlStateNormal];
        isPause = NO;
        if ([_delegate  respondsToSelector:@selector(recordIndicatoryViewContinue)]) {
            [_delegate recordIndicatoryViewContinue];
        }
    }
}

- (void) tapStopBtn
{
    if ([_delegate  respondsToSelector:@selector(recordIndicatoryViewTapStop:)]) {
        [_delegate recordIndicatoryViewTapStop:self];
    }
}

- (void) setCurrentPower:(float)currentPower
{
    audioView.currentProcess = currentPower;
}

- (void) setMaxPower:(float)maxPower
{
    audioView.maxProcess = maxPower;
}

- (float) currentPower
{
    return audioView.currentProcess;
}

- (float) maxPower
{
    return audioView.maxProcess;
}

- (void) setRecordTimeInterval:(float)recordTimeInterval
{
    _recordTimeInterval = recordTimeInterval;
    timeLabel.text = [NSString stringHMSFromTimeInterval:recordTimeInterval];
}

- (void) layoutSubviews
{
    float timeLabelWidth = 100;
    float btnWidth  = 60;
    float pauseBtnWidth  = 32;
    float itemSpace = 5;
    float itemHeight = CGRectGetHeight(self.bounds) * 0.618;
    float minY = (CGRectGetHeight(self.bounds) - itemHeight) /2;
    float audioWidth = CGRectGetWidth(self.bounds) - timeLabelWidth - btnWidth - itemSpace * 4 - pauseBtnWidth -10;
    if (iPad) {
        timeLabel.frame = CGRectMake(itemSpace, minY, timeLabelWidth, itemHeight);
        audioView.frame = CGRectMake(CGRectGetMaxX(timeLabel.frame), minY, audioWidth, itemHeight);
        pauseBtn.frame = CGRectMake(CGRectGetMaxX(audioView.frame) + 14, (CGRectGetHeight(self.bounds) - pauseBtnWidth) /2,pauseBtnWidth, pauseBtnWidth);
        stopBtn.frame = CGRectMake(CGRectGetMaxX(pauseBtn.frame) + itemSpace, minY, btnWidth, itemHeight);
    }else{
        timeLabel.frame = CGRectMake(0, minY, 85, itemHeight);
        audioView.frame = CGRectMake(CGRectGetMaxX(timeLabel.frame), minY, 294/2, itemHeight);
        pauseBtn.frame = CGRectMake(CGRectGetMaxX(audioView.frame)+ 5, (CGRectGetHeight(self.bounds) - pauseBtnWidth) /2,pauseBtnWidth, pauseBtnWidth);
        stopBtn.frame = CGRectMake(CGRectGetMaxX(pauseBtn.frame)+ 5, minY, btnWidth-10, itemHeight);
    }
}

@end
