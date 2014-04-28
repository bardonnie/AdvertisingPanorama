//
//  WizAppStatueCenter.m
//  WizNote
//
//  Created by dzpqzb on 13-8-2.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizAppStatueCenter.h"
#import "WizGlobalData.h"
#import "WizNotificationCenter.h"
#import "WizNavigationViewController.h"
#import <objc/runtime.h>
#import "WizAllNoteViewController.h"
#import "WizGlobalError.h"

static NSString* const kAnimationKindShow = @"kAnimationKindShow";
static NSString* const kAnimationKindHidden = @"kAnimationKindHidden";

static NSString* const kAnimationPosition = @"position";

static float const kAppStatusViewHeight = 44;

@interface CAAnimation (WizProperty)
@property (nonatomic, strong) NSString* kindTitle;
@end

@implementation CAAnimation(WizProperty)

@dynamic kindTitle;

- (void) setKindTitle:(NSString *)kindTitle
{
    [self setValue:kindTitle forKey:@"title"];
}

- (NSString*) kindTitle
{
    return [self valueForKey:@"title"];
}

@end

@interface WizAppStatueView : UIView
{
    UILabel* messageLabel;
}
@property (nonatomic, strong) NSString* messageText;
@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, assign) BOOL isShowing;
@end

@implementation WizAppStatueView
@synthesize messageText = _messageText;

- (id) init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    messageLabel = [UILabel new];
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.textAlignment = UITextAlignmentCenter;
    messageLabel.adjustsFontSizeToFitWidth = YES;
    messageLabel.textColor = [UIColor whiteColor];
    [self addSubview:messageLabel];
    
    return self;
}

- (void) layoutSubviews
{
    messageLabel.frame = self.bounds;
}

- (void) setMessageText:(NSString *)messageText
{
    _messageText = messageText;
    messageLabel.text  = messageText;
}

NSString* (^kAnimationKindTitle)(NSString*, NSString*) = ^(NSString* kind, NSString* title) {
    return [NSString stringWithFormat:@"%@=====%@",kind,title];
};

NSString* (^kAnimationKindFromTitle)(NSString*) = ^(NSString* title)
{
    NSArray* strs = [title componentsSeparatedByString:@"====="];
    NSString* ret = nil;
    if(strs.count == 2)
    {
        ret = strs[0];
    }
    return ret;
};


NSString* (^kAnimationKeyPathFromKindTitle)(NSString*) = ^(NSString* title)
{
    NSArray* strs = [title componentsSeparatedByString:@"====="];
    NSString* ret = nil;
    if(strs.count == 2)
    {
        ret = strs[1];
    }
    return ret;
};

BOOL (^IsAnimationConfirmKind)(NSString* title, NSString* kind) = ^(NSString* title, NSString* kind) {
    return [kAnimationKindFromTitle(title) isEqualToString:kind];
};

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([anim isKindOfClass:[CABasicAnimation class]]) {
        CABasicAnimation* a = (CABasicAnimation*)anim;
        if([kAnimationKeyPathFromKindTitle(a.kindTitle) isEqualToString:kAnimationPosition])
        {
            self.layer.position = [a.toValue CGPointValue];
        }
    }
}


@end


@interface UIViewController (WizAppStatues)
@property (nonatomic, strong) WizAppStatueView* statusView;
@property (nonatomic, strong, readonly) UIView* noScrollView;
@end

static void * kAssociatedObjectStatusView = &kAssociatedObjectStatusView;

