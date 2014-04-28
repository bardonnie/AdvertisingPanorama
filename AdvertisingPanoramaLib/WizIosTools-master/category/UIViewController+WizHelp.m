//
//  UIViewController+WizHelp.m
//  WizNote
//
//  Created by dzpqzb on 13-4-3.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "UIViewController+WizHelp.h"
#import "UIColor+SSToolkitAdditions.h"
#import "SSDrawingUtilities.h"
#import "WizNavigationViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CIALBrowserViewController.h"
#import <objc/runtime.h>
#import "UIImage+WizTintColor.h"

static char _KeyWizFirstAppear;
static char _KeyWizOneTimersArray;

static char _KeyWizNavigationBarHidden;
static char _KeyWizToolbarHidden;

#define KeyWizNavigationBarHidden &_KeyWizNavigationBarHidden
#define KeyWizToolbarHidden &_KeyWizToolbarHidden
#define KeyWizFirstAppear &_KeyWizFirstAppear
#define KeyWizFirstLoad &_KeyWizFirstLoad 
#define KeyWizOneTimersArray &_KeyWizOneTimersArray


CGFloat CGPointDistance(CGPoint point1, CGPoint point2)
{
    return sqrt(pow((point2.x - point1.x), 2) + pow(point2.y -point2.y , 2 ));
}

CGFloat CGPointAngle(CGPoint point1, CGPoint point2)
{
    CGPoint point3 = CGPointMake(point1.y, point2.x);
    double c = CGPointDistance(point1, point2);
    double b = CGPointDistance(point1, point3);
    double a = CGPointDistance(point2, point3);
    return acos((b*b+c*c - a*a)/(2*b*c));
}

CGRect CGRectSetCenterY(CGRect rect, float height)
{
    return CGRectMake(CGRectGetMinX(rect), (CGRectGetHeight(rect) - height ) / 2, CGRectGetWidth(rect), height);
}

CGPoint CGCenterPoint(CGRect rect)
{
	return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

CGRect CGRectSetCenterX(CGRect rect, float width)
{
    return CGRectMake((CGRectGetWidth(rect) - width)/2, CGRectGetMinY(rect), width, CGRectGetHeight(rect));
}

CGRect CGRectSetBottomCenterX(CGRect rect , CGSize size)
{
    return CGRectMake((CGRectGetWidth(rect) - size.width) /2, CGRectGetHeight(rect) - size.height, size.width, size.height);
}


CGRect CGRectSetCenter(CGRect parentRect,CGSize size)
{
    return CGRectMake((CGRectGetWidth(parentRect) - size.width)/2, (CGRectGetHeight(parentRect) - size.height)/2, size.width, size.height);
}
CGPoint CGPointAddY(CGPoint point, float Y)
{
    return CGPointMake(point.x, point.y + Y);
}


CGPoint CGPointAddX(CGPoint point , float x)
{
    return CGPointMake(point.x + x, point.y);
}

CGRect CGRectGetOrientationRect(UIInterfaceOrientation ori, CGRect baseRect)
{
    CGRect rect = baseRect;
    float width_ = CGRectGetWidth(rect);
    float height_ = CGRectGetHeight(rect);
    
    float max = MAX(width_, height_);
    float min = MIN(width_, height_);
    if (UIInterfaceOrientationIsLandscape(ori)) {
        return CGRectSetSize(CGRectZero, CGSizeMake(max, min));
    }
    else
    {
        return CGRectSetSize(CGRectZero, CGSizeMake(min, max));
    }
}

CGRect CGRectGetMainScreen(UIInterfaceOrientation ori)
{
    return CGRectGetOrientationRect(ori, [UIScreen mainScreen].bounds);
}



@class WizTimer;

@interface WizTimer : NSObject
@property (nonatomic, assign) NSTimer* timer;
@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL selecotr;
@end
@implementation WizTimer

@synthesize timer = _timer;
@synthesize target = _target;
@synthesize selecotr = _selecotr;

+ (NSMutableArray*) getGlobalOneceTimerArray
{
    static NSMutableArray*  GlobalOneceTimerArray = nil;
    if (GlobalOneceTimerArray == nil) {
        GlobalOneceTimerArray = [NSMutableArray new];
    }
    return GlobalOneceTimerArray;
}

+ (void) removeGlobalOneceTimerByTarget:(id)target
{
    NSMutableArray* array = [[WizTimer getGlobalOneceTimerArray] copy];
    for (WizTimer* timer in array) {
        if ([timer.target isEqual:target]) {
            [timer.timer invalidate];
            [[WizTimer getGlobalOneceTimerArray] removeObject:timer];
        }
    }
}

+ (void) addGlobalOnceTimer:(id)target selector:(SEL)selector interval:(NSTimeInterval)interval
{
    WizTimer* timer = [[WizTimer alloc] initWithTarget:target selector:selector interval:interval];
    [[WizTimer getGlobalOneceTimerArray] addObject:timer];
}

- (void) excuteSelector
{
    SendSelectorToObjectInMainThreadWithoutParams(_selecotr, _target);
    [WizTimer removeGlobalOneceTimerByTarget:_target];
}

- (id) initWithTarget:(id)target selector:(SEL)sel interval:(NSTimeInterval)interval
{
    self = [super init];
    if (self) {
        NSTimer* onceTimer = [NSTimer timerWithTimeInterval:interval target:self selector:@selector(excuteSelector) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:onceTimer forMode:NSRunLoopCommonModes];
        _timer = onceTimer;
        _selecotr = sel;
        _target = target;
        
    }
    return self;
}
@end



@interface WizSwipView : UIView
{
    UISwipeGestureRecognizer* swipGestrue;
}
@end

@implementation WizSwipView
- (id) initWithTarget:(id)target selector:(SEL)sel
{
    self = [super init];
    if (self) {
        swipGestrue = [[UISwipeGestureRecognizer alloc] initWithTarget:target action:sel];
        swipGestrue.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:swipGestrue];
    }
    return self;
}
- (void) dealloc
{
    
}

