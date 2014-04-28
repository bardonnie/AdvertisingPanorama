//
//  WizAccountManager.h
//  Wiz
//
//  Created by 朝 董 on 12-4-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


#define WizAcccountResignMessage @"resignActiveAccount" 

#define WGDefaultAccountUserId      getDefaultAccountUserId()
#define WGDefaultAccountPassword    getDefaultAccountPassword()

NSString* getDefaultAccountPassword();
NSString* getDefaultAccountUserId();
@class WizGroup;
/*
Account manager, store all the account data. provide active account user id and manage the active account. If you want to get the password of an ccount, you will use this class. The is class is designed using siglon pattern. 
*/
@interface WizAccountManager : NSObject
+ (WizAccountManager *) defaultManager;
- (NSArray*)            allAccountUserIds;
- (BOOL)                canFindAccount: (NSString*)userId;
- (NSString*)           accountPasswordByUserId:(NSString *)userID;
- (NSString*)   personalKbguidByUSerId:(NSString*)userId;
//
- (void)                registerActiveAccount:(NSString*)userId;
- (void)                resignAccount;
- (NSString*)           activeAccountUserId;
- (void) updateAccount:(NSString *)userId password:(NSString *)passwrod personalKbguid:(NSString *)kbguid;
- (void)                removeAccount: (NSString*)userId;
- (void) updateGroup:(WizGroup*)group froAccount:(NSString*)userId;
- (void) updateGroups:(NSArray*)groups forAccount:(NSString*)accountUserId;
- (NSArray*) groupsForAccount:(NSString*)userId;
- (WizGroup*) groupFroKbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
- (NSArray*) allGroupedGroupsForAccountUserId:(NSString*)accountUserId;
@end
