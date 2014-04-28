//
//  WizNetworkEngine.m
//  WizNote
//
//  Created by dzpqzb on 13-5-31.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizNetworkEngine.h"
#import "WizGlobals.h"
#import "SBJson.h"
#import "WizTokenManger.h"

static NSString* const WizNetworkCommandMessageVersion = @"message_version";
static NSString* const WizNetworkCommandSyncHttp = @"sync_http";
static NSString* const WizNetworkCommandSyncHttps = @"sync_https";
static NSString* const WizNetworkKeyWordAboutWizNote = @"ioshelp";
static NSString* const WizNetworkKeyWordNewFunction = @"iosfeatures";
static NSString* const WizNetworkKeyWordAbstract = @"abstract";
static NSString* const WizNetworkKeyWordEmail = @"mail_share";

NSString* (^kWizNetworkCommandSyncType)() = ^
{
    WizSyncEncryptType type = [[WizSettings defaultSettings] syncEncryptType];
    if(type == WizSyncHTTPS)
    {
        return WizNetworkCommandSyncHttps;
    }
    else
    {
        return WizNetworkCommandSyncHttp;
    }
};

static NSString* const WizNetworkKeyWordErrorStr = @"hello wiz";

@interface NSURLConnection (WizNetworkEngine)
+ (NSString*) stringSendSynchronousRequest:(NSURLRequest*)request returningResponse:(NSURLResponse**)response error:(NSError**)error;
+ (NSString*) stringSendSynchronousWithUrl:(NSURL*)url returningResponse:(NSURLResponse**)response error:(NSError**)error;
+ (id) JSONSendSynchronousRequest:(NSURLRequest*)request returningResponse:(NSURLResponse**)response error:(NSError**)error;
@end


@implementation NSURLConnection (WizNetworkEngine)

+ (NSString*) stringSendSynchronousRequest:(NSURLRequest*)request returningResponse:(NSURLResponse**)response error:(NSError**)error
{
    NSURLResponse* res = nil;
    if (response == NULL) {
        res = [[NSURLResponse alloc] init];
    }
    else
    {
        res = *response;
    }
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:error];
    if (*error) {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (id) JSONSendSynchronousRequest:(NSURLRequest*)request returningResponse:(NSURLResponse**)response error:(NSError**)error
{
    NSURLResponse* res = nil;
    if (response == NULL) {
        res = [[NSURLResponse alloc] init];
    }
    else
    {
        res = *response;
    }
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:error];
    if (*error) {
        return nil;
    }
    return [[[SBJsonParser alloc] init] objectWithData:data];
}

+ (id) JSONSendSynchronousURL:(NSURL*)url returningResponse:(NSURLResponse**)response error:(NSError**)error
{
    return [self JSONSendSynchronousRequest:[NSURLRequest requestWithURL:url] returningResponse:response error:error];
}
+ (NSString*) stringSendSynchronousWithUrl:(NSURL*)url returningResponse:(NSURLResponse**)response error:(NSError**)error
{
    return [NSURLConnection stringSendSynchronousRequest:[NSURLRequest requestWithURL:url] returningResponse:response error:error];
}
@end

@implementation WizNetworkEngine
@synthesize hostName = _hostName;
- (id) initWithHostName:(NSString *)hostName
{
    self = [super init];
    if (self) {
        _hostName = hostName;
    }
    return self;
}

- (NSURL*) urlWithCommand:(NSString*)command
{
    static  NSString* version = nil;
    static NSString* plat = nil;
    static NSString* debug = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        BOOL isDebug = [[NSUserDefaults standardUserDefaults] boolForKey:@"urldebug"];
        version = [WizGlobals wizNoteVersion];
        plat = [WizGlobals wizSoftName];
        debug = isDebug ? @"true" : @"false";
    });
    NSString* url = [NSString stringWithFormat:@"/?p=wiz&v=%@&c=%@&plat=%@&debug=%@",version,command, plat, debug];
    if (!self.hostName) {
        return nil;
    }
    return [NSURL URLWithString:[_hostName stringByAppendingString:url]];
}


- (NSURL*)urlWithKeyWord:(NSString*)keyWord
{
    static NSString* version = nil;
    static NSString* language = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        version = [WizGlobals wizNoteVersion];
        language = [WizGlobals localLanguageKey];
    });
    NSString* urlString = [NSString stringWithFormat:@"/?p=wiz&v=%@&c=%@&l=%@",version,keyWord,language];
    return [NSURL URLWithString:[_hostName stringByAppendingString:urlString]];
}

