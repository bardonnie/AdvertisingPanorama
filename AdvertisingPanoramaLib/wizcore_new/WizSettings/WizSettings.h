//
//  WizSettings.h
//  WizIos
//
//  Created by dzpqzb on 12-12-24.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizObject.h"

#define kWizAppearOnceHelpMainReact @"kWizAppearOnceHelpMainReact"
//%2 is reverse
static NSString* const SettingGlobalKbguid = @"SettingGlobalKbguid";
static NSString* const SettingGlobalAccountUserId = @"SettingGlobalAccountUserId";


typedef enum 
{
    WizSyncHTTP = 0,
    WizSyncHTTPS  =1
}WizSyncEncryptType;

static NSString* const kWizSyncEncryptHttp = @"http";
static NSString* const kWizSyncEncryptHttps = @"https";
extern  NSString* (^kWizSyncEncryptStringFromType)(WizSyncEncryptType);
extern  NSString* (^kWizCurrentSyncEncryptString)();
//

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

enum WizHomePageType{
    WizHomePageTypeMessageCenter = 1,
    WizHomePageTypePersonalNotes = 100,
};

@interface NSDictionary (AccountAttributes)
- (int) userPoint;
- (NSString*) userPointsString;
- (NSString*) userType;
- (NSDate*) expireVipDate;
- (NSString*) userGuid;
@end


@interface WizEditingDocument : WizDocument <NSCopying>
@property (nonatomic, strong) NSString* accountUserId;
@property (nonatomic, strong) NSString* kbguid;
@property (nonatomic, assign) BOOL isNewNote;
@property (nonatomic, strong) NSMutableArray *deletedAttachments;
@property (nonatomic, strong) NSMutableArray *addedAttachments;

- (id) initWithDocument:(WizDocument*)doc;
@end

@interface WizSettings : NSObject
+ (WizSettings*) defaultSettings;
//

- (NSString*) activeAccountUserId;
- (void)updateActiveAccountUserID:(NSString*)accountUserId;
- (NSDate*) lastUpdateDate:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
- (void) setLastUpdate:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
//offline duration
- (void) setOfflineDownloadDuration:(enum WizOfflineDownloadDuration)duration  kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
- (enum WizOfflineDownloadDuration) offlineDownloadDuration:(NSString*)kbguid accountUserID:(NSString*)accontUserId;
- (BOOL) isAutoUploadEnable:(NSString*)kbguid accountUserID:(NSString*)accountUserID;
- (void) setAutoUplloadEnable:(BOOL)able kbguid:(NSString*)kbguid accountUserID:(NSString*)accountUserID;
- (BOOL) isPasscodeEnable;
- (BOOL) isViewSubFolderDocument;
- (BOOL) isViewSubTagDocument;
- (NSString*) passcodePassword;
- (void) setPasscodePassword:(NSString*)password;
- (void) setIsViewSubFolderDocument:(BOOL)enable;
- (void) setIsViewSubTagDocument:(BOOL)enable;
- (enum WizPhotoQulity) photoQulity;
- (void) setPhotoQulity:(enum WizPhotoQulity) qulity;
//
- (BOOL) canAutoSync;
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
- (WizEditingDocument*) lastEditingDocumentForAccountUserId:(NSString*)accountUserId kbguid:(NSString*)kbguid;
- (BOOL) setLastEditingDocument:(WizEditingDocument*)document accountUserId:(NSString*)accountUserId kbguid:(NSString*)kbguid;
- (BOOL) setLastEditingDocument:(WizEditingDocument*)document addedAttachments:(NSMutableArray *)addedAttachments deletedAttachments:(NSMutableArray *)deletedAttachments accountUserId:(NSString*)accountUserId kbguid:(NSString*)kbguid;

- (NSString*) mywizEmailForAccount:(NSString*)accountUserId;
- (NSString*) personalKbGuid:(NSString*)accountUserId;

- (BOOL) isAutoSyncVia3GEnable;
- (void) setAutoSyncVia3GEnable:(BOOL)enable;
- (BOOL) isAutoSyncViaWiFiEnable;
- (void) setAutoSyncViaWiFiEnable:(BOOL)enable;

- (void) setLastUpdateDateForMessageCenter:(NSString*)accountUserId;
- (NSDate*)LastUpdateDateForMessageCenter:(NSString*)accountUserId;


- (void) setAccountType:(WizProType)proType accountUserId:(NSString*)userId;

- (BOOL) isNewBizUserForAccount:(NSString*)accountUserId;
- (void) setAccountIsOldBizUser:(NSString*)accountUserId;

- (enum WizHomePageType)defaultHomePageTypeForAccount:(NSString*)accountUserId;
- (void)setDefaultHomePageType:(enum WizHomePageType)homePageType ForAccount:(NSString*)accountUserId;
//
- (void) setAppCrash:(BOOL)crash;
- (BOOL) appCrash;

- (WizSyncEncryptType) syncEncryptType;
- (void) setSyncEncryptType:(WizSyncEncryptType)type;
- (void) setAppearOnceKey:(NSString*)key;
- (BOOL) appearOnceKeyExist:(NSString*)key;

//
- (void) setLastUnActiveDate:(NSDate*)date;
- (float) lastUnActiveLength;
@end
