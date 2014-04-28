//
//  WizNavigationViewController.h
//  WizNote
//
//  Created by dzpqzb on 13-8-2.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+WizAppStatus.h"
@protocol UIViewControllerISShowing
@property (nonatomic, assign, readonly) BOOL  isVisibling;
@end

@interface WizNavigationViewController : UINavigationController <UIViewControllerISShowing>
- (id)initWithRootViewController:(UIViewController *)rootViewController reciveMessage:(BOOL)messageIsVisible;
@end
