//
//  WizRecordIndicatoryView.h
//  WizNote
//
//  Created by dzpqzb on 13-6-25.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WizRecordIndicatoryView;
@protocol WizRecordIndicatoryDelegate
@optional
- (void) recordIndicatoryViewTapStop:(WizRecordIndicatoryView*)recordView;
- (void) recordIndicatoryViewPause;
- (void) recordIndicatoryViewContinue;
@end


@interface WizRecordIndicatoryView : UIImageView
@property (nonatomic, weak) NSObject<WizRecordIndicatoryDelegate>* delegate;
@property (nonatomic, assign) float currentPower;
@property (nonatomic, assign) float maxPower;
@property (nonatomic, assign) float recordTimeInterval;
@end
