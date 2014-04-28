//
//  UIViewController+WizPopoverController.m
//  WizNote
//
//  Created by dzpqzb on 13-4-2.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "UIViewController+WizPopoverController.h"

#import <objc/runtime.h>


@interface WizPopoverBackgroudView : UIPopoverBackgroundView
@property (nonatomic, assign) UIPopoverArrowDirection direction;
@property (nonatomic, assign) CGFloat offSet;
@end
@implementation WizPopoverBackgroudView
@synthesize direction = _direction;
@synthesize offSet = _offSet;

- (CGFloat) arrowOffset
{
    return _offSet;
}

- (void) setArrowOffset:(CGFloat)arrowOffset
{
    _offSet = arrowOffset;
}

- (void) setArrowDirection:(UIPopoverArrowDirection)arrowDirection
{
    _direction = arrowDirection;
}

- (UIPopoverArrowDirection) arrowDirection
{
    return _direction;
}
- (void) layoutSubviews
{
    [super layoutSubviews];
    self.backgroundColor = [UIColor clearColor];
}
+ (UIEdgeInsets)contentViewInsets
{
    return UIEdgeInsetsMake(10, 0, 0, 0);
}

+ (CGFloat)arrowBase
{
    return 10;
}

+ (CGFloat)arrowHeight
{
    return 20;
}

@end

static char _WizPopoverViewControllerKey;
static char _WizPopoverParentViewControllerKey;
static char _WizViewControllerParentViewControllerKey;
static char _WizPopoverViewControllerFromItemKey;
static char _WizPopoverViewControllerFromRectKey;


#define WizPopoverViewControllerKey &_WizPopoverViewControllerKey
#define WizPopoverParentViewControllerKey &_WizPopoverParentViewControllerKey
#define WizViewControllerParentViewControllerKey &_WizViewControllerParentViewControllerKey
#define WizPopoverViewControllerFromItemKey &_WizPopoverViewControllerFromItemKey
#define WizPopoverViewControllerFromRectKey &_WizPopoverViewControllerFromRectKey
@interface UIPopoverController (WizPopover)
- (UIBarButtonItem*) currentPoppoverViewFromItem;
- (void)setCurrentPopoverViewFromItem:(UIBarButtonItem*)item;

- (CGRect) currentPoppoverViewFromRect;
- (void)setCurrentPopoverViewFromRect:(CGRect)rect;

- (void) setParentViewController:(UIViewController*)viewController;
- (UIViewController*) parentViewController;

- (void) setArrowFromView:(UIView*)viewx;
- (UIView*) arrowFromView;
@end
//
@interface UIViewController (WizRefresh)
- (void) showPoperFromBarItem:(UIBarButtonItem*)item withContent:(UIViewController*)viewController;
@end

//action sheet

static char _WizActionParentViewController;
#define WizActionParentViewController &_WizActionParentViewController

@interface UIActionSheet (WizActionSheet)
@property (nonatomic, assign) UIViewController* parentViewController;


@end

@implementation UIActionSheet (WizActionSheet)

@dynamic parentViewController;
- (void) setParentViewController:(UIViewController *)parentViewController
{
    objc_setAssociatedObject(self, WizActionParentViewController, parentViewController, OBJC_ASSOCIATION_ASSIGN);
}
- (UIViewController*) parentViewController
{
    return objc_getAssociatedObject(self, WizActionParentViewController);
}
@end

//
static char _WizActionSheetCurrentKey;
#define WizActionSheetCurrentKey &_WizActionSheetCurrentKey
@implementation UIViewController (WizRefresh)

- (UIActionSheet*) currentActionSheet
{
    return objc_getAssociatedObject(self, WizActionSheetCurrentKey);
}

