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

#import "WizObject.h"

#define KeyOfAccounts               @"accounts"
#define KeyOfUserId                 @"userId"
#define KeyOfPassword               @"password"

#define KeyOfDefaultUserId          @"defaultUserId"
#define KeyOfProtectPassword        @"protectPassword"
#define KeyOfKbguids                @"KeyOfKbguids"
#import "WizNotificationCenter.h"
#import "WizDownloadThread.h"



//
//
static NSString* const WizSettingAccountsArray = @"WizSettingAccountsArray";

static NSString* const KeyOfWizAccountPassword = @"KeyOfWizAccountPassword";
static NSString* const KeyOfWizAccountUserId = @"KeyOfWizAccountUserId";
static NSString* const KeyOfWizAccountPersonalKbguid = @"KeyOfWizAccountPersonalKbguid";
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
        [dic setObject:self.password forKey:KeyOfWizAccountPersonalKbguid];
    }
    return dic;
}
- (void) fromLocalModel:(NSDictionary *)dic
{
    self.accountUserId = dic[KeyOfWizAccountUserId];
    self.password = dic[KeyOfWizAccountPassword];
    self.personalKbguid = dic[KeyOfWizAccountPersonalKbguid];
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

- (void) updateAccount:(NSString *)userId password:(NSString *)passwrod personalKbguid:(NSString *)kbguid
{
    WizAccount* account = [[WizAccount alloc] init];
    account.accountUserId = userId;
    account.password = passwrod;
    account.personalKbguid = kbguid;
    NSDictionary* accountDic = [account toLocalModel];
    NSMutableArray* array = [NSMutableArray arrayWithArray:[self allAccounts]];
    NSInteger indexOfAccount = [self indexOfAccount:userId inArray:array];
    if (indexOfAccount != NSNotFound) {
        [array removeObjectAtIndex:indexOfAccount];
    }
    [array insertObject:accountDic atIndex:0];
    [self updateAccounts:array];
}


- (void) removeAccount:(NSString *)userId
{
    NSMutableArray* array = [NSMutableArray arrayWithArray:[self allAccounts]];
    NSInteger indexOfAccount = [self indexOfAccount:userId inArray:array];
    if (indexOfAccount != NSNotFound) {
        [array removeObjectAtIndex:indexOfAccount];
    }
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

- (NSString*) accountPasswordByUserId:(NSString *)userID
{
    userID = [userID lowercaseString];
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
    if (kbguid == nil) {
        WizGroup* group = [[WizGroup alloc] init];
        group.title = NSLocalizedString(@"My Knowlaghe", nil);
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
        //        [self updateAccount:WGDefaultChineseUserName password:WGDefaultChinesePassword];
        //        [self updateAccount:WGDefaultEnglishUserName password:WGDefaultEnglishPassword];
        [self upgradeAccountSettings];
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
    return [[WizSettings defaultSettings] updateActiveAccountUserID:userId];
}

- (NSString*) activeAccountUserId
{
    NSString* activeUserId = [[WizSettings defaultSettings] activeAccountUserId];
    //    if (activeUserId == nil) {
    //        return WGDefaultAccountUserId;
    //    }
    return activeUserId;
}
- (void) resignAccount
{
    NSMutableDictionary* activeAccountUserInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    NSString* preUserId = [self activeAccountUserId];
    if (preUserId) {
        [activeAccountUserInfo setObject:preUserId forKey:@"userId"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WizAcccountResignMessage object:nil userInfo:activeAccountUserInfo];
    [self updateActiveAccontUserId:WGDefaultAccountUserId];
    //
}
- (void) registerActiveAccount:(NSString *)userId
{
//    [self resignAccount];
    [self updateActiveAccontUserId:userId];
    //
    NSMutableDictionary* activeUserInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    if (userId) {
        [activeUserInfo setObject:userId forKey:@"userId"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"registerActiveAccount" object:nil userInfo:activeUserInfo];
    
    
}

- (NSArray*) allGroupedGroupsForAccountUserId:(NSString*)accountUserId
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

- (void) upgradeAccountSettings
{
    //    NSString* dbPath = [[WizFileManager documentsPath] stringByAppendingPathComponent:@"accounts.db"];
    //    if ([[NSFileManager defaultManager] fileExistsAtPath:dbPath]) {
    //        id<WizSettingsDbDelegate> dataBase = [[WizSettingsDataBase alloc]initWithPath:dbPath modelName:@"WizSettingsDataBaseModel"];
    //        NSArray* accounts = [dataBase allAccounts];
    //        for (WizAccount* each in accounts) {
    //            [self updateAccount:each.accountUserId password:each.password personalKbguid:nil];
    //        }
    //        NSString* defatultUserId = [dataBase defaultAccountUserId];
    //        [self updateActiveAccontUserId:defatultUserId];
    //    }
    //    [[NSFileManager defaultManager] removeItemAtPath:dbPath error:nil];
}
@end
