//
//  UIViewController+WizHelp.h
//  WizNote
//
//  Created by dzpqzb on 13-4-3.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UISwipeGestureRecognizer.h>


static float const WizAnimatedDuration = 0.25;

#ifdef __cplusplus

extern "C"
{
#endif
    extern CGRect CGRectSetCenter(CGRect parentRect,CGSize size);
    extern CGRect CGRectSetCenterY(CGRect rect, float height);
    extern CGRect CGRectSetCenterX(CGRect rect, float width);
    extern CGPoint CGPointAddY(CGPoint point, float Y);
    extern CGPoint CGPointAddX(CGPoint point , float x);
    extern CGFloat CGPointDistance(CGPoint point1, CGPoint point2);
    extern CGFloat CGPointAngle(CGPoint point1, CGPoint point2);
    extern CGRect CGRectSetBottomCenterX(CGRect rect , CGSize size);
    extern CGPoint CGCenterPoint(CGRect rect);
    extern CGRect CGRectGetMainScreen(UIInterfaceOrientation ori);
    extern CGRect CGRectGetOrientationRect(UIInterfaceOrientation ori, CGRect baseRect);
#ifdef __cplusplus
}
#endif

//
@interface UIViewController (WizHelp)<UIGestureRecognizerDelegate ,UIDocumentInteractionControllerDelegate>
@property (nonatomic, assign) BOOL isFirstAppear;

- (void) addScheduledOneTimeWithInterval:(NSTimeInterval)interval selector:(SEL)selector;
- (void) invalidScheduledOnceTimer;
- (BOOL) showUrlFromInnerBrowser:(NSURL*)url;
- (BOOL) openFileViewController:(NSURL*)url;
- (UIView*) lineViewWithFrame:(CGRect)frame;
- (void) firstAppearPerformSelector:(SEL)aSelector;
//
- (void) storeLastBarsHidden;
- (void) restoreLastBarsHidden;
- (void) loadNavigationBarHidden:(BOOL)navigationHidden toolbarHidden:(BOOL)toolHidden;
- (UIImage *)captureView:(UIView *)view;
@end