@implementation UIViewController (WizAppStatues)
@dynamic statusView;
@dynamic noScrollView;
- (void) setStatusView:(WizAppStatueView *)statusView
{
    objc_setAssociatedObject(self, kAssociatedObjectStatusView, statusView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView*) noScrollView
{
    UIView* aView = self.view;
    //    if ([aView isKindOfClass:[UIScrollView class]]) {
    //        if (self.parentViewController) {
    //            return [self.parentViewController noScrollView];
    //        }
    //    }
    return aView;
}
- (WizAppStatueView*) statusView
{
    WizAppStatueView* appStatueView = objc_getAssociatedObject(self, kAssociatedObjectStatusView);
    if (!appStatueView) {
        appStatueView = [[WizAppStatueView alloc] init];
        appStatueView.backgroundColor = WizColorByKind(ColorOfDefaultTintColor);
        appStatueView.alpha = 0.9;
        appStatueView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        UIView* parentView = [self noScrollView];
        [parentView addSubview:appStatueView];
        [self setStatusView:appStatueView];
        appStatueView.frame = CGRectMake(0, CGRectGetHeight(parentView.frame), CGRectGetWidth(parentView.frame), 40);
    }
    return appStatueView;
}


- (void) animationDidStart:(CAAnimation *)anim
{
    CABasicAnimation* a = (CABasicAnimation*)anim;
    if([kAnimationKeyPathFromKindTitle(a.kindTitle) isEqualToString:kAnimationPosition])
    {
        NSString* kind = kAnimationKindFromTitle(a.kindTitle);
        if ([kind isEqualToString:kAnimationKindHidden]) {
            CGRect frame = self.noScrollView.frame;
            //
            float yoffset = [self animationStartPointYOffSet];
            CGRect fromRect = CGRectMake(0, CGRectGetHeight(frame)- kAppStatusViewHeight - yoffset, CGRectGetWidth(frame), kAppStatusViewHeight);
            CGRect toRect = CGRectOffset(fromRect, 0, kAppStatusViewHeight + 88);
            self.statusView.layer.position = CGCenterPoint(toRect);
        }
        else
        {
            self.statusView.layer.position = [a.toValue CGPointValue];
        }
    }
    self.statusView.isAnimating = YES;
}

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([anim isKindOfClass:[CABasicAnimation class]]) {
        self.statusView.isAnimating = NO;
        CABasicAnimation* a = (CABasicAnimation*)anim;
        self.statusView.isAnimating = NO;
        NSString* kind = kAnimationKindFromTitle(a.kindTitle);
        if ([kind isEqualToString:kAnimationKindShow]) {
            self.statusView.isShowing = YES;
        }
        else if ([kind isEqualToString:kAnimationKindHidden])
        {
            self.statusView.isShowing = NO;
        }
    }
}

- (CABasicAnimation*) animationRect:(CGRect)r1 toRect:(CGRect)r2
{
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:kAnimationPosition];
    CGPoint fromPoint = CGCenterPoint(r1);
    CGPoint toPoint = CGCenterPoint(r2);
    animation.fromValue = [NSValue valueWithCGPoint:fromPoint];
    animation.toValue = [NSValue valueWithCGPoint:toPoint];
    animation.duration = 0.5;
    animation.repeatCount = 1;
    animation.delegate = self;
    animation.removedOnCompletion = YES;
    return animation;
}

- (float) animationStartPointYOffSet
{
    float offY = 0;
    if ([self isKindOfClass:[UINavigationController class]]) {
        UINavigationController* nav = (UINavigationController*)self;
        if (!nav.toolbarHidden) {
            offY += CGRectGetHeight(nav.toolbar.frame);
        }
    }
    if (!DEVICE_VERSION_BELOW_7) {
        if ([self.parentViewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController* tabBarCon = (UITabBarController*)self.parentViewController;
            if (!tabBarCon.tabBar.isHidden) {
                offY += CGRectGetHeight(tabBarCon.tabBar.frame);
            }
        }
    }
    return offY;
}

- (CABasicAnimation*) showingAnimation
{
    
    CGRect frame = self.noScrollView.frame;
    CGRect fromRect = CGRectMake(0, CGRectGetHeight(frame) - [self animationStartPointYOffSet], CGRectGetWidth(frame), kAppStatusViewHeight);
    CGRect toRect = CGRectMake(0, CGRectGetHeight(frame) - [self animationStartPointYOffSet] - kAppStatusViewHeight, CGRectGetWidth(frame), kAppStatusViewHeight);
    CABasicAnimation* animation = [self animationRect:fromRect toRect:toRect];
    animation.kindTitle = kAnimationKindTitle(kAnimationKindShow, kAnimationPosition);
    
    return animation;
}

- (CABasicAnimation*) hiddingAnimation
{
    CGRect frame = self.noScrollView.frame;
    //
    float yoffset = [self animationStartPointYOffSet];
    CGRect fromRect = CGRectMake(0, CGRectGetHeight(frame)- kAppStatusViewHeight - yoffset, CGRectGetWidth(frame), kAppStatusViewHeight);
    CGRect toRect = CGRectOffset(fromRect, 0, kAppStatusViewHeight + 88);
    CABasicAnimation* animation = [self animationRect:fromRect toRect:toRect];
    animation.kindTitle = kAnimationKindTitle(kAnimationKindHidden, kAnimationPosition);
    //
    return animation;
}

- (void) doShow:(NSString*)text delayTime:(double)delayTime
{
    WizAppStatueView* statusView = self.statusView;
    statusView.messageText = text;
    statusView.bounds = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kAppStatusViewHeight);
    if (self.statusView.isAnimating || self.statusView.isShowing) {
        return;
    }
    if ([self isKindOfClass:[UINavigationController class]]) {
        UINavigationController* nav = (UINavigationController*)self;
        [nav.view insertSubview:statusView belowSubview:nav.toolbar];
        
    }
    else
    {
        [self.view addSubview:statusView];
        [self.statusView.superview bringSubviewToFront:statusView];
    }
    //
    float timeBase = CACurrentMediaTime();
    CABasicAnimation* showingAnimation = [self showingAnimation];
    
    //
    showingAnimation.beginTime = timeBase;
    //
    double delayInSeconds = delayTime;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        CABasicAnimation* hiddenAnimation = [self hiddingAnimation];
        [statusView.layer addAnimation:hiddenAnimation forKey:@"hidden"];
    });
    [statusView.layer addAnimation:showingAnimation forKey:@"aa"];
    
}

