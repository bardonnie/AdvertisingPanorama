//
//  WizObjec.m
//  WizIos
//
//  Created by dzpqzb on 12-12-19.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import "WizObject.h"
//
#import "WizGlobals.h"


NSString* const WizObjectTypeDocument = @"document";
NSString* const WizObjectTypeTag = @"tag";
NSString* const WizObjectTypeAttachment = @"attachment";

@interface NSMutableDictionary (NotNil)
- (void) setObjectNotNil:(id)anObject forKey:(id<NSCopying>)aKey;
@end

@implementation NSMutableDictionary (NotNil)

- (void) setObjectNotNil:(id)anObject forKey:(NSString*)aKey
{
    if (anObject == nil) {
        return;
    }
    if (aKey == nil) {
        return;
    }
    [self setObject:anObject forKey:aKey];
}

@end

//
@implementation WizObject
@synthesize guid;
@synthesize title;
@synthesize version;
- (void) fromWizServerObject:(id)obj
{
    
}
@end

@interface WizDictionayObject ()
@property (nonatomic, strong) NSDictionary* dic;
@end
@implementation WizDictionayObject
@synthesize dic;
- (void) fromWizServerObject:(id)obj
{
    if ([obj isKindOfClass:[NSDictionary class]]) {
        self.dic = obj;
    }
}
@end
//
@implementation WizLoginData

- (NSString*) token
{
    return [self.dic objectForKey:@"token"];
}

- (NSString*) kapiUrl
{
    return [self.dic objectForKey:@"kapi_url"];
}

- (NSString*) kbguid
{
    return [self.dic objectForKey:@"kb_guid"];
}
- (NSDictionary*) userAttributes
{
    return self.dic;
}
@end

@implementation WizAllVersionData

- (int64_t) getVersionForKey:(NSString*)key
{
    NSNumber* version = [self.dic objectForKey:key];
    if (version == nil) {
        return -1;
    }
    return [version intValue];
}

- (int64_t) deletedGuidVersion
{
    return [self getVersionForKey:@"deleted_version"];
}

- (int64_t) attachmentVersion
{
    return [self getVersionForKey:@"attachment_version"];
}
- (int64_t) tagVersion
{
    return [self getVersionForKey:@"tag_version"];
}

- (int64_t) documentVersion
{
    return [self getVersionForKey:@"document_version"];
}
@end

@implementation WizServerData
@synthesize data =_data;
@synthesize isEof;
@synthesize objSize;
@synthesize partMd5;
- (void) fromWizServerObject:(id)obj
{
    if ([obj isKindOfClass:[NSDictionary class]]) {
        _data = obj[@"data"];
        partMd5 = obj[@"part_md5"];
        objSize = [obj[@"obj_size"] intValue];
        isEof = [obj[@"eof"] boolValue];
    }
}

@end

@implementation WizServerObjectsArray
@synthesize array= _array;
- (id) init
{
    self = [super init];
    if (self) {
        _array = [[NSMutableArray alloc] init];
    }
    return self;
}
- (void) addObject:(id)obj
{
    [_array addObject:obj];
}
- (void) fromWizServerObject:(id)obj
{
    
}
@end
@implementation WizServerGroupsArray
- (void) fromWizServerObject:(id)obj
{
    if ([obj isKindOfClass:[NSArray class]]) {
        for (NSDictionary* each in obj) {
            WizGroup* group = [[WizGroup alloc] init];
            [group fromWizServerObject:each];
            [self addObject:group];
        }
    }
}
@end
@implementation WizServerTagsArray
- (void) fromWizServerObject:(id)obj
{
    if ([obj isKindOfClass:[NSArray class]]) {
        for (NSDictionary* each in obj) {
            WizTag* tag = [[WizTag alloc] init];
            [tag fromWizServerObject:each];
            [self addObject:tag];
        }
    }
}
- (int) version
{
    int version = 0;
    for (WizTag* tag in self.array) {
        version = version > tag.version ? version : tag.version;
    }
    return version;
}
@end

@implementation WizServerDocumentsArray

