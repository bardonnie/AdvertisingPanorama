//
//  WizGlocalError.m
//  WizUIDesign
//
//  Created by dzpqzb on 13-1-27.
//  Copyright (c) 2013年 cn.wiz. All rights reserved.
//

#import "WizGlocalError.h"

NSString* const WizErrorDomain = @"cn.wiz.error";

@implementation WizGlocalError
+ (NSError*) noNetWorkError
{
    return [NSError errorWithDomain:WizErrorDomain code:WizNetworkErrorNoNetwork userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"No Internet connection avaiable", nil) forKey:NSLocalizedDescriptionKey]];
}
+ (NSError*) tokenUnActiveError
{
    return [NSError errorWithDomain:WizErrorDomain code:WizNetworkErrorTokenUnactiveError userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"Token 失效", nil) forKey:NSLocalizedDescriptionKey]];
}
@end
