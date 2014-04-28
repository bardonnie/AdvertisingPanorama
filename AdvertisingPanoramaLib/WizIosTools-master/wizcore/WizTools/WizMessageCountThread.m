//
//  WizMessageCountThread.m
//  WizNote
//
//  Created by dzpqzb on 13-7-12.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizMessageCountThread.h"

@interface WizMessageCountThread () <WizMessageChangedProtocol>
{
    NSMutableSet* commondSet;
}
@end

@implementation WizMessageCountThread

- (void) didMessageChange:(NSString *)messageId accountUserId:(NSString *)accountUserId
{
    [self addCommand:accountUserId];
}

- (void) addCommand:(NSString*)accountUserId
{
    @synchronized(commondSet)
    {
        if (accountUserId) {
            [commondSet addObject:accountUserId];
        }
    }
}
- (NSString*) anyCommand
{
    @synchronized(commondSet)
    {
        return [commondSet anyObject];
    }
}
- (void) removeCommand:(NSString*)accountUserId
{
    @synchronized(commondSet)
    {
        if (accountUserId) {
            [commondSet removeObject:accountUserId];
        }
    }
}
- (void) dealloc
{
    [[WizNotificationCenter shareCenter] removeObserver:self];
}
- (id) init
{
    self = [super init];
    if (self) {
        commondSet = [NSMutableSet new];
        [[WizNotificationCenter shareCenter] addMessageChangedObserver:self];
    }
    return self;
}

- (void) main
{
    while (true) {
        @autoreleasepool {
            NSString* accountUserId = [self anyCommand];
            if (accountUserId) {
                id<WizTemporaryDataBaseDelegate> db = [WizDBManager temporaryDataBase];
                NSDictionary* dic = [db unreadCountDictionary:accountUserId];
                if (dic) {
                    [[WizGlobalCache shareInstance] setUnreadCountDictionary:dic accountUserId:accountUserId];
                }
                [self removeCommand:accountUserId];
            }
            else
            {
//                wenlin  start
                [NSThread sleepForTimeInterval:10];
//                [NSThread sleepForTimeInterval:1];
//                wenlin  end
            }
        }
    }
}

@end

