//
//  WizSyncCenter.m
//  WizIos
//
//  Created by dzpqzb on 12-12-20.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import "WizSyncCenter.h"
#import "WizGlobalData.h"
#import "WizSyncAccountThread.h"
#import "WizSyncKbThread.h"
#import "WizDownloadThread.h"
#import "WizNotificationCenter.h"
#import "WizWorkQueue.h"
#import "WizXmlAccountServer.h"
#import "WizAccountManager.h"
#import "WizSyncKb.h"
#import "WizFileManager.h"
#import "WizGlobals.h"
#import "WizGlobalCache.h"
#import "WizNotificationCenter.h"
#import "WizSyncStatueCenter.h"
#import "WizDBManager.h"
#import "WizTokenManger.h"
#import "Reachability.h"
#import "WizSettings.h"


@implementation NSOperationQueue(WizOperation)
+ (NSOperationQueue*)backGroupQueue
{
    @synchronized(self)
    {
        return [WizGlobalData shareInstanceFor:[NSOperationQueue class] category:@"WizBackgroudOperation"];
    }
}
@end

static NSInteger const MaxCountOfDownloadThread = 10;
static NSInteger const MaxCountOfBackgroudDownloadThread = 7;
static NSInteger const MaxCountOfSyncKbThread  = 3;

@interface WizSyncCenter ()
{
    BOOL isUploadOnly_;
}
@end

@implementation WizSyncCenter

- (void) stopAutoDownload
{
    [[WizWorkQueue downloadSourceQueue] removeAllWorkObject];
    [[WizAutoDownloadThread shareInstance] cancelAllWork];
    [[WizWorkQueue downloadWorkQueueBackgroud] removeAllWorkObject];
}
- (void) reachabilityChanged:(NSNotification*)nc
{
    Reachability* reach = [nc object];
    if ([reach currentReachabilityStatus] != ReachableViaWiFi) {
        [self stopAutoDownload];
    }
}

- (id) init
{
    self = [super init];
    if (self) {
        [WizNotificationCenter shareCenter];
        [WizGlobalCache shareInstance];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        NetworkUnreachable showUnreadchAlert = ^(Reachability* reachability)
        {
            if ([NSThread isMainThread]) {
                [WizGlobals reportWarningWithString:NSLocalizedString(@"No Internet connection avaiable", nil)];
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                   [WizGlobals reportWarningWithString:NSLocalizedString(@"No Internet connection avaiable", nil)];
                });
            }
        };
        AddUnReachableBlock(showUnreadchAlert);
        
        AddReachableBlock(^(Reachability *reachability) {
            if (reachability.isReachable && reachability.currentReachabilityStatus == ReachableViaWiFi) {
               [self startAutoDownload:nil];
            }
        });
        AddUnReachableBlock(^(Reachability *reachability) {
            [self stopAutoDownload];
        });
        for (int i = 0; i < MaxCountOfSyncKbThread; i++) {
        WizSyncKbThread* thread = [[WizSyncKbThread alloc] init];
        [thread start];
        } 
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerAccountNotificate:) name:@"registerActiveAccount" object:nil];
    }
    return self;
}
+ (WizSyncCenter*) shareCenter
{
    @synchronized(self)
    {
        return [WizGlobalData shareInstanceFor:[WizSyncCenter class]];
    }
}
- (void) startAutoDownloadForAccount:(NSString*)userId
{
    @autoreleasepool
    {
        __block NSString* accountUserId = userId;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            if (accountUserId == nil) {
                accountUserId = [[WizAccountManager defaultManager] activeAccountUserId];
            }
            if (accountUserId == nil || [accountUserId isEqualToString:WGDefaultAccountUserId]) {
                return ;
            }
            if (!IsReachableInternerViaWifi()) {
                return;
            }
            NSArray* groups = [[WizAccountManager defaultManager] groupsForAccount:accountUserId];
            for (WizGroup* each in groups) {
                [[WizAutoDownloadThread shareInstance] addWorkObject:each.guid accountUserId:each.accountUserId];
            }
        });
    }

}

- (void) startAutoDownload:(NSTimer*)timer
{
    @autoreleasepool
    {
        __block NSString* accountUserId = [[timer userInfo] objectForKey:@"userId"];
        [self startAutoDownloadForAccount:accountUserId];
    }
    
}

- (void) registerAccountNotificate:(NSNotification*)nc
{
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(startAutoDownload:) userInfo:[nc userInfo] repeats:NO];
}

- (void) syncAccount:(NSString*)accountUserId password:(NSString*)password isGroup:(BOOL) isGroup isUploadOnly:(BOOL) isUploadOnly
{
    WizSyncAccountType type = isGroup ? WizSyncAccountTypeAll : WizSyncAccountTypePesonal;
    WizSyncAccountThread* syncAccount = [[WizSyncAccountThread alloc] initWithAccountUserId:accountUserId password:password isUploadOnly:isUploadOnly syncType:type kbguid:nil];
    isUploadOnly_ = isUploadOnly;
    [syncAccount start];
}


