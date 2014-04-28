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
static NSString* const SettingPhotoQulity   = @"SettingPhotoQulity";
static NSString* const SettingAutoSyncEnable = @"SettingAutoSyncEnable";
static NSString* const SettingAccountAttribute = @"SettingAccountAttribute";
static NSString* const SettingWebSharingEnable = @"SettingWebSharingEnable";

//
static NSString* const SettingGlobalKbguid = @"SettingGlobalKbguid";
static NSString* const SettingGlobalAccountUserId = @"SettingGlobalAccountUserId";
//
static NSString* const SettingLastEditingDocument = @"SettingLastEditingDocument";
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
@implementation WizEditingDocument

@synthesize accountUserId;
@synthesize kbguid;
@synthesize isNewNote;

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
    [[NSUserDefaults standardUserDefaults] setObject:accountUserId  forKey:WizSettingsActiveAccountUserId];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    [self setValue:date key:SettingLastUpdateDate kbguid:kbguid accountUserId:accountUserId];
}
- (NSDate*) lastUpdateDate:(NSString *)kbguid accountUserId:(NSString *)accountUserId
{
    NSDate* date = [self value:SettingLastUpdateDate kbguid:kbguid accountUserId:accountUserId];
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

- (enum WizPhotoQulity) photoQulity
{
    NSNumber* number = [self value:SettingPhotoQulity kbguid:SettingGlobalKbguid accountUserId:SettingGlobalAccountUserId];
    if (!number) {
        return WizPhotoQulityHigh;
    }
    return [number floatValue];
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

- (BOOL) canAutoUpload
{
    if ([self isAutoSyncEnable] && IsReachableInternerViaWifi()) {
            return YES;
    }
    return NO;
}

- (void) setAccount:(NSString *)accountUserID attribute:(NSDictionary *)attribute
{
    [self setValue:attribute key:SettingAccountAttribute kbguid:SettingGlobalKbguid accountUserId:accountUserID];
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

@end
