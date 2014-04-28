//
//  WizNetworkEngine.h
//  WizNote
//
//  Created by dzpqzb on 13-5-31.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "MKNetworkEngine.h"

@interface WizNetworkEngine : NSObject
@property (nonatomic, strong, readonly) NSString* hostName;
@property (nonatomic, assign) int portNumber;

+ (id) shareEngine;
- (id) initWithHostName:(NSString*)hostName;
- (NSString*) syncServerURLString:(NSError**)error;
- (NSURL*) messageCurrentVersionURLForUserGUID:(NSString*)guid;
- (int64_t) messageMaxVersionForUserGUID:(NSString*)guid;
- (NSString*) getStringWithCommand:(NSString*)command error:(NSError**)error;
- (NSURL*) wizNewFunctionURL;
- (NSURL*) aboutWizNoteURL;
- (NSURL*) urlWithCommand:(NSString*)command;
- (NSURL*) abstractURL;
- (NSDictionary*) abstractData:(NSString*)documentGuid kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
- (NSURL*) commentUrlWithAccountUserId:(NSString*)accountUserId kbguid:(NSString*)kbguid documentGuid:(NSString*)documentGuid error:(NSError**)error;
- (NSURL*)getCommentCountURLWith:(NSString*)documentGuid group:(WizGroup*)group;
+(void) getAllWizUsers:(NSString *)accountUserId
                kbguid:(NSString *)kbguid
               bizguid:(NSString *)bizguid;
- (NSURL*) wizEmailUrl;
@end