- (void) fromWizServerObject:(id)obj
{
    if ([obj isKindOfClass:[NSArray class]]) {
        for (NSDictionary* each in obj) {
            WizDocument* document = [[WizDocument alloc] init];
            [document fromWizServerObject:each];
            [self addObject:document];
        }
    }
}
- (int) version
{
    int version = 0;
    for (WizDocument* doc in self.array) {
        version = version > doc.version ? version : doc.version;
    }
    return version;
}
@end

@implementation WizServerDeletedGuidsAarray

- (void) fromWizServerObject:(id)obj
{
    if ([obj isKindOfClass:[NSArray class]]) {
        for (NSDictionary* each in obj) {
            WizDeletedGuid* deleteguid = [[WizDeletedGuid alloc] init];
            [deleteguid fromWizServerObject:each];
            [self addObject:deleteguid];
        }
    }
}

- (int) version
{
    int version = 0;
    for (WizDeletedGuid* deletedguid in self.array) {
        version = version > deletedguid.version ? version : deletedguid.version;
    }
    return version;
}

@end

@implementation WizServerAttachmentsArray

- (void) fromWizServerObject:(id)obj
{
    if ([obj isKindOfClass:[NSArray class]]) {
        for (NSDictionary*  each in obj) {
            WizAttachment* attachment = [[WizAttachment alloc] init];
            [attachment fromWizServerObject:each];
            [self addObject:attachment];
        }
    }
}

- (int) version
{
    int version = 0;
    for (WizAttachment* each in self.array) {
        version = version > each.version ? version: each.version;
    }
    return version;
}

@end
//document
static NSString* const  DataTypeUpdateDocumentGUID          =       @"document_guid";
static NSString* const DataTypeUpdateDocumentTitle          =       @"document_title";
static NSString* const DataTypeUpdateDocumentLocation       =       @"document_location";
static NSString* const DataTypeUpdateDocumentDataMd5        =       @"data_md5";
static NSString* const DataTypeUpdateDocumentUrl            =       @"document_url";
static NSString* const DataTypeUpdateDocumentTagGuids       =       @"document_tag_guids";
static NSString* const DataTypeUpdateDocumentDateCreated    =       @"dt_created";
static NSString* const DataTypeUpdateDocumentDateModified   =       @"dt_modified";
static NSString* const DataTypeUpdateDocumentType           =       @"document_type";
static NSString* const DataTypeUpdateDocumentFileType       =       @"document_filetype";
static NSString* const DataTypeUpdateDocumentAttachmentCount=       @"document_attachment_count";
static NSString* const DataTypeUpdateDocumentLocalchanged   =       @"document_localchanged";
static NSString* const DataTypeUpdateDocumentServerChanged  =       @"document_serverchanged";
static NSString* const DataTypeUpdateDocumentProtected      =       @"document_protect";
static NSString* const DataTypeUpdateDocumentGPS_LATITUDE   =       @"gps_latitude";
static NSString* const DataTypeUpdateDocumentGPS_LONGTITUDE =       @"gps_longitude";
static NSString* const DataTypeUpdateDocumentGPS_ALTITUDE   =       @"GPS_ALTITUDE";
static NSString* const DataTypeUpdateDocumentGPS_DOP        =       @"GPS_DOP";
static NSString* const DataTypeUpdateDocumentGPS_ADDRESS    =       @"GPS_ADDRESS";
static NSString* const DataTypeUpdateDocumentGPS_COUNTRY    =       @"GPS_COUNTRY";
static NSString* const DataTypeUpdateDocumentGPS_LEVEL1     =       @"GPS_LEVEL1";
static NSString* const DataTypeUpdateDocumentGPS_LEVEL2     =       @"GPS_LEVEL2";
static NSString* const DataTypeUpdateDocumentGPS_LEVEL3     =       @"GPS_LEVEL3";
static NSString* const DataTypeUpdateDocumentGPS_DESCRIPTION=       @"GPS_DESCRIPTION";
static NSString* const DataTypeUpdateDocumentREADCOUNT      =       @"READCOUNT";
static NSString* const DataTypeUpdateDocumentOwner          =       @"document_owner";
static NSString* const DataTypeOfVersion                    =       @"version";
static NSString* const DataTypeUpdateDocumentKeyWords       =       @"document_keywords";
@implementation WizDocument
@synthesize dataMd5;
@synthesize dateCreated;
@synthesize dateModified;
@synthesize attachmentCount;
@synthesize fileType;
@synthesize gpsAddress;
@synthesize gpsAltitude;
@synthesize gpsCountry;
@synthesize gpsDescription;
@synthesize gpsDop;
@synthesize gpsLatitude;
@synthesize gpsLevel1;
@synthesize gpsLevel2;
@synthesize gpsLevel3;
@synthesize gpsLongtitude;
@synthesize localChanged;
@synthesize location;
@synthesize nReadCount;
@synthesize bProtected;
@synthesize serverChanged;
@synthesize tagGuids;
@synthesize type;
@synthesize url;
@synthesize ownerName;
@synthesize keyWords;
- (void) setLocalChanged:(enum WizEditDocumentType)localChanged_
{
    if (localChanged == WizEditDocumentTypeAllChanged && localChanged_ == WizEditDocumentTypeInfoChanged) {
        return;
    }
    localChanged = localChanged_;
}

