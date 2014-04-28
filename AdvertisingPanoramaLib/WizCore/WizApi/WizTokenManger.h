//
//  WizTokenManger.h
//  WizUIDesign
//
//  Created by dzpqzb on 13-1-23.
//  Copyright (c) 2013年 cn.wiz. All rights reserved.
//

#import <Foundation/Foundation.h>

/**Manager the glocal token and kb's url
 */
@interface WizTokenAndKapiurl : NSObject
@property (nonatomic, strong) NSString* token;
@property (nonatomic, strong) NSString* kApiUrl;
@property (nonatomic, strong) NSString* guid;
@end
@interface WizTokenManger : NSObject
+ (id) shareInstance;
- (WizTokenAndKapiurl*) tokenUrlForAccountUserId:(NSString *)accountUserId  kbguid:(NSString*)kbguid error:(NSError**)error;
@end
