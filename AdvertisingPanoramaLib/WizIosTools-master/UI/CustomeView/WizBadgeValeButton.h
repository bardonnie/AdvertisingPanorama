//
//  WizBadgeValeButton.h
//  WizIphone7
//
//  Created by wzz on 13-9-4.
//  Copyright (c) 2013年 dzpqzb inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WizBadgeValeButton : UIButton
@property (nonatomic, assign) NSInteger badgeValue;
@property (nonatomic, setter = setBadgeRoundImage:) UIImage* badgeRoundImage;
@end