- (id) copyWithZone:(NSZone *)zone
{
    WizDocument* document ;
    document = [[self class] allocWithZone:zone];
    return document;
}
- (void) fromWizServerObject:(id)doc
{
    self.guid = [doc valueForKey:DataTypeUpdateDocumentGUID];
    self.title =[doc valueForKey:DataTypeUpdateDocumentTitle];
    self.location = [doc valueForKey:DataTypeUpdateDocumentLocation];
    self.dataMd5 = [doc valueForKey:DataTypeUpdateDocumentDataMd5];
    self.url = [doc valueForKey:DataTypeUpdateDocumentUrl];
    self.tagGuids = [doc valueForKey:DataTypeUpdateDocumentTagGuids];
    self.dateCreated = [doc valueForKey:DataTypeUpdateDocumentDateCreated];
    self.dateModified = [doc valueForKey:DataTypeUpdateDocumentDateModified];
    self.type = [doc valueForKey:DataTypeUpdateDocumentType];
    self.fileType = [doc valueForKey:DataTypeUpdateDocumentFileType];
    self.ownerName = [doc valueForKey:DataTypeUpdateDocumentOwner];
    self.keyWords = [doc valueForKey:DataTypeUpdateDocumentKeyWords];
    NSNumber* nAttachmentCount = [doc valueForKey:DataTypeUpdateDocumentAttachmentCount];
    NSNumber* nProtected = [doc valueForKey:DataTypeUpdateDocumentProtected];
    NSNumber* nReadCount_ = [doc valueForKey:DataTypeUpdateDocumentREADCOUNT];
    NSNumber* gpsLatitue = [doc valueForKey:DataTypeUpdateDocumentGPS_LATITUDE];
    NSNumber* gpsLongtitue = [doc valueForKey:DataTypeUpdateDocumentGPS_LONGTITUDE];
    NSNumber* gpsAltitue    = [doc valueForKey:DataTypeUpdateDocumentGPS_ALTITUDE];
    NSNumber* gpsDop_        = [doc valueForKey:DataTypeUpdateDocumentGPS_DOP];
    NSNumber* version = [doc valueForKey:DataTypeOfVersion];
    if (version) {
        self.version = [version intValue];
    }
    if (nProtected) {
        self.bProtected = [nProtected boolValue];
    }
    
    if (nReadCount_) {
        self.nReadCount = [nReadCount_ intValue];
    }
    if (gpsLatitue) {
        self.gpsLatitude = [gpsLatitue floatValue];
    }
    if (gpsLongtitue) {
        self.gpsLongtitude = [gpsLongtitue floatValue];
    }
    if (gpsDop_) {
        self.gpsDop = [gpsDop_ floatValue];
    }
    if (gpsAltitue) {
        self.gpsAltitude = [gpsAltitue floatValue];
    }
    if (nAttachmentCount) {
        self.attachmentCount = [nAttachmentCount intValue];
    }
    self.gpsAddress  = [doc valueForKey:DataTypeUpdateDocumentGPS_ADDRESS];
    self.gpsCountry = [doc valueForKey:DataTypeUpdateDocumentGPS_COUNTRY];
    self.gpsLevel1 = [doc valueForKey:DataTypeUpdateDocumentGPS_LEVEL1];
    self.gpsLevel2 = [doc valueForKey:DataTypeUpdateDocumentGPS_LEVEL2];
    self.gpsLevel3 = [doc valueForKey:DataTypeUpdateDocumentGPS_LEVEL3];
    self.gpsDescription  = [doc valueForKey:DataTypeUpdateDocumentGPS_DESCRIPTION];
 
}

