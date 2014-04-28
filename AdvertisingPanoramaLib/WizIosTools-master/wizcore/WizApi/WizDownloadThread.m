//
//  WizDownloadThread.m
//  WizIos
//
//  Created by dzpqzb on 12-12-20.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import "WizDownloadThread.h"
#import "WizWorkQueue.h"
#import "WizSyncKb.h"
#import "WizXmlAccountServer.h"
#import "WizGlobals.h"
#import "WizFileManager.h"
#import "WizNotificationCenter.h"
#import "WizTokenManger.h"
#import "WizGlobalError.h"
#import "WizGlobalData.h"
#import "Reachability.h"
@interface WizWorkOperationQueue ()
@property (nonatomic, assign) NSInteger balanceOperationCount;
+ (id) autoDownloadOperationQueue;
- (float) maxOperationthreadPriority;

@end
@interface WizBackgroudDownloadOperationQueue : WizWorkOperationQueue

@end

@implementation WizBackgroudDownloadOperationQueue

- (void) addOperation:(NSOperation *)op
{
    NSAssert([op isKindOfClass:[WizDownloadOperation class]], @"the operation is not wizDownloadOperation");
    NSArray* ops = [[self operations] copy];
    for (WizDownloadOperation* eachOp in ops) {
        if ([eachOp isEqualToWizDownloadOperation:(WizDownloadOperation*)op]) {
            return;
        }
    }
    op.threadPriority = [self maxOperationthreadPriority] - 1000 +1.0;
    [super addOperation:op];
}

@end




//download queue
@interface WizDownloadOperationQueue : WizWorkOperationQueue
@end
@implementation WizDownloadOperationQueue
- (id) init
{
    self = [super init];
    if (self) {
    }
    return self;
}
- (void) addOperation:(NSOperation *)op
{
    NSAssert([op isKindOfClass:[WizDownloadOperation class]], @"the operation is not wizDownloadOperation");
    NSArray* ops = [[self operations] copy];
    for (WizDownloadOperation* eachOp in ops) {
        if ([eachOp isEqualToWizDownloadOperation:(WizDownloadOperation*)op]) {
            WizDownloadOperation* dOp = (WizDownloadOperation*)op;
            eachOp.delegate = dOp.delegate;
            return;
        }
    }
    op.threadPriority = [self maxOperationthreadPriority] +1.0;
    [super addOperation:op];
}
@end


@implementation WizWorkOperationQueue
@synthesize balanceOperationCount;
- (void) balanceOperations
{
    
}
- (float) maxOperationthreadPriority
{
    float maxPriority = 100000;
    NSArray* operations = [[self operations] copy];
    for (NSOperation* each in operations) {
        maxPriority = each.threadPriority > maxPriority ? each.threadPriority : maxPriority;
    }
    return maxPriority;
}
+ (id) autoDownloadOperationQueue
{
    static WizWorkOperationQueue* workQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        workQueue = [WizGlobalData shareInstanceFor:[WizWorkOperationQueue class]];;
    });
    return workQueue;
}

+ (id) backgroudDownloadOperationQueue
{
    static WizWorkOperationQueue* workQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        workQueue =  [WizGlobalData shareInstanceFor:[WizWorkOperationQueue class] category:@"backgroudOperationQueue"];
    });
    return workQueue;
}

+ (id) userDownloadQueue{
    static WizDownloadOperationQueue* workQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        workQueue =[WizGlobalData shareInstanceFor:[WizDownloadOperationQueue class]];
    });
    return workQueue;
}

@end



@implementation WizDownloadOperation

