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

static NSString* const DataTypeOfVersion = @"version";

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

- (id) init
{
    self = [super init];
    if (self) {
        guid = [WizGlobals genGUID];
    }
    return self;
}
- (void) fromWizServerObject:(id)obj
{
    
}
- (void) setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:DataTypeOfVersion]) {
        version = [value longLongValue];
    }
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

-(NSString *)userGuid {
   NSDictionary *dictionary= [self.dic objectForKey:@"user"];
    return [dictionary objectForKey:@"user_guid"];
}

- (NSDictionary*) userAttributes
{
    return self.dic;
}


@end



//
@implementation WizCertData

- (NSString*) n
{
    return [self.dic objectForKey:@"n"];
}

- (NSString*) e
{
    return [self.dic objectForKey:@"e"];
}

- (NSString*) encrypted_d
{
    return [self.dic objectForKey:@"d"];
}


- (NSString*) hint
{
    return [self.dic objectForKey:@"hint"];
}

- (NSDictionary *)dict {
    return self.dic;
}
- (void)setDict:(NSDictionary *)dictionary {
    self.dic = dictionary;
}

@end




@implementation WizAllVersionData

- (int64_t) getVersionForKey:(NSString*)key
{
    NSNumber* version = [self.dic objectForKey:key];
    if (version == nil) {
        return -1;
    }
    return [version longLongValue];
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
        if ([_data length] == 0)
        {
            NSLog(@"failed to downlad data");
        }
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
- (int64_t) version
{
    int64_t version = 0;
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
- (int64_t) version
{
    int64_t version = 0;
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

- (int64_t) version
{
    int64_t version = 0;
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

- (int64_t) version
{
    int64_t version = 0;
    for (WizAttachment* each in self.array) {
        version = version > each.version ? version: each.version;
    }
    return version;
}

@end
//document

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

- (void) setLocalChanged:(WizEditDocumentType)localChanged_
{
    if (localChanged == WizEditDocumentTypeAllChanged && localChanged_ == WizEditDocumentTypeInfoChanged) {
        return;
    }
    localChanged = localChanged_;
}

- (id) copyWithZone:(NSZone *)zone
{
    WizDocument* document ;
    document = [[[self class] allocWithZone:zone] init];
    [document setValuesForKeysWithDictionary:[self toWizServerObject]];
    return document;
}
- (void) updatePropertyFromDictionary:(NSDictionary*)dic
{
    [self setValuesForKeysWithDictionary:dic];
}

- (void) setValue:(id)value forUndefinedKey:(NSString *)key
{
    if (!value) {
        return;
    }
    if ([key isEqualToString:DataTypeUpdateDocumentGUID]) {
            self.guid = value;
    }
    else if ([key isEqualToString:DataTypeUpdateDocumentTitle])
    {
            self.title = value;
    }
    else if ([key isEqualToString:DataTypeUpdateDocumentLocation])
    {
            self.location = value;
    }
    else if ([key isEqualToString:DataTypeUpdateDocumentDataMd5])
    {
            self.dataMd5 = value;
    }
    else if ([key isEqualToString:DataTypeUpdateDocumentUrl])
    {
            self.url = value;
    }
    else if ([key isEqualToString:DataTypeUpdateDocumentTagGuids])
    {
        self.tagGuids = value;
    }
    else if ([key isEqualToString:DataTypeUpdateDocumentDateCreated])
    {
        dateCreated = value;
    }
    else if ([key isEqualToString:DataTypeUpdateDocumentDateModified])
    {
        dateModified = value;
    }
    else if ([key isEqualToString:DataTypeUpdateDocumentType])
    {
        type = value;
    }
    else if ([key isEqualToString:DataTypeUpdateDocumentFileType])
    {
        fileType = value;
    }
    else if ([key isEqualToString:DataTypeUpdateDocumentOwner])
    {
        ownerName = value;
    }
    else if ([key isEqualToString:DataTypeUpdateDocumentKeyWords])
    {
        keyWords = value;
    }
    else if ([key isEqualToString:DataTypeUpdateDocumentGPS_ADDRESS])
    {
        gpsAddress = value;
    }
    else if ([key isEqualToString:DataTypeUpdateDocumentGPS_COUNTRY])
    {
        gpsCountry = value;
    }
    else if ([key isEqualToString:DataTypeUpdateDocumentGPS_LEVEL1])
    {
        gpsLevel1= value;
    }
    else if ([key isEqualToString:DataTypeUpdateDocumentGPS_LEVEL2])
    {
        gpsLevel2 = value;
    }
    else if ([key isEqualToString:DataTypeUpdateDocumentGPS_LEVEL3])
    {
        gpsLevel3 = value;
    }
    else if ([key isEqualToString:DataTypeUpdateDocumentGPS_DESCRIPTION])
    {
        gpsDescription = value;
    }
    else if ([key isEqualToString:DataTypeUpdateDocumentAttachmentCount])
    {
        attachmentCount = [value intValue];
    }
    else if ([key isEqualToString:DataTypeUpdateDocumentREADCOUNT])
    {
        nReadCount = [value intValue];
    }
    else if ([key isEqualToString:DataTypeUpdateDocumentProtected])
    {
        bProtected = [value boolValue];
    }
    else if ([key isEqualToString:DataTypeUpdateDocumentGPS_LATITUDE])
    {
        gpsLatitude = [value floatValue];
    }
    else if ([key isEqualToString:DataTypeUpdateDocumentGPS_LONGTITUDE])
    {
        gpsLongtitude = [value floatValue];
    }
    else if ([key isEqualToString:DataTypeUpdateDocumentGPS_DOP])
    {
        gpsDop = [value floatValue];
    }
    else if ([key isEqualToString:DataTypeUpdateDocumentGPS_ALTITUDE])
    {
        gpsAltitude = [value floatValue];
    }
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
        self.version = [version longLongValue];
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

- (NSDate*) dateModified
{
    if (!dateModified) {
        if (self.dateCreated) {
            return self.dateCreated;
        }
        else
        {
            return [NSDate dateWithTimeIntervalSince1970:0];
        }
    }
    return dateModified;
}

- (NSDictionary*) toWizServerObject
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObjectNotNil:self.guid forKey:DataTypeUpdateDocumentGUID];
    [dic setObjectNotNil:self.title forKey:DataTypeUpdateDocumentTitle];
    [dic setObjectNotNil:self.type forKey:DataTypeUpdateDocumentType];
    [dic setObjectNotNil:self.fileType forKey:DataTypeUpdateDocumentFileType];
    [dic setObjectNotNil:self.dateModified forKey:DataTypeUpdateDocumentDateModified];
    [dic setObjectNotNil:self.location forKey:DataTypeUpdateDocumentLocation];
    [dic setObjectNotNil:self.dataMd5 forKey:DataTypeUpdateDocumentZipDataMd5];
    [dic setObjectNotNil:self.dataMd5 forKey:DataTypeUpdateDocumentDataMd5];
    [dic setObjectNotNil:self.location forKey:@"document_category"];
    [dic setObjectNotNil:self.dateCreated forKey:DataTypeUpdateDocumentDateCreated];
    [dic setObjectNotNil:[NSNumber numberWithInt:self.attachmentCount] forKey:DataTypeUpdateDocumentAttachmentCount];
    [dic setObjectNotNil:self.tagGuids forKey:DataTypeUpdateDocumentTagGuids];
    [dic setObjectNotNil:self.ownerName forKey:DataTypeUpdateDocumentOwner];
    [dic setObjectNotNil:self.keyWords forKey:DataTypeUpdateDocumentKeyWords];
    [dic setObjectNotNil:[NSNumber numberWithBool:self.bProtected] forKey:DataTypeUpdateDocumentProtected];
    [dic setObjectNotNil:self.url forKey:DataTypeUpdateDocumentUrl];
    
    
    return dic;
}

- (void) setTagGuidsFromTagArray:(NSArray*)array
{
    NSMutableString* string = [NSMutableString new];
    for (WizTag* each in array) {
        [string appendFormat:@"%@;",each.guid];
    }
    if ([string hasSuffix:@";"]) {
        [string deleteCharactersInRange:NSMakeRange(string.length -1, 0)];
    }
    self.tagGuids = string;
}

- (void) loadDefaultValue
{
    if (!self.guid) {
        self.guid = [WizGlobals genGUID];
    }
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

- (BOOL) isInDeletedBox
{
    return [self.location hasPrefix:WizDeletedItemsKey];
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
            self.version = [versionN longLongValue];
        }
    }
}
- (void) loadDefaultValue
{
    if (!self.guid) {
        self.guid = [WizGlobals genGUID];
    }
    if (!self.dateInfoModified) {
        self.dateInfoModified = [NSDate date];
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



@implementation WizAttachment
@synthesize type = _type;
@synthesize dataMd5 = _dataMd5;
@synthesize detail = _detail;
@synthesize dateModified = _dateModified;
@synthesize documentGuid = _documentGuid;
@synthesize serverChanged = _serverChanged;
@synthesize localChanged = _localChanged;
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
    if (!_type) {
        return [self.title fileType];
    }
    return _type;
}

- (void) fromWizServerObject:(id)obj
{
    self.guid = [obj objectForKey:DataTypeUpdateAttachmentGuid];
    self.documentGuid = [obj objectForKey:DataTypeUpdateAttachmentDocumentGuid];
    self.title = [obj objectForKey:DataTypeUpdateAttachmentTitle];
    self.detail = [obj objectForKey:DataTypeUpdateAttachmentDescription];
    self.dateModified = [obj objectForKey:DataTypeUpdateAttachmentDateModified];
    self.dataMd5 = [obj objectForKey:DataTypeUpdateAttachmentDataMd5];
    self.version = [obj[DataTypeOfVersion] longLongValue];
    NSNumber* server = [obj objectForKey:DataTypeUpdateAttachmentServerChanged];
    NSNumber* local  = [obj objectForKey:DataTypeUpdateAttachmentLocalChanged];
    if (server) {
        self.serverChanged = [server integerValue];
    }
    if (local) {
        self.localChanged = [local integerValue];
    }
}
- (void) setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:DataTypeUpdateAttachmentDataMd5]) {
        _dataMd5 = value;
    }
    else if ([key isEqualToString:DataTypeUpdateAttachmentGuid])
    {
        self.guid = value;
    }
    else if ([key isEqualToString:DataTypeUpdateAttachmentDocumentGuid])
    {
        _documentGuid = value;
    }
    else if ([key isEqualToString:DataTypeUpdateAttachmentTitle])
    {
        self.title = value;
    }
    else if ([key isEqualToString:DataTypeUpdateAttachmentDateModified])
    {
        if ([value isKindOfClass:[NSString class]]) {
            NSString* dateStr = (NSString*)value;
            _dateModified = [dateStr dateFromSqlTimeString];
        }
        else if ([value isKindOfClass:[NSDate class]])
        {
            _dateModified = value;
        }
    }
    else if ([key isEqualToString:DataTypeUpdateAttachmentDescription])
    {
        _detail = value;
    }
    else if ([key isEqualToString:DataTypeOfVersion])
    {
        if ([value isKindOfClass:[NSNumber class]]) {
            self.version = [value longLongValue];
        }
        else if ([value isKindOfClass:[NSString class]])
        {
            self.version = [value longLongValue];
        }
    }
    else if ([key isEqualToString:DataTypeUpdateAttachmentServerChanged])
    {
        _serverChanged = [value boolValue];
    }
    else if ([key isEqualToString:DataTypeUpdateAttachmentLocalChanged])
    {
        _localChanged = [value boolValue];
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

    //添加以下两个字段用于临时保存。但修改此结构可能会将以下两个字段post到服务器，但服务器会忽略处理
    [model setObjectNotNil:[NSNumber numberWithInt:self.serverChanged] forKey:DataTypeUpdateAttachmentServerChanged];
    [model setObjectNotNil:[NSNumber numberWithInt:self.localChanged] forKey:DataTypeUpdateAttachmentLocalChanged];

    return model;
}
@end

@implementation WizDeletedGuid
- (void) fromWizServerObject:(id)obj
{
    if ([obj isKindOfClass:[NSDictionary class]]) {
        self.guid = obj[@"deleted_guid"];
        self.type = obj[@"guid_type"];
        self.version = [obj[@"version"] longLongValue];
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
NSString* const KeyOfKbBizGuid = @"biz_guid";
NSString* const KeyOfKbMyWizEmail = @"mywiz_email";
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
@synthesize isBiz;
@synthesize mywizEmail;
@synthesize bizGuid;

- (BOOL) isEqualToGroup:(WizGroup*)group
{
    if (![group.accountUserId isEqualToString:self.accountUserId]) {
        return NO;
    }
    if (!group.guid && !self.guid) {
        return YES;
    }
    return [group.guid isEqualToString:self.guid];
}

- (void) fromWizServerObject:(id)obj
{
    if ([obj isKindOfClass:[NSDictionary class]]) {
        self.dateCreated = obj[KeyOfKbDateCreated];
        self.dateModified = obj[KeyOfKbDateModified];
        self.dateRoleCreated = obj[KeyOfKbRoleCreated];
        self.guid = obj[KeyOfKbKbguid];
        self.kbId = obj[@"kb_id"];
        self.title = obj[KeyOfKbName];
        self.kbSeo = obj[KeyOfKbSeo];
        self.kbNote = obj[KeyOfKbNote];
        self.kbType = obj[KeyOfKbType];
        self.ownerName = obj[KeyOfKbOwnerName];
        self.roleNote = obj[KeyOfKbRoleNote];
        self.serverUrl = obj[@"server_url"];
        self.userGroup = [obj[KeyOfKbUserGroup] intValue];
        self.bizName = obj[KeyOfKbBizName];
        self.bizGuid = obj[KeyOfKbBizGuid];
        NSString* apiUrl = obj[KeyOfKbKApiUrl];
        self.kApiurl = apiUrl;
        self.mywizEmail = obj[KeyOfKbMyWizEmail];
    }
}
- (BOOL) isBiz
{
    if (_bizName && ![_bizName isEqualToString:WizStrPersonalNotes] && ![_bizName isEqualToString:NSLocalizedString(@"Personal Group", nil)]) {
        return YES;
    }
    else
    {
        return NO;
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
    [model setObjectNotNil:self.bizGuid forKey:KeyOfKbBizGuid];
    [model setObjectNotNil:self.mywizEmail forKey:KeyOfKbMyWizEmail];
    return model;
}

-(BOOL)isPrivateKB {
    if (self.guid == nil)
        return YES;
    if ([self.guid isEqualToString:@""])
        return YES;
    return NO;
}

@end

@implementation WizQueryDocument
@synthesize dataMd5;
@synthesize dtDataModified;
@synthesize dtInfoModified;
@synthesize dtParamModified;
@synthesize infoMd5;
@synthesize paramMd5;

- (NSDate*) getDate:(NSString*)key dic:(NSDictionary*)dic
{
    id value = dic[key];
    if ([value isKindOfClass:[NSDate class]]) {
        return value;
    }
    else if ([value isKindOfClass:[NSString class]])
    {
        NSString* str = value;
        if ([str isEqualToString:@""]) {
            return [NSDate dateWithTimeIntervalSince1970:0];
        }
        return [str dateFromSqlTimeString];
    }
    else
    {
        return [NSDate dateWithTimeIntervalSince1970:0];
    }
}
- (void) fromWizServerObject:(id)obj
{
    if ([obj isKindOfClass:[NSDictionary class]]) {
        self.dataMd5 = obj[@"data_md5"];
        self.infoMd5 = obj[@"info_md5"];
        self.paramMd5 = obj[@"param_md5"];
        self.dtParamModified = [self getDate:@"dt_param_modified" dic:obj];
        self.dtInfoModified = [self getDate:@"dt_info_modified" dic:obj];
        self.dtDataModified = [self getDate:@"dt_data_modified" dic:obj];
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
@synthesize userGuid;
- (NSString*) type
{
    NSDictionary* attribute = [[WizSettings defaultSettings] accountAttributes:self.accountUserId];
    return [attribute userType];
}
- (NSString*) userTypeAlertText
{
    NSDictionary* attribute = [[WizSettings defaultSettings] accountAttributes:self.accountUserId];
    if ([self.type hasPrefix:@"vip"]) {
        NSDate* expireDate = [attribute expireVipDate];
        if (expireDate) {
           return [NSString stringWithFormat:NSLocalizedString( @"Your vip will expire in %@",nil),[ [attribute expireVipDate] stringLocal] ];
        }
        else
        {
            return NSLocalizedString(@"Your are VIP", nil);
        }
        
    }
    else
    {
        return NSLocalizedString(@"Your are free user", nil);
    }
}

- (WizProType) userProLevel
{
    if ([self.type hasPrefix:@"vip"]) {
        return WizProTypeLevel1;
    }
    else
    {
        return WizProTypeNone;
    }
}

- (NSString*)displayName
{
    NSDictionary* attribute = [[WizSettings defaultSettings] accountAttributes:self.accountUserId];
    return [[attribute objectForKey:@"user"] objectForKey:@"displayname"];
}

@end

@implementation WizAbstract

@synthesize guid;
@synthesize image;
@synthesize text;

@end


@implementation WizServerObject

@synthesize data = _data;

- (void) fromWizServerObject:(id)obj
{
    if (obj != nil) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary* dic = (NSDictionary*)obj;
            _data = [dic objectForKey:@"value_of_key"];
        }
        else
        {
            _data = obj;
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

@synthesize dateSearched = _dateSearched;
@synthesize count = _count;
@synthesize kbguid = _kbguid;
@synthesize keyWords = _keyWords;
@synthesize type = _type;
@synthesize accountUserId = _accountUserId;
@synthesize tagGuids = _tagGuids;
@synthesize folder = _folder;
- (id) initWithKeyWords:(NSString*)keyWords
                  count:(NSInteger)count
                 kbguid:(NSString*)kbguid
          accountUserId:(NSString*)accountUserId
                   type:(enum WizSearchType)type
               tagguids:(NSString*)tagguids
                 folder:(NSString*)folder
{
    self = [super init];
    if (self) {
        _keyWords = keyWords;
        _count = count;
        _kbguid = kbguid;
        _accountUserId = accountUserId;
        _type = type;
        _folder = folder;
        _tagGuids = tagguids;
        _dateSearched = [NSDate date];
    }
    return self;
}
@end


@implementation WizDocumentCount
@synthesize docCountBySelf;
@synthesize docCountWithSub;
@end



static NSString* const  WizMessagedocumentGuid = @"document_guid";
static NSString* const  WizMessagedtCreated = @"dt_created";
static NSString* const  WizMessagebizGuid = @"biz_guid";
static NSString* const  WizMessageemailSendStatus = @"email_status";
static NSString* const  WizMessagekbGuid = @"kb_guid";
static NSString* const  WizMessagemessageId = @"id";
static NSString* const  WizMessagemessageNote = @"note";
static NSString* const  WizMessagemessageType = @"message_type";
static NSString* const  WizMessagereadStatus = @"read_status";
static NSString* const  WizMessagereceiverAlias = @"receiver_alias";
static NSString* const  WizMessagereceiverGuid = @"receiver_guid";
static NSString* const  WizMessagereceiverId = @"receiver_id";
static NSString* const  WizMessagesenderAlias = @"sender_alias";
static NSString* const  WizMessagesenderGuid = @"sender_guid";
static NSString* const  WizMessagesenderId = @"sender_id";
static NSString* const  WizMessagesmsSendStatus = @"sms_status";
static NSString* const  WizMessageversion = @"version";
static NSString* const  WizMessageTitle = @"title";
static NSString* const  WizMessageBody = @"body";
@implementation WizMessage

@synthesize documentGuid = _documentGuid;
@synthesize dtCreated = _dtCreated;
@synthesize bizGuid = _bizGuid;
@synthesize emailSendStatus = _emailSendStatus;
@synthesize kbGuid = _kbGuid;
@synthesize messageId = _messageId;
@synthesize messageNote = _messageNote;
@synthesize messageType = _messageType;
@synthesize readStatus = _readStatus;
@synthesize receiverAlias = _receiverAlias;
@synthesize receiverGuid = _receiverGuid;
@synthesize receiverId = _receiverId;
@synthesize senderAlias = _senderAlias;
@synthesize senderGuid = _senderGuid;
@synthesize senderId = _senderId;
@synthesize smsSendStatus = _smsSendStatus;
@synthesize version = _version;
@synthesize title = _title;
@synthesize body = _body;
@synthesize taskEndDate = _taskEndDate;
@synthesize localChanged = _localChanged;

- (NSString*) title
{
    if (_title) {
        return _title;
    }
    else
    {
       return [NSString stringWithFormat:@"id is %lld %@",_messageId,_messageType == WizMessageTypeNormalAt ? @"@":@"modified document"]; 
    }
    
}
- (void) setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:WizMessagebizGuid]) {
        _bizGuid = value;
    }
    else if ([key isEqualToString:WizMessagedocumentGuid])
    {
        _documentGuid = value;
        
    }
    else if ([key isEqualToString:WizMessagedtCreated])
    {
        _dtCreated = value;
    }
    else if ([key isEqualToString:WizMessagekbGuid])
    {
        _kbGuid = value;
    }
    else if ([key isEqualToString:WizMessagemessageId])
    {
        _messageId = [value longLongValue];
    }
    else if ([key isEqualToString:WizMessagemessageNote])
    {
        _messageNote = value;
    }
    else if ([key isEqualToString:WizMessagemessageType])
    {
        _messageType = [value longLongValue];
    }
    else if ([key isEqualToString:WizMessagereadStatus])
    {
        _readStatus = [value longLongValue];
    }
    else if ([key isEqualToString:WizMessagereceiverAlias])
    {
        _receiverAlias = value;
    }
    else if ([key isEqualToString:WizMessagereceiverGuid])
    {
        _receiverGuid = value;
    }
    else if ([key isEqualToString:WizMessagereceiverId])
    {
        _receiverId = value;
    }

    else if ([key isEqualToString:WizMessagesenderAlias])
    {
        _senderAlias = value;
    }
    else if ([key isEqualToString:WizMessagesenderGuid])
    {
        _senderGuid= value;
    }
    else if ([key isEqualToString:WizMessagesenderId])
    {
        _senderId = value;
    }
    else if ([key isEqualToString:WizMessagesmsSendStatus])
    {
        _smsSendStatus = [value longLongValue];
    }
    else if ([key isEqualToString:WizMessageversion])
    {
        _version = [value longLongValue];
    }

    else if ([key isEqualToString:WizMessageemailSendStatus])
    {
        _emailSendStatus = [value longLongValue];
    }
    else if ([key isEqualToString:WizMessageTitle])
    {
        _title = value;
    }
    else if ([key isEqualToString:WizMessageBody])
    {
        _body = value;
    }
}

- (BOOL) saveChanges
{
    id<WizTemporaryDataBaseDelegate> db = [WizDBManager temporaryDataBase];
    return [db updateMessage:self];
}

@end

@implementation WizServerMessageArray
- (void) fromWizServerObject:(id)obj
{
    if ([obj isKindOfClass:[NSArray class]]) {
        NSArray* array = (NSArray*)obj;
        for (id each in array) {
            if ([each isKindOfClass:[NSDictionary class]]) {
                WizMessage* message = [[WizMessage alloc] init];
                [message setValuesForKeysWithDictionary:(NSDictionary*)each];
                [self addObject:message];
            }
        }
    }
}

- (int64_t) version
{
    int64_t version = -1;
    for (WizMessage* each in self.array) {
        version = version > each.version ? version : each.version;
    }
    return version;
}
@end


@implementation WizBizUser

@synthesize alias = _alias;
@synthesize aliasPinyin = _aliasPinyin;
@synthesize guid = _guid;
@synthesize userId = _userId;
@synthesize bizGuid = _bizGuid;

- (void) setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"alias"]) {
        _alias = value;
    }
    else if ([key isEqualToString:@"pinyin"]) {
        _aliasPinyin = value;
    }
    else if ([key isEqualToString:@"user_guid"])
    {
        _guid = value;
    }
    else if ([key isEqualToString:@"user_id"])
    {
        _userId = value;
    }
}

@end

@implementation WizUserTask

@synthesize dtCreated = _dtCreated;
@synthesize dtDeadline = _dtDeadline;
@synthesize documentGuid = _documentGuid;
@synthesize body = _body;
@synthesize title = _title;
@synthesize bizGuid = _bizGuid;
@synthesize kbguid = _kbguid;
@synthesize accountUserId = _accountUserId;
@synthesize guid = _guid;

- (void) setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:WizUserTaskModelColumnAccountUserId]) {
        _accountUserId = value;
    }
    else if ([key isEqualToString:WizUserTaskModelColumnBizGuid])
    {
        _bizGuid = value;
    }
    else if ([key isEqualToString:WizUserTaskModelColumnDtCreated])
    {
        if (value && [value isKindOfClass:[NSString class]]) {
            _dtCreated = [(NSString*)value dateFromSqlTimeString];
        }
    }
    else if ([key isEqualToString:WizUserTaskModelColumnDtDeadline])
    {
        if (value && [value isKindOfClass:[NSString class]]) {
            _dtDeadline = [(NSString*)value dateFromSqlTimeString];
        }
    }
    else if ([key isEqualToString:WizUserTaskModelColumnDocumentGuid])
    {
        _documentGuid = value;
    }
    else if ([key isEqualToString:WizUserTaskModelColumnBody])
    {
        _body = value;
    }
    else if ([key isEqualToString:WizUserTaskModelColumnTitle])
    {
        _title = value;
    }
    else if ([key isEqualToString:WizUserTaskModelColumnGUID])
    {
        _guid = value;
    }
    else if ([key isEqualToString:WizUserTaskModelColumnKbGuid])
    {
        _kbguid = value;
    }
}

