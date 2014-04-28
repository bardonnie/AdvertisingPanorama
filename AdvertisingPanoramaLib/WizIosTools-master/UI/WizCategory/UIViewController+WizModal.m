//
//  UIViewController+WizModal.m
//  WizNote
//
//  Created by dzpqzb on 13-3-29.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "UIViewController+WizModal.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
static int const WizModalViewMaskTag = 10001;
static char _WIZMODAL_KEY_MINWIDTH;
static char _WIZMODAL_KEY_ISZOOMED;
static char _WIZMODAL_KEY_IS_WIZMODALVIEWCONTROLLER;

static char _WIZMODEL_KEY_TAPGESTRUE;
static char _WIZMODEL_KEY_MASKVIEWSARRAY;

#define WIZMODAL_KEY_MINWIDTH &_WIZMODAL_KEY_MINWIDTH
#define WIZMODAL_KEY_ISZOOMED &_WIZMODAL_KEY_ISZOOMED 
#define WIZMODAL_KEY_IS_WIZMODALVIEWCONTROLLER &_WIZMODAL_KEY_IS_WIZMODALVIEWCONTROLLER
#define WIZMODEL_KEY_TAPGESTRUE &_WIZMODEL_KEY_TAPGESTRUE
#define WIZMODEL_KEY_MASKVIEWSARRAY &_WIZMODEL_KEY_MASKVIEWSARRAY

CGSize CGSizeRotaion90(CGSize size)
{
    return CGSizeMake(size.height, size.width);
}


BOOL (^FloatIsEqaul)(float,float) = ^(float f1, float f2)
{
    if(ABS(f1-f2) < 0.01) return YES;
    return NO;
};

@interface UIView (WizModal)
- (void) setDismissTapGesture:(UITapGestureRecognizer*)gesture;
- (void) removeDismissTapGesture;
@end

@implementation UIView (WizModal)

- (UITapGestureRecognizer*)tapToDismissGesture
{
    return objc_getAssociatedObject(self, WIZMODEL_KEY_TAPGESTRUE);
}

