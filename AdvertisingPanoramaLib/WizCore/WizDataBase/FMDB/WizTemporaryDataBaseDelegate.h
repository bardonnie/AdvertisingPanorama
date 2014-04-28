//
//  WizTemporaryDataBaseDelegate.h
//  Wiz
//
//  Created by 朝 董 on 12-4-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizObject.h"
@class WizAbstract;
@class WizSearch;
@protocol WizTemporaryDataBaseDelegate <NSObject>
- (BOOL) isAbstractExist:(NSString*)documentGuid;
- (WizAbstract*) abstractOfDocument:(NSString *)documentGUID;
- (BOOL) clearCache;
- (BOOL) deleteAbstractByGUID:(NSString *)documentGUID;
- (BOOL) deleteAbstractsByAccountUserId:(NSString*)accountUserID;
- (BOOL) updateAbstract:(NSString*)text imageData:(NSData*)imageData guid:(NSString*)guid type:(NSString*)type kbguid:(NSString*)kbguid;
//
- (BOOL) deleteWizSearch:(NSString *)keywords kbguid:(NSString*)kbguid;
- (BOOL) updateWizSearch:(WizSearch*)search;
- (NSArray*) allSearchByKbguid:(NSString*)kbguid;
@end
