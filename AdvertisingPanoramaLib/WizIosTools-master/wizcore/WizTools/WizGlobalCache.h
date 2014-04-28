//
//  WizGlobalCache.h
//  WizCoreFunc
//
//  Created by dzpqzb on 12-12-24.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WizAbstract;
@interface WizGlobalCache : NSCache
+ (id) shareInstance;
- (WizAbstract*) abstractForDoc:(NSString*)docGuid kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
- (int64_t) unreadMessageCountOfAccount:(NSString*)accountUserId type:(WizMessageType)type;

- (int64_t) unreadMessageCountOfAccount:(NSString*)accountUserId  kbguid:(NSString*)kbguid type:(WizMessageType)type;

@property (readonly,nonatomic, strong) NSMutableDictionary *folderDocCountDict;
@property (readonly,nonatomic, strong) NSMutableDictionary *tagDocCountDict;

- (WizDocumentCount*) tagCount:(NSString*)tagGuid kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
- (WizDocumentCount*) folderCount:(NSString*)folder kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;

- (UIImage*) userAvatarByGuid:(NSString*)guid;
- (NSString*) groupUserGuidByUserId:(NSString*)userId;
- (NSString*) groupUserAliasByUserId:(NSString*)userId kbguid:(NSString*)kbguid accountUserId:(NSString*)accountId bizGuid:(NSString*)bizGuid;
//

@property (atomic, strong) NSMutableDictionary* allUserNameDictionary;
@property (atomic, strong) NSMutableDictionary* allUserNameDictionaryNew;

@property (atomic, assign) BOOL isAllUserNameDirty;
- (void) addAbstract:(WizAbstract*)abstract forDocumentGuid:(NSString*)docGuid kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
- (void) clearCacheForDocument:(NSString *)guid kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
- (void) setUnreadCountDictionary:(NSDictionary*)dic accountUserId:(NSString*)accountUserId;
- (void) setFolderCountDictionary:(NSDictionary*)folderDic tagDic:(NSDictionary*)tagDic kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
@end
