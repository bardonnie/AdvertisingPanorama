
//
//  WizSyncCenter.m
//  WizIos
//
//  Created by dzpqzb on 12-12-20.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//
#import "WizAppStatueCenter.h"
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
#import "WizGlobalError.h"

#import "WizNetworkEngine.h"
dispatch_source_t CreateDispatchTimer(uint64_t interval,
                                      uint64_t leeway,
                                      dispatch_queue_t queue,
                                      dispatch_block_t block)
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                                     0, 0, queue);
    if (timer)
    {
        dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), interval, leeway);
        dispatch_source_set_event_handler(timer, block);
        
    } 
    return timer; 
}

@implementation NSOperationQueue(WizOperation)
+ (NSOperationQueue*)backGroupQueue
{
    @synchronized(self)
    {
        return [WizGlobalData shareInstanceFor:[NSOperationQueue class] category:@"WizBackgroudOperation"];
    }
}
+ (NSOperationQueue*) searchOperationQueue
{
    @synchronized(self)
    {
        NSOperationQueue* queue = [WizGlobalData shareInstanceFor:[NSOperationQueue class] category:@"WizSearchOperationQueue"];
        return queue;
    }
}
@end

static NSInteger const MaxCountOfDownloadThread = 10;
static NSInteger const MaxCountOfBackgroudDownloadThread = 7;
//wenlin start
static NSInteger const MaxCountOfSyncKbThread  = 1;
//static NSInteger const MaxCountOfSyncKbThread  = 3;
//wenlin end

@interface WizSyncCenter ()
{
    BOOL isUploadOnly_;
    dispatch_source_t checkeMessageTimeSourceT;
    
    //
    NSMutableSet* syncMessageCommands;
}
@end

@implementation WizSyncCenter

- (void) stopAutoDownload
{
    [[WizWorkQueue downloadSourceQueue] removeAllWorkObject];
    [WizAutoDownloadThread stopAllWorks];
    [[WizWorkQueue downloadWorkQueueBackgroud] removeAllWorkObject];
}
- (void) reachabilityChanged:(NSNotification*)nc
{
//    Reachability* reach = [nc object];
//    if ([reach currentReachabilityStatus] != ReachableViaWiFi) {
//        [self stopAutoDownload];
//    }
    if (![[WizSettings defaultSettings]canAutoSync]) {
        [self stopAutoDownload];
    }
}

- (void) addCheckeMessageTimer
{
    static double MessageCheckTimeSpace = 180ull;
    dispatch_source_t aTimer = CreateDispatchTimer(MessageCheckTimeSpace*NSEC_PER_SEC, 1ull*NSEC_PER_SEC, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
//        NSLog(@"WizSyncCenter addCheckeMessageTimer start");
        
        NSString* accountUserId = [[WizAccountManager defaultManager] activeAccountUserId];
        NSDictionary* dic = [[WizSettings defaultSettings] accountAttributes:accountUserId];
        if (dic) {
            if (IsReachableInternerViaWifi()) {
                NSString* guid = [dic userGuid];
                if (guid && ![guid isBlock]) {
                    int64_t version = [[WizNetworkEngine  shareEngine] messageMaxVersionForUserGUID:guid];
                    id<WizTemporaryDataBaseDelegate> db = [WizDBManager temporaryDataBase];
                    int64_t localVersion = [db messageVersionForAccount:accountUserId];
                    if (localVersion < version || [db isMessagesDataDirty:accountUserId])
                    {
                        [[WizSyncCenter shareCenter] syncMessagesForAccountUserId:accountUserId];
                    }
                }
            }
        }
    });
    checkeMessageTimeSourceT = aTimer;
    double delayInSeconds = MessageCheckTimeSpace;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void)
    {
        dispatch_resume(checkeMessageTimeSourceT);
    });
}


- (id) init
{
    self = [super init];
    if (self) {
        syncMessageCommands = [NSMutableSet set];
        [NSURLCache setSharedURLCache:[[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil]];
        [WizNotificationCenter shareCenter];
        [WizGlobalCache shareInstance];
        [self addCheckeMessageTimer];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        NetworkUnreachable showUnreadchAlert = ^(Reachability* reachability)
        {
            if ([reachability currentReachabilityStatus] == NotReachable) {
                
                if ([NSThread isMainThread]){
                    [[WizAppStatueCenter shareInstance] showGlobalErrorMessage:NSLocalizedString(@"No Internet connection avaiable", nil)];
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[WizAppStatueCenter shareInstance] showGlobalErrorMessage:NSLocalizedString(@"No Internet connection avaiable", nil)];
                    });
                }
            }
          
        };
        AddUnReachableBlock(showUnreadchAlert);
        
        AddUnReachableBlock(^(Reachability *reachability) {
            [self stopAutoDownload];
        });
        AddReachableBlock(^(Reachability *reachability) {
            if (reachability.isReachable && reachability.currentReachabilityStatus == ReachableViaWiFi) {
//                [WizAutoDownloadThread beginAutoDownload:accountUserId];
            }
        });

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
    [WizAutoDownloadThread beginAutoDownload:userId];
}


