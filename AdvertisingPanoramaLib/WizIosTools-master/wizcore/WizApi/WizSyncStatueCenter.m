//
//  WizSyncStatueCenter.m
//  WizIphoneClient
//
//  Created by dzpqzb on 13-1-10.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizSyncStatueCenter.h"
#import "WizGlobalData.h"
#import "WizLogger.h"
#import "WizNotificationCenter.h"
#import "WizAccountManager.h"
@interface WizSyncStatueCenter ()
@property (atomic, strong) NSMutableDictionary* stateDic;
@property (atomic, assign) int64_t networkInteractCount;
@end

@implementation WizSyncStatueCenter
@synthesize stateDic;
@synthesize networkInteractCount = _networkInteractCount;
- (void) dealloc
{
}

- (void)showNetworkIndicator:(BOOL)show
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = show;
}

- (void) showNetworkIndicator
{
    MULTIMAIN(^{
        if (_networkInteractCount > 0) {
            if (![UIApplication sharedApplication].networkActivityIndicatorVisible) {
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                [[NSNotificationCenter defaultCenter]postNotificationName:WizNetWorkActivityIndicatorStatueChanged object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:KeyOfIndicatorStatue]];
            }
        }
        else
        {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [[NSNotificationCenter defaultCenter]postNotificationName:WizNetWorkActivityIndicatorStatueChanged object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:KeyOfIndicatorStatue]];
        }
        if (_networkInteractCount == -1) {
            NSLog(@"error");
        }
    });
    
}

- (void) increaseNetworkInteractCount
{
    @synchronized(self)
    {
        _networkInteractCount ++;
        [self showNetworkIndicator];
    }
}

- (void) decreaseNetworInteractCount
{
    @synchronized(self)
    {
        _networkInteractCount --;
        [self showNetworkIndicator];
    }
}
- (void) setApplicationNetworkIndicator:(NSTimer*)timer
{
    @autoreleasepool {
        NSDate* date = [NSDate date];
        NSDate* lasteDate = [self syncValueForKey:WizNetWorkStatue];
        if (lasteDate) {
            if (abs([lasteDate timeIntervalSinceDate:date]) <= 1) {
                if (![UIApplication sharedApplication].networkActivityIndicatorVisible) {
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                }
            }
            else
            {
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            }
        }
    }

}

- (id) init
{
    self = [super init];
    if (self) {
        stateDic = [[NSMutableDictionary alloc] init];
        _networkInteractCount = 0;
    }
    return self;
}

+ (WizSyncStatueCenter*) shareInstance
{
    static WizSyncStatueCenter* statueCenter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        statueCenter = [WizGlobalData shareInstanceFor:[WizSyncStatueCenter class]];
    });
    return statueCenter;
}


- (void) setSyncValue:(id)value forKey:(NSString*)key
{
    [self.stateDic setValue:value forKey:key];
}

- (id) syncValueForKey:(NSString*)key
{
    return [self.stateDic valueForKey:key];
}
- (void) changedKey:(NSString*)key statue:(NSInteger)state
{
    if (key != nil) {
        [self.stateDic setObject:[NSNumber numberWithInteger:state] forKey:key];
    }
}

- (NSInteger) stateOfKey:(NSString*)key
{
    NSNumber* state = [self.stateDic objectForKey:key];
    if (state) {
        return [state integerValue];
    }
    else
    {
        return 0;
    }
}

- (int) kbSyncStatue:(NSString*)kbguid
{
    if (!kbguid) {
        kbguid = WizGlobalPersonalKbguid;
    }
    return [self stateOfKey:kbguid];
}
@end
