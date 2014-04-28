//
//  NSDate+WizTools.m
//  Wiz
//
//  Created by 朝 董 on 12-4-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSDate+WizTools.h"
#import "NSDate-Utilities.h"

@implementation NSDate (WizTools)
+ (NSDateFormatter*) shareSqlDataFormater
{
    static NSDateFormatter* shareSqlFormater = nil;
    if (!shareSqlFormater) {
        shareSqlFormater = [[NSDateFormatter alloc] init];
        [shareSqlFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return shareSqlFormater;
}

- (NSString*) stringYearAndMounth
{
    NSString* dateToLocalString = [self stringSql];
    if (nil == dateToLocalString || dateToLocalString.length <7) {
        return nil;
    }
    NSRange range = NSMakeRange(0, 7);
   return [dateToLocalString substringWithRange:range];
}
- (NSString*) stringLocal
{
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        NSLocale *locale = [NSLocale currentLocale];
        [dateFormatter setLocale:locale];
    }
    return [dateFormatter stringFromDate:self];
}
-(NSString*) stringSql
{
    NSDateFormatter* formatter = [NSDate shareSqlDataFormater];
	return [formatter stringFromDate:self];
}
- (NSString*) getDisplayText
{
    if ([self isToday]) {
        return [NSString stringWithFormat:@"%002d:%002d",[self hour],[self minute]];
    }
    else if ([self isYesterday])
    {
        return NSLocalizedString(@"Yesterday", nil);
    }
    else if ([self isThisWeek])
    {
        return NSLocalizedString(@"This Week", nil);
    }
    else if ([self isThisYear])
    {
        return [NSString stringWithFormat:@"%002d-%002d",[self month], [self day]];
    }
    else
    {
        return [self stringYearAndMounth];
    }
}
@end