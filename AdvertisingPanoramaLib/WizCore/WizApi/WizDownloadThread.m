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
#import "WizGlocalError.h"
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
        self.maxConcurrentOperationCount = 10;
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
    @autoreleasepool {
        WizTokenAndKapiurl* tokenAndUrl = [[WizTokenManger shareInstance] tokenUrlForAccountUserId:_accountUserId kbguid:_kbguid error:error];
        if (tokenAndUrl == nil) {
            return NO;
        }
        NSString* objectPath = [[WizFileManager shareManager] wizObjectFilePath:_objGuid accountUserId:_accountUserId];

        id<WizInfoDatabaseDelegate> db = [WizDBManager getMetaDataBaseForKbguid:self.kbguid accountUserId:self.accountUserId];
        WizSyncKb* syncKb = [[WizSyncKb alloc] initWithUrl:[NSURL URLWithString:tokenAndUrl.kApiUrl] token:tokenAndUrl.token kbguid:_kbguid accountUserId:_accountUserId dataBaser:db isUploadOnly:NO userPrivilige:0 isPersonal:NO];
        if ([_objType isEqualToString:WizObjectTypeDocument]) {
            if (![syncKb downloadDocument:_objGuid filePath:objectPath]) {
                *error = syncKb.kbServer.lastError;
                return NO;
            }
        }
        else if ([_objType isEqualToString:WizObjectTypeAttachment])
        {
            if (![syncKb downloadAttachment:_objGuid filePath:objectPath]) {
                *error = syncKb.kbServer.lastError;
                return NO;
            }
        }
        return YES;
    }
    
}
//using block to end is so complex in manangering the menmory.