@end

@implementation  WizKBIdentifyObject

@synthesize accountUserId;
@synthesize kbguid;

@end

@implementation WizShotCut

@synthesize document;
@synthesize group;

@end

@interface WizShotCutCache ()
{
    NSMutableDictionary* _shotcutDictionary;
}
@end

@implementation WizShotCutCache


- (id) init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    _shotcutDictionary = [NSMutableDictionary new];
    id<WizTemporaryDataBaseDelegate> db = [WizDBManager temporaryDataBase];
    NSArray* shotcuts = [db allShotCuts];
    for (int i = 0 ; i < shotcuts.count; ++i) {
        WizShotCutInner* inner = shotcuts[i];
        WizShotCut* shotCut = [[WizShotCut alloc] init];
        shotCut.group = [[WizAccountManager defaultManager] groupFroKbguid:inner.groupGuid accountUserId:inner.accountUserId];
        id<WizInfoDatabaseDelegate> db = [WizDBManager getMetaDataBaseForKbguid:inner.groupGuid accountUserId:inner.accountUserId];
        shotCut.document = [db documentFromGUID:inner.documentGuid];
        shotCut.lastModifiedDate = inner.dateModified;
        [[self allShotCutOfAccountUserId:inner.accountUserId] addObject:shotCut];
    }

    return self;
}
- (WizShotCut*) shotCutByAccountUserId:(NSString*)accountUserId Kbguid:(NSString*)kbguid documentGuid:(NSString*)docGuid
{
    NSMutableArray* array = [self allShotCutOfAccountUserId:accountUserId];
    for (WizShotCut*  each   in array) {
        if (((!each.group.guid && !kbguid) || [each.group.guid isEqualToString:kbguid]) && [docGuid isEqualToString:each.document.guid]) {
            return each;
        }
    }
    return Nil;
}
+ (id) shareInstance
{
    static WizShotCutCache* cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [WizShotCutCache new];
    });
    return cache;
}

