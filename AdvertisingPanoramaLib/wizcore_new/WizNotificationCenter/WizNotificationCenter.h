//
//  WizNotificationCenter.h
//  WizIos
//
//  Created by dzpqzb on 12-12-21.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizAudioManager.h"
#import "WizObject.h"

typedef enum {
    WizModifiedShotcutTypeAdd,
    WizModifiedShotcutTypeRemove
}WizModifiedShotcutType;

static NSString* const WizNotificationMessageAudioChanged= @"WizNotificationMessageAudioChanged";

static NSString* const WizNotificationMessageShake = @"WizNotificationMessageShake";
static NSString* const WizNotificationMessageUserAttributeUpdate = @"WizNotificationMessageUserAttributeUpdate";

static NSString* const WizNotificationUserInfoKbguid = @"WizNotificationUserInfoKbguid";
static NSString* const WizNotificationUserInfoAccountUserId = @"WizNotificationUserInfoAccountUserId";
static NSString* const WizNotificationUserInfoDocumentGuid = @"WizNotificationUserInfoDocumentGuid";


static NSString* const WizXmlSyncEventMessageTypeAccount = @"WizXmlSyncEventMessageTypeAccount";
static NSString* const WizXmlSyncEventMessageTypeKbguid = @"WizXmlSyncEventMessageTypeKbguid";
static NSString* const WizXmlSyncEventMessageTypeDownload = @"WizXmlSyncEventMessageTypeDownload";
static NSString* const WizXmlSyncEventMessageTypeUpload = @"WizXmlSyncEventMessageTypeUpload";

static NSString* const WizGeneraterAbstractMessage              = @"WizGeneraterAbstractMessage";
static NSString* const WizReflushDocumentCountInFolder              = @"WizReflushDocumentCountInFolder";
static NSString* const WizCrashHandler = @"WizCrashHandler";
extern NSString* const WizModifiedDocumentMessage;
static NSString* const WizWillRegisterAccountMessage = @"WizWillRegisterAccountMessage";
static NSString* const WizSyncWizMessageMessage = @"WizSyncWizMessageMessage";
static NSString* const WizMessageCountChangedMessage = @"WizMessageCountChangedMessage";
//
static NSString* const WizMessageChangedMesssage = @"WizMessageChangedMesssage";
//
static NSString* const WizApplicationWillGotoBackgroudMessage = @"WizApplicationWillGotoBackgroudMessage";

static NSString* const WizMessagePurchaseMessage = @"WizMessagePurchaseMessage";

static NSString* const WizMessageGetUserAvartImageMessage = @"WizMessageGetUserAvartImageMessage";
//
static NSString* const WizErrorMessageUserPasswordInvalid = @"WizErrorMessageUserPasswordInvalid";

static NSString* const kWizModifiedShotcutMessage = @"kWizModifiedShotcutMessage";
//
static NSString* const WizMessageWizBizUserModified = @"WizMessageWizBizUserModified";
//wenlin add start
static NSString* const WizSyncWizMessageServerVersion = @"WizSyncWizMessageServerVersion";
//wenlin add end
static NSString* const WizAutoDownloadMessage = @"WizAutoDownloadMessage";

@interface NSMutableDictionary (WizNotificationUserInfo)
- (void) addAudioStatus:(WizAudioStatus)status;
- (void) addMessageDatas:(NSDictionary*)datas;
- (void) addErrorData:(NSError*)error;
- (void) addDocumentGuid:(NSString*)documentGuid;
- (void) addKbguid:(NSString*)kbguid;
- (void) addAccountUserId:(NSString*)accountUserId;
- (void) addEventStatue:(int)event;
- (void) addBizUser:(WizBizUser*)user;
- (void) addShotcut:(WizShotCut*)shotcut;
- (void) addShotcutModifiedType:(WizModifiedShotcutType)type;
@end



