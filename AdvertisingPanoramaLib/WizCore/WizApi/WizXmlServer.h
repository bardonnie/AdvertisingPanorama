//
//  WizXmlServer.h
//  WizIos
//
//  Created by dzpqzb on 12-12-19.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizObject.h"
#import "Reachability.h"
BOOL IsReachableInternet();
NetworkStatus CurrentNetWorkStatues();
BOOL IsReachableInternerViaWifi();
void AddReachableBlock(NetworkReachable block);
void RemoveReachableBlock(NetworkReachable block);
void AddUnReachableBlock(NetworkUnreachable block);
void RemoveUnReachableBlock(NetworkUnreachable block);
//
extern NSString* const SyncMethod_KeepAlive;
extern NSString* const SyncMethod_ClientLogin;
extern NSString* const SyncMethod_ClientLogout;
extern NSString* const SyncMethod_CreateAccount;
extern NSString* const SyncMethod_ChangeAccountPassword;
extern NSString* const SyncMethod_GetAllCategories;
extern NSString* const SyncMethod_DownloadAllTags;
extern NSString* const SyncMethod_PostTagList;
extern NSString* const SyncMethod_DocumentsByKey;
extern NSString* const SyncMethod_DownloadDocumentList;
extern NSString* const SyncMethod_DocumentsByCategory;
extern NSString* const SyncMethod_DocumentsByTag;
extern NSString* const SyncMethod_DocumentPostSimpleData;
extern NSString* const SyncMethod_DownloadDeletedList;
extern NSString* const SyncMethod_UploadDeletedList;
extern NSString* const SyncMethod_DownloadObject;
extern NSString* const SyncMethod_UploadObject;
extern NSString* const SyncMethod_AttachmentPostSimpleData;
extern NSString* const SyncMethod_DownloadAttachmentList;
extern NSString* const SyncMethod_GetUserInfo;
extern NSString* const SyncMethod_GetGropKbGuids;
extern NSString* const SyncMethod_DownloadAllObjectVersion;
extern NSString* const SyncMethod_DownloadDocumentListByGuids;
extern NSString* const SyncMethod_DownloadAttachmentListByGuids;
extern NSString* const SyncMethod_AccountGetValue;
extern NSString* const SyncMethod_AccountSetValue;
extern NSString* const SyncMethod_AccountGetValueVersion;
extern NSString* const SyncMethod_KbGetValue;
extern NSString* const SyncMethod_KbSetValue;
extern NSString* const SyncMethod_KbGetValueVersion;
//
extern NSString* const WizXmlSyncStateChangedKey;
//

typedef NS_ENUM(NSInteger, WizXmlSyncState) {
    WizXmlSyncStateStart = 1,
    WizXmlSyncStateEnd = 0,
    WizXmlSyncStateDownloadAllVersions = 2,
    WizXmlSyncStateUploadDeletedList =3,
    WizXmlSyncStateDownloadDeletedList = 4,
    WizXmlSyncStateDownloadTagList = 5,
    WizXmlSyncStateUploadTagList = 6,
    WizXmlSyncStateDownloadDocumentList = 7,
    WizXmlSyncStateDownloadAttachmentList = 8,
    WizXmlSyncStateUploadDocument = 9,
    WizXmlSyncStateUploadAttachment = 10,
    WizXmlSyncStateDownloadDocumentListWithProcess = 11,
    WizXmlSyncStateDownloadFolders = 12,
    WizXmlSyncStateError = -1
};

/**Packing the fundamental xml-rpc network sync method. Post data and get data.
    This class need a server url and some params of the method.
 */
@interface WizXmlServer : NSObject
@property (nonatomic, strong) NSError* lastError;

/**Init
 传入服务器URl
 */
- (id) initWithUrl:(NSURL*)url;
- (void) addCommontParams:(NSMutableDictionary*)postParams;
- (BOOL) callXmlRpc:(NSMutableDictionary *)postParams methodKey:(NSString *)methodKey  retObj:(id<WizObject>)ret;
- (BOOL) isStop;
@end