- (BOOL) deleteShotCut:(WizShotCut*)shotcut
{
    [[self allShotCutOfAccountUserId:shotcut.group.accountUserId] removeObject:shotcut];
    
    NSMutableDictionary* userInfo = [NSMutableDictionary new];
    [userInfo addAccountUserId:shotcut.group.accountUserId];
    [userInfo addShotcut:shotcut];
    [userInfo addShotcutModifiedType:WizModifiedShotcutTypeRemove];
    [[NSNotificationCenter defaultCenter] postNotificationName:kWizModifiedShotcutMessage object:nil userInfo:userInfo];
    
    id<WizTemporaryDataBaseDelegate> db = [WizDBManager temporaryDataBase];
    return [db deleteWizShotcut:shotcut.group.accountUserId groupguid:shotcut.group.guid documentGuid:shotcut.document.guid];
    
    
}

- (BOOL) isShotCutWithDocumentExist:(NSString*)shotcut accountUserId:(NSString*)accountUserId
{
    NSMutableArray* array = [self allShotCutOfAccountUserId:accountUserId];
    for (WizShotCut*  each   in array) {
        if ([shotcut isEqualToString:each.document.guid]) {
            return YES;
        }
    }
    return NO;
}
- (NSInteger) indexOfShotcut:(WizShotCut*)shotcut accountUserId:(NSString*)accountUserId
{
    NSMutableArray* array = [self allShotCutOfAccountUserId:accountUserId];
    
    for (int i = 0 ; i < array.count; ++i) {
        WizShotCut* each = array[i];
        if ([shotcut.document.guid isEqualToString:each.document.guid]) {
            return i;
        }
    }
    return NSNotFound;
}
- (BOOL) addShotCut:(WizShotCut*)shotCut
{
    if (!shotCut) {
        return NO;
    }
    if (![self isShotCutWithDocumentExist:shotCut.document.guid accountUserId:shotCut.group.accountUserId]) {
        [[self allShotCutOfAccountUserId:shotCut.group.accountUserId] addObject:shotCut];
    }
    else
    {
        NSInteger index = [self indexOfShotcut:shotCut accountUserId:shotCut.group.accountUserId];
        if (index!= NSNotFound) {
            [[self allShotCutOfAccountUserId:shotCut.group.accountUserId] replaceObjectAtIndex:index withObject:shotCut];
        }
    }
    shotCut.lastModifiedDate = [NSDate date];
    WizShotCutInner* inner = [[WizShotCutInner alloc] init];
    inner.documentGuid = shotCut.document.guid;
    inner.accountUserId = shotCut.group.accountUserId;
    inner.groupGuid = shotCut.group.guid;
    inner.localChanged = YES;
    id<WizTemporaryDataBaseDelegate> db = [WizDBManager temporaryDataBase];
    
    NSMutableDictionary* userInfo = [NSMutableDictionary new];
    [userInfo addAccountUserId:shotCut.group.accountUserId];
    [userInfo addShotcut:shotCut];
    [userInfo addShotcutModifiedType:WizModifiedShotcutTypeAdd];
    [[NSNotificationCenter defaultCenter] postNotificationName:kWizModifiedShotcutMessage object:nil userInfo:userInfo];
    return [db updateWizShotcut:inner];
}

