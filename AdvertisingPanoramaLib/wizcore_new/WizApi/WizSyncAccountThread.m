//
//  WizSyncAccountThread.m
//  WizIos
//
//  Created by dzpqzb on 12-12-20.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import "WizSyncAccountThread.h"
#import "WizFileManager.h"
#import "WizXmlAccountServer.h"
#import "WizGlobals.h"
#import "WizLogger.h"
#import "WizWorkQueue.h"
#import "WizNotificationCenter.h"
#import "WizGlobalError.h"
#import "WizAccountManager.h"
#import "WizSyncKb.h"
#import "WizSyncStatueCenter.h"

static NSMutableDictionary* g_threads = nil;

@interface WizSyncAccountThread ()
{
    NSString* accountUserId;
    NSString* password;
    BOOL isUploadOnly;
    WizSyncAccountType syncType;
    NSString *kbguid;
    WizXmlAccountServer* accountServer;
    NSMutableSet* uploadOnlyKbs;
    WizServerGroupsArray* groupsArray;
}
@property (nonatomic, assign) BOOL isSyncing;
@property (nonatomic, assign) BOOL isNeedToBeSync;
@property (nonatomic, assign) BOOL stop;
@property (nonatomic, strong) NSString * currentKbGuid;
@end
@implementation WizSyncAccountThread
@synthesize isSyncing,isNeedToBeSync;
@synthesize stop;
@synthesize currentKbGuid;

- (id) initWithAccountUserId:(NSString *)accountUserId_ password:(NSString *)password_ isUploadOnly:(BOOL)isUploadOnly_ syncType:(WizSyncAccountType)type kbguid:(NSString *)kbguid_
{
    self = [super init];
    if (self) {
        accountUserId = accountUserId_;
        password = password_;
        isUploadOnly = isUploadOnly_;
        kbguid = kbguid_;
        syncType = type;
        uploadOnlyKbs = [NSMutableSet set];
        isSyncing = NO;
        isNeedToBeSync = YES;
        stop = NO;
    }
    return self;
}
- (void) sendErrorMessage:(NSError*)error
{
    [WizNotificationCenter OnSyncState:accountUserId event:WizXmlSyncStateError messageType:WizXmlSyncEventMessageTypeAccount process:0.0];
    if (syncType == WizSyncAccountTypeKbguid) {
        [WizNotificationCenter OnSyncErrorStatue:kbguid messageType:WizXmlSyncEventMessageTypeKbguid error:error];

    }
    else{
        [WizNotificationCenter OnSyncErrorStatue:WizGlobalPersonalKbguid messageType:WizXmlSyncEventMessageTypeKbguid error:error];
    }
 
}

- (BOOL)login
{
    if (accountServer == nil) {
        return NO;
    }
    if (![accountServer accountClientLogin:accountUserId passwrod:password]) {
        DDLogError(@"account login error !");
        [self sendErrorMessage:accountServer.lastError];
        if (accountServer.lastError.code == WizErrorCodeInvalidPassword ||accountServer.lastError.code == 312) {
            [[NSNotificationCenter defaultCenter] postNotificationName:WizErrorMessageUserPasswordInvalid object:nil userInfo:nil];
        }
        return NO;
    }
    return YES;
}

- (BOOL)checkToken
{
    if (accountServer == nil) {
        accountServer = [[WizXmlAccountServer alloc] initWithUrl:[WizGlobals wizServerUrl]];
        return [self login];
    }
    if (accountServer.loginData != nil && accountServer.loginData.token != nil) {
        if ([accountServer keepAlive:accountServer.loginData.token]) {
            return YES;
        }
    }
    return [self login];
}

+ (void)clear:(NSString*)accountUserId
{
    WizSyncAccountThread* accountThread = [WizSyncAccountThread getAccountThread:accountUserId];
    if (accountThread == nil) {
        return ;
    }
    accountThread.stop = YES;
    @synchronized(g_threads){
        [g_threads removeObjectForKey:accountUserId];
    }
}

+ (BOOL)isSyncingAccount:(NSString*)accountUserId
{
    WizSyncAccountThread* accountThread = [WizSyncAccountThread getAccountThread:accountUserId];
    if (accountThread == nil) {
        return NO;
    }
    return accountThread.isSyncing;
}

+ (void)addKb:(NSString *)kbguid_ accountUserId:(NSString*)accountId
{
    WizSyncAccountThread* accountThread = [WizSyncAccountThread getAccountThread:accountId];
    if (accountThread == nil) {
        return ;
    }
    [accountThread addKb:kbguid_];
}

- (void)addKb:(NSString*)kbguid_
{
    @synchronized(self){
        if (kbguid_ == nil) {
            kbguid_ = WizGlobalPersonalKbguid;
            [uploadOnlyKbs addObject:kbguid_];
        } else {
            [uploadOnlyKbs addObject:kbguid_];
        }
    }
}

