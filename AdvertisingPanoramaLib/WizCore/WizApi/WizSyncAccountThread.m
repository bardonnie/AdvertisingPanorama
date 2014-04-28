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
#import "WizAccountManager.h"
@interface WizSyncAccountThread ()
{
    NSString* accountUserId;
    NSString* password;
    BOOL isUploadOnly;
    WizSyncAccountType syncType;
    NSString* kbguid;
}
@end
@implementation WizSyncAccountThread

- (id) initWithAccountUserId:(NSString *)accountUserId_ password:(NSString *)password_ isUploadOnly:(BOOL)isUploadOnly_ syncType:(WizSyncAccountType)type kbguid:(NSString *)kbguid_
{
    self = [super init];
    if (self) {
        accountUserId = accountUserId_;
        password = password_;
        isUploadOnly = isUploadOnly_;
        kbguid = kbguid_;
        syncType = type;
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

- (BOOL) accountSync
{
    WizXmlAccountServer* accountServer = [[WizXmlAccountServer alloc] initWithUrl:[WizGlobals wizServerUrl]];
    if (![accountServer accountClientLogin:accountUserId passwrod:password]) {
        WizLogError(@"account login error !");
        [self sendErrorMessage:accountServer.lastError];
        return NO;
    }
    WizServerGroupsArray* groupsArray = [[WizServerGroupsArray alloc] init];
    if (![accountServer getGroupList:groupsArray]) {
        [self sendErrorMessage:accountServer.lastError];
        return NO;
    }
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
    [[WizWorkQueue kbSyncWorkQueue] addWorkObject:kb];
    //over
    //group sync
    for (WizGroup* each in groupsArray.array) {
        if (syncType == WizSyncAccountTypeAll || (syncType == WizSyncAccountTypeKbguid && [kbguid isEqualToString:each.guid])) {
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
            [[WizWorkQueue kbSyncWorkQueue] addWorkObject:kb];
        }
    }
    [[WizAccountManager defaultManager] updateGroups:groupsArray.array forAccount:accountUserId];
    return YES;
}
- (void) main
{
    @autoreleasepool {
        
        [WizNotificationCenter OnSyncState:accountUserId event:WizXmlSyncStateStart messageType:WizXmlSyncEventMessageTypeAccount process:0.0];
        if (![self accountSync]) {
            return;
        }
        while (true) {
            if ([[WizWorkQueue kbSyncWorkQueue] hasMoreWorkObject]) {
               [NSThread sleepForTimeInterval:0.5]; 
            }
            else
            {
                break;
            }
        }
        [WizNotificationCenter OnSyncState:accountUserId event:WizXmlSyncStateEnd messageType:WizXmlSyncEventMessageTypeAccount process:1.0];
    }
}
@end
