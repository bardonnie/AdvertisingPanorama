//
//  WizSettings.m
//  WizIos
//
//  Created by dzpqzb on 12-12-24.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import "WizSettings.h"
#import "WizGlobalData.h"
#import "Reachability.h"
#import "WizXmlServer.h"
#import <AddressBook/AddressBook.h>
static NSString* const SettingLastUpdateDate = @"SettingLastUpdateDate";
static NSString* const SettingOfflineDownloadDuration = @"SettingOfflineDownloadDuration";
static NSString* const SettingAotoUpload        =@"SettingAotoUpload";
static NSString* const SettingPasscodeEnable = @"SettingPasscodeEnable";
static NSString* const SettingViewSubFolderDocumentEnable = @"SettingViewSubFolderDocumentEnable";
static NSString* const SettingViewSubTagDocumentEnable = @"SettingViewSubTagDocumentEnable";
static NSString* const SettingPhotoQulity   = @"SettingPhotoQulity";
static NSString* const SettingAutoSyncEnable = @"SettingAutoSyncEnable";
static NSString* const SettingAutoSyncVia3GEnable = @"SettingAutoSyncVia3GEnable";
static NSString* const SettingAccountAttribute = @"SettingAccountAttribute";
static NSString* const SettingWebSharingEnable = @"SettingWebSharingEnable";

//
//
static NSString* const SettingLastEditingDocument = @"SettingLastEditingDocument";
static NSString* const SettingMessageCenterLastUpadateDate = @"SettingMessageCenterLastUpadateDate";
static NSString* const SettingDefaultHomePageName = @"SettingDefaultHomePageName";
static NSString* const SettingWizAccountIsOldBizUser = @"SettingKeyOfWizAccountIsOldUser";



NSString* (^kWizSyncEncryptStringFromType)(WizSyncEncryptType) = ^(WizSyncEncryptType type)
{
    switch(type)
    {
            case WizSyncHTTP:
                return kWizSyncEncryptHttp;
            case WizSyncHTTPS:
                return kWizSyncEncryptHttps;
            default:
                return kWizSyncEncryptHttps;
    }
};
NSString* (^kWizCurrentSyncEncryptString)() = ^
{
    WizSyncEncryptType type = [[WizSettings defaultSettings] syncEncryptType];
    NSString* key = kWizSyncEncryptStringFromType(type);
    return key;
};
/////
//  //
//    //
//     //
//      //
//     //
//   //
//  //
/////
BOOL isReverseMask(NSInteger mask)
{
    if (mask %2 == 0) {
        return YES;
    }
    else
    {
        return NO;
    }
}


static NSString* const (^WizSettingKey)(NSString*,NSString*,NSString*) = ^(NSString* key, NSString* kbguid, NSString* accountUserId)
{
    NSString* kb = kbguid;
    if(kb == nil)
    {
        kb = WizGlobalPersonalKbguid;
    }
    return [NSString stringWithFormat:@"%@-%@-%@",key,kb, accountUserId];
};

static NSString* const WizSettingsActiveAccountUserId = @"WizSettingsActiveAccountUserId";


static NSString* const WizEditingDocumentAccountUserID = @"WizEditingDocumentAccountUserID";
static NSString* const WizEditingDocumentKbguid = @"WizEditingDocumentKbguid";
static NSString* const WizEditingDocumentIsNewNote = @"WizEditingDocumentIsNewNote";
static NSString* const WizEditingAddedAttachements = @"WizEditingAddedAttachements";
static NSString* const WizEditingDeletedAttachements = @"WizEditingDeletedAttachments";
@implementation WizEditingDocument

@synthesize accountUserId;
@synthesize kbguid;
@synthesize isNewNote;
@synthesize deletedAttachments;
@synthesize addedAttachments;
- (id) copyWithZone:(NSZone *)zone
{
    WizEditingDocument* doc = [[[self class] allocWithZone:zone] init];
    [doc setValuesForKeysWithDictionary:[self toWizServerObject]];
    return doc;
}
- (id) initWithDocument:(WizDocument*)doc
{
    self = [super init];
    if (self) {
        [self fromWizServerObject:[doc toWizServerObject]];
    }
    return self;
}

