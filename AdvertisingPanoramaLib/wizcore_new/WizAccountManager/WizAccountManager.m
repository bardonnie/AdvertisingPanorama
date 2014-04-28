//
//  WizAccountManager.m
//  Wiz
//
//  Created by 朝 董 on 12-4-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizAccountManager.h"
#import "WizFileManager.h"
#import "WizGlobalData.h"
#import "WizGlobals.h"
#import "WizSettings.h"
#import "WizLogger.h"

#import "WizObject.h"

#define KeyOfAccounts               @"accounts"
#define KeyOfUserId                 @"userId"
#define KeyOfPassword               @"password"

#define KeyOfDefaultUserId          @"defaultUserId"
#define KeyOfProtectPassword        @"protectPassword"
#define KeyOfKbguids                @"KeyOfKbguids"
#import "WizNotificationCenter.h"
#import "WizDownloadThread.h"
#import "WizXmlAccountServer.h"
#import "WizDBManager.h"
#import "WizSyncAccountThread.h"
#import "KeychainItemWrapper.h"
//
//
static NSString* const WizSettingAccountsArray = @"WizSettingAccountsArray";
static NSString* const WizSettingGuidToLocalFolder = @"WizSettingGuidToLocalFolder";
static NSString* const WizSettingIsExperiencing = @"WizSettingIsExperiencing";
static NSString* const KeyOfWizAccountPassword = @"KeyOfWizAccountPassword";
static NSString* const KeyOfWizAccountUserId = @"KeyOfWizAccountUserId";
static NSString* const KeyOfWizAccountPersonalKbguid = @"KeyOfWizAccountPersonalKbguid";
static NSString* const KeyOfWizAccountUserGuid = @"KeyOfWizAccountUserGuid";
//wenlin add
static NSString* const WizSettingIsFristLogin = @"WizSettingIsFristLogin";

NSString *_activeKbGuid= nil;
//
//
#define WGDefaultChineseUserName    @"groupdemo@wiz.cn"
#define WGDefaultChinesePassword    @"kk0x5yaxt1ey6v4n"

//
#define WGDefaultEnglishUserName    @"groupdemo@wiz.cn"
#define WGDefaultEnglishPassword    @"kk0x5yaxt1ey6v4n"

WizGroup* (^PersonalGroupForAccountUserId)(NSString*) = ^(NSString* userId)
{
    WizGroup* group = [[WizGroup alloc] init];
    group.guid = nil;
    group.accountUserId = userId;
    group.title = WizStrPersonalNotes;
    group.userGroup = 0;

    return group;
};

NSString* getDefaultAccountUserId()
{
    if ([WizGlobals isChineseEnviroment]) {
        return WGDefaultChineseUserName;
    }
    else
    {
        return WGDefaultEnglishUserName;
    }
}

NSString* getDefaultAccountPassword()
{
    if ([WizGlobals isChineseEnviroment]) {
        return WGDefaultChinesePassword;
    }
    else
    {
        return WGDefaultEnglishPassword;
    }
}
//
NSString* (^WizSettingsGroupsKey)(NSString*) = ^(NSString* accountUserId)
{
    return [@"WizGroupsLocal" stringByAppendingString:accountUserId];
};

NSString* (^WizSettingsCertKey)(NSString*) = ^(NSString* accountUserId)
{
    return [@"WizCert" stringByAppendingString:accountUserId];
};
//
@interface WizAccount (WizLocal)
- (NSDictionary*) toLocalModel;
- (void) fromLocalModel:(NSDictionary*)dic;
@end
@implementation WizAccount(WizLocal)
- (NSDictionary*) toLocalModel
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:3];
    if (self.accountUserId) {
        [dic setObject:self.accountUserId forKey:KeyOfWizAccountUserId];
    }
    if (self.password) {
        [dic setObject:self.password forKey:KeyOfWizAccountPassword];
    }
    if (self.personalKbguid) {
        [dic setObject:self.personalKbguid forKey:KeyOfWizAccountPersonalKbguid];
    }
    if (self.userGuid) {
        [dic setObject:self.userGuid forKey:KeyOfWizAccountUserGuid];
    }
    return dic;
}
- (void) fromLocalModel:(NSDictionary *)dic
{
    self.accountUserId = dic[KeyOfWizAccountUserId];
    self.password = dic[KeyOfWizAccountPassword];
    self.personalKbguid = dic[KeyOfWizAccountPersonalKbguid];
    self.userGuid = dic[KeyOfWizAccountUserGuid];
}
@end
//
@interface WizAccountManager()



