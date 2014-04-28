//
//  UIBarButtonItem+WizBarButtonItem.h
//  WizUIDesign
//
//  Created by wiz on 13-1-10.
//  Copyright (c) 2013年 cn.wiz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (WizBarButtonItem)
+ (UIBarButtonItem*)itemWithImage:(UIImage *)image target:(id)target action:(SEL)action;
+ (UIBarButtonItem*)itemWithTitle:(NSString*)title target:(id)target action:(SEL)action;
+ (UIBarButtonItem*)toolbarItemWithImage:(UIImage *)image target:(id)target action:(SEL)action;
- (void)setBarButtonItemEnabled:(BOOL)enabled;
//- (void)setItemBadgeValue:(NSInteger)value;
- (void)setItemBadgeValue:(NSInteger)value ctrl:(UIViewController *)ctrl action:(SEL)action
;
@end
