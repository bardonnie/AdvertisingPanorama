
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
#import "WizGlobalError.h"
#import "SBJson.h"


@implementation WizXmlAccountServer
@synthesize loginData = _loginData;
@synthesize currentUserGuid = _currentUserGuid;
@synthesize currentUserId = _currentUserId;
- (id) initWithUrl:(NSURL *)url
{
    self = [super initWithUrl:url];
    if (self) {
        _loginData = [[WizLoginData alloc] init];
    }
    return self;
}
- (NSString*) currentUserGuid
{
    return [self.loginData.userAttributes objectForKey:@"user_guid"];
}
- (BOOL) accountClientLogin:(NSString *)accountUserId passwrod:(NSString *)password
{
    if (password == nil) {
        return NO;
    }
    if (accountUserId == nil) {
        return NO;
    }
    _currentUserId = accountUserId;
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

- (NSString *)userGuidByUserId:(NSString *)accountUserId password:(NSString *)password {
    BOOL isSuccess=[self verifyAccount:accountUserId passwrod:password];
    if (isSuccess){
        return self.loginData.userGuid;
    }
    return nil;
}

- (BOOL) getGroupList:(WizServerGroupsArray *)groupsArray
{
    NSMutableDictionary* post = [NSMutableDictionary dictionaryWithCapacity:1];
    [post setObject:self.loginData.token forKey:@"token"];
    return [self callXmlRpc:post methodKey:SyncMethod_GetGropKbGuids retObj:groupsArray];
}

- (BOOL) getKeyVersion:(NSString *)key version:(int64_t* const )version
{
    NSMutableDictionary* postParams = [NSMutableDictionary dictionary];
    [postParams setObject:key forKey:@"key"];
    [self addCommontParams:postParams];
    WizAddTokenToParams(self.loginData.token, postParams);
    WizServerVersionObject* versionObject = [[WizServerVersionObject alloc] init];
    BOOL ret = [self callXmlRpc:postParams methodKey:SyncMethod_AccountGetValueVersion retObj:versionObject];
    if (ret) {
        int64_t ver = versionObject.version;
        *version = ver;
    }
    return ret;
}


- (BOOL) getValue:(WizServerObject*)retObject forKey:(NSString*)key
{
    NSMutableDictionary* postParams = [NSMutableDictionary new];
    [self addCommontParams:postParams];
    WizAddTokenToParams(self.loginData.token,postParams);
    [postParams setObject:key forKey:@"key"];
    return [self callXmlRpc:postParams methodKey:SyncMethod_AccountGetValue retObj:retObject];
}

- (BOOL) getAllKMUsersList:(NSSet*)bizGuids db:(id<WizTemporaryDataBaseDelegate>)db
{
    for (NSString* bizGuid in bizGuids) {
        NSString* key = [NSString stringWithFormat:@"biz_users/%@",bizGuid];
        int64_t localVersion = [db syncVersion:key];
        int64_t serverVersion = 0;
        if(![self getKeyVersion:key version:&serverVersion])
        {
            return NO;
        }
        if (localVersion < serverVersion) {
            WizServerObject* serverObject = [WizServerObject new];
            if (![self getValue:serverObject forKey:key]) {
                return NO;
            }
            SBJsonParser* jsonParser = [[SBJsonParser alloc] init];
            if ([serverObject.data isKindOfClass:[NSString class]]) {
                id userList = [jsonParser objectWithString:serverObject.data];
                if([userList isKindOfClass:[NSArray class]])
                {
                    for(NSDictionary* dic in userList)
                    {
                        WizBizUser* user = [WizBizUser new];
                        [user setValuesForKeysWithDictionary:dic];
                        user.bizGuid = bizGuid;
                        [db updateWizBizUser:user];
                    }
                }
            }
            
            [db setSyncVersion:key version:serverVersion];
        }
    }
    return YES;
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
    if ([accountUserId length]%2 == 0) {
        inviteCode = @"b4c36667";
    }
    [postParams setObject:inviteCode forKey:@"invite_code"];
    return [self callXmlRpc:postParams methodKey:SyncMethod_CreateAccount retObj:nil];
}

- (BOOL) getMessage:(int64_t)startVersion pageSize:(int64_t)pageSize retObject:(WizServerMessageArray*)messageArray
{
    NSMutableDictionary* postParams = [NSMutableDictionary new];
    [self addCommontParams:postParams];
    if (self.loginData.token) {
       postParams[@"token"] = self.loginData.token;
    }
    else
    {
        return NO;
    }
    
    postParams[@"version"] = Int64ToString(startVersion);
    postParams[@"page_size"] = @(pageSize);
    return [self callXmlRpc:postParams methodKey:SyncMethod_GetMessages retObj:messageArray];
}

void (^WizAddTokenToParams)(NSString*, NSMutableDictionary*) = ^(NSString* token, NSMutableDictionary* params)
{
    [params setObject:token forKey:@"token"];
};


- (BOOL) setMessages:(NSString*)messageIds newStatus:(WizMessageReadStatus)readStatus retObject:(WizDictionayObject*)messageDic
{
    NSMutableDictionary* postParams = [NSMutableDictionary new];
    [self addCommontParams:postParams];
    postParams[@"token"] = self.loginData.token;
    if (![messageIds.trim isBlock]) {
        postParams[@"ids"] = messageIds;
        postParams[@"status"] = @(readStatus);
        return [self callXmlRpc:postParams methodKey:SyncMethod_SetReadStatus retObj:messageDic];
    }
    return NO;
}

- (BOOL) postAllChangedStatusMessages:(id<WizTemporaryDataBaseDelegate>)db forAccount:(NSString*)accountUserId status:(WizMessageReadStatus)status
{
    WizDictionayObject* dic = [WizDictionayObject new];
    NSArray* dirtyArray = [db messagesForLocalChanged:accountUserId];
    NSArray* IdsArray = [[WizAccountManager defaultManager]messageIdsForLocalChanged:accountUserId readStatus:status];
    if (![self setMessages:[IdsArray componentsJoinedByString:@","] newStatus:status retObject:dic]) {
        return NO;
    }
    for (WizMessage* each in dirtyArray) {
        if (each.readStatus == status) {
            each.localChanged = 0;
            if (![db updateMessage:each]) {
                return NO;
            }
        }
    }
    return YES;
}


- (BOOL) getAllMessages:(id<WizTemporaryDataBaseDelegate>)db forAccount:(NSString*)userId sendMessage:(BOOL)willSendMessage
{
    if (willSendMessage) {
       [WizNotificationCenter OnSyncMessageAccountUserId:userId event:WizXmlSyncStateStart error:nil];
    }
    int64_t localVersion = [db messageVersionForAccount:userId];
    int64_t serverVersion = 0;    
    while (true) {
        WizServerMessageArray* messagesArray = [WizServerMessageArray new];
        if (![self getMessage:localVersion+1 pageSize:50 retObject:messagesArray]) {
            if (willSendMessage) {
               [WizNotificationCenter OnSyncMessageAccountUserId:userId event:WizXmlSyncStateError error:self.lastError];
            }
            return NO;
        }
        serverVersion = messagesArray.version;
        NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:1];
        dic[@"serverVersion"]=[NSNumber numberWithLongLong:serverVersion];
        [[NSNotificationCenter defaultCenter] postNotificationName:WizSyncWizMessageServerVersion object:nil userInfo:dic];
        if (serverVersion != -1) {
            [db updateMessages:messagesArray.array];
        }
        if (serverVersion == -1) {
            break;
        }
        if (serverVersion <=0) {
            serverVersion = localVersion;
        }
        [db setMessageVesion:serverVersion forAccount:userId];
        localVersion = serverVersion;
        
        if ([messagesArray.array count] < 1) {
            break;
        }
    }
    if (willSendMessage) {
       [WizNotificationCenter OnSyncMessageAccountUserId:userId event:WizXmlSyncStateEnd error:nil];
    }
    return YES;
}

- (WizCertData*) getCert:(NSString *)accountUserId passwrod:(NSString *)password
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
    
    WizCertData* data = [[WizCertData alloc] init];
    
    [self callXmlRpc:postParams methodKey:@"accounts.getCert" retObj:data];
    //
    return data;
    
}


- (BOOL) accountLogout
{
    NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
    if (self.loginData.token) {
        [postParams setObject:self.loginData.token forKey:@"token"];
        return [self callXmlRpc:postParams methodKey:SyncMethod_ClientLogout retObj:nil];
    } 
    return NO;
}
@end
