//
//  WizTokenManger.m
//  WizUIDesign
//
//  Created by dzpqzb on 13-1-23.
//  Copyright (c) 2013年 cn.wiz. All rights reserved.
//

#import "WizTokenManger.h"
#import "WizGlobalData.h"
#import "WizXmlAccountServer.h"
#import "WizAccountManager.h"
#import "WizGlobalError.h"
#import "WizGlobals.h"
#import "WizNotificationCenter.h"
@interface WizTokenManger ()
{
    WizXmlAccountServer* accountServer;
    NSMutableDictionary* urlMap;
    NSMutableDictionary* tokenMap;
}
- (BOOL) refreshTokenAndUrl:(NSString*)accountUserId password:(NSString*)password;
@end




@implementation WizAccountSyncManager

+ (id) shareInstance
{
    static WizAccountSyncManager* server = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        server = [[WizAccountSyncManager alloc] init];
    });
    return server;
}

- (void) ensureAccountUserIdIsLogIn:(NSString*)userId
{
    if (![[[WizTokenManger shareInstance] shareAccountServer].currentUserId isEqualToString:userId]) {
        NSString* password = [[WizAccountManager defaultManager] activeAccountPassword];
        [[WizTokenManger shareInstance] refreshTokenAndUrl:userId password:password];
    }
}

- (void) getAllMessageForAccountUserId:(NSString*)userId
{
    [self ensureAccountUserIdIsLogIn:userId];
    id<WizTemporaryDataBaseDelegate> db = [WizDBManager temporaryDataBase];
    [[[WizTokenManger shareInstance] shareAccountServer] getAllMessages:db forAccount:userId sendMessage:YES];
}

@end

@implementation WizTokenAndKapiurl
@synthesize token;
@synthesize kApiUrl;
@synthesize guid;
@end


@implementation WizTokenManger
@synthesize shareAccountServer;
NSString* (^PersonalKbguidForAccountUserIdKey)(NSString*) = ^(NSString* accountUserId)
{
    return [NSString stringWithFormat:@"WizPersonalKbguid--%@",accountUserId];
};
- (WizXmlAccountServer*) shareAccountServer
{
    return accountServer;
}
- (id) init
{
    self = [super init];
    if (self) {
        accountServer = [[WizXmlAccountServer alloc] initWithUrl:[WizGlobals wizServerUrl]];
        urlMap = [NSMutableDictionary dictionary];
        tokenMap = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    return self;
}

- (BOOL) refreshUrls:(NSString*)accountUserId
{
    WizServerGroupsArray* groupsArray = [[WizServerGroupsArray alloc] init];
    if (![accountServer getGroupList:groupsArray]) {
        return NO;
    }
    for (WizGroup* group in groupsArray.array) {
        [urlMap setObject:group.kApiurl forKey:group.guid];
    }
    [[WizAccountManager defaultManager] updateGroups:groupsArray.array forAccount:accountUserId];
    WizTokenManger* manager = self;
    MULTIBACK(^{
        [manager getAllMessages:accountUserId];
    });
    
    return YES;
}
- (void) getAllMessages:(NSString*)accountUserId
{
    id<WizTemporaryDataBaseDelegate> db = [WizDBManager temporaryDataBase];
    [accountServer getAllMessages:db forAccount:accountUserId sendMessage:YES];
}

- (void) getAllKMUsers:(NSSet*)bizGuids
{
    id<WizTemporaryDataBaseDelegate> db = [WizDBManager temporaryDataBase];
    [accountServer getAllKMUsersList:bizGuids db:db];
}

- (BOOL) refreshTokenAndUrl:(NSString*)accountUserId  password:(NSString*)password
{

    if (![accountServer accountClientLogin:accountUserId passwrod:password]) {
        if (accountServer.lastError.code == WizErrorCodeInvalidPassword || accountServer.lastError.code == 312) {
        }
        return NO;
    }
    else
    {
        [urlMap setObject:accountServer.loginData.kapiUrl forKey:accountUserId];
        [urlMap setObject:accountServer.loginData.kapiUrl forKey:accountServer.loginData.kbguid];
        [tokenMap setObject:accountServer.loginData.token forKey:accountUserId];
        [tokenMap setObject:accountServer.loginData.kbguid forKey:PersonalKbguidForAccountUserIdKey(accountUserId)];
        return [self refreshUrls:accountUserId];
    }
}
- (NSString*) getUrlForAccountUserId:(NSString*)accountUserId kbguid:(NSString*)kbguid
{
    if (!kbguid) {
        return [urlMap objectForKey:accountUserId];
    }
    else
    {
        return [urlMap objectForKey:kbguid];
    }
}
- (WizTokenAndKapiurl*) tokenUrlForAccountUserId:(NSString *)accountUserId  password:(NSString*)password kbguid:(NSString*)kbguid error:(NSError **)error
{
    @synchronized(self)
    {
        if ([accountUserId isEqualToString:WGDefaultAccountUserId]) {
            return nil;
        }
        if ([kbguid isEqualToString:WizGlobalPersonalKbguid]) {
            kbguid = nil;
        }
        NSString* token = [tokenMap objectForKey:accountUserId];
        NSString* url = [self getUrlForAccountUserId:accountUserId kbguid:kbguid];
        
        if (!token || !url) {
            if (![self refreshTokenAndUrl:accountUserId password:password]) {
                if (error != NULL) {
                    
                    *error = [accountServer.lastError copy];
                }
                return nil;
            };
        }
        else
        {
            if (![ accountServer keepAlive:token]) {
                if (![self refreshTokenAndUrl:accountUserId password:password]) {
                    if (error != NULL) {
                        *error = accountServer.lastError;
                    }
                    return nil;
                }
            }
        }
        
        static NSDate* date;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            date = [[NSDate alloc] init];
        });
        
        NSDate* currentDate = [[NSDate alloc] init];
        if (abs([currentDate timeIntervalSinceDate:date]) > 600) {
            date = currentDate;
            [self refreshUrls:accountUserId];
        }
        WizTokenAndKapiurl* tokenUrl = [[WizTokenAndKapiurl alloc] init];
        tokenUrl.token = [tokenMap objectForKey:accountUserId];
        tokenUrl.kApiUrl = [self getUrlForAccountUserId:accountUserId kbguid:kbguid];
        if (kbguid == nil) {
            tokenUrl.guid = [tokenMap objectForKey:PersonalKbguidForAccountUserIdKey(accountUserId)];
        }
        else
        {
            tokenUrl.guid = kbguid;
        }
        return tokenUrl;
    }
 
}

- (WizTokenAndKapiurl*) tokenUrlForAccountUserId:(NSString *)accountUserId  kbguid:(NSString*)kbguid error:(NSError **)error
{
    NSString* password = [[WizAccountManager defaultManager] accountPasswordByUserId:accountUserId];
   return  [self tokenUrlForAccountUserId:accountUserId password:password kbguid:kbguid error:error];
}

+ (id) shareInstance
{
    static WizTokenManger* tokenManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tokenManager = [WizGlobalData shareInstanceFor:[WizTokenManger class]];
    });
    return  tokenManager;
}

@end