- (void) fromWizServerObject:(id)obj
{
    [super fromWizServerObject:obj];
    self.accountUserId = [obj objectForKey:WizEditingDocumentAccountUserID];
    self.kbguid = [obj objectForKey:WizEditingDocumentKbguid];
    NSNumber* noteNew = [obj objectForKey:WizEditingDocumentIsNewNote];

    NSMutableArray *tempDeletedAttachments= [obj objectForKey:WizEditingDeletedAttachements];
    self.deletedAttachments=[NSMutableArray array];
    if (tempDeletedAttachments!=nil){
        for (NSDictionary *attachmentDict in tempDeletedAttachments){
            WizAttachment *attachment= [[WizAttachment alloc] init];
            [attachment fromWizServerObject:attachmentDict];
            [self.deletedAttachments addObject:attachment];
        }
    }

    NSMutableArray *tempAdddAttachments= [obj objectForKey:WizEditingAddedAttachements];
    self.addedAttachments=[NSMutableArray array];
    if (tempAdddAttachments!=nil){
        for (NSDictionary *attachmentDict in tempAdddAttachments){
            WizAttachment *attachment= [[WizAttachment alloc] init];
            [attachment fromWizServerObject:attachmentDict];
            [self.addedAttachments addObject:attachment];
        }
    }




    if (noteNew) {
        self.isNewNote = [noteNew boolValue];
    }
    else
    {
        self.isNewNote = NO;
    }
}

- (NSDictionary*) toWizServerObject
{
    NSMutableDictionary* model = [[super toWizServerObject] mutableCopy];
    if (self.accountUserId) {
        [model setObject:self.accountUserId forKey:WizEditingDocumentAccountUserID];
    }
    if (self.kbguid) {
        [model setObject:self.kbguid forKey:WizEditingDocumentKbguid];
    }

    NSMutableArray *tempDeletedAttachments= [[NSMutableArray alloc] init];
    if (self.deletedAttachments!=nil){
        for (WizAttachment *attachment in self.deletedAttachments){
            [tempDeletedAttachments addObject:[attachment toWizServerObject]];
        }
    }
    [model setObject:tempDeletedAttachments forKey:WizEditingDeletedAttachements];

    NSMutableArray *tempAddedAttachments= [[NSMutableArray alloc] init];
    if (self.addedAttachments!=nil){
        for (WizAttachment *attachment in self.addedAttachments){
            [tempAddedAttachments addObject:[attachment toWizServerObject]];
        }
    }
    [model setObject:tempAddedAttachments forKey:WizEditingAddedAttachements];

    [model setObject:[NSNumber numberWithBool:self.isNewNote] forKey:WizEditingDocumentIsNewNote];
    return model;
}

@end
@implementation WizSettings
+ (WizSettings*) defaultSettings
{
    static WizSettings* settings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        settings = [WizGlobalData shareInstanceFor:[WizSettings class]];
    });
    return settings;
}

- (NSString*)activeAccountUserId
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:WizSettingsActiveAccountUserId];
}

- (void)updateActiveAccountUserID:(NSString*)accountUserId
{
    if (accountUserId == nil || [accountUserId length] == 0) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:WizSettingsActiveAccountUserId];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:accountUserId forKey:WizSettingsActiveAccountUserId];
    }
    if (![[NSUserDefaults standardUserDefaults] synchronize]) {
        [self updateActiveAccountUserID:accountUserId];
    }
}


- (void) setLastUnActiveDate:(NSDate*)date
{
    [self setValue:date key:@"UnActiveDate" kbguid:WizGlobalPersonalKbguid accountUserId:WizGlobalPersonalKbguid];
}

- (float) lastUnActiveLength
{
    NSDate* date = [self value:@"UnActiveDate" kbguid:WizGlobalPersonalKbguid accountUserId:WizGlobalPersonalKbguid];
    if (!date) {
        return 0;
    }
    return ABS([date timeIntervalSinceNow]);
}