@interface NSDictionary (WizNotificationUserInfoParse)
- (WizBizUser*) userInfoBizUser;
- (WizAudioStatus) userInfoAudioStatus;
- (NSError*) userInfoErrorData;
- (NSDictionary*) userInfoMessageDatas;
- (WizShotCut*) shotcut;
- (WizModifiedShotcutType) modifiedShotcutType;
//
- (NSString*) userInfoDocumentGuid;
- (NSString*) userInfoKbguid;
- (NSString*) userInfoAccountUserId;
//
- (int) userInfoEventStatue;
@end

@protocol WizAudioStatusChangedProtocol <NSObject>
@optional
- (void)  audioStatusDidChangedToRecordStart;
- (void)  audioStatusDidChangedToRecordEnd:(NSString*)audioFilePath;
- (void)  audioStatusDidChangedToRecordFaild:(NSError*)error;
- (void)  audioStatusDidChangedToRecordUpdateDatas:(NSDictionary*)dic;
- (void)  audioStatusDidChangedToPlayStart:(NSString*)filePath;
- (void)  audioStatusDidChangedToPlayEnd:(NSString*)filePath;
- (void)  audioStatusDidChangedToPalyUpdateDatas:(NSDictionary*)dic;

@end

@protocol WizBizUserModifiedProtocol <NSObject>

- (void) didUpdateBizUser:(WizBizUser*)user;

@end


@protocol WizPurchaseProtocol <NSObject>


@end


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

//- (void) didSyncKbDownloadDeletedGuids:(NSString*)kbguid;
//- (void) willSyncKbDownloadDelegatedGuids:(NSString*)kbguid;

//- (void) didSyncKbDownloadDocuments:(NSString*)kbguid;
//- (void) willSyncKbDownloadDocuments:(NSString*)kbguid;

//- (void) didSyncKbDownloadAttachmentsList:(NSString*)kbguid;
//- (void) willSyncKbDownloadAttachmentsList:(NSString*)kbguid;

- (void) didSyncKbDownloadTags:(NSString*)kbguid;
//- (void) willSyncKbDownloadTags:(NSString*)kbguid;

- (void) didSyncKbDownloadFolders:(NSString*)kbguid;
//- (void) willSyncKbDownloadFolders:(NSString*)kbguid;

- (void) didSyncKbDownloadDocuments:(NSString *)kbguid process:(float)process;

//- (void) willSyncKbUploadAllChanges:(NSString*)kbguid;
//- (void) didSyncKbUploadAllChanges:(NSString*)kbguid;
//- (void) willSyncKbUploadTags:(NSString*)kbguid;
//- (void) willSyncKbUploadDocuments:(NSString*)kbguid;
//- (void) willSyncKbUploadAttachments:(NSString*)kbguid;
//- (void) willSyncKbUploadDeletedList:(NSString*)kbguid;

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

@protocol WizSetUserAvartProtocol <NSObject>
- (void) didGetUserAvart:(UIImage*)avartImage forUserGuid:(NSString*)userGuid;
@end


@protocol WizSyncUploadDelegate <NSObject>
@optional
//- (void) didUploadStart:(NSString*)guid;
- (void) didUploadSuccess:(WizDocument*)document kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
//- (void) didUploadFaild:(NSString*)guid error:(NSError*)error;
//- (void) didUploadObject:(NSString*)guid withUserInfo:(NSString*)userInfo;
@end

@protocol WizGenerateAbstractDelegate <NSObject>
- (void) didGenerateAbstract:(WizAbstract*)abstract kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
@end


@protocol WizReflushDocumentCountDelegate <NSObject>
- (void) willReflushDocumentCountForGroup:(NSString*)guid;
@end

@protocol WizMessageChangedProtocol <NSObject>
- (void) didMessageChange:(NSString*)messageId accountUserId:(NSString*)accountUserId;
@end

@protocol WizMessageCountChangeProtocol <NSObject>
- (void) didWizMessageUnreadCountChanged:(NSString*)accountUserId;
@end