@end

@implementation WizAccountManager

- (void) updateAccounts:(NSArray*)array
{
    if (array == nil) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:WizSettingAccountsArray];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray*) allAccounts
{
    NSArray* accounts = [[NSUserDefaults standardUserDefaults] arrayForKey:WizSettingAccountsArray];
    if (accounts == nil) {
        accounts = [NSArray array];
        [self updateAccounts:accounts];
    }
    return accounts;
}

-(void) updateGuidToLocalFolder:(NSDictionary *)dict{
    if (dict==nil)
        return;

    @synchronized (WizSettingGuidToLocalFolder) {
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:WizSettingGuidToLocalFolder];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
-(NSDictionary *)guidToLocalFolderDict{
    @synchronized (WizSettingGuidToLocalFolder) {
        NSDictionary *dictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:WizSettingGuidToLocalFolder];
        if (dictionary == nil) {
            dictionary = [NSDictionary dictionary];
            [self updateGuidToLocalFolder:dictionary];
        }
        return dictionary;
    }
}
- (void)updateGuid:(NSString *)userGuid toLocalFolder:(NSString *)localFolder {
    @synchronized (WizSettingGuidToLocalFolder) {
        NSMutableDictionary *dictionary= [NSMutableDictionary dictionaryWithDictionary:[self guidToLocalFolderDict]];
        [dictionary setObject:localFolder forKey:userGuid];
        [self updateGuidToLocalFolder:dictionary];
    }
}
- (NSString *)localFolderByGuid:(NSString *)userGuid {
    @synchronized (WizSettingGuidToLocalFolder) {
        NSDictionary *dictionary=[self guidToLocalFolderDict];
        NSString *result=[dictionary objectForKey:userGuid];
        return result;
    }
}
-(NSString *)userGuidByUserId:(NSString *)userId {
    NSArray* array = [self allAccounts];
    for (NSDictionary* each in array) {
        NSString* uid = each[KeyOfWizAccountUserId];
        if ([uid isEqualToString:userId]){
            return each[KeyOfWizAccountUserGuid];
        }
    }
    return nil;
}

-(void)fixGuidField{
    static BOOL hasFixed = NO;
    if (hasFixed)
        return;
    hasFixed = YES;
    NSArray *array = [self allAccounts];
    for (NSDictionary *each in array) {
        NSString *guid = each[KeyOfWizAccountUserGuid];
        if (guid == nil || [guid isEqualToString:@""]) {
            NSString *userId = each[KeyOfWizAccountUserId];
            NSString *userPwd = each[KeyOfWizAccountPassword];
            NSDictionary *dictionary = [[WizSettings defaultSettings] accountAttributes:userId];
            guid = [dictionary userGuid];
            if ([userId isEqualToString:[self activeAccountUserId]]) {
                [self updateAccount:userId password:userPwd personalKbguid:nil userGuid:guid];
            }
        }
    }
}




- (NSInteger) indexOfAccount:(NSString*)userId inArray:(NSArray*)array
{
    for (int i = 0 ; i < [array count] ; i++) {
        NSDictionary* each = [array objectAtIndex:i];
        NSString* accountUserId = [each objectForKey:KeyOfWizAccountUserId];
        if ([accountUserId isEqualToString:userId]) {
            return i;
        }
    }
    return NSNotFound;
}

- (void) updateAccount:(NSString *)userId
              password:(NSString *)passwrod
        personalKbguid:(NSString *)kbguid
              userGuid:(NSString *)userGuid
{
    WizAccount* account = [[WizAccount alloc] init];
    account.accountUserId = userId;
    account.password = passwrod;
    account.personalKbguid = kbguid;
    account.userGuid = userGuid;
    NSDictionary* accountDic = [account toLocalModel];
    NSMutableArray* array = [NSMutableArray arrayWithArray:[self allAccounts]];
    NSInteger indexOfAccount = [self indexOfAccount:userId inArray:array];
    if (indexOfAccount != NSNotFound) {
        [array removeObjectAtIndex:indexOfAccount];
    }
    [array insertObject:accountDic atIndex:0];
    [self updateAccounts:array];
}

- (BOOL) canFindAccount:(NSString *)userId
{
    NSMutableArray* array = [NSMutableArray arrayWithArray:[self allAccounts]];
    NSInteger indexOfAccount = [self indexOfAccount:userId inArray:array];
    if (indexOfAccount == NSNotFound) {
        return NO;
    }
    else
    {
        return YES;
    }
}


