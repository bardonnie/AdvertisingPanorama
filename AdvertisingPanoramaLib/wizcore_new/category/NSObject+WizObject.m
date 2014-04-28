//
//  NSObject+WizObject.m
//  WizIphone7
//
//  Created by dzpqzb on 13-8-31.
//  Copyright (c) 2013年 dzpqzb inc. All rights reserved.
//

#import "NSObject+WizObject.h"
#import <objc/runtime.h>
static void*  kWizObjectGroup = &kWizObjectGroup;
@implementation NSObject (WizObject)
@dynamic group;
- (void) setGroup:(WizGroup *)group
{
    objc_setAssociatedObject(self, kWizObjectGroup, group, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (WizGroup*) group
{
    return objc_getAssociatedObject(self, kWizObjectGroup);
}
@end