- (NSDictionary*) toWizServerObject
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObjectNotNil:self.guid forKey:@"document_guid"];
    [dic setObjectNotNil:self.title forKey:@"document_title"];
    [dic setObjectNotNil:self.type forKey:@"document_type"];
    [dic setObjectNotNil:self.fileType forKey:@"document_filetype"];
    [dic setObjectNotNil:self.dateModified forKey:@"dt_modified"];
    [dic setObjectNotNil:self.location forKey:@"document_category"];
    [dic setObjectNotNil:[NSNumber numberWithInt:1] forKey:@"document_info"];
    [dic setObjectNotNil:self.dataMd5 forKey:@"document_zip_md5"];
    [dic setObjectNotNil:self.dateCreated forKey:@"dt_created"];
    [dic setObjectNotNil:[NSNumber numberWithInt:self.attachmentCount] forKey:@"document_attachment_count"];
    [dic setObjectNotNil:self.tagGuids forKey:@"document_tag_guids"];
    return dic;
}

- (void) loadDefaultValue
{
    if (self.location == nil) {
        self.location = @"/My Notes/";
    }
    if (self.type == nil) {
        self.type = @"ios-note";
    }
    if (self.title == nil) {
        self.title = NSLocalizedString(@"No Title", nil);
    }
    if (self.dateModified == nil) {
        self.dateModified = [NSDate date];
    }
    if (self.dateCreated == nil) {
        self.dateCreated = [NSDate date];
    }
    if (self.tagGuids == nil) {
        self.tagGuids = @"";
    }
}

@end

//tag
#define DataTypeUpdateTagTitle                  @"tag_name"
#define DataTypeUpdateTagGuid                   @"tag_guid"
#define DataTypeUpdateTagParentGuid             @"tag_group_guid"
#define DataTypeUpdateTagDescription            @"tag_description"
#define DataTypeUpdateTagVersion                @"version"
#define DataTypeUpdateTagDtInfoModifed          @"dt_info_modified"
#define DataTypeUpdateTagLocalchanged           @"local_changed"


@implementation WizTag
@synthesize dateInfoModified;
@synthesize detail;
@synthesize parentGUID;
@synthesize namePath;
- (void) fromWizServerObject:(id)tag
{
    if ([tag isKindOfClass:[NSDictionary class]]) {
        self.guid = [tag objectForKey:DataTypeUpdateTagGuid];
        self.title = [tag objectForKey:DataTypeUpdateTagTitle];
        self.parentGUID = [tag objectForKey:DataTypeUpdateTagParentGuid];
        self.detail = [tag objectForKey:DataTypeUpdateTagDescription];
        self.dateInfoModified = [tag objectForKey:DataTypeUpdateTagDtInfoModifed];
        NSNumber* localChangedN = [tag objectForKey:DataTypeUpdateTagLocalchanged];
        if (localChangedN) {
            self.localChanged = [localChangedN integerValue];
        }
        else
        {
            self.localChanged = 0;
        }
        NSNumber* versionN = [tag objectForKey:DataTypeOfVersion];
        if (versionN) {
            self.version = [versionN intValue];
        }
    }
}
- (NSDictionary*) toWizServerObject
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:5];
    [dic setObjectNotNil:self.guid forKey:@"tag_guid"];
    [dic setObjectNotNil:self.parentGUID forKey:@"tag_group_guid"];
    [dic setObjectNotNil:self.title forKey:@"tag_name"];
    [dic setObjectNotNil:self.detail forKey:@"tag_description"];
    [dic setObjectNotNil:self.dateInfoModified forKey:@"dt_info_modified"];
    return dic;
}
@end