- (NSMutableArray*) allShotCutOfAccountUserId:(NSString*)accountUserId
{
    NSMutableArray* array = [_shotcutDictionary objectForKey:accountUserId];
    if (!array) {
        array = [NSMutableArray new];
        [_shotcutDictionary setObject:array forKey:accountUserId];
    }
    //
    return array;
}

@end

@implementation WizShotCutInner
@synthesize documentGuid = _documentGuid;
@synthesize groupGuid = _groupGuid;
@synthesize accountUserId = _accountUserId;
@synthesize localChanged = _localChanged;
@synthesize dateModified = _dateModified;
- (void) setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:kWizShotcutDocumentGuid]) {
        _documentGuid = value;
    }
    else if ([key isEqualToString:kWizShotcutGroupGuid])
    {
        if ([value isEqualToString:WizGlobalPersonalKbguid]) {
            _groupGuid = nil;
        }
        else
        {
            _groupGuid = value;
        }
        
    }
    else if ([key isEqualToString:kWizShotcutAccountUserId])
    {
        _accountUserId =  value;
    }
    else if ([key isEqualToString:kWizShotcutLocalChanged])
    {
        _localChanged = [value boolValue];
    }
    else if ([key isEqualToString:kWizShotcutDateModified])
    {
        _dateModified = [value dateFromSqlTimeString];
    }
}
@end