- (BOOL)hasNextKb
{
    @synchronized(self){
        if (uploadOnlyKbs && [uploadOnlyKbs count]) {
            return YES;
        }
    }
    return NO;
}

- (NSString*)getNextKb
{
    @synchronized(self){
        if (uploadOnlyKbs && [uploadOnlyKbs count]) {
            NSString* kb = [[uploadOnlyKbs allObjects]firstObject];
            [uploadOnlyKbs removeObject:kb];
            return kb;
        }
    }
    return nil;
}

- (BOOL)checkGroupList:(BOOL)force
{
    if (force || !groupsArray || !groupsArray.array) {
        groupsArray = [[WizServerGroupsArray alloc] init];
        if (![accountServer getGroupList:groupsArray]) {
            [self sendErrorMessage:accountServer.lastError];
            return NO;
        }
        
        [[WizAccountManager defaultManager] updateGroups:groupsArray.array forAccount:accountUserId];
    }
    return YES;
}

- (BOOL) syncAll{
    if (![self checkToken]) {
        return NO;
    }
    
    if (![self checkGroupList:YES]) {
        return NO;
    }
    //
    NSString* firstKb = nil;
    @synchronized(self) {
        firstKb = currentKbGuid;
    }
    
    BOOL firstKbSynced = NO;
    if (firstKb != nil && [firstKb length] > 0)
    {
        for (WizGroup* each in groupsArray.array) {
            if ([each.guid isEqualToString:firstKb]) {
                WizSyncKbWorkObject* kb = [[WizSyncKbWorkObject alloc] init];
                kb.kbguid = each.guid;
                kb.accountUserId = accountUserId;
                kb.dbPath = [[WizFileManager shareManager] metaDataBasePathForAccount:accountUserId kbGuid:each.guid];
                kb.key = each.guid;
                kb.kApiUrl = each.kApiurl;
                kb.token = accountServer.loginData.token;
                kb.isUploadOnly = isUploadOnly;
                kb.userPrivilige = each.userGroup;
                each.type = WizGroupTypeGlobal;
                kb.isPersonal = NO;
                [self syncData:kb];
                //
                firstKbSynced = YES;
                break;
            }
        }
        
    }
    //
    //personal sync
    WizSyncKbWorkObject* kb = [[WizSyncKbWorkObject alloc] init];
    kb.dbPath = [[WizFileManager shareManager] metaDataBasePathForAccount:accountUserId kbGuid:nil];
    kb.kbguid = accountServer.loginData.kbguid;
    kb.key = accountServer.loginData.kbguid;
    kb.kApiUrl = accountServer.loginData.kapiUrl;
    kb.token = accountServer.loginData.token;
    kb.isUploadOnly = isUploadOnly;
    kb.userPrivilige = 0;
    kb.accountUserId = accountUserId;
    kb.isPersonal = YES;
    [self syncData:kb];
    
    for (WizGroup* group in groupsArray.array) {
        [WizNetworkEngine getAllWizUsers:accountUserId kbguid:group.guid bizguid:group.bizGuid];
    }
    
    for (WizGroup* each in groupsArray.array) {
        if (syncType == WizSyncAccountTypeAll || (syncType == WizSyncAccountTypeKbguid && [kbguid isEqualToString:each.guid])) {
            if (firstKb == nil || [firstKb length] == 0  //no current kb (or is personal notes)
                || !firstKbSynced  //fist kb has not been synced
                || ![each.guid isEqualToString:firstKb]) {  //each.guid is not first kb
                
                WizSyncKbWorkObject* kb = [[WizSyncKbWorkObject alloc] init];
                kb.kbguid = each.guid;
                kb.accountUserId = accountUserId;
                kb.dbPath = [[WizFileManager shareManager] metaDataBasePathForAccount:accountUserId kbGuid:each.guid];
                kb.key = each.guid;
                kb.kApiUrl = each.kApiurl;
                kb.token = accountServer.loginData.token;
                kb.isUploadOnly = isUploadOnly;
                kb.userPrivilige = each.userGroup;
                each.type = WizGroupTypeGlobal;
                kb.isPersonal = NO;
                [self syncData:kb];
            }
            else {
                if (each.guid != nil) {
                    NSLog(@"skip first kb: %@", each.guid);
                }
            }
        }
    }
    return YES;
}

- (WizGroup*)getGroupByKbGuid:(NSString*)kbguid_
{
    for (WizGroup* each in groupsArray.array) {
        if ([each.guid isEqualToString:kbguid_]) {
            return each;
        }
    }
    return nil;
}