- (WizAccount*) accountFromUserId:(NSString*)userID
{
    NSArray* array = [self allAccounts];
    for (NSDictionary* each in array) {
        if ([each[KeyOfWizAccountUserId] isEqualToString:userID]) {
            WizAccount* account = [[WizAccount alloc] init];
            [account fromLocalModel:each];
            return account;
        }
    }
    return nil;
}

- (NSString*)accountPasswordByUserId:(NSString*)userId
{
    NSString* userID = [userId lowercaseString];
    WizAccount* account = [self accountFromUserId:userID];
    return account.password;
}

- (NSString*) activeAccountPassword
{
    NSString* userID = [[self activeAccountUserId] lowercaseString];
    WizAccount* account = [self accountFromUserId:userID];
    return account.password;
}

- (NSArray*)allAccountUserIds
{
    NSArray* array = [self allAccounts];
    NSMutableArray* accountsIDs = [NSMutableArray array];
    for (NSDictionary* each in array) {
        NSString* userID = each[KeyOfWizAccountUserId];
        [accountsIDs addObject:userID];
    }
    return accountsIDs;
}

- (NSInteger) indexOfGroup:(NSString*)kbguid inArray:(NSArray*)array
{
    for (int i = 0; i < [array count]; ++i) {
        NSDictionary* groupModel = [array objectAtIndex:i];
        if (kbguid == nil) {
            if (groupModel[KeyOfKbKbguid] == nil) {
                return i;
            }
        }
        if ([groupModel[KeyOfKbKbguid] isEqualToString:kbguid]) {
            return i;
        }
    }
    return NSNotFound;
}

- (void) updateGroups:(NSArray*)array accountUserId:(NSString *)userId
{
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:WizSettingsGroupsKey(userId)];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[WizNotificationCenter shareCenter] sendUpdateGroupsNotification:userId];
}

- (NSArray*) groupsLocalForAccount:(NSString *)userId
{
    NSArray* array = [[NSUserDefaults standardUserDefaults] arrayForKey:WizSettingsGroupsKey(userId)];
    if (array == nil) {
        array = [NSArray array];
        [self updateGroups:array accountUserId:userId];
    }
    return array;
}

- (NSArray*) groupsForAccount:(NSString *)userId
{
    NSArray* array = [self groupsLocalForAccount:userId];
    NSMutableArray* groups = [NSMutableArray array];
    for (NSDictionary* each in array) {
        WizGroup* group = [[WizGroup alloc] init];
        [group fromWizServerObject:each];
        group.accountUserId = userId;
        [groups addObject:group];
    }

    WizGroup* personalGroup = PersonalGroupForAccountUserId(userId);
    NSInteger index = [self indexOfGroup:personalGroup.guid inArray:array];
    if (index == NSNotFound) {
        [groups addObject:personalGroup];
    }
    //把个人群组 检测一边有没有 没有的话 加进返回列表
    return groups;
}

- (WizGroup*) groupFroKbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId
{
    if (kbguid == nil || [kbguid isEqualToString:WizGlobalPersonalKbguid]) {
        WizGroup* group = [[WizGroup alloc] init];
        group.title = WizStrPersonalNotes;
        group.userGroup = 0;
        group.guid = nil;
        group.accountUserId = accountUserId;
        return group;
    }
    NSArray* allGroups = [self groupsForAccount:accountUserId];
    for (WizGroup* group in allGroups) {
        if ([group.guid isEqualToString:kbguid]) {
            return group;
        }
    }
    return nil;
}

- (void) updateGroup:(WizGroup *)group froAccount:(NSString *)userId
{
    NSMutableArray* array = [NSMutableArray arrayWithArray:[self groupsLocalForAccount:userId]];
    NSInteger index = [self indexOfGroup:group.guid inArray:array];
    if (index != NSNotFound) {
        [array removeObjectAtIndex:index];
    }
    [array insertObject:[group toWizServerObject] atIndex:0];
    [self updateGroups:array accountUserId:userId];
}
////
- (void) updateGroups:(NSArray *)groups forAccount:(NSString *)accountUserId
{
    //添加个人群组
    NSMutableArray* array = [NSMutableArray array];
    for (WizGroup* group in groups) {
        NSDictionary* dic = [group toWizServerObject];
        [array addObject:dic];
    }
    WizGroup* group = PersonalGroupForAccountUserId(accountUserId);
    [array addObject:[group toWizServerObject]];
    [self updateGroups:array accountUserId:accountUserId];
}