+ (id) shareEngine
{
    static WizNetworkEngine* engine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        engine = [[WizNetworkEngine alloc] initWithHostName:@"http://api.wiz.cn"];
    });
    return engine;
}

- (NSString*) getStringWithCommand:(NSString*)command error:(NSError**)error
{
    NSURL* url = [self urlWithCommand:command];
    NSURLRequest* requst = [NSURLRequest requestWithURL:url];
    NSURLResponse* response = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:requst returningResponse:&response error:error];
    if (*error) {
        return nil;
    }
    NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([str isEqualToString:WizNetworkKeyWordErrorStr]) {
        return nil;
    }
    return str;
}


- (NSString*) syncServerURLString:(NSError**)error
{
    return [self getStringWithCommand:kWizNetworkCommandSyncType() error:error];
}

- (NSString*) messageVersionURLString:(NSError**)error
{
    return [self getStringWithCommand:WizNetworkCommandMessageVersion error:error];
}

- (NSString*) abstractURLString:(NSError**)error
{
    return [self getStringWithCommand:WizNetworkKeyWordAbstract error:error];
}

- (NSURL*) abstractURL
{
    static NSURL* abstractURL = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError* error = nil;
        NSString* str = [self abstractURLString:&error];
        if (str) {
            abstractURL = [NSURL URLWithString:str];
        }
        else
        {
            abstractURL = [NSURL URLWithString:@"http://search.wiz.cn"];
        }
    });
    return abstractURL;
}


- (NSURL*) wizNewFunctionURL
{
    return [self urlWithKeyWord:WizNetworkKeyWordNewFunction];
}

- (NSURL*) aboutWizNoteURL
{
    return [self urlWithKeyWord:WizNetworkKeyWordAboutWizNote];
}

- (NSString*) messageMaxeVersionURLString
{
   static NSString* url = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError* error = nil;
        url = [self messageVersionURLString:&error];
    });
    return url;
}

- (NSURL*) messageCurrentVersionURLForUserGUID:(NSString*)guid
{
    NSString* messageVersionUrl = [self messageMaxeVersionURLString];
    guid = guid?guid:@"NULL";
    messageVersionUrl = [messageVersionUrl stringByReplacingOccurrencesOfString:@"{userGuid}" withString:guid];
    return [NSURL URLWithString:messageVersionUrl];
}

- (int64_t) messageMaxVersionForUserGUID:(NSString*)guid
{
    NSURL* url = [self messageCurrentVersionURLForUserGUID:guid];
    NSError* error = nil;
    NSDictionary* dic = [NSURLConnection JSONSendSynchronousURL:url returningResponse:nil error:&error];
    int64_t returnCode = [[dic objectForKey:@"return_code"] longLongValue];
    if (returnCode == 200) {
        return [[dic objectForKey:@"result"] longLongValue];
    }
    else
    {
        return  INT64_MAX;
    }
}

- (NSDictionary*) abstractData:(NSString*)documentGuid kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId
{
    NSError* error = nil;
    WizTokenAndKapiurl* tokenUrl = [[WizTokenManger shareInstance] tokenUrlForAccountUserId:accountUserId kbguid:kbguid error:&error];
    if (!tokenUrl) {
        DDLogError(@"%@",error);
        return nil;
    }
    if (kbguid == nil) {
        kbguid = [[WizAccountManager defaultManager] activeAccountGuid];
    }

    NSURL* abstractUrl = [self abstractURL];
    [abstractUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"wizsearch/abstract?token=%@&kb_guid=%@&document_guids=%@&type=%d",tokenUrl.token, kbguid, documentGuid, 3]];
    NSURLRequest* request = [NSURLRequest requestWithURL:abstractUrl];
    NSURLResponse* response = [[NSURLResponse alloc] init];
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (!data) {
        return nil;
    }
    NSDictionary* jsonData= [[[SBJsonParser alloc] init] objectWithData:data];
    return jsonData;
}