- (id) value:(NSString*)key kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId
{
    NSString* storeKey =  WizSettingKey(key,kbguid,accountUserId);
    return [[NSUserDefaults standardUserDefaults] valueForKey:storeKey];
    
}
- (void) setValue:(id)value key:(NSString*)key kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId
{
    NSString* storeKey =  WizSettingKey(key,kbguid,accountUserId);
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:storeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setLastUpdate:(NSString *)kbguid accountUserId:(NSString *)accountUserId
{
    NSDate* date = [NSDate date];
    [self setValue:date key:SettingLastUpdateDate kbguid:SettingGlobalKbguid accountUserId:accountUserId];
}
- (NSDate*) lastUpdateDate:(NSString *)kbguid accountUserId:(NSString *)accountUserId
{
    NSDate* date = [self value:SettingLastUpdateDate kbguid:SettingGlobalKbguid accountUserId:accountUserId];
    if (date == nil) {
        [self setLastUpdate:kbguid accountUserId:accountUserId];
        return [NSDate date];
    }
    return date;
}

- (void) setOfflineDownloadDuration:(enum WizOfflineDownloadDuration)duration  kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId
{
    [self setValue:[NSNumber numberWithInteger:duration] key:SettingOfflineDownloadDuration kbguid:kbguid accountUserId:accountUserId];
}
- (enum WizOfflineDownloadDuration) offlineDownloadDuration:(NSString*)kbguid accountUserID:(NSString*)acccountUserId
{
    NSNumber* duration = [self value:SettingOfflineDownloadDuration kbguid:kbguid accountUserId:acccountUserId];
    if (duration == nil) {
        return WizOfflineDownloadNone;
    }
    return [duration integerValue];
}

- (void) setAutoUplloadEnable:(BOOL)able kbguid:(NSString *)kbguid accountUserID:(NSString *)accountUserID
{
    [self setValue:[NSNumber numberWithBool:able] key:SettingAotoUpload kbguid:kbguid accountUserId:accountUserID];
    
}

- (BOOL) isAutoUploadEnable:(NSString *)kbguid accountUserID:(NSString *)accountUserID
{
    return YES;
    NSNumber* number = [self value:SettingAotoUpload kbguid:kbguid accountUserId:accountUserID];
    if (number == nil) {
        return NO;
    }
    return [number boolValue];
}

- (NSString*) passcodePassword
{
    NSString* password = [self value:SettingPasscodeEnable kbguid:SettingGlobalKbguid accountUserId:SettingGlobalAccountUserId];
    return password;
}

- (void) setPasscodePassword:(NSString *)password
{
    [self setValue:password key:SettingPasscodeEnable kbguid:SettingGlobalKbguid accountUserId:SettingGlobalAccountUserId];
}

- (void)setIsViewSubFolderDocument:(BOOL)enable {
    NSString *temp=enable?@"1":@"0";
    [self setValue:temp key:SettingViewSubFolderDocumentEnable kbguid:SettingGlobalKbguid accountUserId:SettingGlobalAccountUserId];
}
-(void)setIsViewSubTagDocument:(BOOL)enable {
    NSString *temp=enable?@"1":@"0";
    [self setValue:temp key:SettingViewSubTagDocumentEnable kbguid:SettingGlobalKbguid accountUserId:SettingGlobalAccountUserId];
}

- (NSString*) viewSubFolderDocument
{
    NSString* folder = [self value:SettingViewSubFolderDocumentEnable kbguid:SettingGlobalKbguid accountUserId:SettingGlobalAccountUserId];
    return folder;
}

- (NSString*) viewSubTagDocument
{
    NSString* tag = [self value:SettingViewSubTagDocumentEnable kbguid:SettingGlobalKbguid accountUserId:SettingGlobalAccountUserId];
    return tag;
}

- (BOOL) isPasscodeEnable
{
    NSString* password = [self passcodePassword];
    if (!password || [password isEqualToString:@""]) {
        return NO;
    }
    else
    {
        return YES;
    }
}
- (BOOL)isViewSubFolderDocument {
    NSString* folder = [self viewSubFolderDocument];
    if (!folder || [folder isEqualToString:@""]) {
        //默认开启
        [self setIsViewSubFolderDocument:YES];
        return YES;
    }
    if ([folder isEqualToString:@"0"])
        return NO;
    else
    {
        return YES;
    }
}

- (BOOL)isViewSubTagDocument {
    NSString* tag = [self viewSubTagDocument];
    if (!tag || [tag isEqualToString:@""]) {
        [self setIsViewSubTagDocument:YES];
        return YES;
    }
    if ([tag isEqualToString:@"0"])
        return NO;
    else
    {
        return YES;
    }
}


- (enum WizPhotoQulity) photoQulity
{
    NSNumber* number = [self value:SettingPhotoQulity kbguid:SettingGlobalKbguid accountUserId:SettingGlobalAccountUserId];
    if (!number) {
        return WizPhotoQulityHigh;
    }
    return [number intValue];
}

- (void) setPhotoQulity:(enum WizPhotoQulity)qulity
{
    [self setValue:[NSNumber numberWithFloat:qulity] key:SettingPhotoQulity kbguid:SettingGlobalKbguid accountUserId:SettingGlobalAccountUserId];
}

- (BOOL) isAutoSyncEnable
{
    NSNumber* sync = [self value:SettingAutoSyncEnable kbguid:SettingGlobalKbguid accountUserId:SettingGlobalAccountUserId];
    if (!sync) {
        return YES;
    }
    return [sync boolValue];
}
- (void) setAutoSyncEnable:(BOOL)enable
{
    [self setValue:[NSNumber numberWithBool:enable] key:SettingAutoSyncEnable kbguid:SettingGlobalKbguid accountUserId:SettingGlobalAccountUserId];
}

- (BOOL) isAutoSyncVia3GEnable
{
    NSNumber* sync = [self value:SettingAutoSyncVia3GEnable kbguid:SettingGlobalKbguid accountUserId:SettingGlobalAccountUserId];
    if (!sync) {
        return NO;
    }
    return [sync boolValue];
}
- (void) setAutoSyncVia3GEnable:(BOOL)enable
{
    [self setValue:[NSNumber numberWithBool:enable] key:SettingAutoSyncVia3GEnable kbguid:SettingGlobalKbguid accountUserId:SettingGlobalAccountUserId];
}
- (BOOL) isAutoSyncViaWiFiEnable
{
    return [self isAutoSyncEnable];
}
- (void) setAutoSyncViaWiFiEnable:(BOOL)enable
{
    [self setAutoSyncEnable:enable];
}

- (BOOL) canAutoSync
{
    if (([self isAutoSyncEnable] && IsReachableInternerViaWifi()) || ([self isAutoSyncVia3GEnable] && IsReachableInternetVia3G())) {
            return YES;
    }
    return NO;
}

- (void) setAccount:(NSString *)accountUserID attribute:(NSDictionary *)attribute
{
    [self setValue:attribute key:SettingAccountAttribute kbguid:SettingGlobalKbguid accountUserId:accountUserID];
    [[NSNotificationCenter defaultCenter] postNotificationName:WizNotificationMessageUserAttributeUpdate object:nil userInfo:@{WizNotificationUserInfoAccountUserId:accountUserID}];
}

- (void) setAccountType:(WizProType)proType accountUserId:(NSString*)userId
{
    NSMutableDictionary* dictionary = [[self accountAttributes:userId] mutableCopy];
    NSString* type = @"free";
    if (proType != WizProTypeNone) {
        type = @"vip";
    }
    dictionary[@"user_type"] = type;
    [self setAccount:userId attribute:dictionary];
}
- (NSDictionary*) accountAttributes:(NSString*)accountUserId
{
    return [self value:SettingAccountAttribute kbguid:SettingGlobalKbguid accountUserId:accountUserId];
}

- (void) setDefaultFolder:(NSString*)folder  accountID:(NSString*)userId
{
    [self setValue:folder key:@"WizDefaultFolder" kbguid:SettingGlobalKbguid accountUserId:userId];
}
- (NSString*) defaultFolder:(NSString*)userId
{
    NSString* folder = [self value:@"WizDefaultFolder" kbguid:SettingGlobalKbguid accountUserId:userId];
    if (folder == nil) {
        folder = @"/My Notes/";
    }
    return folder;
}

- (WizEditingDocument*) lastEditingDocument
{
    NSDictionary* lastEditingDoc = [[NSUserDefaults standardUserDefaults] objectForKey:SettingLastEditingDocument];
    if (lastEditingDoc) {
        WizEditingDocument* doc = [[WizEditingDocument alloc] init];
        [doc fromWizServerObject:lastEditingDoc];
        return doc;
    }
    return nil;
}
- (WizEditingDocument*) lastEditingDocumentForAccountUserId:(NSString*)accountUserId kbguid:(NSString*)kbguid
{
    if (kbguid == nil) {
        kbguid = WizGlobalPersonalKbguid;
    }
    NSString* key = WizSettingKey(accountUserId,kbguid,@"lastEditingDocument");
    NSDictionary* lastEditingDoc = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (!lastEditingDoc) {
        return nil;
    }
    else
    {
        WizEditingDocument* doc = [[WizEditingDocument alloc] init];
        [doc fromWizServerObject:lastEditingDoc];
        [doc updatePropertyFromDictionary:lastEditingDoc];
        return doc;
    }
}

- (BOOL) setLastEditingDocument:(WizEditingDocument*)document accountUserId:(NSString*)accountUserId kbguid:(NSString*)kbguid
{
    return [self setLastEditingDocument:document addedAttachments:[NSMutableArray array] deletedAttachments:[NSMutableArray array] accountUserId:accountUserId kbguid:kbguid];
}

- (BOOL)setLastEditingDocument:(WizEditingDocument *)document addedAttachments:(NSMutableArray *)addedAttachments deletedAttachments:(NSMutableArray *)deletedAttachments accountUserId:(NSString *)accountUserId kbguid:(NSString *)kbguid {
    if (kbguid == nil) {
        kbguid = WizGlobalPersonalKbguid;
    }
    NSString* key = WizSettingKey(accountUserId,kbguid,@"lastEditingDocument");
    if (!document) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
    else
    {
        document.addedAttachments=addedAttachments;
        document.deletedAttachments=deletedAttachments;
        NSDictionary* dic = [document toWizServerObject];
        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:key];
    }
    return  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setLastEditingDocument:(WizEditingDocument *)doc
{
    if (doc) {
        NSDictionary* model = [doc toWizServerObject];
        [[NSUserDefaults standardUserDefaults] setObject:model forKey:SettingLastEditingDocument];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:SettingLastEditingDocument];
    }
}

