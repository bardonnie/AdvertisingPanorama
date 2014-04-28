//
//  WizSyncStatueCenter.h
//  WizIphoneClient
//
//  Created by dzpqzb on 13-1-10.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* const WizNetWorkStatue = @"WizNetWorkStatue";

/**Store all sync thread status, and show the network indication
 
 */
@interface WizSyncStatueCenter : NSObject
+ (WizSyncStatueCenter*) shareInstance;
- (void) changedKey:(NSString*)key statue:(NSInteger)state;
- (NSInteger) stateOfKey:(NSString*)key;
- (void) setSyncValue:(id)value forKey:(NSString*)key;
- (id) syncValueForKey:(NSString*)key;
@end