- (void) setDismissTapGesture:(UITapGestureRecognizer *)gesture
{
    UITapGestureRecognizer* tapGesture = [self tapToDismissGesture];
    if (!tapGesture) {
        [self addGestureRecognizer:gesture];
        objc_setAssociatedObject(self, WIZMODEL_KEY_TAPGESTRUE, gesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    else
    {
        [self addGestureRecognizer:tapGesture];
    }
    
}

- (void) removeDismissTapGesture
{
    UITapGestureRecognizer* tapGesture = [self tapToDismissGesture];
    [self removeGestureRecognizer:tapGesture];
}
@end
@implementation UIViewController (WizModal)
@dynamic  isZoomed;
- (UIViewController*) wiz_parentTargetViewController
{
    UIViewController* target = self;
    while (target.parentViewController != nil) {
        target = target.parentViewController;
    }
    return target;
}

- (void) setMaskViewsArray:(NSArray*)maskViews
{
    objc_setAssociatedObject(self, WIZMODEL_KEY_MASKVIEWSARRAY, maskViews, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray*) maskViewsArray
{
    return objc_getAssociatedObject(self, WIZMODEL_KEY_MASKVIEWSARRAY);
}

- (CGRect) viewControllerFrameInParent
{
    static float UIStatusBarHeight = 20;
    UIViewController* tartget = [self wiz_parentTargetViewController];
    float width = CGRectGetWidth([UIScreen mainScreen].bounds);
    float height = UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? CGRectGetWidth(tartget.view.frame) : CGRectGetHeight(tartget.view.frame);
    float startX = (CGRectGetWidth(tartget.view.bounds) -  width) /2;
    if (CGRectEqualToRect([UIScreen mainScreen].bounds, tartget.view.frame) || CGRectEqualToRect([UIScreen mainScreen].bounds, CGRectSetSize(tartget.view.frame, CGSizeMake(CGRectGetHeight(tartget.view.frame), CGRectGetWidth(tartget.view.frame))))) {
       return CGRectMake(startX , UIStatusBarHeight, width, height - UIStatusBarHeight);
    }
    else
    {
       return CGRectMake(startX, 0, width, height);
    }
}

- (CGRect) parentFrame
{
    float height = CGRectGetHeight([UIScreen mainScreen].bounds);
    float width = CGRectGetWidth([UIScreen mainScreen].bounds);
//    NSLog(@"interface orientation is %d",[[UIDevice currentDevice] orientation]);
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        return CGRectMake(0, CGRectGetMinY(self.view.frame), width, height - 20);
    }
    else
    {
        return CGRectMake(0, CGRectGetMinY(self.view.frame), height, width - 20);
    }
}

- (void) presentWizModalViewController:(UIViewController *)viewController
{
    UIViewController* target = [self wiz_parentTargetViewController];
    [target addChildViewController:viewController];
    [viewController setIsWizModalViewController:YES];
    [viewController willMoveToParentViewController:target];

    NSMutableArray* wizMaskViews = [NSMutableArray arrayWithArray:[target maskViewsArray]];
    UIView* maskView = [[UIView alloc] init];
    maskView.tag = WizModalViewMaskTag + [wizMaskViews count] + 1;
    float height = [UIScreen mainScreen].bounds.size.height;
    maskView.frame =CGRectSetSize(target.view.bounds, CGSizeMake(height,height)) ;
    maskView.autoresizesSubviews =  UIViewAutoresizingFlexibleWidth;
    if ([wizMaskViews count]) {
        maskView.backgroundColor = [UIColor clearColor];
    }else{
        maskView.alpha = 0.5;
        maskView.backgroundColor = [UIColor blackColor];
    }
    [target.view addSubview:maskView];
    [wizMaskViews addObject:maskView];
    [target setMaskViewsArray:wizMaskViews];

    //
    viewController.view.autoresizingMask =  UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    viewController.view.frame = [self viewControllerFrameInParent];
    [viewController viewWillAppear:YES];
    [target.view addSubview:viewController.view];
    CGAffineTransform newTransform = CGAffineTransformScale(viewController.view.transform, 0.1, 0.1);
    [viewController.view setTransform:newTransform];
    [UIView animateWithDuration:0.25 animations:^{
       
        CGAffineTransform transform =            CGAffineTransformConcat(viewController.view.transform,  CGAffineTransformInvert(viewController.view.transform));
        [viewController.view setTransform:transform];
        viewController.view.alpha = 1.0;
    } completion:^(BOOL finished) {
       [viewController didMoveToParentViewController:target];
        [[NSNotificationCenter defaultCenter] addObserver:viewController selector:@selector(deviceOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
        [viewController viewDidAppear:YES];
    }];
    
}
- (void) deviceOrientationChanged:(NSNotificationCenter*)notification
{
    if ([self isZoomed]) {
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            self.view.frame = [self parentFrame];
        }
        else
        {
            self.view.frame = [self parentFrame];
        }
        
    }
}
- (void) dismissWizModalViewControllerAnimated:(BOOL)animated
{
    if (![self isWizModalViewController]) {
        return ;
    }
    UIViewController* controller = self;
    UIViewController* target = [self wiz_parentTargetViewController];
    [controller willMoveToParentViewController:nil];
    [controller removeFromParentViewController];
    
    NSInteger tag = WizModalViewMaskTag + [[target maskViewsArray] count];
    UIView* maskView = [target.view viewWithTag:tag];
    [UIView animateWithDuration:0.25 animations:^{
//        if (animated) {
//            self.view.frame = CGRectMake(CGRectGetWidth(self.view.frame) /2 - 50, CGRectGetHeight(self.view.frame)/2 - 50, 100, 100);
//            self.view.alpha = 0.0;
//            maskView.alpha = 0.0;
//        }
    } completion:^(BOOL finished) {
        [maskView removeFromSuperview];
        [self.view removeFromSuperview];
        NSMutableArray* array = [NSMutableArray arrayWithArray:[target maskViewsArray]];
        [array removeLastObject];
        [target setMaskViewsArray:array];
        [controller didMoveToParentViewController:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
        [self setIsWizModalViewController:NO];
    }];
}

- (BOOL) canZoomToFullScreen
{
    float zoomMinWidth = [self zoomMinWidth];
    if (UIInterfaceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
        return NO;
    }
    if (CGRectGetWidth(self.view.frame) < zoomMinWidth) {
        return NO;
    }
    return YES;
}

- (void) zoomToFullScreenAnimation:(BOOL)animation
{
    if ([self isZoomed]) {
        return;
    }
    if (![self canZoomToFullScreen]) {
        return;
    }
    [UIView animateWithDuration:0.25 animations:^{
       self.view.frame = [self parentFrame]; 
    } completion:^(BOOL finished) {
       
    }];
   [self setIsZoomed:YES];  
    
}

- (void) shrinkToMinWidth
{
    if (![self isZoomed]) {
        return;
    }
    CGRect rect = CGRectSetSize(CGRectZero, CGSizeMake([self zoomMinWidth], CGRectGetHeight([self parentFrame])));
    [UIView animateWithDuration:0.25 animations:^{
       self.view.frame = CGRectSetOrigin(rect, CGPointMake(((CGRectGetWidth([self parentFrame]) - [self zoomMinWidth]) / 2), CGRectGetMinY(self.view.frame)));
    } completion:^(BOOL finished) {
       
    }];
   [self setIsZoomed:NO];  
    
}



- (void) setZoomMinWidth:(float)minWidth
{
    objc_setAssociatedObject(self, WIZMODAL_KEY_MINWIDTH, [NSNumber numberWithFloat:minWidth], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}



- (float) zoomMinWidth
{
    NSNumber* number = objc_getAssociatedObject(self, WIZMODAL_KEY_MINWIDTH);
    if (!number) {
        return CGRectGetWidth([UIScreen mainScreen].bounds);
    }
    return [number floatValue];
}

- (void) setIsZoomed:(BOOL)isZoom
{
    objc_setAssociatedObject(self, WIZMODAL_KEY_ISZOOMED, [NSNumber numberWithBool:isZoom], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (BOOL) isZoomed
{
    NSNumber* zoom = objc_getAssociatedObject(self, WIZMODAL_KEY_ISZOOMED);
    if (!zoom) {
        return NO;
    }
    return [zoom boolValue];
}

- (void) setIsWizModalViewController:(BOOL)isWiz
{
    objc_setAssociatedObject(self, WIZMODAL_KEY_IS_WIZMODALVIEWCONTROLLER, [NSNumber numberWithBool:isWiz], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL) isWizModalViewController
{
    NSNumber* isWiz = objc_getAssociatedObject(self, WIZMODAL_KEY_IS_WIZMODALVIEWCONTROLLER);
    if (!isWiz) {
        return NO;
    }
    return [isWiz boolValue];
}

- (UIViewController*) topWizModalViewController
{
    UIViewController* viewController = self;
    while (viewController) {
        if ([viewController isWizModalViewController]) {
            return viewController;
        }
        viewController = viewController.parentViewController;
    }
    return nil;
}

- (void) setTapMaskToDismissWizModalViewControoler:(BOOL)isTapToDis
{
    UIViewController* topModalVC = [self topWizModalViewController];
    if (isTapToDis && [topModalVC isMovingToParentViewController]) {
        [self performSelector:@selector(setTapMaskToDismissWizModalViewControoler:) withObject:[NSNumber numberWithBool:isTapToDis] afterDelay:WizAnimatedDuration];
        return ;
    }
    UIViewController* target = [self wiz_parentTargetViewController];
    NSInteger tag = WizModalViewMaskTag + [[target maskViewsArray] count];
    UIView* maskView = [target.view viewWithTag:tag];
    if (maskView) {
        if (isTapToDis) {
            UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:topModalVC action:@selector(dismissWizModalViewControllerAnimated:)];
            [maskView setDismissTapGesture:tapGesture];
        }
        else
        {
            [maskView removeDismissTapGesture];
        }
    }
}



@end