//wzz
- (NSString*) mywizEmailForAccount:(NSString*)accountUserId
{
    NSDictionary* dic = [self accountAttributes:accountUserId];
    return [dic objectForKey:@"mywiz_email"];
}

- (NSString*) personalKbGuid:(NSString*)accountUserId
{
    NSDictionary* dic = [self accountAttributes:accountUserId];
    return dic[@"kb_guid"];
}

- (void) setLastUpdateDateForMessageCenter:(NSString*)accountUserId
{
    [self setValue:[NSDate date] key:SettingMessageCenterLastUpadateDate kbguid:SettingGlobalKbguid accountUserId:accountUserId];
}
- (NSDate*)LastUpdateDateForMessageCenter:(NSString*)accountUserId
{
    return [self value:SettingMessageCenterLastUpadateDate kbguid:SettingGlobalKbguid accountUserId:accountUserId];
}

- (enum WizHomePageType)defaultHomePageTypeForAccount:(NSString*)accountUserId
{
    NSNumber* homePageType = [self value:SettingDefaultHomePageName kbguid:SettingGlobalKbguid accountUserId:accountUserId];
    if (!homePageType){
        return WizHomePageTypePersonalNotes;
    }
    return [homePageType intValue];
}

- (void)setDefaultHomePageType:(enum WizHomePageType)homePageType ForAccount:(NSString*)accountUserId
{
    [self setValue:[NSNumber numberWithInt:homePageType] key:SettingDefaultHomePageName kbguid:SettingGlobalKbguid accountUserId:accountUserId];
}