- (void) showWizAppStatusViewWithMessage:(NSString *)text delayTime:(double)delayTime
{
    if ([self conformsToProtocol:@protocol(UIViewControllerISShowing)]) {
        id<UIViewControllerISShowing> trigger = (id<UIViewControllerISShowing>)self;
        if ([[(UINavigationController*)trigger topViewController] isKindOfClass:[WizAllNoteViewController class]]) {
        }
        if (trigger.isVisibling) {
            [self doShow:text delayTime:delayTime];
        }
    }
    else
    {
        [self doShow:text delayTime:delayTime];
    }
}


@end

static NSString* const kTriggerStatusSync = @"kTriggerStatusSync";

@interface WizAppStatueCenter () <WizSyncKbDelegate,
WizMessageSyncProtocol,
WizSyncAccountDelegate,
WizAutoDownloadDelegate>
{
    NSMutableDictionary* trigglersMap;
    
    NSMutableDictionary* _dataMaps;
}
@property (nonatomic, strong, readonly) NSMutableSet* statusSyncTrigglers;
@end

@implementation WizAppStatueCenter

@synthesize statusSyncTrigglers;

- (NSMutableSet*) statusSyncTrigglers
{
    NSMutableSet* trigglers = [trigglersMap objectForKey:kTriggerStatusSync];
    if (!trigglers) {
        trigglers = [NSMutableSet new];
        [trigglersMap setObject:trigglers forKey:kTriggerStatusSync];
    }
    return trigglers;
}
- (id) init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    trigglersMap = [NSMutableDictionary new];
    _dataMaps = [NSMutableDictionary new];
    [[WizNotificationCenter shareCenter] addSyncKbObserver:self];
    [[WizNotificationCenter shareCenter] addSyncWizMessageObserver:self];
    [[WizNotificationCenter shareCenter] addSyncAccountObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeAccountPassword:) name:WizErrorMessageUserPasswordInvalid object:nil];
    [[WizNotificationCenter shareCenter] addAutoDownloadObserver:self];
    return self;
}

+ (WizAppStatueCenter*) shareInstance
{
    static WizAppStatueCenter* share = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [WizGlobalData shareInstanceFor:[WizAppStatueCenter class]];
    });
    return share;
}

- (void) triggleSyncGroupViewController:(UIViewController*)viewController
{
    [self.statusSyncTrigglers addObject:viewController];
}

- (void) removeTriggleSyncGroupViewController:(UIViewController*)vc
{
    [self.statusSyncTrigglers removeObject:vc];
}

- (void) triggleSyncGroupMessage:(NSString*)text delayTime:(double)delayTime
{
    for (UIViewController* each  in self.statusSyncTrigglers) {
        BOOL isFileSizeLimit = [[NSUserDefaults standardUserDefaults] boolForKey:@"FileSizeLimit"];
        if (isFileSizeLimit) {
            [each showWizAppStatusViewWithMessage:NSLocalizedString(@"Your notes exceeds the maximum upload size limit, you can not upload to the server!", nil) delayTime:5];
        }else{
            [each showWizAppStatusViewWithMessage:text delayTime:delayTime];
        }
    }
}