- (void) syncKbGuid:(NSString *)kbguid accountUserId:(NSString *)accountUserId password:(NSString *)password isUploadOnly:(BOOL)isUPloadOnly  userGroup:(NSInteger)userGroup
{
   WizSyncKbWorkObject* kb = [[WizSyncKbWorkObject alloc] init];
   kb.kbguid = kbguid;
   kb.accountUserId = accountUserId;
   kb.dbPath = [[WizFileManager shareManager] metaDataBasePathForAccount:accountUserId kbGuid:kbguid];
   if (kbguid == nil) {
       kb.key = WizGlobalPersonalKbguid;
       kb.isPersonal = YES;
   }
   else
   {
       kb.key = kbguid;
       kb.kbguid = kbguid;
       kb.isPersonal = NO;
   }
   kb.isUploadOnly = isUPloadOnly;
   kb.userPrivilige = userGroup;
   isUploadOnly_ = isUPloadOnly;
   [[WizWorkQueue kbSyncWorkQueue] addWorkObject:kb];
}

- (void) downloadObject:(NSString*)objGuid type:(NSString*)objType kbguid:(NSString *)kbguid accountUserId:(NSString *)accountUserId onQueue:(WizWorkQueue*)queue
{
    WizDownloadOperation* operation = [[WizDownloadOperation alloc] initWithAccountUserId:accountUserId kbguid:kbguid objGuid:objGuid objType:objType];
    [[WizWorkOperationQueue userDownloadQueue] addOperation:operation];
}

- (void) autoSyncKbguid:(NSString *)kbguid accountUserId:(NSString *)accountUserId
{
    if ([[WizSettings defaultSettings] isAutoSyncEnable] && IsReachableInternerViaWifi()) {
        NSString* password = [[WizAccountManager defaultManager] accountPasswordByUserId:accountUserId];
        WizGroup* group = [[WizAccountManager defaultManager] groupFroKbguid:kbguid accountUserId:accountUserId];
        [self syncKbGuid:kbguid accountUserId:accountUserId password:password isUploadOnly:YES userGroup:group.userGroup];
        isUploadOnly_ = YES;
    }
}


- (void) downloadDocument:(NSString *)documentguid kbguid:(NSString *)kbguid accountUserId:(NSString *)accountUserId
{
    [self downloadObject:documentguid type:WizObjectTypeDocument kbguid:kbguid accountUserId:accountUserId onQueue:[WizWorkQueue downloadWorkQueueMain]];
}

- (void) downloadAttachment:(NSString *)attachmentGuid kbguid:(NSString *)kbguid accountUserId:(NSString *)accountUserId
{
    [self downloadObject:attachmentGuid type:WizObjectTypeAttachment kbguid:kbguid accountUserId:accountUserId onQueue:[WizWorkQueue downloadWorkQueueMain]];
}

- (void) autoDownloadDocument:(NSString *)guid kbguid:(NSString *)kbguid accountUserId:(NSString *)accountUserId
{
    [self downloadObject:guid type:WizObjectTypeDocument kbguid:kbguid accountUserId:accountUserId onQueue:[WizWorkQueue downloadWorkQueueBackgroud]];
}

- (void) autoDownloadDocument:(id<WizInfoDatabaseDelegate>)db duration:(NSInteger)duration kbguid:(NSString *)kbguid accountUserId:(NSString *)accountUserId
{
    WizDownloadSourceWorkObject* work = [[WizDownloadSourceWorkObject alloc] initWithAccountUserId:accountUserId kbguid:kbguid];
    [[WizWorkQueue downloadSourceQueue] addWorkObject:work];
}
- (void) autoDownloadDocumentByKbguid:(NSString *)kbguid accountUserId:(NSString *)accountUserId
{
    [[WizAutoDownloadThread shareInstance] addWorkObject:kbguid accountUserId:accountUserId];
}

- (BOOL) isSyncingKey:(NSString*)key
{
    NSInteger state  = [[WizSyncStatueCenter shareInstance] stateOfKey:key];
    if (state != WizXmlSyncStateEnd && state != WizXmlSyncStateError) {
        return YES;
    }
    else
    {
        return NO;
    }
 
}

- (void) downloadAttachment:(NSString *)attachmentGuid kbguid:(NSString *)kbguid accountUserId:(NSString *)accountUserId delegate:(id<WizDownloadDelegate>)delegate
{
    WizDownloadOperation* operation = [[WizDownloadOperation alloc] initWithAccountUserId:accountUserId kbguid:kbguid objGuid:attachmentGuid objType:WizObjectTypeAttachment];
    operation.delegate = delegate;
    [[WizWorkOperationQueue userDownloadQueue] addOperation:operation];
}

