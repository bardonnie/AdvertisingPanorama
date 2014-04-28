//
//  UIViewController+WizModal.h
//  WizNote
//
//  Created by dzpqzb on 13-3-29.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIViewController (WizModal)
@property (nonatomic, assign, readonly) BOOL isZoomed;
- (void) presentWizModalViewController:(UIViewController*)viewController;
- (void) dismissWizModalViewControllerAnimated:(BOOL)animated;
- (void) zoomToFullScreenAnimation:(BOOL)animation;
- (void) setZoomMinWidth:(float)minWidth;
- (void) shrinkToMinWidth;
- (void) setTapMaskToDismissWizModalViewControoler:(BOOL)isTapToDis;
- (CGRect) viewControllerFrameInParent;
@end
