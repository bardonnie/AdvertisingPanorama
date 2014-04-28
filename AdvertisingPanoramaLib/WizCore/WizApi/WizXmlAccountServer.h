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
@property (nonatomic, strong, readonly) WizLoginData* loginData;
- (BOOL) accountClientLogin:(NSString*)accountUserId passwrod:(NSString*)password;
- (BOOL) getGroupList:(WizServerGroupsArray*)groupsArray;
- (BOOL) keepAlive:(NSString*)token;
- (BOOL) verifyAccount:(NSString*)accountUserId passwrod:(NSString*)passwrod;
- (BOOL) createAccount:(NSString*)accountUserId passwrod:(NSString*)password;
- (BOOL) accountLogout;
@end
