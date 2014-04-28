//
//  UINavigationController+WizNavigationController.m
//  WizNote
//
//  Created by wzz on 13-5-17.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "UINavigationController+WizNavigationController.h"
#import <objc/runtime.h>

static char _WizCoverViewOnNaviationControllerKey;
#define WizCoverViewOnNaviationControllerKey &_WizCoverViewOnNaviationControllerKey

static char _WizCoverGestureRecognizerKey;
#define WizCoverGestureRecognizerKey   &_WizCoverGestureRecognizerKey

@implementation UINavigationController (WizNavigationController)

- (void) setCoverView:(UIView *)coverView
{
    objc_setAssociatedObject(self, WizCoverViewOnNaviationControllerKey, coverView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIView*) coverView
{
    return objc_getAssociatedObject(self, WizCoverViewOnNaviationControllerKey);
}

- (void) setGestureRecognizer:(UIGestureRecognizer*)gesture
{
    objc_setAssociatedObject(self, WizCoverGestureRecognizerKey, gesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIGestureRecognizer*)gestureRecognizer{
    return objc_getAssociatedObject(self, WizCoverGestureRecognizerKey);
}

- (void)addTarge:(id)target action:(SEL)seletor
{
    UIView* myCoverView = [self coverView];
    if (nil == myCoverView) {
        UIView* coverView = [[UIView alloc]initWithFrame:CGRectSetY(self.view.frame, 44)];
        coverView.backgroundColor = [UIColor clearColor];
        myCoverView = coverView;
        coverView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:target action:seletor];
    tap.numberOfTapsRequired = 1;
    [myCoverView addGestureRecognizer:tap];
    [self setGestureRecognizer:tap];
    [self.view addSubview:myCoverView];
    [self setCoverView:myCoverView];
}

- (void)removeTarget:(id)target
{
    [[self coverView] removeGestureRecognizer:[self gestureRecognizer]];
    [[self coverView] removeFromSuperview];
}

@end
