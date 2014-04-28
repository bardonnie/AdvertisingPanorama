//
//  WizNotificationCenter.h
//  WizIos
//
//  Created by dzpqzb on 12-12-21.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* const WizXmlSyncEventMessageTypeAccount = @"WizXmlSyncEventMessageTypeAccount";
static NSString* const WizXmlSyncEventMessageTypeKbguid = @"WizXmlSyncEventMessageTypeKbguid";
static NSString* const WizXmlSyncEventMessageTypeDownload = @"WizXmlSyncEventMessageTypeDownload";

static NSString* const WizGeneraterAbstractMessage              = @"WizGeneraterAbstractMessage";
static NSString* const WizCrashHandler = @"WizCrashHandler";
extern NSString* const WizModifiedDocumentMessage;

@protocol WizSyncAccountDelegate <NSObject>
@optional
- (void) didSyncAccountFaild:(NSString*)accountUserId;
- (void) didSyncAccountSucceed:(NSString *)accountUserId;
- (void) didSyncAccountStart:(NSString *)accountUserId;
@end

@protocol WizSyncKbDelegate <NSObject>
@optional
- (void) didSyncKbStart:(NSString*)kbguid;
- (void) didSyncKbEnd:(NSString*)kbguid;
- (void) didUploadEnd:(NSString*)kbguid;
- (void) didSyncKbFaild:(NSString*)kbguid error:(NSError*)error;
- (void) didSyncKbDownloadDeletedGuids:(NSString*)kbguid;
- (void) didSyncKbDownloadDocuments:(NSString*)kbguid;
- (void) didSyncKbDownloadAttachmentsList:(NSString*)kbguid;
- (void) didSyncKbDownloadTags:(NSString*)kbguid;
- (void) didSyncKbDownloadFolders:(NSString*)kbguid;
- (void) didSyncKbDownloadDocuments:(NSString *)kbguid process:(float)process;
@end
static NSString* const WizDownloadInfoTypeProcess = @"process";
static NSString* const WizDownloadInfoTypeTitle = @"title";
@protocol WizSyncDownloadDelegate <NSObject>
@optional
- (void) didDownloadStart:(NSString*)guid;
- (void) didDownloadEnd:(NSString*)guid;
- (void) didDownloadFaild:(NSString*)guid error:(NSError*)error;
- (void) didDownloadObject:(NSString*)guid withUserInfo:(NSString*)userInfo;
@end

@protocol WizGenerateAbstractDelegate <NSObject>
- (void) didGenerateAbstract:(NSString*)guid;
@end

@protocol WizModifiedDcoumentDelegate <NSObject>
@optional
- (void) didDeletedDocument:(NSString*)guid;
- (void) didUpdateDocumentOnServer:(NSString*)guid;
- (void) didUpdateDocumentOnLocal:(NSString*)guid;
- (void) didInserteDocumentOnServer:(NSString*)guid;
- (void) didInserteDocumentOnLocal:(NSString*)guid;

@end

@protocol WizGroupUpdateDelegate <NSObject>

- (void) didUpdateGroups:(NSString* )accountUserId;

@end
/**消息中心，负责在各个模块之间传递消息。消息最终会转化成函数传递给观察者。
 */
@interface WizNotificationCenter : NSObject
+ (id) shareCenter;
- (void) removeObserver:(id)observer;
- (void) addSyncAccountObserver:(id<WizSyncAccountDelegate>)observer;
- (void) addSyncKbObserver:(id<WizSyncKbDelegate>)observer;
- (void) addDownloadDelegate:(id<WizSyncDownloadDelegate>)observer;
- (void) addGenerateAbstractObserver:(id<WizGenerateAbstractDelegate>)observer;
- (void) addModifiedDocumentObserver:(id<WizModifiedDcoumentDelegate>)observer;
- (void) addGroupUpdateObserver:(id<WizGroupUpdateDelegate>)observer;
- (void) sendUpdateGroupsNotification:(NSString*)accountUserId;
//
- (void) removeDownloadObserver:(id)observer;
//
+ (void)OnSyncState:(NSString*)guid event:(int)event messageType:(NSString*)messageType process:(float)process;
+ (void) OnSyncErrorStatue:(NSString*)guid messageType:(NSString*)messageType error:(NSError*)error;
+ (void) OnSyncKbState:(NSString*)kbguid event:(int)event process:(int)process;
+ (void) OnSyncState:(NSString *)guid event:(int)event messageType:(NSString *)messageType otherInfo:(NSDictionary*)dic;
@end
