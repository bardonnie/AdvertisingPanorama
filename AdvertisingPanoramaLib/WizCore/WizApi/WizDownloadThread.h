//
//  WizDownloadThread.h
//  WizIos
//
//  Created by dzpqzb on 12-12-20.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizWorkQueue.h"
//download source type.
typedef void(^WizDownloadFaildBlock)(NSError* error);
typedef void(^WizDownloadSucceedBlock) (NSString* objcegGuid);
enum WizDownloadSourceType {
    //all download queue
    WizDownloadSourceTypeAll = 0,
    //user download queue
    WizDownloadSourceTypeUser = 1
};
/**The download thread.
 When the app luanch , the thread start too. and the thread check the queue, if there are documents or attachments to be downloaded. It will work to download its. If not, thre thread will sleep 0.5 seconds.
 */

@protocol WizDownloadDelegate <NSObject>

- (void) onError:(NSError*)error;

- (void) onSucceed:(NSString*)guid;

@end


@interface WizDownloadOperation : NSOperation
@property (nonatomic, strong) NSString* accountUserId;
@property (nonatomic, strong) NSString* kbguid;
@property (nonatomic, strong) NSString* objGuid;
@property (nonatomic, strong) NSString* objType;
@property (nonatomic, strong) WizDownloadSucceedBlock succeedBlock;
@property (nonatomic, strong) WizDownloadFaildBlock failBlock;
@property (nonatomic, weak) id<WizDownloadDelegate> delegate;
- (id) initWithAccountUserId:(NSString*)accountUserId kbguid:(NSString *)kbguid objGuid:(NSString*)objGuid objType:(NSString*)objType;
- (BOOL) isEqualToWizDownloadOperation:(WizDownloadOperation*)operation;
@end

@interface WizWorkOperationQueue : NSOperationQueue
+ (id) userDownloadQueue;
+ (id) autoDownloadOperationQueue;
- (void) balanceOperations;
@end
@interface WizAutoDownloadThread : NSThread
@property (nonatomic, assign) BOOL isClearStop;
+ (WizAutoDownloadThread*) shareInstance;
- (void) cancelAllWork;
- (void) addWorkObject:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
- (void) removeWorkObject:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
@end