#define DataTypeUpdateAttachmentDescription     @"attachment_description"
#define DataTypeUpdateAttachmentDocumentGuid    @"attachment_document_guid"
#define DataTypeUpdateAttachmentGuid            @"attachment_guid"
#define DataTypeUpdateAttachmentTitle           @"attachment_name"
#define DataTypeUpdateAttachmentDataMd5         @"data_md5"
#define DataTypeUpdateAttachmentDateModified    @"dt_data_modified"
#define DataTypeUpdateAttachmentInfoDateModified @"dt_info_modified"
#define DataTypeUpdateAttachmentServerChanged   @"sever_changed"
#define DataTypeUpdateAttachmentLocalChanged    @"local_changed"

@implementation WizAttachment
@synthesize type;
@synthesize dataMd5;
@synthesize detail;
@synthesize dateModified;
@synthesize documentGuid;
@synthesize serverChanged;
@synthesize localChanged;
- (id) initWithFilePath:(NSString*)filePath
{
    self = [super init];
    if (self) {
        NSString* fileName = [filePath fileName];
        self.title = fileName;
        self.dateModified = [NSDate date];
        self.serverChanged = NO;
        self.localChanged = YES;
        self.documentGuid = nil;
        self.dataMd5 = [WizGlobals fileMD5:filePath];
        self.guid = [WizGlobals genGUID];
        self.detail = filePath;
        self.documentGuid = @"";
    }
    return self;
}
- (NSString*) type
{
    if (!type) {
        return [self.title fileName];
    }
    return type;
}

- (void) fromWizServerObject:(id)obj
{
    self.guid = [obj objectForKey:DataTypeUpdateAttachmentGuid];
    self.documentGuid = [obj objectForKey:DataTypeUpdateAttachmentDocumentGuid];
    self.title = [obj objectForKey:DataTypeUpdateAttachmentTitle];
    self.detail = [obj objectForKey:DataTypeUpdateAttachmentDescription];
    self.dateModified = [obj objectForKey:DataTypeUpdateAttachmentDateModified];
//    if (![self.dateModified isKindOfClass:[NSDate class]]) {
//        self.dateModified = [NSDate date];
//    }
    self.dataMd5 = [obj objectForKey:DataTypeUpdateAttachmentDataMd5];
    self.version = [obj[DataTypeOfVersion] intValue];
    NSNumber* server = [obj objectForKey:DataTypeUpdateAttachmentServerChanged];
    NSNumber* local  = [obj objectForKey:DataTypeUpdateAttachmentLocalChanged];
    if (server) {
        self.serverChanged = [server integerValue];
    }
    if (local) {
        self.localChanged = [local integerValue];
    }
}

- (NSDictionary*) toWizServerObject
{
    NSMutableDictionary* model = [NSMutableDictionary dictionary];
    [model setObjectNotNil:self.title forKey:DataTypeUpdateAttachmentTitle];
    [model setObjectNotNil:self.guid forKey:DataTypeUpdateAttachmentGuid];
    [model setObjectNotNil:self.dateModified forKey:@"dt_modified"];
    [model setObjectNotNil:self.dataMd5 forKey:DataTypeUpdateAttachmentDataMd5];
    [model setObjectNotNil:self.detail forKey:DataTypeUpdateAttachmentDescription];
    [model setObjectNotNil:self.documentGuid forKey:DataTypeUpdateAttachmentDocumentGuid];
    
    return model;
}
@end

@implementation WizDeletedGuid
- (void) fromWizServerObject:(id)obj
{
    if ([obj isKindOfClass:[NSDictionary class]]) {
        self.guid = obj[@"deleted_guid"];
        self.type = obj[@"guid_type"];
        self.version = [obj[@"version"] intValue];
        self.dateDeleted = obj[@"dt_deleted"];
    }
}

