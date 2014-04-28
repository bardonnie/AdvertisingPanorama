//
//  WizRecordView.m
//  WizNote
//
//  Created by dzpqzb on 13-4-24.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizRecordView.h"
#import "WizAudioManager.h"
#import "UIViewController+WizHelp.h"
#import <QuartzCore/QuartzCore.h>
typedef enum {
    WizAudioEndTypeCancel,
    WizAudioEndTypeNormal
} WizAudioEndType;

@interface WizRecordView () <WizAudioRecodDelegate>
{
    UIImageView* recordingProcessCircleView;
    UIImageView* recordingProcessMacView;
    UIButton* cacnelButton;
    UIButton* startButton;
    UILabel* timeProcessLabel;
    WizAudioEndType endType;
}
@end

@implementation WizRecordView

- (UIButton*) recordButtonWithImageName:(NSString*)imageName highlightedImageName:(NSString*)highlightedImageName selector:(SEL)selector
{
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:WizImageByKind(imageName) forState:UIControlStateNormal];
    [btn setImage:WizImageByKind(highlightedImageName) forState:UIControlStateHighlighted];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    return btn;
}
- (void) stopRecord
{
    endType = WizAudioEndTypeNormal;
    [[WizAudioManager shareInstance] stopRecord];
}

- (void) cancelRecord
{
    endType = WizAudioEndTypeCancel;
    [[WizAudioManager shareInstance] stopRecord];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        endType = WizAudioEndTypeNormal;
        recordingProcessCircleView = [UIImageView new];
        recordingProcessCircleView.image = WizImageByKind(ImageOfRecordingProgressCircle);
        recordingProcessMacView = [UIImageView new];
        recordingProcessMacView.image = WizImageByKind(ImageOfRecordingProgressMac);
        [self addSubview:recordingProcessCircleView];
        [self addSubview:recordingProcessMacView];
        
        timeProcessLabel = [UILabel new];
        timeProcessLabel.font = [UIFont boldSystemFontOfSize:20];
        timeProcessLabel.backgroundColor = [UIColor clearColor];
        timeProcessLabel.textColor= [UIColor whiteColor];
        timeProcessLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:timeProcessLabel];
        [WizAudioManager shareInstance].recodDelegate = self;
        cacnelButton = [self recordButtonWithImageName:ImageOfRecordStop highlightedImageName:ImageOfRecordStopHighlighted selector:@selector(cancelRecord)];
        startButton = [self recordButtonWithImageName:ImageOfRecordStart highlightedImageName:ImageOfRecordStartHighlighted selector:@selector(stopRecord)];
        
        // Initialization code
    }
    return self;
}
- (void) startRecord
{
    [[WizAudioManager shareInstance] setRecodDelegate:self];
    [[WizAudioManager shareInstance] startRecord];
}
- (void) recordDidStart
{
//   [recordingProcessView startAnimating];
    
    float beginValue = 0;
    
    CABasicAnimation *anim;
    anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    anim.duration = 0.7;
    anim.repeatCount = CGFLOAT_MAX;
    
    anim.fillMode = kCAFillModeBoth;
    anim.fromValue = [NSNumber numberWithFloat:beginValue];
    anim.repeatDuration = 0;
    //get current layer angle during animation in flight
    anim.toValue = [NSNumber numberWithFloat:(360*M_PI/180 + beginValue)];
    [recordingProcessCircleView.layer addAnimation:anim forKey:@"transform"];
    [self.delegate didStartRecord];
}
- (void) recordProcess:(float)timeInterval audioPower:(float)power
{
   timeProcessLabel.text =  [WizGlobals timerStringFromTimerInver:timeInterval];
}
- (void) recordDidEnd:(NSString *)audioFilePath
{
    if (endType == WizAudioEndTypeNormal) {
       [self.delegate didEndRecord:audioFilePath];
    }
    else
    {
        [self.delegate didCancelRecord];
    }
}


- (void) layoutSubviews
{
    [super layoutSubviews];
    float progessImagesHeight = 148;
    recordingProcessCircleView.frame = CGRectSetY( CGRectSetHeight(CGRectSetCenterX(self.bounds, progessImagesHeight), progessImagesHeight), 13.5);
    recordingProcessMacView.frame = recordingProcessCircleView.frame;
    timeProcessLabel.frame = CGRectSetY(CGRectSetHeight(CGRectSetCenterX(self.bounds, 100) , 20), CGRectGetMaxY(recordingProcessMacView.frame) + 15);;
    float buttonWidth = 62;
    cacnelButton.frame =  CGRectSetHeight(CGRectOffset(CGRectSetCenterX(self.bounds, buttonWidth),- buttonWidth/2, CGRectGetMaxY(timeProcessLabel.frame) + 15), buttonWidth);
    startButton.frame = CGRectOffset(cacnelButton.frame, buttonWidth, 0);
}

@end