- (id) init
{
    self = [super init];
    if (self) {

    }
    return self;
}
+ (id) defaultManager;
{
    static WizAccountManager* accoutManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       accoutManager = [WizGlobalData shareInstanceFor:[WizAccountManager class]];
    });
    return accoutManager;
}

- (NSString*) personalKbguidByUSerId:(NSString *)userId
{
    return [self accountFromUserId:userId].personalKbguid;
}
- (void) updateActiveAccontUserId:(NSString*)userId
{
    [[WizSettings defaultSettings]updateActiveAccountUserID:userId];
}

- (void)getLastActiveAccount
{
    if (![WizGlobals WizDeviceIsPad] && [[WizSettings defaultSettings]appearOnceKeyExist:@"GiveUpKeyChainItem"]) {
        KeychainItemWrapper*  akeyChainItemWrapper = [[KeychainItemWrapper alloc]initWithIdentifier:@"wiznoteiphone" accessGroup:nil];
        NSString* defaultUserId = [akeyChainItemWrapper objectForKey:(__bridge id)kSecAttrService];
        NSString* password = [akeyChainItemWrapper objectForKey:(__bridge id)kSecValueData];
        if (defaultUserId && [defaultUserId length] != 0 && password && [password length] != 0) {
            NSString* userGuid = [self accountGuidByUserId:defaultUserId];
            [self updateAccount:defaultUserId password:password personalKbguid:nil userGuid:userGuid];
            [self registerActiveAccount:defaultUserId];
        }
        [akeyChainItemWrapper resetKeychainItem];
    }
}

- (NSString*) activeAccountUserId
{
    [self getLastActiveAccount];
    return [[WizSettings defaultSettings]activeAccountUserId];
}

- (NSString*) accountGuidByUserId:(NSString *)userId
{
    NSDictionary* attribute = [[WizSettings defaultSettings] accountAttributes:userId];
    return [attribute userGuid];
}

- (NSString*) activeAccountGuid
{
    return [self accountGuidByUserId:[self activeAccountUserId]];
}

-(NSString *)activeKbGuid {
    if ([[self activeAccountUserId] isEqualToString:WGDefaultAccountUserId]){
        return nil;
    }
    return _activeKbGuid;
}
- (void)setActiveKbGuid:(NSString *)guid {
    if (guid == nil) {
        _activeKbGuid = WizGlobalPersonalKbguid;
    }
    else
    {
       _activeKbGuid=guid; 
    }
}


- (void) resignAccount:(NSString*)accountId
{
    [self updateActiveAccontUserId:nil];
    [WizSyncAccountThread clear:accountId];
    [WizAutoDownloadThread stopAutoDownload:accountId];
    //
}