- (void)didSyncAccountSucceed:(NSString *)accountUserId
{
    [self performSelectorOnMainThread:@selector(showSyncSuccessMessage) withObject:nil waitUntilDone:YES];
}

- (void)showSyncSuccessMessage
{
    BOOL isFileSizeLimit = [[NSUserDefaults standardUserDefaults] boolForKey:@"FileSizeLimit"];
    if (isFileSizeLimit) {
        [self triggleSyncGroupMessage:NSLocalizedString(@"Your notes exceeds the maximum upload size limit, you can not upload to the server!", nil) delayTime:5];
//        [SVProgressHUD showImage:nil status:NSLocalizedString(@"Your notes exceeds the maximum upload size limit, you can not upload to the server!",nil)];
    }else{
        [self triggleSyncGroupMessage:NSLocalizedString(@"Sync succeed", nil) delayTime:1.5];
    }
}

- (void)didBeginAutoDownload:(NSString *)guid
{
}

- (void)didEndAutoDownload:(NSString *)guid count:(NSNumber *)count
{
    if ([guid isEqualToString:WizNotificationUserInfoKbguid]) {
        if ([count integerValue] > 0) {
            [self triggleSyncGroupMessage:NSLocalizedString(@"Sync notes successfully", nil) delayTime:1.5];
        }
    }
}

- (void) didUploadEnd:(NSString *)kbguid
{
    NSString* userInfo = nil;
    NSString* accountUserId = [[WizAccountManager defaultManager] activeAccountUserId];
    if ([kbguid isEqualToString:WizGlobalPersonalKbguid]) {
        userInfo = @"";
    }
    else
    {
        WizGroup* group = [[WizAccountManager defaultManager] groupFroKbguid:kbguid accountUserId:accountUserId];
        userInfo = group.title;
    }
    //
    NSString* message = [NSString stringWithFormat:NSLocalizedString(@"%@ upload modifications succeed", nil),userInfo];
    [self triggleSyncGroupMessage:message delayTime:1.5];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"wizUploadSucceed" object:nil];
}

- (void) didChangeAccountPassword:(NSNotification*)nc
{
    [self performSelectorOnMainThread:@selector(showPassworError) withObject:nil waitUntilDone:YES];
}

- (void)showPassworError
{
    //    [self triggleSyncGroupMessage:NSLocalizedString(@"Invalid password", nil) delayTime:5.0];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:WizStrError
                                                    message:NSLocalizedString(@"Password did not match, please login again.", nil)
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:WizStrOK, nil];
    NSLog(@"numberOfButtons:%d",alert.numberOfButtons);
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [[WizAudioManager shareInstance] stopRecord];
    [[WizAudioManager shareInstance] stopPlay:nil];
    if (!iPad) {
        [[Wiz7RootViewController rootViewController] showGuidViewControllerFromHead:NO];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:WizAcccountResignMessage object:nil userInfo:nil];
    }
}

NSString* (^kMessageCountDataByAccountUserId)(NSString*) = ^(NSString* accountUserId) {
    return [NSString stringWithFormat:@"messagecount%@", [accountUserId lowercaseString]];
};

- (int64_t) currentMessageCountOfAccountUserId:(NSString*)accountUserId
{
    id<WizTemporaryDataBaseDelegate> db = [WizDBManager temporaryDataBase];
    return  [db messageTotalCountOfAccountUserId:accountUserId];
}
//
- (void) didSyncMessageStart:(NSString *)accountUserId
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void)
                   {
                       [_dataMaps setObject:@([self currentMessageCountOfAccountUserId:accountUserId]) forKey:kMessageCountDataByAccountUserId(accountUserId)];
                   });
}
//
- (void) didSyncMessageEnd:(NSString *)accountUserId
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        int64_t oldMessageCount = [[_dataMaps objectForKey:kMessageCountDataByAccountUserId(accountUserId)] longLongValue];
        int64_t curMessageCount = [self currentMessageCountOfAccountUserId:accountUserId];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (curMessageCount - oldMessageCount > 0)
            {
                [self triggleSyncGroupMessage:[NSString stringWithFormat: NSLocalizedString(@"Sync %lld messages from server", nil), (curMessageCount - oldMessageCount)] delayTime:1.5];
            }
        });
    });
}


- (void) showGlobalErrorMessage:(NSString*)errorMessages
{
    [self triggleSyncGroupMessage:errorMessages delayTime:1.5];
}


@end