- (void) setCurrentActionSheet:(UIActionSheet*)action
{
    objc_setAssociatedObject(self, WizActionSheetCurrentKey, action, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (void) showActionSheetFromItem:(UIBarButtonItem*)item action:(UIActionSheet*)actionSheet
{
    [self dismissCurrentActionSheet];
    [self dismissCurrentPopoverController];
    [self dismissParentPopoverController];
    [actionSheet showFromBarButtonItem:item animated:YES];
    [self setCurrentActionSheet:actionSheet];
}


- (void) dismissCurrentActionSheet
{
    UIActionSheet* currentSheet = [self currentActionSheet];
    if (currentSheet) {
        [currentSheet dismissWithClickedButtonIndex:currentSheet.cancelButtonIndex animated:YES];
        [self setCurrentActionSheet:nil];
    }
}

- (UIPopoverController*) currentPopoverController
{
    return  objc_getAssociatedObject(self, WizPopoverViewControllerKey);
}

- (void) setCurrentPopoverController:(UIPopoverController*)popover
{
    objc_setAssociatedObject(self, WizPopoverViewControllerKey, popover, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIViewController*) popoverParentViewController
{
    UIPopoverController* parentPopover = [[self _wiz_parentViewController] parentPopoverController];
    if (parentPopover) {
        UIViewController* parentVC = [parentPopover parentViewController];
        if (parentVC) {
            return parentVC;
        }
    }
    return nil;
}
- (void) dismissCurrentPopoverController
{
    UIPopoverController* popover = [self currentPopoverController];
    if (popover) {
        if ([popover isPopoverVisible]) {
           [popover dismissPopoverAnimated:YES]; 
        }
        [self setCurrentPopoverController:nil];
        [popover setParentViewController:nil];
    }
}

- (void) showPoperFromBarItem:(UIBarButtonItem *)item withContent:(UIViewController *)viewController
{
 
    [self dismissCurrentPopoverController];
    [self dismissCurrentActionSheet];
    [self dismissParentPopoverController];
    UIPopoverController* popover = [[UIPopoverController alloc] initWithContentViewController:viewController];
    [self setCurrentPopoverController:popover];
//    [popover setPopoverBackgroundViewClass:[UIPopoverBackgroundView class]];
    [popover presentPopoverFromBarButtonItem:item permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    [popover setParentViewController:self];
    [viewController setParentPopoverController:popover];
    [popover setCurrentPopoverViewFromItem:item];
}


- (void)showPoperFromView:(UIView*)view inRect:(CGRect)rect withContent:(UIViewController*)viewController
{
    [self dismissCurrentPopoverController];
    [self dismissCurrentActionSheet];
    [self dismissParentPopoverController];
    UIPopoverController* popover = [[UIPopoverController alloc] initWithContentViewController:viewController];
    [self setCurrentPopoverController:popover];
    [popover presentPopoverFromRect:rect inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    [popover setParentViewController:self];
    [popover setCurrentPopoverViewFromRect:rect];
    [viewController setParentPopoverController:popover];
}

- (void) showPoperFromView:(UIView *)view arrowFromView:(UIView*)arrowView withContent:(UIViewController *)viewController
{
    [self dismissCurrentPopoverController];
    [self dismissCurrentActionSheet];
    [self dismissParentPopoverController];
    UIPopoverController* popover = [[UIPopoverController alloc] initWithContentViewController:viewController];
    [self setCurrentPopoverController:popover];
    [popover presentPopoverFromRect:[view convertRect:arrowView.frame fromView:view] inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    [popover setParentViewController:self];
    popover.arrowFromView = arrowView;
    [viewController setParentPopoverController:popover];
}

- (UIViewController*) _wiz_parentViewController
{
    UIViewController* parentViewController = self.parentViewController;
    while (parentViewController) {
        if (parentViewController.parentViewController) {
            parentViewController = parentViewController.parentViewController;
        }
        else
        {
            break;
        }
    }
    return parentViewController;
}
- (void) dismissParentPopoverController
{
    [[[self _wiz_parentViewController] parentPopoverController]  dismissPopoverAnimated:NO];
}

- (UIBarButtonItem*) refreshBarItemWithTarget:(id)target selector:(SEL)selector
{
    UIBarButtonItem* barItem = [[UIBarButtonItem alloc]initWithImage:WizImageByKind(BarIconRefresh) style:UIBarButtonItemStyleBordered target:target action:selector];
    return barItem;
}

- (UIBarButtonItem*) activityBarItemWithTagrget:(id)target stopSelector:(SEL)selector
{
    UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [activityView startAnimating];
    [activityView sizeToFit];
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:activityView];
    [item setTarget:target];
    [item setAction:selector];
    return item;
}


- (void) setParentPopoverController:(UIPopoverController*)popover
{
    objc_setAssociatedObject(self, WizViewControllerParentViewControllerKey, popover, OBJC_ASSOCIATION_ASSIGN);
}
- (void) repopverCurrentPopoverViewController
{
    UIPopoverController* currentPopover = [self currentPopoverController];
    if (currentPopover && !currentPopover.currentPoppoverViewFromItem && currentPopover.isPopoverVisible) {
        [currentPopover dismissPopoverAnimated:NO];
        CGRect popoRect = [self.view convertRect:currentPopover.arrowFromView.frame toView:self.view];
        float currentWidth = UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? CGRectGetHeight([UIScreen mainScreen].bounds) : CGRectGetWidth([UIScreen mainScreen].bounds);
        if (currentWidth - CGRectGetMinX(popoRect) < 320) {
            popoRect.origin.x = currentWidth - 200;
        }
        [currentPopover presentPopoverFromRect:popoRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    }
    
}

- (UIPopoverController*) parentPopoverController
{
    UIPopoverController* p = objc_getAssociatedObject(self, WizViewControllerParentViewControllerKey);
    if ([p isKindOfClass:[UIPopoverController class]]) {
        return p;
    }
    return nil;
}

- (UIBarButtonItem*)textBarItemWithText:(NSString*)string
{
    UILabel* textLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
    textLabel.text = string;
    textLabel.font = [UIFont systemFontOfSize:17];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.backgroundColor = [UIColor clearColor];
    UIBarButtonItem* barItem = [[UIBarButtonItem alloc]initWithCustomView:textLabel];
    return barItem;
}

@end

static char _WizPopoverViewControllerArrowView;
#define WizPopoverViewControllerArrowView &_WizPopoverViewControllerArrowView

@implementation UIPopoverController (WizPopover)

- (void) setParentViewController:(UIViewController*)viewController
{
    objc_setAssociatedObject(self, WizPopoverParentViewControllerKey, viewController, OBJC_ASSOCIATION_ASSIGN);
}
- (void) setArrowFromView:(UIView*)view
{
    objc_setAssociatedObject(self, WizPopoverViewControllerArrowView, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIView*) arrowFromView
{
    return objc_getAssociatedObject(self, WizPopoverViewControllerArrowView);
}
- (UIViewController*) parentViewController
{
    return objc_getAssociatedObject(self, WizPopoverParentViewControllerKey);
}


- (UIBarButtonItem*) currentPoppoverViewFromItem
{
    return objc_getAssociatedObject(self, WizPopoverViewControllerFromItemKey);
}

- (void)setCurrentPopoverViewFromItem:(UIBarButtonItem *)item
{
    objc_setAssociatedObject(self, WizPopoverViewControllerFromItemKey, item, OBJC_ASSOCIATION_ASSIGN);
}

- (CGRect)currentPoppoverViewFromRect
{
    return [objc_getAssociatedObject(self, WizPopoverViewControllerFromRectKey) CGRectValue];
}
- (void)setCurrentPopoverViewFromRect:(CGRect)rect
{
    objc_setAssociatedObject(self, WizPopoverViewControllerFromRectKey, [NSValue valueWithCGRect:rect], OBJC_ASSOCIATION_RETAIN);
}

@end