- (void) registerAccountNotificate:(NSNotification*)nc
{
    NSString* accountUserId = [[nc userInfo] objectForKey:@"userId"];
    [WizAutoDownloadThread beginAutoDownload:accountUserId];
}

- (BOOL) syncAccount:(NSString*)accountUserId password:(NSString*)password isGroup:(BOOL) isGroup isUploadOnly:(BOOL) isUploadOnly currentKbGUID: (NSString*)currentKbGUID
{
    if ([[WizAccountManager defaultManager] isExperiencing]) {
        [WizGlobalError reportIsExperiencingWarning];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StopLoadingAnmation" object:nil];
        [WizNotificationCenter OnSyncKbState:WizGlobalPersonalKbguid event:WizXmlSyncStateError process:0];
        return NO;
    }

    WizSyncAccountType type = isGroup ? WizSyncAccountTypeAll : WizSyncAccountTypePesonal;
    
    [WizSyncAccountThread sync:accountUserId password:password isUploadOnly:isUploadOnly syncType:type kbguid:currentKbGUID];
    return YES;
}


- (BOOL) syncKbGuid:(NSString *)kbguid accountUserId:(NSString *)accountUserId password:(NSString *)password isUploadOnly:(BOOL)isUPloadOnly  userGroup:(NSInteger)userGroup
{
    if ([[WizAccountManager defaultManager] isExperiencing]) {
        if (isUPloadOnly) {
            return NO;
        }
        [WizGlobalError reportIsExperiencingWarning];
        [WizNotificationCenter OnSyncKbState:WizGlobalPersonalKbguid event:WizXmlSyncStateError process:0];
        return NO;
    }
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
    return YES;
}

- (void) downloadObject:(NSString*)objGuid type:(NSString*)objType kbguid:(NSString *)kbguid accountUserId:(NSString *)accountUserId onQueue:(WizWorkQueue*)queue
{
    if ([[WizAccountManager defaultManager] isExperiencing]) {
        [WizGlobalError reportIsExperiencingWarning];
        return;
    }
    WizDownloadOperation* operation = [[WizDownloadOperation alloc] initWithAccountUserId:accountUserId kbguid:kbguid objGuid:objGuid objType:objType];
    [[WizWorkOperationQueue userDownloadQueue] addOperation:operation];
}

- (void) autoSyncKbguid:(NSString *)kbguid accountUserId:(NSString *)accountUserId
{
    if ([[WizSettings defaultSettings] canAutoSync]) {
        [WizSyncAccountThread addKb:kbguid accountUserId:accountUserId];
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
- (void) syncMessagesForAccountUserId:(NSString*)accountUserId
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
//        NSLog(@"WizSyncCenter syncMessagesForAccountUserId: start");
        
        [WizNotificationCenter OnSyncMessageAccountUserId:accountUserId event:WizXmlSyncStateStart error:nil];
        WizXmlAccountServer* accountServer = [[WizXmlAccountServer alloc] initWithUrl:[WizGlobals wizServerUrl]];
        id<WizTemporaryDataBaseDelegate> db = [WizDBManager temporaryDataBase];
        NSString* password = [[WizAccountManager defaultManager] activeAccountPassword];
        if (![accountServer accountClientLogin:accountUserId passwrod:password]) {
            [WizNotificationCenter OnSyncMessageAccountUserId:accountUserId event:WizXmlSyncStateError error:accountServer.lastError];
            if (accountServer.lastError.code == WizErrorCodeInvalidPassword || accountServer.lastError.code == 312) {
            }
            return ;
        };

        if (![accountServer getAllMessages:db forAccount:accountUserId sendMessage:NO]) {
            [WizNotificationCenter OnSyncMessageAccountUserId:accountUserId event:WizXmlSyncStateError error:accountServer.lastError];
            return ;
        }
        
        if ([db isMessagesDataDirty:accountUserId]) {
            if (![accountServer postAllChangedStatusMessages:db forAccount:accountUserId status:WizMessageReadStatusReaded]) {
                
            }
        }
        [WizNotificationCenter OnSyncMessageAccountUserId:accountUserId event:WizXmlSyncStateEnd error:nil];
    });
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
                [self.delegate didCreateAccountSucceed:accountUserId password:accountPassword userGuid:@""];
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
    NSString* location;
    NSString* tagGuid;
    BOOL withSubFolder;
    BOOL withSubTag;
}
@end
@implementation WizSearchOnserverOperation
@synthesize delegate;
@synthesize kbguid;
@synthesize keywords;
@synthesize accountUserId;
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