- (void) main
{
    @autoreleasepool {

        [WizNotificationCenter OnSyncState:_objGuid event:WizXmlSyncStateStart messageType:WizXmlSyncEventMessageTypeDownload process:0.0];
        NSError* error = nil;
        if (![self download:&error]) {
           [WizNotificationCenter OnSyncErrorStatue:_objGuid messageType:WizXmlSyncEventMessageTypeDownload error:error];
            [self.delegate onError:error];
            if (self.failBlock) {
                self.failBlock(error);
            }
        }
        else
        {
            NSString* title = NSLocalizedString(@"No title", nil);
            id<WizInfoDatabaseDelegate> db = [WizDBManager getMetaDataBaseForKbguid:_kbguid accountUserId:_accountUserId];
            if ([_objType isEqualToString:WizObjectTypeDocument]) {
                WizDocument* doc = [db documentFromGUID:_objGuid];
                title = doc.title;
                [self.delegate onSucceed:self.objGuid];
                WizGenAbstractWorkObject* work = [[WizGenAbstractWorkObject alloc] init];
                work.accountUserId = self.accountUserId;
                work.docGuid = self.objGuid;
                work.type = WizGenerateAbstractTypeReload;
                [[WizWorkQueue genAbstractQueue] addWorkObject:work];
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

typedef enum  {
    WizAutoDownloadWorkObjectIndexNotFound = -2,
    WizAutoDownloadWorkObjectLastWorkObject = -1,
    } WizAutoDownloadWorkObjectIndex;

@interface WizAutoDownloadThread ()
@property (nonatomic, strong) NSMutableArray* sourceArray;
@property (atomic, strong) WizAutoDownloadWorkObject* lastWorkObject;
@end

@implementation WizAutoDownloadThread
@synthesize isClearStop;
@synthesize lastWorkObject = _lastWorkObject;
@synthesize sourceArray = _sourceArray;
- (id) init
{
    self = [super init];
    if (self) {
        _sourceArray = [NSMutableArray new];
        [self start];
    }
    return self;
}

+ (WizAutoDownloadThread*) shareInstance
{
    static WizAutoDownloadThread* thread = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        thread = [WizGlobalData shareInstanceFor:[WizAutoDownloadThread class]];;
    });
    return thread;
}
- (NSInteger) indexOfWorkObject:(NSString*)kbguid accountUserId:(NSString*)userId
{
    for (int i = 0 ; i < [self.sourceArray count] ; i++) {
        WizAutoDownloadWorkObject* each  = [self.sourceArray objectAtIndex:i];
        if ([each isEqualToKbguid:kbguid accountUserId:userId]) {
            return i;
        }
    }
    if ([self.lastWorkObject isEqualToKbguid:kbguid accountUserId:userId]) {
        return WizAutoDownloadWorkObjectLastWorkObject;
    }
    return WizAutoDownloadWorkObjectIndexNotFound;
}
- (void) addWorkObject:(NSString *)kbguid accountUserId:(NSString *)accountUserId
{
    
    @synchronized(self)
    {
        NSInteger index = [self indexOfWorkObject:kbguid accountUserId:accountUserId];
        if (index >= WizAutoDownloadWorkObjectLastWorkObject) {
            return;
        }
        WizAutoDownloadWorkObject* object = [[WizAutoDownloadWorkObject alloc] init];
        object.kbguid = kbguid;
        object.accountUserId = accountUserId;
        [self.sourceArray addObject:object];
    }
}

- (void) removeWorkObject:(NSString *)kbguid accountUserId:(NSString *)accountUserId
{
    @synchronized(self)
    {
        NSInteger index = [self indexOfWorkObject:kbguid accountUserId:accountUserId];
        if (index > WizAutoDownloadWorkObjectLastWorkObject) {
            [self.sourceArray removeObjectAtIndex:index];
        }
        else if (index == WizAutoDownloadWorkObjectLastWorkObject)
        {
            self.lastWorkObject = nil;
        }
    }
}
- (void) cancelAllWork
{
    @synchronized(self)
    {
        [self.sourceArray removeAllObjects];
        self.lastWorkObject = nil;
    }
}
- (void) main
{
    @autoreleasepool {
        while (true) {
            self.lastWorkObject = [self.sourceArray lastObject];
            [self.sourceArray removeObject:self.lastWorkObject];
            if (self.lastWorkObject) {
                WizAutoDownloadWorkObject* sourceDelegate = self.lastWorkObject;
                if (!sourceDelegate) {
                    continue;
                }
                NSError* error = nil;
                    WizTokenAndKapiurl* tokenAndUrl = [[WizTokenManger shareInstance] tokenUrlForAccountUserId:sourceDelegate.accountUserId kbguid:sourceDelegate.kbguid error:&error];
                    if (!tokenAndUrl) {
                        continue;
                    }
                    id<WizInfoDatabaseDelegate> db = [WizDBManager getMetaDataBaseForKbguid:sourceDelegate.kbguid accountUserId:sourceDelegate.accountUserId];
                    WizSyncKb* syncKb = [[WizSyncKb alloc] initWithUrl:[NSURL URLWithString:tokenAndUrl.kApiUrl] token:tokenAndUrl.token kbguid:sourceDelegate.kbguid accountUserId:sourceDelegate.kbguid dataBaser:db isUploadOnly:NO userPrivilige:0 isPersonal:NO];
                    NSInteger duration = [[WizSettings defaultSettings] offlineDownloadDuration:sourceDelegate.kbguid accountUserID:sourceDelegate.accountUserId];
                    for (WizDocument* doc = [db nextDocumentForDownloadByDuraion:duration] ; doc ; doc = [db nextDocumentForDownloadByDuraion:duration]) {
                        // 下载数据 判断网络条件
                        duration = [[WizSettings defaultSettings] offlineDownloadDuration:sourceDelegate.kbguid accountUserID:sourceDelegate.accountUserId];
                        NSString* objectFilePath = [[WizFileManager shareManager] wizObjectFilePath:doc.guid accountUserId:sourceDelegate.accountUserId];
                        if (![syncKb downloadDocument:doc.guid filePath:objectFilePath]) {
                            [WizNotificationCenter OnSyncErrorStatue:doc.guid messageType:WizXmlSyncEventMessageTypeDownload error:syncKb.kbServer.lastError];
                            break;
                        }
                        else
                        {
                            NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:doc.title, @"title", [NSNumber numberWithInt:1], @"process", nil];
                            [WizNotificationCenter OnSyncState:doc.guid event:WizXmlSyncStateEnd messageType:WizXmlSyncEventMessageTypeDownload otherInfo:userInfo];
                            //
                            WizGenAbstractWorkObject* work = [[WizGenAbstractWorkObject alloc] init];
                            work.accountUserId = sourceDelegate.accountUserId;
                            work.docGuid = doc.guid;
                            work.type = WizGenerateAbstractTypeReload;
                            [[WizWorkQueue genAbstractQueue] addWorkObject:work];
                        }
                    }
                [WizNotificationCenter OnSyncState:sourceDelegate.kbguid event:WizXmlSyncStateEnd messageType:WizXmlSyncEventMessageTypeDownload otherInfo:nil];
                self.lastWorkObject = nil;
            }
            else
            {
                [NSThread sleepForTimeInterval:1];
            }
        }
    }
}

@end