- (void) registerActiveAccount:(NSString *)userId
{
//    //
    [self updateActiveAccontUserId:userId];
    NSMutableDictionary* activeUserInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    if (userId) {
        [activeUserInfo setObject:userId forKey:@"userId"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"registerActiveAccount" object:nil userInfo:activeUserInfo];
}

- (NSMutableArray*) allGroupedGroupsForPadForAccountUserId:(NSString *)accountUserId
{
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
    NSArray* groups = [self groupsForAccount:accountUserId];
    
    NSMutableArray* (^ArrayForBizName)(NSString*) = ^(NSString* bizName)
    {
    NSMutableArray* array = [dictionary objectForKey:bizName];
    if (!array) {
        array = [NSMutableArray array];
        [dictionary setObject:array forKey:bizName];
    }
    return array;
    };
    
    for (WizGroup* group in groups) {
        if ([group.bizName isEqualToString:WizStrPersonalNotes] || [group.bizName isEqualToString:WizStrPersonalGroups]) {
            group.bizName = NSLocalizedString(@"Personal Notes and Groups", nil);
        }
        NSMutableArray* array = ArrayForBizName(group.bizName);
        [array addObject:group];
    }
    NSMutableArray* array = [[dictionary allValues] mutableCopy];
    for (NSMutableArray* each in array) {
        [each sortUsingComparator:^NSComparisonResult(WizGroup* obj1, WizGroup* obj2) {
            if ([obj1.title isEqualToString:WizStrPersonalNotes] || [obj2.title isEqualToString:WizStrPersonalNotes]) {
                return NSOrderedDescending;
            }
            return [obj1.title compareByChinese:obj2.title];
        }];
    }
    //把个人笔记放到第一个
    //把个人群组放到最后一个
    NSArray* personalNotes = [NSArray array];
    [array sortUsingComparator:^NSComparisonResult(NSArray* obj1, NSArray* obj2) {
        return [[[obj1 lastObject] bizName] compareByChinese:[[obj2 lastObject] bizName]];
    }];
    for (NSArray* eachArray in array) {
        if ([[[eachArray lastObject]bizName] isEqualToString:NSLocalizedString(@"Personal Notes and Groups", nil)]) {
            personalNotes = eachArray;
        }
    }
    [array removeObject:personalNotes];
    [array insertObject:personalNotes atIndex:0];
    return array;
}

- (NSMutableArray*) allGroupedGroupsForAccountUserId:(NSString*)accountUserId
{
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
    NSArray* groups = [self groupsForAccount:accountUserId];
    
    NSMutableArray* (^ArrayForBizName)(NSString*) = ^(NSString* bizName)
    {
        NSMutableArray* array = [dictionary objectForKey:bizName];
        if (!array) {
            array = [NSMutableArray array];
            [dictionary setObject:array forKey:bizName];
        }
        return array;
    };
    
    for (WizGroup* group in groups) {
        NSMutableArray* array = ArrayForBizName(group.bizName);
        [array addObject:group];
    }
    NSMutableArray* array = [[dictionary allValues] mutableCopy];
    for (NSMutableArray* each in array) {
        [each sortUsingComparator:^NSComparisonResult(WizGroup* obj1, WizGroup* obj2) {
            return [obj1.title compareByChinese:obj2.title];
        }];
    }
    //把个人笔记放到第一个
    //把个人群组放到最后一个
    NSArray* personalNotes = [NSArray array];
    NSArray* personalGroups = [NSArray array];
    [array sortUsingComparator:^NSComparisonResult(NSArray* obj1, NSArray* obj2) {
        return [[[obj1 lastObject] bizName] compareByChinese:[[obj2 lastObject] bizName]];
    }];
    for (NSArray* eachArray in array) {
        if ([[[eachArray lastObject]bizName] isEqualToString:WizStrPersonalNotes]) {
            personalNotes = eachArray;
        }
        if ([[[eachArray lastObject]bizName] isEqualToString:NSLocalizedString(@"Personal Group", nil)]) {
            personalGroups = eachArray;
        }
    }
    [array removeObject:personalNotes];
    [array removeObject:personalGroups];
    [array insertObject:personalNotes atIndex:0];
    [array addObject:personalGroups];
    return array;
}

- (NSArray*) allGroupedBizGroupForAccountUsrId:(NSString*)accountUserId
{
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
    NSArray* groups = [self groupsForAccount:accountUserId];
    
    NSMutableArray* (^ArrayForBizName)(NSString*) = ^(NSString* bizName)
    {
        NSMutableArray* array = [dictionary objectForKey:bizName];
        if (!array) {
            array = [NSMutableArray array];
            [dictionary setObject:array forKey:bizName];
        }
        return array;
    };
    
    for (WizGroup* group in groups) {
        if ([self isBizGroup:group]) {
            NSMutableArray* array = ArrayForBizName(group.bizName);
            [array addObject:group];
        }
    }
    NSMutableArray* array = [[dictionary allValues] mutableCopy];
    for (NSMutableArray* each in array) {
        [each sortUsingComparator:^NSComparisonResult(WizGroup* obj1, WizGroup* obj2) {
            return [obj1.title compareByChinese:obj2.title];
        }];
    }
    return array;
}

- (WizCertData *) certData:(BOOL)refresh {
    NSString *password = [[WizAccountManager defaultManager] activeAccountPassword];
    NSString *userId = [self activeAccountUserId];
    WizCertData *cert= nil;
    NSDictionary *dictionary= [[NSUserDefaults standardUserDefaults] objectForKey:WizSettingsCertKey(userId)];
    if (dictionary==nil || refresh){
        WizXmlAccountServer *server= [[WizXmlAccountServer alloc] initWithUrl:[WizGlobals wizServerUrl]];
        cert = [server getCert:userId passwrod:password];
        [[NSUserDefaults standardUserDefaults] setObject:cert.dict forKey:WizSettingsCertKey(userId)];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else{
        cert= [[WizCertData alloc] init];
        [cert setDict:dictionary];
    }
    return cert;
}

-(void)clearCertData {
    NSString *userId = [self activeAccountUserId];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:WizSettingsCertKey(userId)] ;
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSString*) experienceAccountUserId
{
//    return @"dzpqzbdzpqzb@dzpqzb.com";
    return NSLocalizedString(@"Experience Account", nil);
}
- (void) setExperiencing:(BOOL)isExperiencing
{
    [[NSUserDefaults standardUserDefaults] setBool:isExperiencing forKey:WizSettingIsExperiencing];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (BOOL) isExperiencing
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:WizSettingIsExperiencing];
}