@end


@implementation UIViewController (WizHelp)
@dynamic isFirstAppear;

- (void) setLastNavigationBarHidden:(BOOL)hidden
{
    objc_setAssociatedObject(self, KeyWizNavigationBarHidden, @(hidden), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL) lastNavigationBarHidden
{
    NSNumber* n = objc_getAssociatedObject(self, KeyWizNavigationBarHidden);
    return [n boolValue];
}

- (void) setLastToolbarHidden:(BOOL)hidden
{
    objc_setAssociatedObject(self, KeyWizToolbarHidden, @(hidden), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL) lastToolbarHidden
{
    NSNumber* n = objc_getAssociatedObject(self, KeyWizToolbarHidden);
    return [n boolValue];
}

- (void) loadNavigationBarHidden:(BOOL)navigationHidden toolbarHidden:(BOOL)toolHidden
{
    [self.navigationController setNavigationBarHidden:navigationHidden];
}

- (void) storeLastBarsHidden
{
    [self setLastNavigationBarHidden:self.navigationController.navigationBarHidden];
    [self setLastToolbarHidden:self.navigationController.toolbarHidden];
}

- (UIImage *)captureView:(UIView *)view
{
    CGRect screenRect = view.bounds;
    
    UIGraphicsBeginImageContext(screenRect.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //    CGContextTranslateCTM(ctx, screenRect.origin.x,  - self.view.bounds.size.height + screenRect.size.height);
    [[UIColor blackColor] set];
    CGContextFillRect(ctx, screenRect);
    
    [view.layer renderInContext:ctx];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}


- (void) restoreLastBarsHidden
{
    self.navigationController.navigationBarHidden =  [self lastNavigationBarHidden];
//    self.navigationController.toolbarHidden = [self lastToolbarHidden];
}

- (void) setIsFirstAppear:(BOOL)isFirstAppear
{
    objc_setAssociatedObject(self, KeyWizFirstAppear, [NSNumber numberWithBool:isFirstAppear], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView*) lineViewWithFrame:(CGRect)frame
{
    UIView* view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = WizColorByKind(ColorReadDocumentTitleLine);
    return view;
}

- (BOOL) isFirstAppear
{
    NSNumber* number = objc_getAssociatedObject(self, KeyWizFirstAppear);
    if (!number) {
        return YES;
    }
    return [number boolValue];
}
- (void) firstAppearPerformSelector:(SEL)aSelector
{
    if (self.isFirstAppear) {
        if ([self respondsToSelector:aSelector]) {
            SendSelectorToObjectInMainThreadWithoutParams(aSelector,self);
        }
        self.isFirstAppear = NO;
    }
}

- (void) setScheduledOneTimerArray:(NSMutableArray*)array
{
    objc_setAssociatedObject(self, KeyWizOneTimersArray, array, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray*) scheduledOneTimerArray
{
    NSMutableArray* array = objc_getAssociatedObject(self, KeyWizOneTimersArray);
    if (!array) {
        array = [NSMutableArray new];
        [self setScheduledOneTimerArray:array];
    }
    return array;
}

- (void) addScheduledOneTimeWithInterval:(NSTimeInterval)interval selector:(SEL)selector
{
    [WizTimer addGlobalOnceTimer:self selector:selector interval:interval];
}

static char WizDocumentInteractionController;

- (void) setCurrentDOcumentInteractionController:(UIDocumentInteractionController*)docVC
{
    objc_setAssociatedObject(self, &WizDocumentInteractionController, docVC, OBJC_ASSOCIATION_RETAIN);
}
- (void) invalidScheduledOnceTimer
{
    [WizTimer removeGlobalOneceTimerByTarget:self];
}

- (BOOL) showUrlFromInnerBrowser:(NSURL *)url
{
    if ([url isFileURL]) {
        NSString* filePath = [[url absoluteString] URLDecodedString];
        NSString* fielType = [filePath fileType];
        if (fielType && [WizGlobals checkAttachmentTypeIsAudio:fielType]) {
            if ([fielType isEqualToString:@"amr"]) {
                [WizGlobals reportWarningWithString:NSLocalizedString(@"This type audio can't open tempoprary.", nil)];
            } else {
                [self showOverlayView:url];
            }
//            else{
//                [[WizAudioManager shareInstance] startPlay:[url path]];
//            }
        } else {
            [self openAttachmentWithUrl:url];
        }
    } else {
        [self openAttachmentWithUrl:url];
    }
    return YES;
}

- (void)showOverlayView:(NSURL *)url{
    
}

- (void) openAttachmentWithUrl:(NSURL *)url{
    CIALBrowserViewController* browserVC = [[CIALBrowserViewController alloc]initWithURL:url];
    browserVC.isViewAttachment = YES;
    if (!iPad) {
        WizNavigationViewController* browserNavCon = [[WizNavigationViewController alloc]initWithRootViewController:browserVC];
//        [self.navigationController presentModalViewController:browserNavCon animated:YES];
        [self.navigationController presentViewController:browserNavCon animated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
        }];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenAttachmentInIpad" object:browserVC];
        //  [self presentWizModalViewController:browserVC];
    }
}

- (void) documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller
{
    [self setCurrentDOcumentInteractionController:nil];
}

- (void) documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application
{
    [self setCurrentDOcumentInteractionController:nil];
}

-(BOOL)openFileViewController:(NSURL *)file_url {
    if (file_url != nil) {
        UIDocumentInteractionController *fileInteractionController = [UIDocumentInteractionController interactionControllerWithURL:file_url];
        fileInteractionController.delegate = self;
        [fileInteractionController presentPreviewAnimated:YES];
        [self setCurrentDOcumentInteractionController:fileInteractionController];
    }
    return YES;
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)interactionController
{
    return self;
}

-(UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller{
    return self.view;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController*)controller
{
    return self.view.frame;
}


- (void)popWithAnimation
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
