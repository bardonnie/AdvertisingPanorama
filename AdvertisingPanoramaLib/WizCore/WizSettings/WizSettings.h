//
//  WizSettings.h
//  WizIos
//
//  Created by dzpqzb on 12-12-24.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizObject.h"
//%2 is reverse
enum WizTableOrder {
    WizTableOrderModifiedDate = 0,
    WizTableOrderTitle = 1

    };
enum WizOfflineDownloadDuration {
    WizOfflineDownloadNone = 0,
    WizOfflineDownloadLastThreeDay = 3,
    WizOfflineDownloadLastWeek = 7,
    WizOfflineDownloadLastMonth = 30,
    WizOfflineDownloadAll = 1000,
};


enum WizPhotoQulity {
    WizPhotoQulityHigh = 1024,
    WizPhotoQulityMiddle = 600,
    WizPhotoQulityLow = 320,
};

@interface NSDictionary (AccountAttributes)
- (int) userPoint;
- (NSString*) userPointsString;
- (NSString*) userType;
@end


@interface WizEditingDocument : WizDocument
@property (nonatomic, strong) NSString* accountUserId;
@property (nonatomic, strong) NSString* kbguid;
@property (nonatomic, assign) BOOL isNewNote;
- (id) initWithDocument:(WizDocument*)doc;
@end

@interface WizSettings : NSObject
+ (WizSettings*) defaultSettings;
- (NSString*) activeAccountUserId;
- (void)updateActiveAccountUserID:(NSString*)accountUserId;
//
- (NSDate*) lastUpdateDate:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
- (void) setLastUpdate:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
//offline duration
- (void) setOfflineDownloadDuration:(enum WizOfflineDownloadDuration)duration  kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
- (enum WizOfflineDownloadDuration) offlineDownloadDuration:(NSString*)kbguid accountUserID:(NSString*)accontUserId;
- (BOOL) isAutoUploadEnable:(NSString*)kbguid accountUserID:(NSString*)accountUserID;
- (void) setAutoUplloadEnable:(BOOL)able kbguid:(NSString*)kbguid accountUserID:(NSString*)accountUserID;
- (BOOL) isPasscodeEnable;
- (NSString*) passcodePassword;
- (void) setPasscodePassword:(NSString*)password;
- (enum WizPhotoQulity) photoQulity;
- (void) setPhotoQulity:(enum WizPhotoQulity) qulity;
//
- (BOOL) canAutoUpload;
//wzz
- (void) setAccount:(NSString*)accountUserID attribute:(NSDictionary*)attribute;
- (NSDictionary*) accountAttributes:(NSString*)accountUserId;

- (void) setDefaultFolder:(NSString*)folder  accountID:(NSString*)userId;
- (NSString*) defaultFolder:(NSString*)userId;
//
- (BOOL) isAutoSyncEnable;
- (void) setAutoSyncEnable:(BOOL)enable;

- (WizEditingDocument*) lastEditingDocument;
- (void) setLastEditingDocument:(WizEditingDocument*)doc;

@end