- (BOOL) isNewBizUserForAccount:(NSString*)accountUserId
{
    NSNumber* isNew = [self value:SettingWizAccountIsOldBizUser kbguid:SettingGlobalKbguid accountUserId:accountUserId];
    if (!isNew) {
        return YES;
    }
    return [isNew boolValue];
}
- (void) setAccountIsOldBizUser:(NSString*)accountUserId
{
    [self setValue:[NSNumber numberWithBool:NO] key:SettingWizAccountIsOldBizUser kbguid:SettingGlobalKbguid accountUserId:accountUserId];
}

static NSString* const WizSyncEncryptTypeKey = @"WizSyncEncryptTypeKey";

- (WizSyncEncryptType) syncEncryptType
{
    NSNumber* type =  [self value:WizSyncEncryptTypeKey kbguid:SettingGlobalKbguid accountUserId:SettingGlobalAccountUserId];
    if (!type) {
        return WizSyncHTTPS;
    }
    return (WizSyncEncryptType)[type intValue];
}
- (void) setSyncEncryptType:(WizSyncEncryptType)type
{
    [self setValue:@(type) key:WizSyncEncryptTypeKey kbguid:SettingGlobalKbguid accountUserId:SettingGlobalAccountUserId];
}

static NSString* const WizAppCrash = @"WizAppCrash";

- (void) setAppCrash:(BOOL)crash
{
    [self setValue:@(crash) key:WizAppCrash kbguid:WizAppCrash accountUserId:WizAppCrash];
}

- (BOOL) appCrash
{
    NSNumber* num = [self value:WizAppCrash kbguid:WizAppCrash accountUserId:WizAppCrash];
    return [num boolValue];
}

- (void) setAppearOnceKey:(NSString *)key
{
    [self setValue:@(1) key:key kbguid:key accountUserId:key];
}
- (BOOL) appearOnceKeyExist:(NSString *)key
{
    BOOL appear = [self value:key kbguid:key accountUserId:key]?YES:NO;
    [self setAppearOnceKey:key];
    return appear;
}
@end

@implementation NSDictionary (AccountAttributes)
- (int) userPoint
{
    return [self[@"user_points"] integerValue];
}
- (NSString*) userPointsString
{
    return [NSString stringWithFormat:@"%d",[self userPoint]];
}


- (NSString*) userType
{
    return self[@"user_type"];
}
- (NSDate*) expireVipDate
{
    return  self[@"vip_date"];
}
- (NSString*) userGuid
{
    return self[@"user"][@"user_guid"];
}
@end
