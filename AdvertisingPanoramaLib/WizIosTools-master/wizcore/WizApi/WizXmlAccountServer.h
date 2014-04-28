//
//  WizXmlAccountServer.h
//  WizIos
//
//  Created by dzpqzb on 12-12-19.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import "WizXmlServer.h"
#import "WizObject.h"

/**The account server.Do the net works abount account, like login and logout.
 */
@interface WizXmlAccountServer : WizXmlServer
@property (nonatomic, strong, readonly) NSString* currentUserId;
@property (nonatomic, strong, readonly) NSString* currentUserGuid;
@property (nonatomic, strong, readonly) WizLoginData* loginData;
- (BOOL) accountClientLogin:(NSString*)accountUserId passwrod:(NSString*)password;
- (BOOL) getGroupList:(WizServerGroupsArray*)groupsArray;
- (BOOL) keepAlive:(NSString*)token;
- (BOOL) verifyAccount:(NSString*)accountUserId passwrod:(NSString*)passwrod;
- (BOOL) createAccount:(NSString*)accountUserId passwrod:(NSString*)password;
- (BOOL) accountLogout;
- (BOOL) getMessage:(int64_t)startVersion pageSize:(int64_t)pageSize retObject:(WizServerMessageArray*)messageArray;
- (WizCertData*) getCert:(NSString*)accountUserId passwrod:(NSString*)passwrod;
- (BOOL) getAllMessages:(id<WizTemporaryDataBaseDelegate>)db forAccount:(NSString*)userId sendMessage:(BOOL)willSendMessage;
- (BOOL) getAllKMUsersList:(NSSet*)bizGuids db:(id<WizTemporaryDataBaseDelegate>)db;
-(NSString *)userGuidByUserId:(NSString *)accountUserId password:(NSString *)password;

- (BOOL) postAllChangedStatusMessages:(id<WizTemporaryDataBaseDelegate>)db forAccount:(NSString*)accountUserId status:(WizMessageReadStatus)status;
@end
