//
//  UIViewController+WizAppStatus.m
//  WizNote
//
//  Created by dzpqzb on 13-8-2.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "UIViewController+WizAppStatus.h"
#import "WizAppStatueCenter.h"
@implementation UIViewController (WizAppStatus)
- (void) triggerSyncGroupStatus
{
    [[WizAppStatueCenter shareInstance] triggleSyncGroupViewController:self];
}

- (void) removeTriggerSyncGroupStatus
{
    [[WizAppStatueCenter shareInstance] removeTriggleSyncGroupViewController:self];
}
@end
