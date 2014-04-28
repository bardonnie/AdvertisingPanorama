//
//  WizXmlServer.m
//  WizIos
//
//  Created by dzpqzb on 12-12-19.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import "WizXmlServer.h"
#import "XMLRPCConnection.h"
#import "XMLRPCResponse.h"
#import "XMLRPCRequest.h"
#import "WizSyncStatueCenter.h"
Reachability *globalReachability();

static NSString* const ReachLock = @"ReachLock";
static NSString* const UnreachLock = @"UnreachLock";

void reportNetworkLost()
{
    if ([NSThread isMainThread]) {
        [WizGlobals reportErrorWithString:NSLocalizedString(@"No Internet connection avaiable", nil)];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [WizGlobals reportErrorWithString:NSLocalizedString(@"No Internet connection avaiable", nil)];
        });
    }
}
static Reachability* reach = nil;
NSMutableArray* reachableArray()
{
    static NSMutableArray* reachableArray = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        reachableArray = [NSMutableArray array];
    });
    return reachableArray;
}
NSMutableArray* unReachableArray()
{
    static NSMutableArray* unReachableArray = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        unReachableArray = [NSMutableArray array];
    });
    return unReachableArray;
}

void AddReachableBlock(NetworkReachable block)
{
    globalReachability();
    @synchronized(ReachLock)
    {
       [reachableArray() addObject:block];
    }
}

void RemoveReachableBlock(NetworkReachable block)
{
    @synchronized(ReachLock)
    {
       [reachableArray() removeObject:block]; 
    }
    
}


void AddUnReachableBlock(NetworkUnreachable block)
{
    globalReachability();
    @synchronized(UnreachLock)
    {
       [unReachableArray() addObject:block]; 
    }
    
}

void RemoveUnReachableBlock(NetworkUnreachable block)
{
    @synchronized(UnreachLock)
    {
       [reachableArray() removeObject:block];
    }
}

Reachability *globalReachability()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        reach = [Reachability reachabilityWithHostname:@"www.wiz.cn"];
        reach.reachableBlock = ^(Reachability* reach)
        {
            @synchronized(ReachLock)
            {
                NSArray* reachBlocks = reachableArray();
                for (NetworkReachable each in reachBlocks) {
                    each(reach);
                }
            }
        };
        reach.unreachableBlock = ^(Reachability* reach)
        {
            @synchronized(UnreachLock)
            {
                NSArray* reachBlocks = unReachableArray();
                for (NetworkUnreachable each in reachBlocks) {
                    each(reach);
                }
            }
        };
        [reach startNotifier];
    });
    return reach;
}


BOOL IsReachableInternet()
{
    if (globalReachability().isReachable) {
        return YES;
    }
    return NO;
}
NetworkStatus CurrentNetWorkStatues()
{
    return globalReachability().currentReachabilityStatus;
}

BOOL IsReachableInternerViaWifi()
{
    if (IsReachableInternet() && CurrentNetWorkStatues() == ReachableViaWiFi) {
        return YES;
    }
    return NO;
}