- (NSString*)stringWithCommand:(NSString *)command group:(WizGroup*)group replaceHostName:(BOOL)replace  error:(NSError *__autoreleasing *)error
{
    NSString* urlString = [self getStringWithCommand:command error:error];
    if (*error) {
        return nil;
    }
    NSString* groupGuid = group.guid;
    if (replace) {
        NSString* groupKapiUrl = group.kApiurl;
        if (groupGuid == nil) {
            groupKapiUrl = [[[WizSettings defaultSettings] accountAttributes:group.accountUserId] objectForKey:@"kapi_url"];
            groupGuid = [[WizSettings defaultSettings]personalKbGuid:group.accountUserId];
        }
        if (!groupKapiUrl) {
            return nil;
        }
        NSURL* url = [NSURL URLWithString:groupKapiUrl];
        urlString = [urlString stringByReplacingOccurrencesOfString:@"{server_host}" withString:url.host];
    }
    WizTokenAndKapiurl* token = [[WizTokenManger shareInstance] tokenUrlForAccountUserId:group.accountUserId kbguid:group.guid error:error];
    if (*error) {
        return nil;
    }
    urlString = [urlString stringByReplacingOccurrencesOfString:@"{token}" withString:token.token];
    urlString =[urlString stringByReplacingOccurrencesOfString:@"{kbGuid}" withString:groupGuid];
    return urlString;
}

- (NSURL*) commentUrlWithAccountUserId:(NSString *)accountUserId kbguid:(NSString *)kbguid documentGuid:(NSString *)documentGuid error:(NSError *__autoreleasing *)error
{
    WizTokenAndKapiurl* token = [[WizTokenManger shareInstance] tokenUrlForAccountUserId:accountUserId kbguid:kbguid error:error];
    
    if (*error) {
        return nil;
    }
    else
    {
        if (kbguid == nil) {
            kbguid = [[WizSettings defaultSettings]personalKbGuid:accountUserId];
        }
        return [NSURL URLWithString:[NSString stringWithFormat:@"http://note.wiz.cn/otherClient/comment.html?token=%@&kb_guid=%@&document_guid=%@&client_type=ios",token.token,kbguid, documentGuid]];
    }
}

- (NSURL*)getCommentCountURLWith:(NSString*)documentGuid group:(WizGroup*)group
{
    if (documentGuid == nil) {
        return nil;
    }
    NSError* error = nil;
    NSString* string = [self stringWithCommand:@"comment_count" group:group replaceHostName:YES error:&error];
    if (error) {
        return nil;
    }else{
        string = [string stringByReplacingOccurrencesOfString:@"{documentGuid}" withString:documentGuid];
    }
    return [NSURL URLWithString:string];
}

+(void) getAllWizUsers:(NSString *)accountUserId
                kbguid:(NSString *)kbguid
               bizguid:(NSString *)bizguid
{
    WizTokenAndKapiurl* token = [[WizTokenManger shareInstance] tokenUrlForAccountUserId:accountUserId kbguid:kbguid error:nil];
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://as.wiz.cn/wizas/a/biz/user_aliases?token=%@&kb_guid=%@&biz_guid=%@&client_type=ios",token.token,kbguid, bizguid]];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSMutableURLRequest*  request = [NSMutableURLRequest new];
        [request setURL:url];
        [request setHTTPMethod:@"GET"];
        NSURLResponse* response ;
        NSData* data =  [NSURLConnection sendSynchronousRequest:request
                                              returningResponse:&response error:nil];
        SBJsonParser* parser = [[SBJsonParser alloc]init];
        NSDictionary* dictionary = [parser objectWithData:data];
        NSInteger returnCode = [[dictionary objectForKey:@"return_code"] integerValue];
        if (returnCode == 200) {
            id<WizTemporaryDataBaseDelegate> db = [WizDBManager temporaryDataBase];
            [db deleteWizBizUser:kbguid];
            NSArray* arr = [dictionary objectForKey:@"result"];
            for(NSDictionary* dic in arr)
            {
                WizBizUser* user = [WizBizUser new];
                user.alias = [dic objectForKey:@"alias"];
                user.aliasPinyin = [dic objectForKey:@"pinyin"];
                user.guid = [dic objectForKey:@"user_guid"];
                user.userId = [dic objectForKey:@"user_id"];
                user.bizGuid = kbguid;
                [db updateWizBizUser:user];
            }
        }
//    });
}

- (NSURL*) wizEmailUrl
{
    return [self urlWithKeyWord:WizNetworkKeyWordEmail];
}

@end
