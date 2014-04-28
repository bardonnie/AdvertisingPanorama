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
#import "BWStatusBarOverlay.h"
#import "WizAccountManager.h"
@interface WizSyncStatueCenter () <WizSyncKbDelegate>
@property (atomic, strong) NSMutableDictionary* stateDic;
@end

@implementation WizSyncStatueCenter
@synthesize stateDic;
- (void) dealloc
{
    [[WizNotificationCenter shareCenter] removeObserver:self];
}
- (void) didSyncKbEnd:(NSString *)kbguid
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
    
//    NSString* message = [NSString stringWithFormat:NSLocalizedString(@"%@ sync succeed", nil),userInfo];
//       [BWStatusBarOverlay showSuccessWithMessage:message duration:2.0 animated:YES];
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
    
//    NSString* message = [NSString stringWithFormat:NSLocalizedString(@"%@ upload modifications succeed", nil),userInfo];
//    [BWStatusBarOverlay showSuccessWithMessage:message duration:2.0 animated:YES];
}


- (void) didSyncKbFaild:(NSString *)kbguid error:(NSError*)error
{
    [BWStatusBarOverlay showErrorWithMessage:[error localizedDescription] duration:1.5 animated:YES];
}


- (void) setApplicationNetworkIndicator:(NSTimer*)timer
{
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

- (id) init
{
    self = [super init];
    if (self) {
        stateDic = [[NSMutableDictionary alloc] init];
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [NSTimer scheduledTimerWithTimeInterval:0.9 target:self selector:@selector(setApplicationNetworkIndicator:) userInfo:nil repeats:YES] ;
            });
        });
        [[WizNotificationCenter shareCenter] addSyncKbObserver:self];
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
        [self.stateDic setObject:stateDic forKey:[NSNumber numberWithInt:state]];
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

@end