@synthesize accountUserId = _accountUserId;
@synthesize kbguid = _kbguid;
@synthesize objGuid = _objGuid;
@synthesize objType = _objType;
@synthesize failBlock = _failBlock;
@synthesize succeedBlock = _succeedBlock;
@synthesize delegate;
- (id) initWithAccountUserId:(NSString*)accountUserId kbguid:(NSString *)kbguid objGuid:(NSString*)objGuid objType:(NSString*)objType
{
    self = [super init];
    if (self) {
        _accountUserId = accountUserId;
        _kbguid = kbguid;
        _objType = objType;
        _objGuid = objGuid;
        
    }
    return self;
}
- (BOOL) isEqualToWizDownloadOperation:(WizDownloadOperation *)operation
{
    return [self.accountUserId isEqualToString:operation.accountUserId] && [self.kbguid isEqualToString:operation.kbguid] && [self.objGuid isEqualToString:operation.objGuid];
}
- (BOOL) download:(NSError**)error
{
        WizTokenAndKapiurl* tokenAndUrl = [[WizTokenManger shareInstance] tokenUrlForAccountUserId:_accountUserId kbguid:_kbguid error:error];
        if (tokenAndUrl == nil) {
            return NO;
        }
        NSString* objectPath = [[WizFileManager shareManager] wizObjectFilePath:_objGuid accountUserId:_accountUserId];
        id<WizInfoDatabaseDelegate> db = [WizDBManager getMetaDataBaseForKbguid:self.kbguid accountUserId:self.accountUserId];
        WizSyncKb* syncKb = [[WizSyncKb alloc] initWithUrl:[NSURL URLWithString:tokenAndUrl.kApiUrl] token:tokenAndUrl.token kbguid:_kbguid accountUserId:_accountUserId dataBaser:db isUploadOnly:NO userPrivilige:0 isPersonal:NO];
        if ([_objType isEqualToString:WizObjectTypeDocument]) {
            if (![syncKb downloadDocument:_objGuid filePath:objectPath]) {
                if (error != NULL) {
                   *error = syncKb.kbServer.lastError; 
                }
                
                return NO;
            }
        }
        else if ([_objType isEqualToString:WizObjectTypeAttachment])
        {
            if (![syncKb downloadAttachment:_objGuid filePath:objectPath]) {
                if (error != NULL) {
                    *error = syncKb.kbServer.lastError;
                }
                return NO;
            }
        }
        return YES;
}
//using block to end is so complex in manangering the menmory.

- (void) main
{
    @autoreleasepool {
        [WizNotificationCenter OnSyncState:_objGuid event:WizXmlSyncStateStart messageType:WizXmlSyncEventMessageTypeDownload process:0.0];
        NSError* error = nil;
        if (![self download:&error]) {
           [WizNotificationCenter OnSyncErrorStatue:_objGuid messageType:WizXmlSyncEventMessageTypeDownload error:error];
        }
        else
        {
            NSString* title = NSLocalizedString(@"No title", nil);
            id<WizInfoDatabaseDelegate> db = [WizDBManager getMetaDataBaseForKbguid:_kbguid accountUserId:_accountUserId];
            if ([_objType isEqualToString:WizObjectTypeDocument]) {
                WizDocument* doc = [db documentFromGUID:_objGuid];
                title = doc.title;
                [self.delegate onSucceed:self.objGuid];
            }
            else if ([_objType isEqualToString:WizObjectTypeAttachment])
            {
                WizAttachment* attachment = [db attachmentFromGUID:_objGuid];
                title = attachment.title;
            }
            NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:title, @"title", [NSNumber numberWithInt:1], @"process", nil];
            [WizNotificationCenter OnSyncState:_objGuid event:WizXmlSyncStateEnd messageType:WizXmlSyncEventMessageTypeDownload otherInfo:userInfo];
            if (self.succeedBlock) {
                self.succeedBlock(self.objGuid);
            }
        }
    }
}
@end



@protocol WizAutoDownloadProtocol <NSObject>
- (void) loadResources;
- (NSString*) autoDownloadAccountUserId;
- (NSString*) autoDownloadUserId;
- (WizDocument*) nextDocumentForDownload;
@end



@interface WizAutoDownloadWorkObject ()
- (BOOL) isEqualToKbguid:(NSString*)kb accountUserId:(NSString*)userId;
@end

@implementation WizAutoDownloadWorkObject

