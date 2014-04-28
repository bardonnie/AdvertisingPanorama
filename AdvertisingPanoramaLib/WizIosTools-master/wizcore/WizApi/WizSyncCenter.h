//
//  WizSyncCenter.h
//  WizIos
//
//  Created by dzpqzb on 12-12-20.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizInfoDatabaseDelegate.h"
#import "WizSyncStatueCenter.h"
#import "WizDownloadThread.h"
#import "WizXmlServer.h"
#import "WizXmlKbServer.h"

/**The wiz backgroud operation queue.
 if you want to start a backgroup short process like NSOperation, you can use this queue.
 */
@interface NSOperationQueue (WizOperation)
+ (NSOperationQueue*) backGroupQueue;
+ (NSOperationQueue*) searchOperationQueue;
@end

/**The sync manager
 All sync commonds must be sended via this singleton class.
 */
@interface WizSyncCenter : NSObject
+ (WizSyncCenter*) shareCenter;
- (BOOL) syncAccount:(NSString*)accountUserId password:(NSString*)password isGroup:(BOOL) isGroup isUploadOnly:(BOOL) isUploadOnly currentKbGUID: (NSString*)currentKbGUID;
- (void) downloadDocument:(NSString*)documentguid kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
- (void) downloadAttachment:(NSString*)attachmentGuid kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
- (void) autoDownloadDocument:(id<WizInfoDatabaseDelegate>)db duration:(NSInteger)duration kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
- (BOOL) syncKbGuid:(NSString*)kbguid accountUserId:(NSString*)accountUserId password:(NSString*) password isUploadOnly:(BOOL) isUPloadOnly userGroup:(NSInteger)userGroup;
- (BOOL) isSyncingAccount:(NSString*)accountUserId;
- (BOOL) isSyncingKbguid:(NSString*)kbguid;
- (BOOL) isSyncingDocument:(NSString*)documentguid;
- (void) autoSyncKbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
- (BOOL) isUploadOnly;
- (void) downloadAttachment:(NSString *)attachmentGuid kbguid:(NSString *)kbguid accountUserId:(NSString *)accountUserId delegate:(id<WizDownloadDelegate>)delegate;
- (void) downloadDocument:(NSString *)documentguid kbguid:(NSString *)kbguid accountUserId:(NSString *)accountUserId delegate:(id<WizDownloadDelegate>)delegate;
- (void) startAutoDownloadForAccount:(NSString*)userId;
- (void) syncMessagesForAccountUserId:(NSString*)accountUserId;
@end
/**Verify account delegate
 
 */
@protocol WizVerifyAccountDelegate <NSObject>
- (void) didVerifyAccountFailed:(NSError*)error;
- (void) didVerifyAccountSucceed:(NSString*) userId password:(NSString*)password kbguid:(NSString*)kbguid userGuid:(NSString *)userGuid;
@end

@interface WizVerifyAccountOperation : NSOperation
@property (nonatomic, weak) id<WizVerifyAccountDelegate> delegate;
- (id) initWithAccount:(NSString*)userId password:(NSString*)password;
@end

@protocol WizCreateAccountDelegate <NSObject>
- (void) didCreateAccountFaild:(NSError*)error;
- (void) didCreateAccountSucceed:(NSString*)userId password:(NSString*)password userGuid:(NSString *)userGuid;
@end
@interface WizCreateAccountOperation : NSOperation
@property (nonatomic, weak) id<WizCreateAccountDelegate> delegate;
- (id) initWithUserID:(NSString*)userid  password:(NSString*)password;
@end

@class WizSearchOnserverOperation;
@protocol WizSearchOnServerDelegate <NSObject>
@optional
- (void) didSearchFaild:(WizSearchOnserverOperation*)searchOperation  error:(NSError*)error;
- (void) didsearchSucceed:(WizSearchOnserverOperation*)searchOperation   result:(NSArray*)array;
- (void) didSearchCancel:(WizSearchOnserverOperation*)searchOperation;
@end

@interface WizSearchOnserverOperation : NSOperation
@property (nonatomic, weak) id<WizSearchOnServerDelegate> delegate;
@property (nonatomic, strong) NSString* keywords;
@property (nonatomic, strong) NSString* kbguid;
@property (nonatomic, strong) NSString* accountUserId;
- (id) initWithKb:(NSString*)kbguid accountUserId:(NSString*)accountUserId keywords:(NSString*)key;
- (id) initWithKb:(NSString*)kbguid
    accountUserId:(NSString*)accountUserId
         keywords:(NSString*)key
         location:(NSString *)location
    withSubFolder:(BOOL)withSubFolder
              tag:(NSString *)tagGuid
       withSubTag:(BOOL)withSubTag;
@end

