//
//  WizCore.h
//  WizNote
//
//  Created by dzpqzb on 13-5-10.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizGlobals.h"

static NSString* const kSceneLife = @"kSceneLife";
static NSString* const kSceneComputerEnginner = @"kSceneComputerEnginner";
static NSString* const kSceneStudent = @"kSceneStudent";
static NSString* const kSceneBrainWork = @"kSceneBrainWork";

@interface WizCore : NSObject
+ (BOOL) deleteTag:(NSString*)tagGuid kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
+ (BOOL) handleOpenURL:(NSURL*)openURL;
+ (void) initWizApp;
+ (BOOL) uploadFile:(NSString*)filePath toAccountUserId:(NSString*)accountUserId password:(NSString*)password kbguid:(NSString*)kbguid attributes:(NSDictionary*)attributes;
+ (BOOL) deletedFolder:(NSString*)folder group:(WizGroup*)group;
+ (BOOL) wizReductionFolder:(NSString*)folder group:(WizGroup*)group;
+ (BOOL) deleteDocumentForever:(NSString*)documentGuid group:(WizGroup*)group;
+ (BOOL) deleteFolderForever:(NSString*)folder group:(WizGroup*)group;
+ (BOOL) deleteDocument:(NSString*)documentGuid group:(WizGroup*)group;
//
+ (BOOL) addDocumentFromHtml:(NSString*)filePath toAccountUserId:(NSString*)accountUserId  kbguid:(NSString*)kbguid;
+ (NSString*) addDocumentFromZiw:(NSString*)filePath toAccountUserId:(NSString*)accountUserId kbguid:(NSString*)kbguid withDocumentAttribute:(NSDictionary*)attributes;

+ (BOOL) addIntroduceDataToAccount:(NSString*)accountUserId kbguid:(NSString*)kbguid;
+ (BOOL) addAttachmentFromZiw:(NSString*)filePath toAccountUserId:(NSString*)accountUserId kbguid:(NSString*)kbguid withAttachmentAttribute:(NSDictionary*)attributes;
+ (BOOL) markAllMessageReaded:(NSString*)accountUserId kbguid:(NSString*)kbguid messageType:(WizMessageType)messageType;
+ (BOOL) addIntroduceFolders:(NSArray*)folders tagNames:(NSArray*)tagNames toAccount:(NSString *)accountUserId kbguid:(NSString *)kbguid;

+ (void) saveAccount:(NSString *)accountUserId password:(NSString *)password;
+ (NSDictionary *) accountIdAndPassword;

+ (void)updateUserInfo:(NSString*)userId key:(NSString*) key value:(BOOL)isOK;
+ (BOOL) userInfo:(NSString*)userId key:(NSString*) key;
+ (WizEditingDocument* ) handleURL:(NSURL*)openURL;
@end