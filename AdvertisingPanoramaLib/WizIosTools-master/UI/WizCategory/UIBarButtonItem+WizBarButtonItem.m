//
//  UIBarButtonItem+WizBarButtonItem.m
//  WizUIDesign
//
//  Created by wiz on 13-1-10.
//  Copyright (c) 2013年 cn.wiz. All rights reserved.
//

#import "UIBarButtonItem+WizBarButtonItem.h"
#import "UIImage+WizTintColor.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import "WizBadgeView.h"
static char _WizActionNavigationController;
#define WizActionNavigationController &_WizActionNavigationController

@interface UIView (WizAction)

@end

@implementation UIView (WizAction)

- (UINavigationController*) currentNavigationController
{
    return objc_getAssociatedObject(self, WizActionNavigationController);
}

- (void) setCurrentNavigationController:(UINavigationController*)nac
{
    objc_setAssociatedObject(self, WizActionNavigationController, nac, OBJC_ASSOCIATION_ASSIGN);
}

- (void) popCurrentNavigationController
{
    UINavigationController* nac = [self currentNavigationController];
    [self setCurrentNavigationController:nil];
    if (nac) {
        [nac popViewControllerAnimated:YES];
    }
    
}

@end
@implementation UIBarButtonItem (WizBarButtonItem)
+ (UIBarButtonItem*)itemWithImage:(UIImage *)image target:(id)target action:(SEL)action
{
    UIBarButtonItem* item = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStyleBordered target:target action:action];
    [item setBackgroundImage:[WizImageByKind(ImageOfNoBackgroundBarButtonBG) resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    return item;
}

+ (UIBarButtonItem*)itemWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
    UIBarButtonItem* item = [[UIBarButtonItem alloc]initWithTitle:title style:UIBarButtonItemStyleBordered target:target action:action];
    [item setBackgroundImage:[WizImageByKind(ImageOfNoBackgroundBarButtonBG) resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    return item;
}


+ (UIBarButtonItem *)toolbarItemWithImage:(UIImage *)image target:(id)target action:(SEL)action
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 44, 44);
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:[image imageWithTintColor:[UIColor colorWithHexHex:0xd2eaff]] forState:UIControlStateHighlighted];
    [button setImage:[image imageWithTintColor:[UIColor lightGrayColor]] forState:UIControlStateDisabled];
    
    UIBarButtonItem* item = [[UIBarButtonItem alloc]initWithCustomView:button];
    return item;

}


//- (void)setItemBadgeValue:(NSInteger)value
//{
//    if (value < 0) {
//        value = 0;
//    }
//    UIView* customeView = self.customView;
//    BOOL found = NO;
//    if ([customeView isKindOfClass:[UIButton class]]) {
//        UIButton* button = (UIButton*)customeView;
//        for (UIView* view in [button subviews]) {
//            if ([view isKindOfClass:[WizBadgeView class]]) {
//                found = YES;
//                WizBadgeView* badgeView = (WizBadgeView*)view;
//                badgeView.count = value;
//            }
//        }
//        if (!found && value != 0) {
//            WizBadgeView* badgeView = [[WizBadgeView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(button.frame)/2, CGRectGetHeight(button.frame)/2)];
//            badgeView.count = value;
//            [button addSubview:badgeView];
//        }
//    }
//}

- (void)setItemBadgeValue:(NSInteger)value ctrl:(UIViewController *)ctrl action:(SEL)action
{
    if (value < 0) {
        value = 0;
    }
    UIView* customeView = self.customView;
    BOOL found = NO;
    if ([customeView isKindOfClass:[UIButton class]]) {
        UIButton* button = (UIButton*)customeView;
        for (UIView* view in [button subviews]) {
            if ([view isKindOfClass:[WizBadgeView class]]) {
                found = YES;
                WizBadgeView* badgeView = (WizBadgeView*)view;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:ctrl action:action];
                [badgeView addGestureRecognizer:tap];
                badgeView.count = value;
            }
        }
        if (!found && value != 0) {
            WizBadgeView* badgeView = [[WizBadgeView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(button.frame)/2, CGRectGetHeight(button.frame)/2)];
            badgeView.count = value;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:ctrl action:action];
            [badgeView addGestureRecognizer:tap];
            [button addSubview:badgeView];
        }
    }
}

- (void)setBarButtonItemEnabled:(BOOL)enabled;
{
    self.enabled = enabled;
}


@end

