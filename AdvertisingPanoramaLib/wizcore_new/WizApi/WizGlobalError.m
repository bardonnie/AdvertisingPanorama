//
//  WizGlobalError.m
//  WizUIDesign
//
//  Created by dzpqzb on 13-1-27.
//  Copyright (c) 2013年 cn.wiz. All rights reserved.
//

#import "WizGlobalError.h"
#import "WizGlobalData.h"
#import "WizAppStatueCenter.h"

static  float const WizGlobalAlertViewTagExperienceWizNote  = 4909;


@interface WizGlobalError()<UIAlertViewDelegate>
@property (nonatomic, assign) BOOL isShowingExperienceAlert;
@end
NSString* const WizErrorDomain = @"cn.wiz.error";

@implementation WizGlobalError
@synthesize isShowingExperienceAlert;
+ (id) shareInstance
{
    static WizGlobalError* error = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        error = [WizGlobalData shareInstanceFor:[WizGlobalError class]];
    });
    return error;
}
- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == WizGlobalAlertViewTagExperienceWizNote) {
        [[WizGlobalError shareInstance] setIsShowingExperienceAlert:NO];
        if (buttonIndex != alertView.cancelButtonIndex) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:WizWillRegisterAccountMessage object:nil];
        }
    }
}

+ (void) reportIsExperiencingWarning
{
    if (![WizGlobals WizDeviceIsPad]) {
        [[WizAppStatueCenter shareInstance] showGlobalErrorMessage:NSLocalizedString(@"Can't sync data without an account!", nil)];
    }else{
        [SVProgressHUD showImage:nil status:NSLocalizedString(@"Can't sync data without an account!", nil)];
    }
}

+ (NSError*) noNetWorkError
{
    return [NSError errorWithDomain:WizErrorDomain code:WizNetworkErrorNoNetwork userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"No Internet connection avaiable", nil) forKey:NSLocalizedDescriptionKey]];
}
+ (NSError*) tokenUnActiveError
{
    return [NSError errorWithDomain:WizErrorDomain code:WizNetworkErrorTokenUnactiveError userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"Token 失效", nil) forKey:NSLocalizedDescriptionKey]];
}

+ (NSError*) notExistDocumentError
{
    static NSError* error = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        error = [NSError errorWithDomain:WizErrorDomain code:501 userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Note does not exist!", nil)}];
    });
    return error;
}

+ (NSError*) unzipFileError
{
    static NSError* error = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        error = [NSError errorWithDomain:WizErrorDomain code:502 userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Unzip file error!", nil)}];
    });
    return error;
}

+ (NSError*) errorWithLocalizedString:(NSString*)localizedString
{
    return [NSError errorWithDomain:WizErrorDomain code:-89 userInfo:@{NSLocalizedDescriptionKey:localizedString}];
}
@end