- (BOOL) ensureSaveExperienceDataToAccount:(NSString*)accountUserId
{
    if ([self isExperiencing]) {
        [self copyExperienceAccountFileTo:accountUserId];
        [self setExperiencing:NO];
        [self removeExperienceDirectory];
    }
    return YES;
}

- (BOOL) copyExperienceAccountFileTo:(NSString *)accountUserId
{
    NSString* experienceAccountUserId = [self experienceAccountUserId];
    NSString* experienceingAccountFilePath = [[WizFileManager shareManager] accountPathFor:experienceAccountUserId];
    NSString* toAccountPath = [[WizFileManager shareManager] accountPathFor:accountUserId];
    NSError* error = nil;
    if ([WizFileManager moveDirectory:experienceingAccountFilePath toDirectory:toAccountPath strategy:WizFileMoveStrategyCover error:&error]) {
        return YES;
    }
    else
    {
        DDLogError(@"move experiencing account error %@",error);
        return NO;
    }
}
- (BOOL) removeExperienceDirectory
{
    NSString* accountUserId = [self experienceAccountUserId];
    NSString* accountPath = [[WizFileManager shareManager] accountPathFor:accountUserId];
    NSError* error = nil;
//    if (![[WizFileManager shareManager] removeDirectory:accountPath error:&error] ) {
//        DDLogError(@"%@",error);
    if (![[WizFileManager shareManager] removeDirectory:accountPath error:&error]) {
        DDLogError(@"删除体验用户数据不成功==%@",error);
        [[WizFileManager shareManager] removeDirectory:accountPath error:&error];
        return NO;
    }
    else
    {
        return YES;
    }
    
}

- (NSArray*)allBizGroupsForAccount:(NSString*)accountUserId
{
    NSArray* allGroups = [self allGroupedGroupsForAccountUserId:accountUserId];
    NSMutableArray* bizGroups = [NSMutableArray array];
    for (NSArray* each in allGroups) {
        WizGroup* group = [each lastObject];
        if ([self isBizGroup:group]) {
            [bizGroups addObjectsFromArray:each];
        }
    }
    return bizGroups;
}

- (BOOL)isBizGroup:(WizGroup*)group
{
    if (group.bizName != nil && ![group.bizName isEqualToString:WizStrPersonalNotes] && ![group.bizName isEqualToString:NSLocalizedString(@"Personal Group", nil)]) {
        return YES;
    }
    return NO;
}

- (NSMutableArray*)allBizUsersAfterSortByBizGuid:(NSString*)bizGuid
{
    id<WizTemporaryDataBaseDelegate> tempDB = [WizDBManager temporaryDataBase];
    NSMutableArray* bizUsers = [NSMutableArray arrayWithArray:[tempDB bizUsersByBizGuid:bizGuid]];
    [bizUsers sortUsingComparator:^NSComparisonResult(WizBizUser* obj1, WizBizUser* obj2) {
        return [obj1.alias compareByChinese:obj2.alias];
    }];
    return bizUsers;
}

- (BOOL)isBizUserByAccount:(NSString*)accountUserId
{
    NSInteger count = [[self allBizGroupsForAccount:accountUserId] count];
    if (count) {
        return YES;
    }
    return NO;
}

- (NSArray*)messageIdsForLocalChanged:(NSString*)accountUserId readStatus:(WizMessageReadStatus)status
{
    id<WizTemporaryDataBaseDelegate> database = [WizDBManager temporaryDataBase];
    NSArray* sourceArray = [database messagesForLocalChanged:accountUserId];
    NSMutableArray* idsArray = [NSMutableArray array];
    for (WizMessage* eachMsg in sourceArray) {
        if (eachMsg.readStatus == status) {
            [idsArray addObject:@(eachMsg.messageId)];
        }
    }
    return idsArray;
}

@end
