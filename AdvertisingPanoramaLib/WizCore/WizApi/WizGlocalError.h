//
//  WizGlocalError.h
//  WizUIDesign
//
//  Created by dzpqzb on 13-1-27.
//  Copyright (c) 2013年 cn.wiz. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const WizErrorDomain;

typedef enum {
    WizNetworkErrorNoNetwork = 1001,
    WizNetworkErrorTokenUnactiveError
}WizNetworkError;
/**Global Error Class
 return the global errors.
 */
@interface WizGlocalError : NSObject
+ (NSError*) noNetWorkError;
+ (NSError*) tokenUnActiveError;
@end
