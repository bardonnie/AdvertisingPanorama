//
//  WizXmlAccountServer.m
//  WizIos
//
//  Created by dzpqzb on 12-12-19.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import "WizXmlAccountServer.h"
#import "WizObject.h"
#import "WizGlobals.h"
#import "WizSettings.h"
#import "WizAccountManager.h"
#import "WizGlobalData.h"



@implementation WizXmlAccountServer
@synthesize loginData = _loginData;

- (id) initWithUrl:(NSURL *)url
{
    self = [super initWithUrl:url];
    if (self) {
        _loginData = [[WizLoginData alloc] init];
    }
    return self;
}

- (BOOL) accountClientLogin:(NSString *)accountUserId passwrod:(NSString *)password
{
    if (password == nil) {
        return NO;
    }
    if (accountUserId == nil) {
        return NO;
    }
    NSMutableDictionary* postParams = [ NSMutableDictionary dictionary];
    [postParams setObject:password forKey:@"password"];
    [postParams setObject:accountUserId forKey:@"user_id"];
    BOOL isSucceed = [self callXmlRpc:postParams methodKey:SyncMethod_ClientLogin retObj:_loginData];
    if (isSucceed) {
        [[WizSettings defaultSettings] setAccount:accountUserId attribute:_loginData.userAttributes];
    }
    return isSucceed;
}
- (BOOL) verifyAccount:(NSString *)accountUserId passwrod:(NSString *)passwrod
{
    return [self accountClientLogin:accountUserId passwrod:passwrod];
}

- (BOOL) getGroupList:(WizServerGroupsArray *)groupsArray
{
    NSMutableDictionary* post = [NSMutableDictionary dictionaryWithCapacity:1];
    [post setObject:self.loginData.token forKey:@"token"];
    return [self callXmlRpc:post methodKey:SyncMethod_GetGropKbGuids retObj:groupsArray];
}

- (BOOL) keepAlive:(NSString *)token
{
    NSMutableDictionary* postParams = [NSMutableDictionary dictionaryWithCapacity:4];
    [postParams setObject:token forKey:@"token"];
    return [self callXmlRpc:postParams methodKey:SyncMethod_KeepAlive retObj:nil];
}

- (BOOL) createAccount:(NSString *)accountUserId passwrod:(NSString *)password
{
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[postParams setObject:accountUserId forKey:@"user_id"];
	[postParams setObject:password forKey:@"password"];
    if ([WizGlobals WizDeviceIsPad]) {
        [postParams setObject:@"wiz_ipad" forKey:@"product_name"];
    }
    else
    {
        [postParams setObject:@"wiz_iphone" forKey:@"product_name"];
    }
    
    NSString* inviteCode = @"f6d9193f";
    [postParams setObject:inviteCode forKey:@"invite_code"];
    return [self callXmlRpc:postParams methodKey:SyncMethod_CreateAccount retObj:nil];
}

- (BOOL) accountLogout
{
    NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
    if (self.loginData.token) {
        [postParams setObject:self.loginData.token forKey:@"token"];
    }
    return [self callXmlRpc:postParams methodKey:SyncMethod_ClientLogout retObj:nil];
}
@end