- (NSDictionary*) toWizServerObject
{
    NSMutableDictionary* deletedObject = [NSMutableDictionary dictionaryWithCapacity:3];
    [deletedObject setObjectNotNil:self.guid forKey:@"deleted_guid"];
    [deletedObject setObjectNotNil:self.type forKey:@"guid_type"];
    [deletedObject setObjectNotNil:self.dateDeleted forKey:@"dt_deleted"];
    return deletedObject;
}

@end

 NSString* const KeyOfKbKbguid = @"kb_guid";
 NSString* const KeyOfKbType = @"kb_type";
 NSString* const KeyOfKbName =@"kb_name";
 NSString* const KeyOfKbUserGroup=@"user_group";
 NSString* const KeyOfKbDateCreated=@"dt_created";
 NSString* const KeyOfKbDateModified=@"dt_modified";
 NSString* const KeyOfKbRoleCreated=@"dt_role_created";
 NSString* const KeyOfKbSeo=@"kb_seo";
 NSString* const KeyOfKbOwnerName=@"owner_name";
NSString* const KeyOfKbBizName = @"biz_name";
 NSString* const KeyOfKbNote=@"role_note";
NSString* const KeyOfKbKApiUrl = @"kapi_url";
 NSString* const KeyOfKbAccountUserId=@"AccountUserId";
 NSString* const KeyOfKbRoleNote = @"role_note";
@implementation WizGroup
@synthesize dateCreated;
@synthesize dateModified;
@synthesize dateRoleCreated;
@synthesize accountUserId;
@synthesize kbNote;
@synthesize kbId;
@synthesize orderIndex;
@synthesize ownerName;
@synthesize serverUrl;
@synthesize userGroup;
@synthesize roleNote;
@synthesize kbType;
@synthesize kbSeo;
@synthesize kApiurl;
@synthesize type;
@synthesize bizName=_bizName;
- (void) fromWizServerObject:(id)obj
{
    if ([obj isKindOfClass:[NSDictionary class]]) {
        self.dateCreated = obj[@"dt_created"];
        self.dateModified = obj[@"dt_modified"];
        self.dateRoleCreated = obj[@"dt_role_created"];
        self.guid = obj[@"kb_guid"];
        self.kbId = obj[@"kb_id"];
        self.title = obj[@"kb_name"];
        self.kbSeo = obj[@"kb_seo"];
        self.kbNote = obj[@"kb_note"];
        self.kbType = obj[@"kb_type"];
        self.ownerName = obj[@"owner_name"];
        self.roleNote = obj[@"role_note"];
        self.serverUrl = obj[@"server_url"];
        self.userGroup = [obj[@"user_group"] intValue];
        self.bizName = obj[@"biz_name"];
        NSString* apiUrl = obj[@"kapi_url"];
        self.kApiurl = apiUrl;
    }
}
- (NSString*) bizName
{
    if (!_bizName) {
        if (!self.guid) {
            return WizStrPersonalNotes;
        }
        else if ([self.guid isEqualToString:WizGlobalPersonalKbguid])
        {
            return WizStrPersonalNotes;
        }
        else
        {
            return NSLocalizedString(@"Personal Group", nil);
        }
    }
    return _bizName;
}
- (NSDictionary*) toWizServerObject
{
    NSMutableDictionary* model = [NSMutableDictionary dictionaryWithCapacity:10];
    [model setObjectNotNil:self.guid forKey:KeyOfKbKbguid];
    [model setObjectNotNil:self.dateCreated forKey:KeyOfKbDateCreated];
    [model setObjectNotNil:self.dateModified forKey:KeyOfKbDateModified];
    [model setObjectNotNil:self.title forKey:KeyOfKbName];
    [model setObjectNotNil:self.kbSeo forKey:KeyOfKbSeo];
    [model setObjectNotNil:self.kbType forKey:KeyOfKbType];
    [model setObjectNotNil:self.kApiurl forKey:KeyOfKbKApiUrl];
    [model setObjectNotNil:self.kbNote forKey:KeyOfKbNote];
    [model setObjectNotNil:self.ownerName forKey:KeyOfKbOwnerName];
    [model setObjectNotNil:self.roleNote forKey:KeyOfKbRoleNote];
    [model setObjectNotNil:self.bizName forKey:KeyOfKbBizName];
    [model setObjectNotNil:[NSNumber numberWithInt:self.userGroup] forKey:KeyOfKbUserGroup];
    return model;
}
@end