@synthesize accountUserId;
@synthesize kbguid;

- (NSString*) key
{
    return [NSString stringWithFormat:@"%@%@",kbguid,accountUserId];
}
- (BOOL) isEqualToKbguid:(NSString*)kb accountUserId:(NSString*)userId
{
    if ([kbguid isEqualToString:kb] && [userId isEqualToString:accountUserId]) {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end

NSMutableDictionary* allDownloadThreads = nil;
NSMutableArray* allErrorDownloadDocments = nil;
typedef enum  {
    WizAutoDownloadWorkObjectIndexNotFound = -2,
    WizAutoDownloadWorkObjectLastWorkObject = -1,
    } WizAutoDownloadWorkObjectIndex;

@interface WizAutoDownloadThread ()
{
    NSArray* groupsArray;
    NSInteger needDownloadCount;
}
@property (nonatomic, strong) NSString* accountUserId;
@property (nonatomic, assign) BOOL stop;
@property (nonatomic, assign) BOOL restartAutoDownload;
@end

@implementation WizAutoDownloadThread
@synthesize accountUserId = _accountUserId;
@synthesize stop = _stop;
@synthesize restartAutoDownload = _restartAutoDownload;

- (id) init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (id) initWithAccountUserId:(NSString*)accountUserId_
{
    self = [super init];
    if (self) {
        self.accountUserId = accountUserId_;
        _stop = NO;
        _restartAutoDownload = YES;
    }
    return self;
}

+ (void)beginAutoDownload:(NSString *)accountUserId
{
    if (accountUserId == nil || [accountUserId isEqualToString:WGDefaultAccountUserId]) {
        return ;
    }
    if (![[WizSettings defaultSettings]canAutoSync]) {
        return ;
    }
    if (allDownloadThreads == nil) {
        allDownloadThreads = [NSMutableDictionary dictionary];
    }
    @synchronized(allDownloadThreads){
        WizAutoDownloadThread* thread = [allDownloadThreads objectForKey:accountUserId];
        if (thread == nil) {
            thread = [[WizAutoDownloadThread alloc]initWithAccountUserId:accountUserId];
            [thread setThreadPriority:0.0];
            [thread start];
            [allDownloadThreads setObject:thread forKey:accountUserId];
        }
        if (thread.restartAutoDownload) {
            return ;
        }
        thread.stop = NO;
        thread.restartAutoDownload = YES;
    }
}

+ (void)stopAllWorks
{
    @synchronized(allDownloadThreads){
        if ([allDownloadThreads count] > 0) {
            for (WizAutoDownloadThread* eachThread in [allDownloadThreads allValues]) {
                eachThread.stop = YES;
            }
            [allDownloadThreads removeAllObjects];
        }
    }
}

+ (void)stopAutoDownload:(NSString *)accountUserId
{
    WizAutoDownloadThread* thread = [allDownloadThreads objectForKey:accountUserId];
    if (thread == nil) {
        return ;
    }
    thread.stop = YES;
    thread.restartAutoDownload = NO;
    @synchronized(allDownloadThreads){
        [allDownloadThreads removeObjectForKey:accountUserId];
    }
}


- (NSArray*)getMoreNeedsDownloadDocumentsFromDB:(id<WizInfoDatabaseDelegate>)database duration:(NSInteger)duration
{
    NSString* errorGuids = [allErrorDownloadDocments componentsJoinedByString:@","];
    return [database documentsForDownloadByDuration:duration exceptGuids:errorGuids];
}

- (BOOL)autoDownloadKb:(NSString*)kbguid
{
    NSError* error = nil;
    WizTokenAndKapiurl* tokenAndUrl = [[WizTokenManger shareInstance] tokenUrlForAccountUserId:_accountUserId kbguid:kbguid error:&error];
    if (!tokenAndUrl) {
        return NO;
    }
    id<WizInfoDatabaseDelegate> db = [WizDBManager getMetaDataBaseForKbguid:kbguid accountUserId:_accountUserId];
    WizSyncKb* syncKb = [[WizSyncKb alloc] initWithUrl:[NSURL URLWithString:tokenAndUrl.kApiUrl] token:tokenAndUrl.token kbguid:kbguid accountUserId:kbguid dataBaser:db isUploadOnly:NO userPrivilige:0 isPersonal:NO];
    if (allErrorDownloadDocments == nil) {
        allErrorDownloadDocments = [NSMutableArray array];
    }
    while (1) {
        NSInteger duration = 0;
        if (kbguid) {
            duration = [[WizSettings defaultSettings] offlineDownloadDuration:SettingGlobalKbguid accountUserID:_accountUserId];
        }else{
            duration = [[WizSettings defaultSettings] offlineDownloadDuration:nil accountUserID:_accountUserId];
        }
        NSArray* array = [self getMoreNeedsDownloadDocumentsFromDB:db duration:duration];
        if ([array count] == 0) {
            break ;
        }
        needDownloadCount += [array count];
        for (WizDocument* doc in array) {
            NSString* objectFilePath = [[WizFileManager shareManager] wizObjectFilePath:doc.guid accountUserId:_accountUserId];
            if (![syncKb downloadDocument:doc.guid filePath:objectFilePath]) {
                [allErrorDownloadDocments addObject:[NSString stringWithFormat:@"'%@'",doc.guid]];
            }
            if (_stop) {
                break;
            }
            sleep(0.1);
        }
        if (_stop) {
            break;
        }
    }
    return YES;
}

- (BOOL)startAutoDownload
{
    BOOL success = YES;
    needDownloadCount = 0;
    [WizNotificationCenter OnSyncState:WizGlobalPersonalKbguid event:WizAutoDownloadThreadStateStart messageType:WizAutoDownloadMessage otherInfo:nil];
    success = [self autoDownloadKb:nil];
    [WizNotificationCenter OnSyncState:WizGlobalPersonalKbguid event:WizAutoDownloadThreadStateEnd messageType:WizAutoDownloadMessage otherInfo:[NSDictionary dictionaryWithObject:@(needDownloadCount) forKey:KeyOfDownloadNotesCount]];
    
    needDownloadCount = 0;
    groupsArray = [[WizAccountManager defaultManager]groupsForAccount:_accountUserId];
    [WizNotificationCenter OnSyncState:WizNotificationUserInfoKbguid event:WizAutoDownloadThreadStateStart messageType:WizAutoDownloadMessage otherInfo:nil];
    for (WizGroup* eachGroup in groupsArray) {
        if (eachGroup.guid == nil || [eachGroup.guid isEqualToString:WizGlobalPersonalKbguid]) {
            continue ;
        }
       success = [self autoDownloadKb:eachGroup.guid] && success;
    }
    [WizNotificationCenter OnSyncState:WizNotificationUserInfoKbguid event:WizAutoDownloadThreadStateEnd messageType:WizAutoDownloadMessage otherInfo:[NSDictionary dictionaryWithObject:@(needDownloadCount) forKey:KeyOfDownloadNotesCount]];
    return success;
}

+ (BOOL)isAutoDownloading:(NSString *)accountUserId
{
    @synchronized(allDownloadThreads){
        if (allDownloadThreads == nil || [allDownloadThreads count] == 0) {
            return NO;
        }
        WizAutoDownloadThread* thread = [allDownloadThreads objectForKey:accountUserId];
        if (thread == nil) {
            return NO;
        }
        return thread.restartAutoDownload;
    }
}

- (void)main
{
    while (1) {
        @autoreleasepool {
            if (_stop) {
                break ;
            }
            if (_restartAutoDownload) {
                [[WizSyncStatueCenter shareInstance]increaseNetworkInteractCount];
                [self startAutoDownload];
                _restartAutoDownload = NO;
                [[WizSyncStatueCenter shareInstance]decreaseNetworInteractCount];
            }else{
                sleep(10);
            }
        }
    }
}


@end