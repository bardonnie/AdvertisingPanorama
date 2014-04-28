//
//  WizPlayProgressView.h
//  WizNote
//
//  Created by dzpqzb on 13-6-24.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WizPlayProgressView;
@protocol WizPlayProgressDelegate
- (void) playProgressViewDidTapStopButton:(WizPlayProgressView*)playView;
- (void) playProgressViewDidTapPlayButton:(WizPlayProgressView*)playView;
- (void) playProgressViewDidTapPauseButton:(WizPlayProgressView*)playView;
@end

@interface WizPlayProgressView : UIView
@property (nonatomic, weak) NSObject<WizPlayProgressDelegate>* delegate;
@property (nonatomic, strong) UIImage* backgroudImage;
@property (nonatomic, strong) UIImage* progressBackgroudImage;
@property (nonatomic, assign) float maxProgress;
@property (nonatomic, assign) float currentProgress;
//
@property (nonatomic, strong) UIColor* progressColor;
@property (nonatomic, strong) UIColor* progressLineColor;
@property (nonatomic, strong) UIColor* progressBackgroudColor;
- (void) resetToPlay;
@end
