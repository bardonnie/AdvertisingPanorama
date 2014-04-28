//
//  WizGlobalError.h
//  WizUIDesign
//
//  Created by dzpqzb on 13-1-27.
//  Copyright (c) 2013年 cn.wiz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVProgressHUD.h"

extern NSString* const WizErrorDomain;

typedef enum {
    WizNetworkErrorNoNetwork = 1001,
    WizNetworkErrorTokenUnactiveError,
    WizErrorCodeInvalidPassword = 301
}WizNetworkError;
/**Global Error Class
 return the global errors.
 */
@interface WizGlobalError : NSObject
+ (NSError*) noNetWorkError;
+ (NSError*) tokenUnActiveError;
+ (NSError*) notExistDocumentError;
+ (NSError*) unzipFileError;
+ (void) reportIsExperiencingWarning;
+ (NSError*) errorWithLocalizedString:(NSString*)localizedString;
@end
