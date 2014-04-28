//
//  NSObject+WizAddtionParams.m
//  WizNote
//
//  Created by dzpqzb on 13-4-16.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "NSObject+WizAddtionParams.h"
#import <objc/runtime.h>

static char _WizAddtionParamsGroup;
#define WizAddtionParamsGroup &_WizAddtionParamsGroup
@implementation NSObject (WizAddtionParams)
@dynamic  wizGroup;
- (WizGroup*) wizGroup
{
    return objc_getAssociatedObject(self, WizAddtionParamsGroup);
}

- (void) setWizGroup:(WizGroup *)wizGroup
{
    objc_setAssociatedObject(self, WizAddtionParamsGroup, wizGroup, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (id) initWithGroup:(WizGroup *)group
{
    self = [self init];
    if (self) {
        [self setWizGroup:group];
    }
    return self;
}
@end
