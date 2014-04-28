//
//  WizProgressBar.h
//  WizIphone7
//
//  Created by wzz on 13-11-21.
//  Copyright (c) 2013年 dzpqzb inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WizProgressBar : UIView
@property (nonatomic, strong)UIColor* processTintColor;
@property (nonatomic, strong)UIColor* trackTintColor;
- (void) setProgress:(CGFloat)value animated:(BOOL)animated;
@end