NSString* const SyncMethod_KeepAlive                    = @"accounts.keepAlive";
NSString* const SyncMethod_ClientLogin                  = @"accounts.clientLogin";
NSString* const SyncMethod_ClientLogout                 = @"accounts.clientLogout";
NSString* const SyncMethod_CreateAccount                = @"accounts.createAccount";
NSString* const SyncMethod_ChangeAccountPassword        = @"accounts.changePassword";
NSString* const SyncMethod_GetAllCategories             = @"category.getAll";
NSString* const SyncMethod_DownloadAllTags                   = @"tag.getList";
NSString* const SyncMethod_PostTagList                  = @"tag.postList";
NSString* const SyncMethod_DocumentsByKey               = @"document.getSimpleListByKey";
NSString* const SyncMethod_DownloadDocumentList         = @"document.getSimpleList";
NSString* const SyncMethod_DocumentsByCategory          = @"document.getSimpleListByCategory";
NSString* const SyncMethod_DocumentsByTag               = @"document.getSimpleListByTag";
NSString* const SyncMethod_DocumentPostSimpleData       = @"document.postSimpleData";
NSString* const SyncMethod_DownloadDeletedList          = @"deleted.getList";
NSString* const SyncMethod_UploadDeletedList            = @"deleted.postList";
NSString* const SyncMethod_DownloadObject               = @"data.download";
NSString* const SyncMethod_UploadObject                 = @"data.upload";
NSString* const SyncMethod_AttachmentPostSimpleData     = @"attachment.postSimpleData";
NSString* const SyncMethod_DownloadAttachmentList            = @"attachment.getList";
NSString* const SyncMethod_GetUserInfo                  = @"wiz.getInfo";
NSString* const SyncMethod_GetGropKbGuids               = @"accounts.getGroupKbList";
NSString* const SyncMethod_DownloadAllObjectVersion          = @"wiz.getVersion";
NSString* const SyncMethod_DownloadDocumentListByGuids  = @"document.downloadList";
NSString* const SyncMethod_DownloadAttachmentListByGuids    = @"attachment.downloadList";
NSString* const WizXmlSyncStateChangedKey                   = @"WizXmlSyncStatueChanged";
NSString* const SyncMethod_AccountGetValue                  = @"accounts.getValue";
NSString* const SyncMethod_AccountSetValue                  = @"accounts.setValue";
NSString* const SyncMethod_AccountGetValueVersion           = @"accounts.getValueVersion";
NSString* const SyncMethod_KbGetValue                       = @"kb.getValue";
NSString* const SyncMethod_KbSetValue                       = @"kb.setValue";
NSString* const SyncMethod_KbGetValueVersion                = @"kb.getValueVersion";
NSString* const WizUserStopMessage                          = @"WizUserStopMessage";

@interface WizXmlServer ()
{
    NSURL* serverUrl;
}
@property (atomic, assign) BOOL isUserStop;
@end

@implementation WizXmlServer
@synthesize lastError;
@synthesize isUserStop;

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) startNetworkNotificate
{
    [[WizSyncStatueCenter shareInstance] setSyncValue:[NSDate date] forKey:WizNetWorkStatue];
}

- (void) stopNetworkNotificate
{
    
}
- (BOOL) callXmlRpc:(XMLRPCRequest*)request retObj:(id<WizObject>)ret
{
    NSError* error = nil;
    [self startNetworkNotificate];
    XMLRPCResponse* response = [XMLRPCConnection sendSynchronousXMLRPCRequest:request error:&error];
    [self stopNetworkNotificate];
    if (error != nil) {
        self.lastError = error;
        return NO;
    }
    if (response == nil) {
        return NO;
    }
    if ([response.object isKindOfClass:[NSError class]]) {
        self.lastError = response.object;
        return NO;
    }
    else
    {
        if (response.isFault) {
            self.lastError = [NSError errorWithDomain:@"error.wiz.cn" code:[response.faultCode integerValue] userInfo:[NSDictionary dictionaryWithObject:response.faultString forKey:NSLocalizedDescriptionKey]];
            return NO;
            
        }
        [ret fromWizServerObject:response.object];
        return YES;
    }
}
- (BOOL) callXmlRpc:(NSMutableDictionary *)postParams methodKey:(NSString *)methodKey  retObj:(id<WizObject>)ret
{
    XMLRPCRequest* request = [[XMLRPCRequest alloc] initWithURL:serverUrl];
    [self addCommontParams:postParams];
    [request setMethod:methodKey withParameters:[NSArray arrayWithObject:postParams]];
    return [self callXmlRpc:request retObj:ret];
}
- (void) addCommontParams:(NSMutableDictionary*)postParams
{
    [postParams setObject:@"iphone" forKey:@"client_type"];
    [postParams setObject:@"normal" forKey:@"program_type"];
    [postParams setObject:[NSNumber numberWithInt:4] forKey:@"api_version"];
}

- (void) setUserStop:(NSNotification*)nc
{
    self.isUserStop = YES;
}

- (id) init
{
    self = [super init];
    if(self)
    {
        isUserStop = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUserStop:) name:WizUserStopMessage object:nil];
    }
    return self;
}

- (id) initWithUrl:(NSURL *)url
{
    self = [super init];
    if (self) {
        serverUrl = url;
        isUserStop = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUserStop:) name:WizUserStopMessage object:nil];
    }
    return self;
}
- (BOOL) isStop
{
    if (self.lastError != nil && self.lastError.code == 301)
    {
        return YES;
    }
    if (self.isUserStop) {
        return YES;
    }
    return NO;
}



@end
