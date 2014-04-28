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

@implementation WizTokenAndKapiurl
@synthesize token;
@synthesize kApiUrl;
@synthesize guid;
@end

@interface WizTokenManger ()
{
    WizXmlAccountServer* accountServer;
    NSMutableDictionary* urlMap;
    NSMutableDictionary* tokenMap;
}
@end
@implementation WizTokenManger
NSString* (^PersonalKbguidForAccountUserIdKey)(NSString*) = ^(NSString* accountUserId)
{
    return [NSString stringWithFormat:@"WizPersonalKbguid--%@",accountUserId];
};

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
    return YES;
}

- (BOOL) refreshTokenAndUrl:(NSString*)accountUserId
{
    NSString* password = [[WizAccountManager defaultManager] accountPasswordByUserId:accountUserId];
    if (![accountServer accountClientLogin:accountUserId passwrod:password]) {
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

- (WizTokenAndKapiurl*) tokenUrlForAccountUserId:(NSString *)accountUserId  kbguid:(NSString*)kbguid error:(NSError **)error
{
    @synchronized(self)
    {

        if ([accountUserId isEqualToString:WGDefaultAccountUserId]) {
            return nil;
        }
        NSString* token = [tokenMap objectForKey:accountUserId];
        NSString* url = [self getUrlForAccountUserId:accountUserId kbguid:kbguid];
        if (!token || !url) {
            if (![self refreshTokenAndUrl:accountUserId]) {
                *error = accountServer.lastError;
                return nil;
            };
        }
        else
        {
            if (![ accountServer keepAlive:token]) {
                if (![self refreshTokenAndUrl:accountUserId]) {
                    *error = accountServer.lastError;
                    return nil;
                }
            }
        }
        
        static NSDate* date;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            date = [NSDate date];
        });
        
        NSDate* currentDate = [NSDate date];
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
