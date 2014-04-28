//
//  WizTemporaryDataBaseDelegate.h
//  Wiz
//
//  Created by 朝 董 on 12-4-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizObject.h"

extern NSString* (^WizUnreadCountMessageKeyUserIdType)(NSString*,WizMessageType);
extern NSString* (^WizUnreadCountMessageKeyUserIdKbguidType)(NSString*,NSString*, WizMessageType);

@class WizAbstract;
@class WizSearch;
@protocol WizTemporaryDataBaseDelegate <NSObject>
- (BOOL) isAbstractExist:(NSString*)documentGuid;
- (WizAbstract*) abstractOfDocument:(NSString *)documentGUID;
- (BOOL) clearCache;
- (BOOL) deleteAbstractByGUID:(NSString *)documentGUID;
- (BOOL) deleteAbstractsByAccountUserId:(NSString*)accountUserID;
- (BOOL) updateAbstract:(NSString*)text imageData:(NSData*)imageData guid:(NSString*)guid type:(NSString*)type kbguid:(NSString*)kbguid;
//search

- (BOOL) deleteWizSearch:(NSString *)keywords kbguid:(NSString *)kbguid accountUserId:(NSString*)accountUserId;
- (BOOL) deleteAllWizSearchKbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
- (WizSearch*) searchDataFromDb:(NSString*)keywords kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
- (NSArray*) allSearchByKbguid:(NSString *)kbguid accountUserId:(NSString*)accountUserId;
- (BOOL) updateWizSearch:(WizSearch *)search;
//message
- (int64_t) messageVersionForAccount:(NSString*)accountUserId;
- (BOOL) setMessageVesion:(int64_t)ver forAccount:(NSString*)accountUserId;
- (BOOL) updateMessage:(WizMessage*)message;
- (BOOL) updateMessages:(NSArray*)array;
- (BOOL) messageLocalChanged:(WizMessage*)message;
- (BOOL) deleteMessage:(WizMessage*)message;
- (BOOL) deleteMessages:(NSArray*)messagesArray;

- (BOOL) isMessagesDataDirty:(NSString*)accountUserId;

- (NSArray*) messagesForLocalChanged:(NSString*)accountUserId;

- (NSArray*) messagesByReciverAccountUserId:(NSString*)accountUserId;
- (int64_t) messageUnreadCountOfAccountUserId:(NSString*)userId type:(WizMessageType)type;
- (int64_t) messageUnreadCountOfAccountUserId:(NSString*)userId kbguid:(NSString*)kbguid type:(WizMessageType)type;
- (int64_t) messageTotalCountOfAccountUserId:(NSString*)userId;

- (NSArray*) messagesByReciverAccountUserId:(NSString*)accountUserId SenderGroupKbGuid:(NSString*)kbguid;
- (NSArray*) messagesByReciverAccountUserId:(NSString *)accountUserId SenderGroupKbGuid:(NSString *)kbguid messageType:(WizMessageType)messageType;
- (BOOL) updateAllUnreadMessageToReaded:(NSString*)accountUserId SenderGroupKbGuid:(NSString*)kbguid messageType:(WizMessageType)messageType;

- (NSSet*) allNotificatedKMByReciver:(NSString*)accountUserIdD;
- (NSDictionary*) unreadCountDictionary:(NSString*)accountUserId;

- (void) setSelectedMessageGroup:(NSString*)groupKbGuid forAccount:(NSString*)accountUserId;
- (NSString*)getSelectedMessageGroupKbGuidForAccount:(NSString*)accountUserId;

- (BOOL) setSyncVersion:(NSString*)type  version:(int64_t)ver;
- (int64_t) syncVersion:(NSString*)type;

- (WizBizUser*) bizUserFromGuid:(NSString*)guid userBizGuid:(NSString*)userBizGuid;
- (WizBizUser*) bizUserFromUserId:(NSString*)userId userBizGuid:(NSString*)userBizGuid;

- (BOOL) updateWizBizUser:(WizBizUser *)bizUser;
- (BOOL) deleteWizBizUser:(NSString*)kbguid;
- (NSArray*) bizUsersByBizGuid:(NSString*)bizGuid;
- (NSArray*) allBizUsers;
//Task
- (WizUserTask*) userTaskFromGuid:(NSString*)guid;
- (NSArray*) allUserTasksByAccountUserId:(NSString*)accountUserId;
- (BOOL) updateWizUserTask:(WizUserTask *)usertask;
- (WizUserTask*) userTaskFromDocumentGuid:(NSString*)guid;
//
- (NSArray*) allShotCutOfAccountUserId:(NSString*)accountUserId;
- (NSArray*) allShotCuts;
- (BOOL) deleteWizShotcut:(NSString*)accountUserId groupguid:(NSString*)groupguid documentGuid:(NSString*)documentGuid;
- (BOOL) updateWizShotcut:(WizShotCutInner*)shotcut;
@end
