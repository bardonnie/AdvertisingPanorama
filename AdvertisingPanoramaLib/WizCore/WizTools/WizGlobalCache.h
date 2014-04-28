//
//  WizGlobalCache.h
//  WizCoreFunc
//
//  Created by dzpqzb on 12-12-24.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WizAbstract;
@interface WizGlobalCache : NSCache
- (void) clearCacheForDocument:(NSString*)guid;
+ (id) shareInstance;
- (WizAbstract*) abstractForDoc:(NSString*)docGuid accountUserId:(NSString*)accountUserId;
@end
