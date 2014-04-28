//
//  WizSyncCenter.h
//  WizIos
//
//  Created by dzpqzb on 12-12-20.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizInfoDatabaseDelegate.h"

#import "WizDownloadThread.h"

/**The wiz backgroud operation queue.
 if you want to start a backgroup short process like NSOperation, you can use this queue.
 */
@interface NSOperationQueue (WizOperation)
+ (NSOperationQueue*) backGroupQueue;
@end

/**The sync manager
 All sync commonds must be sended via this singleton class.
 */
@interface WizSyncCenter : NSObject
+ (WizSyncCenter*) shareCenter;
- (void) syncAccount:(NSString*)accountUserId password:(NSString*)password isGroup:(BOOL) isGroup isUploadOnly:(BOOL) isUploadOnly;
- (void) downloadDocument:(NSString*)documentguid kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
- (void) downloadAttachment:(NSString*)attachmentGuid kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
- (void) autoDownloadDocument:(id<WizInfoDatabaseDelegate>)db duration:(NSInteger)duration kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
- (void) syncKbGuid:(NSString*)kbguid accountUserId:(NSString*)accountUserId password:(NSString*) password isUploadOnly:(BOOL) isUPloadOnly userGroup:(NSInteger)userGroup;
- (BOOL) isSyncingAccount:(NSString*)accountUserId;
- (BOOL) isSyncingKbguid:(NSString*)kbguid;
- (BOOL) isSyncingDocument:(NSString*)documentguid;
- (void) autoSyncKbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
- (BOOL) isUploadOnly;
- (void) downloadAttachment:(NSString *)attachmentGuid kbguid:(NSString *)kbguid accountUserId:(NSString *)accountUserId delegate:(id<WizDownloadDelegate>)delegate;
- (void) downloadDocument:(NSString *)documentguid kbguid:(NSString *)kbguid accountUserId:(NSString *)accountUserId delegate:(id<WizDownloadDelegate>)delegate;
- (void) autoDownloadDocumentByKbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
- (void) startAutoDownloadForAccount:(NSString*)userId;
@end
/**Verify account delegate
 
 */
@protocol WizVerifyAccountDelegate <NSObject>
- (void) didVerifyAccountFailed:(NSError*)error;
- (void) didVerifyAccountSucceed:(NSString*) userId password:(NSString*)password kbguid:(NSString*)kbguid;
@end

@interface WizVerifyAccountOperation : NSOperation
@property (nonatomic, assign) id<WizVerifyAccountDelegate> delegate;
- (id) initWithAccount:(NSString*)userId password:(NSString*)password;
@end

@protocol WizCreateAccountDelegate <NSObject>
- (void) didCreateAccountFaild:(NSError*)error;
- (void) didCreateAccountSucceed:(NSString*)userId  password:(NSString*)password;
@end
@interface WizCreateAccountOperation : NSOperation
@property (nonatomic, assign) id<WizCreateAccountDelegate> delegate;
- (id) initWithUserID:(NSString*)userid  password:(NSString*)password;
@end


@protocol WizSearchOnServerDelegate <NSObject>
@optional
- (void) didSearchFaild:(NSError*)error;
- (void) didsearchSucceed:(NSArray*)array;
@end

@interface WizSearchOnserverOperation : NSOperation
@property (nonatomic, assign) id<WizSearchOnServerDelegate> delegate;
- (id) initWithKb:(NSString*)kbguid accountUserId:(NSString*)accountUserId keywords:(NSString*)key;
@end