- (void) downloadDocument:(NSString *)documentguid kbguid:(NSString *)kbguid accountUserId:(NSString *)accountUserId delegate:(id<WizDownloadDelegate>)delegate
{
    WizDownloadOperation* operation = [[WizDownloadOperation alloc] initWithAccountUserId:accountUserId kbguid:kbguid objGuid:documentguid objType:WizObjectTypeAttachment];
    operation.delegate = delegate;
    [[WizWorkOperationQueue userDownloadQueue] addOperation:operation];
}

- (BOOL) isSyncingAccount:(NSString *)accountUserId
{
    return [self isSyncingKey:accountUserId];
}

- (BOOL) isSyncingDocument:(NSString *)documentguid
{
    if ([[WizWorkQueue downloadWorkQueueMain] hasWorkObjectByKey:documentguid]) {
        return YES;
    }
    return [self isSyncingKey:documentguid];
}

- (BOOL) isSyncingKbguid:(NSString *)kbguid
{
    if ([[WizWorkQueue kbSyncWorkQueue] hasWorkObjectByKey:kbguid]) {
        return YES;
    }
    return [self isSyncingKbguid:kbguid];
}

- (BOOL) isUploadOnly
{
    return isUploadOnly_;
}

@end
@interface WizCreateAccountOperation()
{
    NSString* accountUserId;
    NSString* accountPassword;
}
@end
@implementation WizCreateAccountOperation
@synthesize delegate;
- (id) initWithUserID:(NSString *)userid password:(NSString *)password
{
    self = [super init];
    if (self) {
        accountPassword = password;
        accountUserId = userid;
    }
    return self;
}
- (BOOL) isConcurrent
{
    return YES;
}
- (void) main
{
    @autoreleasepool {
        WizXmlAccountServer* accountServer = [[WizXmlAccountServer alloc] initWithUrl:[WizGlobals wizServerUrl]];
        if (![accountServer createAccount:accountUserId passwrod:accountPassword]) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate didCreateAccountFaild:accountServer.lastError];
            });
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate didCreateAccountSucceed:accountUserId password:accountPassword];
            });
        }
    }
}
@end

@interface WizSearchOnserverOperation ()
{
    NSString* kbguid;
    NSString* accountUserId;
    NSString* keywords;
}
@end
@implementation WizSearchOnserverOperation
@synthesize delegate;

- (id) initWithKb:(NSString *)kbguid_ accountUserId:(NSString *)accountUserId_ keywords:(NSString *)key
{
    self = [super init];
    if (self) {
        kbguid = kbguid_;
        accountUserId = accountUserId_;
        keywords = key;
    }
    return self;
}
- (BOOL) isConcurrent
{
    return YES;
}
- (void) main
{
    @autoreleasepool {
        NSError* error = nil;
        WizTokenAndKapiurl* tokenAndUrl = [[WizTokenManger shareInstance] tokenUrlForAccountUserId:accountUserId kbguid:kbguid error:&error];
        if (tokenAndUrl == nil) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate didSearchFaild:nil];
            });
        }
        else
        {
            id<WizInfoDatabaseDelegate> db = [WizDBManager getMetaDataBaseForKbguid:kbguid accountUserId:accountUserId];
            WizSyncKb* synckb = [[WizSyncKb alloc] initWithUrl:[NSURL URLWithString:tokenAndUrl.kApiUrl] token:tokenAndUrl.token kbguid:kbguid accountUserId:accountUserId dataBaser:db isUploadOnly:NO userPrivilige:0 isPersonal:NO];

            NSArray* array =  [synckb searchDocumentOnSearver:keywords];
            if (array == nil) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.delegate didSearchFaild:synckb.kbServer.lastError];
                });
            }
            else
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.delegate didsearchSucceed:array];
                });
            }
        }
    }
}
@end

@interface WizVerifyAccountOperation ()
{
    NSString* accountUserId;
    NSString* accountPassword;
}
@end
@implementation WizVerifyAccountOperation
@synthesize delegate;
- (id) initWithAccount:(NSString *)userId password:(NSString *)password;
{
    self = [super init];
    if (self) {
        accountPassword = password;
        accountUserId = userId;
    }
    return self;
}
- (BOOL) isConcurrent
{
    return YES;
}
- (void) main
{
    @autoreleasepool {
        WizXmlAccountServer* accountServer = [[WizXmlAccountServer alloc] initWithUrl:[WizGlobals wizServerUrl]];
        if (![accountServer verifyAccount:accountUserId passwrod:accountPassword]) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate didVerifyAccountFailed:accountServer.lastError];
            });
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate didVerifyAccountSucceed:accountUserId password:accountPassword kbguid:accountServer.loginData.kbguid];
            });
        }
        [accountServer accountLogout];
    }
}
@end


@interface WizSyncThread : NSThread
@property (nonatomic, strong) NSString* accountUserId;

@end

@implementation WizSyncThread

@synthesize accountUserId;

@end