- (id)initWithKb:(NSString *)kbguid_ accountUserId:(NSString *)accountUserId_ keywords:(NSString *)key_ location:(NSString *)location_ withSubFolder:(BOOL)withSubFolder_ tag:(NSString *)tagGuid_ withSubTag:(BOOL)withSubTag_ {
    self=[self initWithKb:kbguid_ accountUserId:accountUserId_ keywords:key_];
    if (self){
        location=location_;
        tagGuid=tagGuid_;
        withSubTag=withSubTag_;
        withSubFolder=withSubFolder_;
    }
    return self;
}


- (BOOL) isConcurrent
{
    return YES;
}
- (void) start
{
    @autoreleasepool {
        if (self.isCancelled) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate didSearchFaild:self error:nil];
            });
            return;
        }
        NSError* error = nil;
        WizTokenAndKapiurl* tokenAndUrl = [[WizTokenManger shareInstance] tokenUrlForAccountUserId:accountUserId kbguid:kbguid error:&error];
        if (self.isCancelled) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate didSearchFaild:self error:error];
            });
            return;
        }
        if (tokenAndUrl == nil) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate didSearchFaild:self error:nil];
            });
        }
        else
        {
            id<WizInfoDatabaseDelegate> db = [WizDBManager getMetaDataBaseForKbguid:kbguid accountUserId:accountUserId];
            WizSyncKb* synckb = [[WizSyncKb alloc] initWithUrl:[NSURL URLWithString:tokenAndUrl.kApiUrl] token:tokenAndUrl.token kbguid:kbguid accountUserId:accountUserId dataBaser:db isUploadOnly:NO userPrivilige:0 isPersonal:NO];
            if (self.isCancelled) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.delegate didSearchFaild:self error:nil];
                });
                return;
            }

            NSArray* array= nil;
            if (location==nil&&tagGuid==nil)
                array = [synckb searchDocumentOnSearver:keywords];
            else if (location!=nil){
                //搜索文件夹，忽略标签
                NSMutableString *searchPara= [NSMutableString stringWithFormat:@"%@ folder:%@",keywords,location];
                if (withSubFolder){
                    NSArray *subFolders=[db subFolders:location];
                    for (int i=0;i<subFolders.count;i++){
                        [searchPara appendFormat:@" folder:%@", [subFolders objectAtIndex:i]];
                    }
                }
                array = [synckb searchDocumentOnSearver:searchPara];
                //备注：测试发现服务器返回结果不正确。已经和服务器确认问题在服务器。 2013.04.24
            } else if (tagGuid!=nil){
                //由于上面的文件夹搜索已经出现问题，所以tag未测试
                NSMutableString *searchPara= [NSMutableString stringWithFormat:@"%@ any: tag:%@",keywords,tagGuid];
                if (withSubTag){
                    NSArray *subTags=[db subTags:tagGuid];
                    for (int i=0;i<subTags.count;i++){
                        WizTag *tag= [subTags objectAtIndex:i];
                        [searchPara appendFormat:@" tag:%@", tag.guid];
                    }
                }
                array = [synckb searchDocumentOnSearver:searchPara];
            }


            if (self.isCancelled) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if ([delegate respondsToSelector:@selector(didSearchCancel:)]) {
                        [delegate didSearchCancel:self];
                    }
                });
                return;
            }
            if (array == nil) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.delegate didSearchFaild:self error:synckb.kbServer.lastError];
                });
            }
            else
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if ([self.delegate respondsToSelector:@selector(didsearchSucceed:result:)]) {
                        [self.delegate didsearchSucceed:self result:array];
                    }
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
                [self.delegate didVerifyAccountSucceed:accountUserId password:accountPassword kbguid:accountServer.loginData.kbguid userGuid:accountServer.loginData.userGuid];
            });
        }
        [[WizAccountManager defaultManager] fixGuidField];
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

@interface WizGetCerOperation : NSOperation
@end

@interface WizGetCerOperation ()
@property (nonatomic, strong) NSString* accountUserId;
@end

@implementation WizGetCerOperation

@synthesize accountUserId = _accountUserId;
@end