- (void)syncDataByKbguid:(NSString*)_kbguid
{
    if (![self checkToken]) {
        return ;
    }
    if (![self checkGroupList:NO]) {
        return ;
    }
    WizSyncKbWorkObject* kb = [[WizSyncKbWorkObject alloc] init];
    kb.isPersonal = NO;
    kb.kbguid = _kbguid;
    if ([_kbguid length] == 0 || [_kbguid isEqualToString:WizGlobalPersonalKbguid]) {
        kb.isPersonal = YES;
        kb.kbguid = accountServer.loginData.kbguid;
        kb.kApiUrl = accountServer.loginData.kapiUrl;
        kb.userPrivilige = 0;
    }else{
        WizGroup* group = [self getGroupByKbGuid:_kbguid];
        if (group == nil) {
            return ;
        }
        kb.kApiUrl = group.kApiurl;
        kb.userPrivilige = group.userGroup;
    }
    kb.accountUserId = accountUserId;
    kb.dbPath = [[WizFileManager shareManager] metaDataBasePathForAccount:accountUserId kbGuid:_kbguid];
    kb.key = kb.kbguid;
    kb.token = accountServer.loginData.token;
    kb.isUploadOnly = YES;
    [self syncData:kb];
}

- (void)syncData:(WizSyncKbWorkObject *)object{
//    @synchronized(self){
    id<WizInfoDatabaseDelegate> db = nil;
    if (object.isPersonal) {
        db = [WizDBManager getMetaDataBaseForKbguid:nil accountUserId:object.accountUserId];;
    }else{
        db = [WizDBManager getMetaDataBaseForKbguid:object.kbguid accountUserId:object.accountUserId];
    }
    WizSyncKb* syncKb = [[WizSyncKb alloc] initWithUrl:[NSURL URLWithString:object.kApiUrl]token:object.token kbguid:object.kbguid accountUserId:object.accountUserId dataBaser:db isUploadOnly:object.isUploadOnly userPrivilige:object.userPrivilige isPersonal:object.isPersonal];
    if (![syncKb sync]) {
        
    }
//    }
}


-(void)setParams:(NSString*)accountUserId_ password:(NSString*)password_ isUploadOnly:(BOOL)isUploadOnly_ syncType:(WizSyncAccountType )type_ kbguid:(NSString*)kbguid_{
    @synchronized(self)
    {
        accountUserId = accountUserId_;
        password = password_;
        isUploadOnly = isUploadOnly_;
        syncType = type_;
        kbguid = kbguid_;
    }
}

+ (WizSyncAccountThread*)getAccountThread:(NSString*)accountUserId
{
    if (g_threads == nil)
    {
        return nil;
    }
    @synchronized(g_threads){
        return [g_threads objectForKey:accountUserId];
    }
}

+ (void)sync:(NSString*)accountUserId password:(NSString*)password isUploadOnly:(BOOL)isUploadOnly syncType:(WizSyncAccountType)type kbguid:(NSString*)kbguid
{
    if (g_threads == nil)
    {
        g_threads = [NSMutableDictionary dictionary];
    }
    @synchronized(g_threads){
        WizSyncAccountThread* accountThread = [g_threads objectForKey:accountUserId];
//        if (!accountThread) {
            accountThread = [[WizSyncAccountThread alloc] initWithAccountUserId:accountUserId password:password isUploadOnly:isUploadOnly syncType:type kbguid:kbguid];
            [accountThread setThreadPriority:0.0];
            [accountThread start];
            [g_threads setObject:accountThread forKey:accountUserId];
//        }
        if (accountThread.isSyncing) {
            return ;
        }
        //
        @synchronized(accountThread){
            accountThread.currentKbGuid = kbguid;
        }
        //
        accountThread.isNeedToBeSync = YES;
    }
}

- (void) main
{
    while (1) {
        if (stop) {
            break ;
        }
        if (self.isNeedToBeSync){
            @autoreleasepool {
                [[WizSyncStatueCenter shareInstance]increaseNetworkInteractCount];
                [WizNotificationCenter OnSyncState:accountUserId event:WizXmlSyncStateStart messageType:WizXmlSyncEventMessageTypeAccount process:0.0];
                self.isSyncing = YES;
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FileSizeLimit"];
                if (![[NSUserDefaults standardUserDefaults] synchronize]) {
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                BOOL success = [self syncAll];
                self.isSyncing = NO;
                WizXmlSyncState state = success?WizXmlSyncStateEnd:WizXmlSyncStateError;
                [WizNotificationCenter OnSyncState:accountUserId event:state messageType:WizXmlSyncEventMessageTypeAccount process:1.0];
                [[WizSyncStatueCenter shareInstance]decreaseNetworInteractCount];
            }
                self.isNeedToBeSync = NO;
        }
        else if([self hasNextKb])
        {
            NSString* kb = [self getNextKb];
            self.isSyncing = YES;
            [[WizSyncStatueCenter shareInstance]increaseNetworkInteractCount];
            [self syncDataByKbguid:kb];
            if (!self.isNeedToBeSync && ![self hasNextKb]) {
                [[WizSyncStatueCenter shareInstance]decreaseNetworInteractCount];
                self.isSyncing = NO;
            }
        }
        else{
            sleep(1);
        }
    }
}
@end