@implementation WizQueryDocument
@synthesize dataMd5;
@synthesize dtDataModified;
@synthesize dtInfoModified;
@synthesize dtParamModified;
@synthesize infoMd5;
@synthesize paramMd5;
- (void) fromWizServerObject:(id)obj
{
    if ([obj isKindOfClass:[NSDictionary class]]) {
        self.dataMd5 = obj[@"data_md5"];
        self.infoMd5 = obj[@"info_md5"];
        self.paramMd5 = obj[@"param_md5"];
        self.dtParamModified = obj[@"dt_param_modified"];
        self.dtInfoModified = obj[@"dt_info_modified"];
        self.dtDataModified = obj[@"dt_data_modified"];
        self.guid = obj[@"document_guid"];
        self.title = obj[@"document_title"];
    }
}

@end

@implementation WizQuerayDocumentDictionay

- (void) fromWizServerObject:(id)obj
{
    if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
        for (NSDictionary* each in obj) {
            WizQueryDocument* docQuery = [[WizQueryDocument alloc] init];
            [docQuery fromWizServerObject:each];
            [dic setObjectNotNil:docQuery forKey:docQuery.guid];
        }
        self.dic = dic;
    }
}
- (WizQueryDocument*) queryDocumentForGuid:(NSString *)guid
{
    return [self.dic objectForKey:guid];
}

@end

@implementation WizQuerayAttachmentDictionay
- (void) fromWizServerObject:(id)obj
{
    
}

@end

@implementation WizUserPrivilige

+ (BOOL) canDownloadList:(int)privilige
{
    return privilige <= 10000;
}

+ (BOOL) canEditNote:(WizDocument*)doc privilige:(int)privilige accountUserId:(NSString*)accountUserId
{
    if ([WizUserPrivilige isSupreEditor:privilige]) {
        return YES;
    }
    else if(privilige <= 100 && [accountUserId isEqualToString:doc.ownerName])
    {
        return YES;
    }
    return NO;
}

+ (BOOL) canUploadDeletedList:(int)privilige
{
    return privilige <= 100;
}
+ (BOOL) isSupreEditor:(int)privilige
{
    return privilige <=50;
}
+ (BOOL) canUploadDocuments:(int)privilige
{
    return privilige <= 100;
}

+ (BOOL) canUploadTags:(int)privilige
{
    return privilige <= 10;
}
+ (BOOL) canNewNote:(int)privilige
{
    return privilige <=100;
}

@end


@implementation WizAccount
@synthesize accountUserId;
@synthesize password;
@synthesize personalKbguid;
@end

@implementation WizAbstract

@synthesize guid;
@synthesize image;
@synthesize text;

@end


@implementation WizServerObject

@synthesize data;

- (void) fromWizServerObject:(id)obj
{
    if (obj != nil) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary* dic = (NSDictionary*)obj;
            data = [dic objectForKey:@"value_of_key"];
        }
        else
        {
            data = obj;
        }
    }
}

@end

@implementation WizServerVersionObject

@synthesize version;

- (void) fromWizServerObject:(id)obj
{
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)obj;
        version = [dic[@"version"] longLongValue];
    }
}

@end


@implementation WizFolder

@synthesize key;
@synthesize parentKey;
@synthesize localChanged;
- (NSString*) getParentKey
{
    if (key) {
        return [key stringByDeletingLastPathComponent];
    }
    else
    {
        return @"/";
    }
}
@end


@implementation WizSearch

@synthesize dateSearched;
@synthesize count;
@synthesize kbguid;
@synthesize keyWords;
@synthesize type;

@end
