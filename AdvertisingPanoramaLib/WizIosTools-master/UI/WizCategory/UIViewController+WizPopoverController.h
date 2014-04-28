//
//  UIViewController+WizPopoverController.h
//  WizNote
//
//  Created by dzpqzb on 13-4-2.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (WizPopoverController)
- (void) dismissCurrentPopoverController;
- (void) showPoperFromBarItem:(UIBarButtonItem *)item withContent:(UIViewController *)viewController;
- (void)showPoperFromView:(UIView*)view inRect:(CGRect)rect withContent:(UIViewController*)viewController;
- (UIBarButtonItem*) refreshBarItemWithTarget:(id)target selector:(SEL)selector;
- (UIBarButtonItem*) activityBarItemWithTagrget:(id)target stopSelector:(SEL)selector;
- (void) dismissParentPopoverController;
- (UIViewController*) popoverParentViewController;
- (void) showActionSheetFromItem:(UIBarButtonItem*)item action:(UIActionSheet*)actionSheet;
- (void) dismissCurrentActionSheet;
- (UIPopoverController*) currentPopoverController;
- (UIBarButtonItem*)textBarItemWithText:(NSString*)string;
- (void) repopverCurrentPopoverViewController;
- (void) showPoperFromView:(UIView *)view arrowFromView:(UIView*)arrowView withContent:(UIViewController *)viewController;
- (UIActionSheet*) currentActionSheet;
- (void) setCurrentActionSheet:(UIActionSheet*)action;
@end

