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

typedef enum {
    WizAccoutBizStateNoRegister,
    WizAccoutBizStateNewRegister,
    WizAccoutBizStateRegister,
}WizAccoutBizState;


NSString* getDefaultAccountPassword();
NSString* getDefaultAccountUserId();
@class WizGroup;
@class WizAccount;
/*
Account manager, store all the account data. provide active account user id and manage the active account. If you want to get the password of an ccount, you will use this class. The is class is designed using siglon pattern. 
*/
@interface WizAccountManager : NSObject
+ (WizAccountManager *)defaultManager;

- (void)updateAccount:(NSString *)userId
             password:(NSString *)passwrod
       personalKbguid:(NSString *)kbguid
             userGuid:(NSString *)userGuid;
- (NSArray*)allAccountUserIds;
- (BOOL)canFindAccount:(NSString*)userId;

- (NSString*)personalKbguidByUSerId:(NSString*)userId;
- (void)updateGuid:(NSString *)userGuid toLocalFolder:(NSString *)localFolder;
- (NSString *)localFolderByGuid:(NSString *)userGuid;

- (NSString *)userGuidByUserId:(NSString *)userId;
- (NSString*)accountGuidByUserId:(NSString*)userId;
- (void)fixGuidField;
- (NSString*)accountPasswordByUserId:(NSString*)userId;

//活跃账户信息
- (void)registerActiveAccount:(NSString*)userId;
- (NSString*)activeAccountUserId;
- (NSString*)activeAccountPassword;
- (NSString*)activeAccountGuid;
- (NSString *)activeKbGuid;

- (void)resignAccount:(NSString*)accountId;
- (void)setActiveKbGuid:(NSString *)guid;


- (void)updateGroup:(WizGroup*)group froAccount:(NSString*)userId;
- (void)updateGroups:(NSArray*)groups forAccount:(NSString*)accountUserId;
- (NSArray*) groupsForAccount:(NSString*)userId;
- (WizGroup*) groupFroKbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;

- (NSMutableArray*) allGroupedGroupsForAccountUserId:(NSString*)accountUserId;
- (NSMutableArray*) allGroupedGroupsForPadForAccountUserId:(NSString *)accountUserId;

- (WizCertData *) certData:(BOOL)refresh;
- (void) clearCertData;

//免注册体验账户
- (NSString*) experienceAccountUserId;
- (BOOL) isExperiencing;
- (void) setExperiencing:(BOOL)isExperiencing;
- (BOOL) copyExperienceAccountFileTo:(NSString*)accountUserId;
- (BOOL)removeExperienceDirectory;
- (BOOL) ensureSaveExperienceDataToAccount:(NSString*)accountUserId;

//biz群组
- (NSArray*)allBizGroupsForAccount:(NSString*)accountUserId;
- (NSMutableArray*)allBizUsersAfterSortByBizGuid:(NSString*)bizGuid;
- (NSArray*) allGroupedBizGroupForAccountUsrId:(NSString*)accountUserId;
- (WizAccount*) accountFromUserId:(NSString*)userID;
- (BOOL)isBizUserByAccount:(NSString*)accountUserId;

- (NSArray*)messageIdsForLocalChanged:(NSString*)accountUserId readStatus:(WizMessageReadStatus)status;
@end