@protocol WizMessageSyncProtocol <NSObject>
@optional
- (void) didSyncMessageEnd:(NSString*)accountUserId;
- (void) didSyncMessageStart:(NSString*)accountUserId;
- (void) didSyncMessageFaild:(NSString*)accountUserId error:(NSError*)error;
@end

@protocol WizModifiedDcoumentDelegate <NSObject>
@optional
- (void) didDeletedDocument:(NSString*)guid kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
- (void) didInserteDocumentsOnServerKbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
- (void) didUpdateDocumentOnLocal:(WizDocument*)document kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
- (void) didInserteDocumentOnLocal:(WizDocument*)document kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
@end

@protocol WizGroupUpdateDelegate <NSObject>
@optional
- (void) didUpdateGroups:(NSString* )accountUserId;
@end

@protocol WizModifiedShotcutProtocol <NSObject>
@optional
- (void) didAddShotCut:(WizShotCut*)shotcut accountUserId:(NSString*)accountUserId;
- (void) didRemoveShotCut:(WizShotCut*)shotcut accountUserId:(NSString*)accountUserId;
@end

@protocol WizAutoDownloadDelegate <NSObject>
- (void)didBeginAutoDownload:(NSString*)guid;
- (void)didEndAutoDownload:(NSString*)guid count:(NSNumber*)count;
@end

/**消息中心，负责在各个模块之间传递消息。消息最终会转化成函数传递给观察者。
 */
@interface WizNotificationCenter : NSObject
+ (id) shareCenter;
- (void) removeObserver:(id)observer;
- (void) addSyncAccountObserver:(id<WizSyncAccountDelegate>)observer;
- (void) addSyncKbObserver:(id<WizSyncKbDelegate>)observer;
- (void) addDownloadDelegate:(id<WizSyncDownloadDelegate>)observer;
- (void) addUploadDelegate:(id<WizSyncUploadDelegate>)observer;
- (void) addGenerateAbstractObserver:(id<WizGenerateAbstractDelegate>)observer;
- (void) addReflushDocumentCountObserver:(id<WizReflushDocumentCountDelegate>)observer;
- (void) addModifiedDocumentObserver:(id<WizModifiedDcoumentDelegate>)observer;
- (void) addGroupUpdateObserver:(id<WizGroupUpdateDelegate>)observer;
- (void) addMessageChangedObserver:(id<WizMessageChangedProtocol>)observer;
- (void) addSyncWizMessageObserver:(id<WizMessageSyncProtocol>)observer;
- (void) addMssageUnreadCountChangedObserver:(id<WizMessageCountChangeProtocol>)observer;
- (void) addUserAvartImageObserver:(id<WizSetUserAvartProtocol>)observer;
- (void) addAudioStatusChangedObserver:(id<WizAudioStatusChangedProtocol>)observer;
- (void) addBizUserModifiedObserver:(id<WizBizUserModifiedProtocol>)observer;
- (void) addModifiedShotcutObserver:(id<WizModifiedShotcutProtocol>)observer;
- (void) addAutoDownloadObserver:(id<WizAutoDownloadDelegate>)observer;
//
- (void) sendUpdateGroupsNotification:(NSString*)accountUserId;
//
- (void) removeDownloadObserver:(id)observer;
//
+ (void)OnSyncState:(NSString*)guid event:(int)event messageType:(NSString*)messageType process:(float)process;
+ (void) OnSyncErrorStatue:(NSString*)guid messageType:(NSString*)messageType error:(NSError*)error;
+ (void) OnSyncKbState:(NSString*)kbguid event:(int)event process:(int)process;
+ (void) OnSyncState:(NSString *)guid event:(int)event messageType:(NSString *)messageType otherInfo:(NSDictionary*)dic;
+ (void) OnSyncMessageAccountUserId:(NSString*)accountUserId event:(int)event error:(NSError*)error;
@end
