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
    @synchronized(formatter)
    {
        return [formatter stringFromDate:self];
    }
}
- (NSString*) getDisplayText
{
    time_t current = [self timeIntervalSince1970];
    struct tm tmCurrent;
    localtime_r(&current, &tmCurrent);
    time_t now = time(NULL);
    struct tm tmNow;
    localtime_r(&now, &tmNow);
    //
    struct tm tmYesterday1 = tmNow;
    tmYesterday1.tm_hour = 0;
    tmYesterday1.tm_min = 0;
    tmYesterday1.tm_sec = 0;
    time_t yesterday1 = mktime(&tmYesterday1);
    time_t yesterday2 = yesterday1 - 24 * 60 * 60;
    
    if (tmNow.tm_year == tmCurrent.tm_year
        && tmNow.tm_mon == tmCurrent.tm_mon
        && tmNow.tm_mday  == tmCurrent.tm_mday){
        return [NSString stringWithFormat:@"%@ %002d:%002d",NSLocalizedString(@"Today", nil),tmCurrent.tm_hour,tmCurrent.tm_min];
    }
    else if(current >= yesterday2
             && current < yesterday1){
        return [NSString stringWithFormat:@"%@ %002d:%002d", NSLocalizedString(@"Yesterday", nil),tmCurrent.tm_hour,tmCurrent.tm_min];
    }
    else if([self thisWeek]){
        return [NSString stringWithFormat:@"%@%@ %002d-%002d %002d:%002d ", NSLocalizedString(@"This Week", nil),[self str:tmCurrent.tm_wday],tmCurrent.tm_mon + 1,tmCurrent.tm_mday,tmCurrent.tm_hour,tmCurrent.tm_min];
    }
    
    else if([self lastWeek]){
        return [NSString stringWithFormat:@"%@%@ %002d-%002d %002d:%002d ", NSLocalizedString(@"Last Week", nil),[self str:tmCurrent.tm_wday],tmCurrent.tm_mon + 1,tmCurrent.tm_mday,tmCurrent.tm_hour,tmCurrent.tm_min];
    }
    
    else {
        return [NSString stringWithFormat:@"%002d-%002d-%002d",tmCurrent.tm_year + 1900, tmCurrent.tm_mon + 1,tmCurrent.tm_mday];
    }
    
    
//    if ([self isToday]) {
//        return [NSString stringWithFormat:@"%002d:%002d",[self hour],[self minute]];
//    }
//    else if ([self isYesterday])
//    {
//        return NSLocalizedString(@"Yesterday", nil);
//    }
//    else if ([self isThisWeek])
//    {
//        return NSLocalizedString(@"This Week", nil);
//    }
//    else if ([self isThisYear])
//    {
//        return [NSString stringWithFormat:@"%002d-%002d",[self month], [self day]];
//    }
//    else
//    {
//        return [self stringYearAndMounth];
//    }
}

- (NSString* )str:(int) wday
{
    NSString *str = @"";
    switch (wday) {
        case 0:
            str = @"日";
            break;
        case 1:
            str = @"一";
            break;
        case 2:
            str = @"二";
            break;
        case 3:
            str = @"三";
            break;
        case 4:
            str = @"四";
            break;
        case 5:
            str = @"五";
            break;
        case 6:
            str = @"六";
            break;
        default:
            break;
    }
    return str;
}

- (long)getMonday:(long) date{
    struct tm tmCurrent;
    localtime_r(&date, &tmCurrent);
    tmCurrent.tm_hour=0;
    tmCurrent.tm_min=0;
    tmCurrent.tm_sec=0;
    tmCurrent.tm_isdst=0;
    
    time_t t_of_day = mktime(&tmCurrent);
    int week = tmCurrent.tm_wday;
    if(week == 0) week = 7;
    int day = week - 1;
    t_of_day -= day*24*3600;
    return t_of_day;
}

- (BOOL) thisWeek
{
    time_t current = [self timeIntervalSince1970];
    time_t now = time(NULL);
    if ([self getMonday:current] == [self getMonday:now]) {
        return YES;
    }else{
        return NO;
    }
}

- (BOOL) lastWeek
{
    time_t current = [self timeIntervalSince1970] + 24 * 60 * 60 * 7;
    time_t now = time(NULL);
    if ([self getMonday:current] == [self getMonday:now]) {
        return YES;
    }else{
        return NO;
    }
}

@end