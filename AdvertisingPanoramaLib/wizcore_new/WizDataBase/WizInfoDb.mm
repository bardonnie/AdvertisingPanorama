//
//  WizInfoDb.m
//  WizIos
//
//  Created by dzpqzb on 12-12-20.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import "WizInfoDb.h"
#import "WizWorkQueue.h"
#import "WizObject.h"
#import "NSString+WizString.h"
#import "NSDate-Utilities.h"
#import "NSDate+WizTools.h"
#import <map>
#import "WizNotificationCenter.h"
//database version
static int const WizInfoDataBaseVersion = 10;
//
static NSString* const KeyOfSyncVersion         =               @"SYNC_VERSION";
static NSString* const  KeyOfSyncVersionDocument        =@"DOCUMENT";
static NSString* const  KeyOfSyncVersionDeletedGuid=     @"DELETED_GUID";
static NSString* const  KeyOfSyncVersionAttachment=      @"ATTACHMENT";
static NSString* const  KeyOfSyncVersionTag=             @"TAG";
//
//
@implementation WizInfoDb
@synthesize kbguid = _kbguid;
@synthesize accountUserId = _accountUserId;

- (id) initWithPath:(NSString *)dbPath modelName:(NSString *)modelName accountUserId:(NSString *)userId kbguid:(NSString *)kbguid
{
    self = [super initWithPath:dbPath modelName:modelName];
    if (self) {
        _kbguid = kbguid;
        _accountUserId = userId;
    }
    return self;
}

- (NSDate*) maxDocumentEditingDate
{
    NSString* sql = @"select max(DT_CREATED) from WIZ_DOCUMENT";
    FMResultSet* result = [dataBase executeQuery:sql];
    NSDate* date = [NSDate date];
    if ([result next]) {
        NSString* sql = [result stringForColumnIndex:0];
        date = [sql dateFromSqlTimeString];
    }
    [result close];
    if (!date) {
        date = [NSDate date];
    }
    return date;
    
}
- (NSDate*) minDocumentEditingDate
{
    NSString* sql = @"select min(DT_CREATED) from WIZ_DOCUMENT";
    FMResultSet* result = [dataBase executeQuery:sql];
    NSDate* date = [NSDate date];
    if ([result next]) {
        NSString* sql = [result stringForColumnIndex:0];
        date = [sql dateFromSqlTimeString];
    }
    [result close];
    if (!date) {
        date = [NSDate dateWithDaysBeforeNow:30*12];
    }
    return date;
}

- (WizDocument*) randomDocument
{    
    WizDocument* document = nil;
    int i = 0;
    while (!document && i < 4) {
        document = [[self recentDocuments] lastObject];
        ++i;
    }
    return document;
}

- (void) sendMessageDeleteDocument:(NSString*)docGuid
{
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
    [userInfo setObject:[NSNumber numberWithInt:WizModifiedDocumentTypeDeleted] forKey:@"type"];
    [userInfo setObject:docGuid forKey:@"guid"];

    if (!self.kbguid) {
        [userInfo setObject:WizGlobalPersonalKbguid forKey:WizNotificationUserInfoKbguid];
    }
    else
    {
        [userInfo setObject:self.kbguid forKey:WizNotificationUserInfoKbguid];
    }
    [userInfo setObject:self.accountUserId forKey:WizNotificationUserInfoAccountUserId];
    [[NSNotificationCenter defaultCenter] postNotificationName:WizModifiedDocumentMessage object:nil userInfo:userInfo];
}

- (void) sendMessageEditDocumentType:(int)type  document:(WizDocument*)document
{
    if (document) {
        WizDocument* doc = [[WizDocument alloc] init];
        [doc setValuesForKeysWithDictionary:[document toWizServerObject]];
        [doc setLocalChanged:document.localChanged];
        document = doc;
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
        [userInfo setObject:[NSNumber numberWithInt:type] forKey:@"type"];
        [userInfo setObject:document.guid forKey:@"guid"];
        [userInfo setObject:document forKey:@"document"];
        if (!self.kbguid) {
            [userInfo setObject:WizGlobalPersonalKbguid forKey:WizNotificationUserInfoKbguid];
        }
        else
        {
            [userInfo setObject:self.kbguid forKey:WizNotificationUserInfoKbguid];
        }
        [userInfo setObject:self.accountUserId forKey:WizNotificationUserInfoAccountUserId];
        [[NSNotificationCenter defaultCenter] postNotificationName:WizModifiedDocumentMessage object:nil userInfo:userInfo];
    }
    
}

- (int) currentVersion
{
    return WizInfoDataBaseVersion;
}

- (NSString*) getMeta:(NSString*)lpszName  withKey:(NSString*) lpszKey
{
    NSString* sql = [NSString stringWithFormat:@"select META_VALUE from WIZ_META where META_NAME='%@' and META_KEY='%@'",lpszName,lpszKey];
    NSString* value = nil;
    FMResultSet* s = [dataBase executeQuery:sql];
    if ([s next]) {
        value = [s stringForColumnIndex:0];
    }
    else
    {
        value = nil;
    }
    [s close];
    return value;
}
- (BOOL) isMetaExist:(NSString*)lpszName  withKey:(NSString*) lpszKey
{
    if ([self getMeta:lpszName withKey:lpszKey])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL) setMeta:(NSString*)lpszName  key:(NSString*)lpszKey value:(NSString*)value
{
    BOOL ret;
    if (![self isMetaExist:lpszName withKey:lpszKey])
    {
        ret = [dataBase executeUpdate:@"insert into WIZ_META (META_NAME, META_KEY, META_VALUE) values(?,?,?)",lpszName, lpszKey, value];
    }
    else
    {
        ret= [dataBase executeUpdate:@"update WIZ_META set META_VALUE= ? where META_NAME=? and META_KEY=?",value, lpszName, lpszKey];
    }
    return ret;
}
- (BOOL) setSyncVersion:(NSString*)type  version:(int64_t)ver
{
    NSString* verString = [NSString stringWithFormat:@"%lld", ver];
	return [self setMeta:KeyOfSyncVersion key:type value:verString];
}
- (int64_t) syncVersion:(NSString*)type
{
    NSString* verString = [self getMeta:KeyOfSyncVersion withKey:type];
    if (verString) {
        return [verString longLongValue];
    }
    return 0;
}
- (BOOL) setInsertedExperienceData:(BOOL)inserted
{
    return [self setMeta:@"info" key:@"experience" value:[NSString stringWithFormat:@"%d",inserted]];
}

- (BOOL) isInsertedExperienceData
{
   return [[self getMeta:@"info" withKey:@"experience"] boolValue];
}
- (int64_t) documentVersion
{
    return [self syncVersion:KeyOfSyncVersionDocument];
}

- (BOOL) setDocumentVersion:(int64_t)ver
{
    return [self setSyncVersion:KeyOfSyncVersionDocument version:ver];
}
- (BOOL) setAttachmentVersion:(int64_t)ver
{
    return [self setSyncVersion:KeyOfSyncVersionAttachment version:ver];
}
- (int64_t) attachmentVersion
{
    return [self syncVersion:KeyOfSyncVersionAttachment];
}
- (BOOL) setTagVersion:(int64_t)ver
{
    return [self setSyncVersion:KeyOfSyncVersionTag version:ver];
}
- (int64_t) tagVersion
{
    return [self syncVersion:KeyOfSyncVersionTag];
}
- (BOOL) setDeletedGUIDVersion:(int64_t)ver
{
    return [self setSyncVersion:KeyOfSyncVersionDeletedGuid version:ver];
}
- (int64_t) deletedGUIDVersion
{
    return [self syncVersion:KeyOfSyncVersionDeletedGuid];
}
- (int64_t) documentCount
{
    NSString* sql = @"select count(*) from Wiz_Document";
    FMResultSet* result = [dataBase executeQuery:sql];
    int64_t count = 0;
    if ([result next]) {
        count = [result intForColumnIndex:0];
    }
    [result close];
    return count;
}

- (NSMutableArray*) documentsArrayWithWhereFiled:(NSString*)where arguments:(NSArray*)args
{
    if (nil == where) {
        where = @"";
    }
    NSString* sql = [NSString stringWithFormat:@"select DOCUMENT_GUID, DOCUMENT_TITLE, DOCUMENT_LOCATION, DOCUMENT_URL, DOCUMENT_TAG_GUIDS, DOCUMENT_TYPE, DOCUMENT_FILE_TYPE, DT_CREATED, DT_MODIFIED, DOCUMENT_DATA_MD5, ATTACHMENT_COUNT, SERVER_CHANGED, LOCAL_CHANGED,GPS_LATITUDE ,GPS_LONGTITUDE ,GPS_ALTITUDE ,GPS_DOP ,GPS_ADDRESS ,GPS_COUNTRY ,GPS_LEVEL1 ,GPS_LEVEL2 ,GPS_LEVEL3 ,GPS_DESCRIPTION ,READCOUNT ,PROTECT, OWNER, KEYWORDS from WIZ_DOCUMENT %@",where];
    NSMutableArray* array = [NSMutableArray array];
    FMResultSet* result = [dataBase executeQuery:sql withArgumentsInArray:args];
    while ([result next]) {
        WizDocument* doc = [[WizDocument alloc] init];
        doc.guid = [result stringForColumnIndex:0];
        doc.title = [result stringForColumnIndex:1];
        doc.location = [result stringForColumnIndex:2];
        doc.url = [result stringForColumnIndex:3];
        doc.tagGuids = [result stringForColumnIndex:4];
        doc.type = [result stringForColumnIndex:5];
        doc.fileType = [result stringForColumnIndex:6];
        doc.dateCreated = [[result stringForColumnIndex:7] dateFromSqlTimeString] ;
        doc.dateModified = [[result stringForColumnIndex:8] dateFromSqlTimeString];
        doc.dataMd5 = [result stringForColumnIndex:9];
        doc.attachmentCount = [result intForColumnIndex:10];
        doc.serverChanged = [result intForColumnIndex:11];
        int changed = [result intForColumnIndex:12];
        doc.localChanged = (WizEditDocumentType)changed;
        doc.gpsLatitude = [result doubleForColumnIndex:13];
        doc.gpsLongtitude = [result doubleForColumnIndex:14];
        doc.gpsAltitude = [result doubleForColumnIndex:15];
        doc.gpsDop = [result doubleForColumnIndex:16];
        doc.gpsAddress = [result stringForColumnIndex:17];
        doc.gpsCountry = [result stringForColumnIndex:18];
        doc.gpsLevel1 = [result stringForColumnIndex:19];
        doc.gpsLevel2 = [result stringForColumnIndex:20];
        doc.gpsLevel3 = [result stringForColumnIndex:21];
        doc.gpsDescription = [result stringForColumnIndex:22];
        doc.nReadCount = [result intForColumnIndex:23];
        doc.bProtected = [result intForColumnIndex:24];
        doc.ownerName = [result stringForColumnIndex:25];
        doc.keyWords = [result stringForColumnIndex:26];
        [array addObject:doc];
    }
    [result close];
    return array;
}
- (WizDocument*) documentFromGUID:(NSString *)documentGUID
{
    if (nil == documentGUID) {
        return nil;
    }
    NSArray* array = [self documentsArrayWithWhereFiled:@"where DOCUMENT_GUID = ?" arguments:[NSArray arrayWithObject:documentGUID]];
    return [array lastObject];
}

- (NSArray*) recentDocuments
{
    return [self documentsArrayWithWhereFiled:@"where DOCUMENT_LOCATION not like '/Deleted Items/%'  order by max(DT_CREATED, DT_MODIFIED) desc limit 0, 400" arguments:nil];
}

- (NSArray*) documentForUpload
{
    return [self documentsArrayWithWhereFiled:@"where LOCAL_CHANGED !=0" arguments:nil];
}


- (NSArray*) documentForDownload:(NSInteger)duration
{
    NSDate* date = [NSDate dateWithDaysBeforeNow:duration];
    return [self documentsArrayWithWhereFiled:@"where SERVER_CHANGED!=0 and DT_MODIFIED>? and DOCUMENT_LOCATION not like '/Deleted Items/%' order by max(DT_CREATED, DT_MODIFIED) desc" arguments:@[[date stringSql]]];
}

- (WizDocument*) documentForDownloadNext
{
    NSArray* array = [self documentsArrayWithWhereFiled:@"where SERVER_CHANGED != 0 and DOCUMENT_LOCATION not like '/Deleted Items/%' order by max(DT_CREATED, DT_MODIFIED) desc limit 0, 1" arguments:nil];
    if (array) {
        return [array lastObject];
    }
    return 0;
}

- (WizDocument*) nextDocumentForDownloadByDuraion:(NSInteger)duration
{
    NSDate* date = [NSDate dateWithDaysBeforeNow:duration];
    NSArray* array = [self documentsArrayWithWhereFiled:@"where SERVER_CHANGED != 0 and DT_MODIFIED>?  and DOCUMENT_LOCATION not like '/Deleted Items/%' order by max(DT_CREATED, DT_MODIFIED) desc limit 0, 1" arguments:@[[date stringSql]]];
    if (array) {
        return [array lastObject];
    }
    return 0;
}

- (NSArray*) documentsForDownloadByDuration:(NSInteger)duration exceptGuids:(NSString*)docGuids
{
    NSDate* date = [NSDate dateWithDaysBeforeNow:duration];
    return [self documentsArrayWithWhereFiled:@"where SERVER_CHANGED != 0 and DT_MODIFIED>?  and DOCUMENT_LOCATION not like '/Deleted Items/%' and DOCUMENT_GUID not in (?) order by max(DT_CREATED, DT_MODIFIED) desc limit 0, 10" arguments:@[[date stringSql],docGuids]];
}



- (NSArray*) documentsByKey:(NSString *)keywords fromLocation:(NSString*)location
{
    NSString* sqlWhere = [NSString stringWithFormat:@"%@%@%@",@"%",keywords,@"%"];
    NSString* sqlString = [NSString stringWithFormat:@"where DOCUMENT_TITLE like ? and DOCUMENT_LOCATION = '%@' order by max(DT_CREATED, DT_MODIFIED) desc limit 0, 100",location];
    return [self documentsArrayWithWhereFiled:sqlString arguments:[NSArray arrayWithObject:sqlWhere]];
}

- (NSArray*) documentsByKey:(NSString *)keywords fromTag:(NSString*)tagGuid
{
    NSString* sqlWhere = [NSString stringWithFormat:@"%@%@%@",@"%",keywords,@"%"];
    NSString* sqlRange = [NSString stringWithFormat:@"%@%@%@",@"%",tagGuid,@"%"];
    return [self documentsArrayWithWhereFiled:@"where DOCUMENT_TITLE like ? and DOCUMENT_TAG_GUIDS like ? order by max(DT_CREATED, DT_MODIFIED) desc limit 0, 100" arguments:[NSArray arrayWithObjects:sqlWhere,sqlRange, nil]];
}

- (NSMutableArray*) documentsByKey: (NSString*)keywords
{
    NSString* sqlWhere = [NSString stringWithFormat:@"%@%@%@",@"%",keywords,@"%"];
    return [self documentsArrayWithWhereFiled:@"where DOCUMENT_TITLE like ? and DOCUMENT_LOCATION not like '/Deleted Items/%' order by max(DT_CREATED, DT_MODIFIED) desc limit 0, 100" arguments:[NSArray arrayWithObject:sqlWhere]];
}

- (NSArray*) documentsByLocation:(NSString *)parentLocation
{
    return [self documentsArrayWithWhereFiled:@"where DOCUMENT_LOCATION=? order by max(DT_CREATED, DT_MODIFIED) desc" arguments:[NSArray arrayWithObject:parentLocation]];
}

- (NSArray *)documentsAndSubFolderDocumentsByLocation:(NSString *)parentLocation {
    return [self documentsArrayWithWhereFiled:@"where DOCUMENT_LOCATION like ? order by max(DT_CREATED, DT_MODIFIED) desc" arguments:[NSArray arrayWithObject:[NSString stringWithFormat:@"%@%%",parentLocation]]];
}

- (NSArray*) documentsByTag:(NSString *)tagGUID
{
    NSString* sqlWhere = [NSString stringWithFormat:@"%@%@%@",@"%",tagGUID,@"%"];
    return [self documentsArrayWithWhereFiled:@"where DOCUMENT_TAG_GUIDS like ? and DOCUMENT_LOCATION not like '/Deleted Items/%' order by max(DT_CREATED, DT_MODIFIED) desc" arguments:[NSArray arrayWithObject:sqlWhere]];
}

- (NSArray *)documentsAndSubTagDocumentsByTag:(NSString *)tagGUID {
    NSMutableArray *array= [NSMutableArray arrayWithArray:[self documentsByTag:tagGUID]];
    NSArray *tags= [self tagsArrayWithWhereField:@"where TAG_PARENT_GUID=?" args:[NSArray arrayWithObject:tagGUID]];
    for (WizTag *tag in tags){
        @autoreleasepool {
            NSArray *tempArray= [self documentsAndSubTagDocumentsByTag:tag.guid];
            for(int i=0;i<tempArray.count;i++){
                BOOL isExist= NO;
                for (int j=0;j<array.count;j++){
                    if ([((WizDocument *) [array objectAtIndex:j]).guid isEqualToString:((WizDocument *) [tempArray objectAtIndex:i]).guid]){
                        isExist= YES;
                        break;
                    }
                }
                if (!isExist){
                    [array addObject:[tempArray objectAtIndex:i]];
                }
            }
            //array=[array arrayByAddingObjectsFromArray:[self documentsAndSubTagDocumentsByTag:tag.guid]];
        }
    }
    return array;
}

- (NSArray *)subTags:(NSString *)preTagGuid {
    NSMutableArray *array= [NSMutableArray array];
    NSArray *tags= [self tagsArrayWithWhereField:@"where TAG_PARENT_GUID=?" args:[NSArray arrayWithObject:preTagGuid]];
    [array addObjectsFromArray:tags];

    for (WizTag *tag in tags){
        @autoreleasepool {
            NSArray *tempArray= [self subTags:tag.guid];
            for(int i=0;i<tempArray.count;i++){
                WizTag *tTag=[tempArray objectAtIndex:i];
                [array addObjectsFromArray:[self subTags:tTag.guid]];
            }
        }
    }
    return array;
}

- (NSArray*) documentsByGroupTag
{
    return [self documentsArrayWithWhereFiled:@"where DOCUMENT_TAG_GUIDS=? and DOCUMENT_LOCATION not like '/Deleted Items/%' order by max(DT_CREATED, DT_MODIFIED) desc" arguments:[NSArray arrayWithObject:@""]];
}
- (NSArray*) documentsForCache:(NSInteger)duration
{
    NSDate* date = [NSDate dateWithDaysBeforeNow:duration];
    return [self documentsArrayWithWhereFiled:@"where DT_MODIFIED >= ? and SERVER_CHANGED=1 order by DT_MODIFIED" arguments:[NSArray arrayWithObjects:[date stringSql], nil]];
}

- (WizDocument*) documentForClearCacheNext
{
    NSArray* array = [self documentsArrayWithWhereFiled:@"where  SERVER_CHANGED=0 and LOCAL_CHANGED=0 order by DT_MODIFIED asc limit 0,1" arguments:nil];
    if (array && [array count]) {
        return [array lastObject];
    }
    return 0;
}
- (BOOL) updateDocument:(WizDocument *)doc
{
    WizDocument* docExist = [self documentFromGUID:doc.guid];
    BOOL ret;
    if (docExist)
    {
        if (docExist.localChanged == WizEditDocumentTypeAllChanged && doc.localChanged == WizEditDocumentTypeInfoChanged) {
            doc.localChanged = WizEditDocumentTypeAllChanged;
        }
        ret =[dataBase executeUpdate:@"update WIZ_DOCUMENT set DOCUMENT_TITLE=?, DOCUMENT_LOCATION=?, DOCUMENT_URL=?, DOCUMENT_TAG_GUIDS=?, DOCUMENT_TYPE=?, DOCUMENT_FILE_TYPE=?, DT_CREATED=?, DT_MODIFIED=?, DOCUMENT_DATA_MD5=?, ATTACHMENT_COUNT=?, SERVER_CHANGED=?, LOCAL_CHANGED=?, GPS_LATITUDE=?, GPS_LONGTITUDE=?, GPS_ALTITUDE=?, GPS_DOP=?, GPS_ADDRESS=?, GPS_COUNTRY=?, GPS_LEVEL1=?, GPS_LEVEL2=?, GPS_LEVEL3=?, GPS_DESCRIPTION=?, READCOUNT=?, PROTECT=? , OWNER=? , KEYWORDS=? where DOCUMENT_GUID= ?",
              doc.title,
              doc.location,
              doc.url,
              doc.tagGuids,
              doc.type,
              doc.fileType,
              [doc.dateCreated stringSql],
              [doc.dateModified stringSql],
              doc.dataMd5,
              [NSNumber numberWithInt:doc.attachmentCount],
              [NSNumber numberWithInt:doc.serverChanged],
              [NSNumber numberWithInt:doc.localChanged],
              [NSNumber numberWithDouble:doc.gpsLatitude],
              [NSNumber numberWithDouble:doc.gpsLongtitude],
              [NSNumber numberWithDouble:doc.gpsAltitude],
              [NSNumber numberWithDouble:doc.gpsDop],
              doc.gpsAddress,
              doc.gpsCountry,
              doc.gpsLevel1,
              doc.gpsLevel2 ,
              doc.gpsLevel3,
              doc.gpsDescription,
              [NSNumber numberWithInt:doc.nReadCount],
              [NSNumber numberWithInt:doc.bProtected],
              doc.ownerName,
              doc.keyWords,
              doc.guid
              ];
        
        if (ret) {
            if (doc.localChanged) {
                [self sendMessageEditDocumentType:WizModifiedDocumentTypeLocalUpdate document:doc];
            }
            else
            {
                [self sendMessageEditDocumentType:WizModifiedDocumentTypeServerUpdate document:doc];
            }
        }
       
    }
    else
    {
            ret= [dataBase executeUpdate:@"insert into WIZ_DOCUMENT (DOCUMENT_GUID, DOCUMENT_TITLE, DOCUMENT_LOCATION, DOCUMENT_URL, DOCUMENT_TAG_GUIDS, DOCUMENT_TYPE, DOCUMENT_FILE_TYPE, DT_CREATED, DT_MODIFIED, DOCUMENT_DATA_MD5, ATTACHMENT_COUNT, SERVER_CHANGED, LOCAL_CHANGED,GPS_LATITUDE ,GPS_LONGTITUDE ,GPS_ALTITUDE ,GPS_DOP ,GPS_ADDRESS ,GPS_COUNTRY ,GPS_LEVEL1 ,GPS_LEVEL2 ,GPS_LEVEL3 ,GPS_DESCRIPTION ,READCOUNT ,PROTECT,OWNER,KEYWORDS) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",doc.guid,
                  doc.title,
                  doc.location,
                  doc.url,
                  doc.tagGuids,
                  doc.type,
                  doc.fileType,
                  [doc.dateCreated stringSql],
                  [doc.dateModified stringSql],
                  doc.dataMd5,
                  [NSNumber numberWithInt:doc.attachmentCount],
                  [NSNumber numberWithInt:doc.serverChanged],
                  [NSNumber numberWithInt:doc.localChanged],
                  [NSNumber numberWithDouble:doc.gpsLatitude],
                  [NSNumber numberWithDouble:doc.gpsLongtitude],
                  [NSNumber numberWithDouble:doc.gpsAltitude],
                  [NSNumber numberWithDouble:doc.gpsDop],
                  doc.gpsAddress,
                  doc.gpsCountry,
                  doc.gpsLevel1,
                  doc.gpsLevel2 ,
                  doc.gpsLevel3,
                  doc.gpsDescription,
                  [NSNumber numberWithInt:doc.nReadCount],
                  [NSNumber numberWithBool:doc.bProtected],
                  doc.ownerName,
                  doc.keyWords];
        if (ret) {
            if (doc.localChanged) {
                [self sendMessageEditDocumentType:WizModifiedDocumentTypeLocalInsert document:doc];
            }
        }
    }
    return ret;
}

- (BOOL) setDocumentLocalChanged:(NSString *)guid changed:(WizEditDocumentType)changed
{
    BOOL ret;
        ret = [dataBase executeUpdate:@"update WIZ_DOCUMENT set LOCAL_CHANGED=? where DOCUMENT_GUID= ?",[NSNumber numberWithInt:changed],guid];
    WizDocument* doc = [self documentFromGUID:guid];
    if (doc) {
        [self sendMessageEditDocumentType:WizModifiedDocumentTypeLocalUpdate document:doc];
    }
    return ret;
}
- (BOOL) setDocumentServerChanged:(NSString *)guid changed:(BOOL)changed
{
    BOOL ret;
    ret=  [dataBase executeUpdate:@"update WIZ_DOCUMENT set SERVER_CHANGED=? where DOCUMENT_GUID= ?",[NSNumber numberWithInt:changed],guid];
    WizDocument* doc = [self documentFromGUID:guid];
    if (doc) {
        [self sendMessageEditDocumentType:WizModifiedDocumentTypeLocalUpdate document:doc];
    }
    
    return ret;
}


- (NSArray*) tagsArrayWithWhereField:(NSString*)where   args:(NSArray*)args
{
    if (nil == where) {
        where = @"";
    }
    NSString* sql = [NSString stringWithFormat:@"select TAG_GUID, TAG_PARENT_GUID, TAG_NAME, TAG_DESCRIPTION,LOCALCHANGED, DT_MODIFIED from WIZ_TAG %@",where];
    NSMutableArray* array = [NSMutableArray array];
        FMResultSet* result = [dataBase executeQuery:sql withArgumentsInArray:args];
        while ([result next]) {
            WizTag* tag = [[WizTag alloc] init];
            tag.guid = [result stringForColumnIndex:0];
            tag.parentGUID = [result stringForColumnIndex:1];
            tag.title = [result stringForColumnIndex:2];
            tag.detail= [result stringForColumnIndex:3];
            tag.localChanged = [result intForColumnIndex:4];
            tag.dateInfoModified = [[result stringForColumnIndex:5] dateFromSqlTimeString];
            [array addObject:tag];
        }
        [result close];
    return array;
}

- (WizTag*) tagFromGuid:(NSString *)guid
{
    if (!guid) {
        guid = @"";
    }
    return [[self tagsArrayWithWhereField:@"where TAG_GUID=?" args:[NSArray arrayWithObject:guid]] lastObject];
}

- (NSArray*) subTagsByParentGuid:(NSString*)parentGuid
{
    if (!parentGuid || [parentGuid isEqualToString:@""]) {
        return [self tagsArrayWithWhereField:@"where TAG_PARENT_GUID='' || TAG_PARENT_GUID is null" args:nil];
    }
      return  [self tagsArrayWithWhereField:@"where TAG_PARENT_GUID=?" args:[NSArray arrayWithObject:parentGuid]];
    
}

- (BOOL) isExistTagWithTitle:(NSString*)title
{
    BOOL isExist = NO;
        FMResultSet* result = [dataBase executeQuery:@"select * from WIZ_TAG where TAG_NAME=?",title];
        if ([result next]) {
            isExist = YES;
        }
    return isExist;
}

- (BOOL) updateTag:(WizTag*)tag
{
    BOOL ret;
    if ([self tagFromGuid:tag.guid]) {
            ret = [dataBase executeUpdate:@"update WIZ_TAG set TAG_NAME=?, TAG_DESCRIPTION=?, TAG_PARENT_GUID=?, LOCALCHANGED=?, DT_MODIFIED=? where TAG_GUID=?",tag.title, tag.detail,tag.parentGUID, [NSNumber numberWithInt:tag.localChanged],[tag.dateInfoModified stringSql], tag.guid];
    }
    else
    {
            ret =  [dataBase executeUpdate:@"insert into WIZ_TAG (TAG_GUID, TAG_PARENT_GUID, TAG_NAME, TAG_DESCRIPTION ,LOCALCHANGED, DT_MODIFIED ) values (?, ?, ?, ?, ?, ?)",tag.guid,tag.parentGUID,tag.title,tag.detail,[NSNumber numberWithInt:tag.localChanged],[tag.dateInfoModified stringSql]];
    }
    return ret;
}


- (NSArray*) allTagsForTree
{
    NSMutableArray* allTags =[NSMutableArray arrayWithArray:[self tagsArrayWithWhereField:@"where TAG_NAME not null" args:nil]];
    return allTags;
}


static NSString* InnerWizTagParentNullKey = @"aaa";

- (NSDictionary *)tagGuidAndParentTagGuidKV {
    static NSString* sql = @"select TAG_GUID, TAG_PARENT_GUID from WIZ_TAG";
    NSMutableDictionary* childParentDict = [NSMutableDictionary new];
    FMResultSet* result = [dataBase executeQuery:sql];
    while ([result next]) {
        NSString* tagGuid = [result stringForColumnIndex:0];
        NSString* tagParentGuid = [result stringForColumnIndex:1];
        if (tagGuid) {
            if (!tagParentGuid || [tagParentGuid isEqualToString:@""]) {
                tagParentGuid = InnerWizTagParentNullKey;
            }
            [childParentDict setObject:tagParentGuid forKey:tagGuid];
        }
    }
    [result close];
    return childParentDict;
}

- (NSString*) tagPath:(WizTag*)tag tagDic:(NSDictionary*)tagDic
{
    if (!tag.parentGUID || [tag.parentGUID isEqualToString:@""]) {
        return [@"/" stringAppendingPath:getTagDisplayName(tag.title)];
    }
    else
    {
        WizTag* parentTag = [tagDic objectForKey:tag.parentGUID];
        NSString* parentPath = [self tagPath:parentTag tagDic:tagDic];
        return [parentPath stringAppendingPath:getTagDisplayName(tag.title)];
    }
}

- (NSDictionary*) tagTreeDictionary
{
    NSArray* tags = [self allTagsForTree];
    NSMutableDictionary* tagDic= [NSMutableDictionary dictionary];
    for (WizTag* eachTag in tags) {
        [tagDic setObject:eachTag forKey:eachTag.guid];
    }
    NSMutableDictionary* tagTree = [NSMutableDictionary dictionary];
    NSArray* allTagGuids = [tagDic allKeys];
    for (NSString* guid in allTagGuids) {
        NSString* tagPath = [self tagPath:[tagDic objectForKey:guid] tagDic:tagDic];
        [tagTree setObject:guid forKey:tagPath];
    }
    return tagTree;
}

- (NSDictionary*) tagPathDictionary
{
    NSDictionary* dic = [self tagTreeDictionary];
//    return [NSDictionary dictionaryWithObjects:[dic allKeys] forKeys:[dic allValues]];
    return dic;
}

- (NSDictionary*) tagPathDictionaryNew
{
    NSArray* tags = [self allTagsForTree];
    NSMutableDictionary* tagDic= [NSMutableDictionary dictionary];
    for (WizTag* eachTag in tags) {
        [tagDic setObject:eachTag forKey:eachTag.guid];
    }
    NSMutableDictionary* tagTree = [NSMutableDictionary dictionary];
    NSArray* allTagGuids = [tagDic allKeys];
    for (NSString* guid in allTagGuids) {
        NSString* tagPath = [self tagPath:[tagDic objectForKey:guid] tagDic:tagDic];
        [tagTree setObject:tagPath forKey:guid];
    }
    return tagTree;
}

- (NSString *)tagAbstractString:(NSString *)guid
{
    WizTag* tag = [self tagFromGuid:guid];
    if (tag) {
        if (!tag.parentGUID || [tag.parentGUID isEqualToString:@""]) {
            return [@"/" stringAppendingPath:getTagDisplayName(tag.title)];
        }else{
            WizTag* parentTag = [self tagFromGuid:tag.parentGUID];
            NSString* parentPath = [self tagAbstractString:parentTag.guid];
            return [parentPath stringAppendingPath:getTagDisplayName(tag.title)];
        }
    }
    return @"";
}


- (NSArray*) tagsForUpload
{
    return [self tagsArrayWithWhereField:@"where LOCALCHANGED != 0" args:nil];
}
- (BOOL) setTagLocalChanged:(NSString *)guid changed:(BOOL)changed
{
    return [dataBase executeUpdate:@"update WIZ_TAG set LOCALCHANGED=? where TAG_GUID =?",guid
               , [NSNumber numberWithBool:changed]];
}


- (NSArray*) attachmentsWithWhereFiled:(NSString*)where args:(NSArray*)args
{
    if (nil == where) {
        where = @"";
    }
    NSMutableArray* attachments = [NSMutableArray array];
    NSString* sql = [NSString stringWithFormat:@"select ATTACHMENT_GUID ,DOCUMENT_GUID, ATTACHMENT_NAME,ATTACHMENT_DATA_MD5,ATTACHMENT_DESCRIPTION,DT_MODIFIED,SERVER_CHANGED,LOCAL_CHANGED from WIZ_DOCUMENT_ATTACHMENT %@",where];
        FMResultSet* result = [dataBase executeQuery:sql withArgumentsInArray:args];
        while ([result next]) {
            WizAttachment* attachment = [[WizAttachment alloc] init];
            attachment.guid = [result stringForColumnIndex:0];
            attachment.documentGuid = [result stringForColumnIndex:1];
            attachment.title = [result stringForColumnIndex:2];
            attachment.dataMd5 = [result stringForColumnIndex:3];
            attachment.detail= [result stringForColumnIndex:4];
            attachment.dateModified = [[result stringForColumnIndex:5] dateFromSqlTimeString];
            attachment.serverChanged = [result intForColumnIndex:6];
            attachment.localChanged = [result intForColumnIndex:7];
            [attachments addObject:attachment];
        }
        [result close];
    return attachments;
}

- (WizAttachment*) attachmentFromGUID:(NSString *)guid
{
    return [[self attachmentsWithWhereFiled:@"where ATTACHMENT_GUID=?" args:[NSArray arrayWithObject:guid]] lastObject];
}

- (NSArray*) attachmentsByDocumentGUID:(NSString *)documentGUID
{
    return [self attachmentsWithWhereFiled:@"where DOCUMENT_GUID=?" args:[NSArray arrayWithObject:documentGUID]];
}

- (NSArray*) attachmentsForUpload
{
    return [self attachmentsWithWhereFiled:@"where LOCAL_CHANGED > 0" args:nil];
}

- (BOOL) setAttachmentLocalChanged:(NSString *)attchmentGUID changed:(WizEditAttachmentType)type
{
    BOOL ret;
    ret = [dataBase executeUpdate:@"update WIZ_DOCUMENT_ATTACHMENT set LOCAL_CHANGED=? where ATTACHMENT_GUID=?",[NSNumber numberWithInt:type], attchmentGUID];
    return ret;
}

- (BOOL) setAttachmentServerChanged:(NSString *)attchmentGUID changed:(BOOL)changed
{
    BOOL ret;
        ret = [dataBase executeUpdate:@"update WIZ_DOCUMENT_ATTACHMENT set SERVER_CHANGED=? where ATTACHMENT_GUID=?",[NSNumber numberWithBool:changed], attchmentGUID];
    return ret;
}


- (BOOL) updateAttachment:(WizAttachment *)attachment
{
    WizAttachment* attachmentExist =[self attachmentFromGUID:attachment.guid];
    BOOL ret;
    if (attachment.dateModified==nil)
        attachment.dateModified=[NSDate date];

    if (attachmentExist) {
            ret = [dataBase executeUpdate:@"update WIZ_DOCUMENT_ATTACHMENT set DOCUMENT_GUID=?, ATTACHMENT_NAME=?, ATTACHMENT_DATA_MD5=?, ATTACHMENT_DESCRIPTION=?, DT_MODIFIED=?, SERVER_CHANGED=?, LOCAL_CHANGED=? where ATTACHMENT_GUID=?"
               withArgumentsInArray:[NSArray arrayWithObjects:attachment.documentGuid,
                                     attachment.title,
                                     attachment.dataMd5,
                                     attachment.detail,
                                     [attachment.dateModified stringSql] ,
                                     [NSNumber numberWithInt: attachment.serverChanged],
                                     [NSNumber numberWithInt: attachment.localChanged],
                                     attachment.guid,
                                     nil]];
    }
    else
    {
            ret = [dataBase executeUpdate:@"insert into WIZ_DOCUMENT_ATTACHMENT (ATTACHMENT_GUID ,DOCUMENT_GUID, ATTACHMENT_NAME,ATTACHMENT_DATA_MD5,ATTACHMENT_DESCRIPTION,DT_MODIFIED,SERVER_CHANGED,LOCAL_CHANGED) values(?, ?, ?, ?, ?, ?, ?, ?)"
               withArgumentsInArray:[NSArray arrayWithObjects:attachment.guid,
                                     attachment.documentGuid,
                                     attachment.title,
                                     attachment.dataMd5,
                                     attachment.detail,
                                     [attachment.dateModified stringSql],
                                     [NSNumber numberWithInt: attachment.serverChanged],
                                     [NSNumber numberWithInt: attachment.localChanged],
                                     nil]];
    }
    return ret;
}
//
//
//
//
//
- (BOOL) addDeletedGUIDRecord:(NSString *)guid type:(NSString *)type
{
    BOOL ret;
    ret = [dataBase executeUpdate:@"insert into WIZ_DELETED_GUID (DELETED_GUID, GUID_TYPE, DT_DELETED) values (?, ?, ?)",guid, type, [[NSDate date] stringSql]];
    return ret;
}

- (NSMutableArray*) deletedGuidWithWhereField:(NSString*)whereField args:(NSArray*)args
{
    if (whereField == nil) {
        whereField = @"";
    }
    NSString* sql = [NSString stringWithFormat:@"SELECT DELETED_GUID, GUID_TYPE, DT_DELETED from WIZ_DELETED_GUID %@",whereField];
    
    NSMutableArray* array = [NSMutableArray array];
    FMResultSet* result =  [dataBase executeQuery:sql withArgumentsInArray:args];
    while ([result next]) {
        WizDeletedGuid* deleteGuid = [[WizDeletedGuid alloc] init];
        deleteGuid.guid = [result stringForColumnIndex:0];
        deleteGuid.type = [result stringForColumnIndex:1];
        deleteGuid.dateDeleted = [[result stringForColumnIndex:2] dateFromSqlTimeString];
        [array addObject:deleteGuid];
    }
    [result close];
    return array;
}
- (BOOL) isDeletedGuidExist:(NSString*)guid
{
    NSString* sql = [NSString stringWithFormat:@"select * from WIZ_DELETED_GUID where DELETED_GUID=?"];
    BOOL exist = NO;
    FMResultSet* result = [dataBase executeQuery:sql,guid];
    if ([result next]) {
        exist = YES;
    }
    [result close];
    return exist;
}

- (NSMutableArray*) deletedGUIDsForUpload
{
    return [self deletedGuidWithWhereField:nil args:nil];
}

- (BOOL) clearDeletedGUIDs
{
    BOOL ret;
    ret= [dataBase executeUpdate:@"delete from WIZ_DELETED_GUID"];
    return ret;
}
- (BOOL) deleteAttachment:(NSString *)attachGuid logDeleteRecord:(BOOL)needLog
{
    BOOL ret= [dataBase executeUpdate:@"delete from WIZ_DOCUMENT_ATTACHMENT where ATTACHMENT_GUID=?",attachGuid];
    if (ret && needLog) {
        [self addDeletedGUIDRecord:attachGuid type:WizObjectTypeAttachment];
    }
    return ret;
}

- (BOOL) deleteDocument:(NSString *)documentGUID
{
    BOOL ret;
    ret= [dataBase executeUpdate:@"delete  from WIZ_DOCUMENT where DOCUMENT_GUID=?",documentGUID];
    return ret;
}

//- (BOOL) deleteLocalTag:(NSString *)tagGuid
//{
//    NSArray* documents = [self documentsByTag:tagGuid];
//    for (WizDocument* eachDoc in documents) {
//        NSString* tagGuids = eachDoc.tagGuids;
//        if (tagGuids != nil && eachDoc.serverChanged == 0) {
//            tagGuids = [tagGuids removeTagguid:tagGuid];
//            [self changedDocumentTags:eachDoc.guid tags:tagGuids];
//        }
//    }
//    
//    __block BOOL ret;
//    [self.queue inDatabase:^(FMDatabase *db)
//     {
//         ret= [db executeUpdate:@"delete from WIZ_TAG where TAG_GUID=?",tagGuid];
//     }];
//    
//    if (ret) {
//        [self addDeletedGUIDRecord:tagGuid type:@"tag"];
//    }
//    
//    return ret;
//}

- (int)getAttachmentCountByDocmentGuid:(NSString*)docGuid
{
    FMResultSet* result = [dataBase executeQuery:@"select count(*) from WIZ_DOCUMENT_ATTACHMENT where DOCUMENT_GUID=?",docGuid];
    if ([result next]) {
        return [result intForColumnIndex:0];
    }
    return 0;
}

- (BOOL) deleteTag:(NSString *)tagGuid
{
         return [dataBase executeUpdate:@"delete from WIZ_TAG where TAG_GUID=?",tagGuid];
}

- (NSSet*) allLocationsForTree
{
    NSMutableSet* dic = [NSMutableSet  set];
    FMResultSet* result = [dataBase executeQuery:@"select distinct DOCUMENT_LOCATION from WIZ_DOCUMENT"];
    while ([result next]) {
        NSString* location = [result stringForColumnIndex:0];
        if (!location) {
            continue;
        }
        location = [location folderFormat];
        if ([location isEqualToString:@"/My Notes/"]) {
            continue;
        }
        [dic addObject:location];
    }
    [dic addObject:@"/My Notes/"];
    [result close];
    return dic;
}

- (BOOL) isExistFolderWithTitle:(NSString *)title
{
    FMResultSet* result = [dataBase executeQuery:@"select * from Wiz_LOCATION where DOCUMENT_LOCATION = ?", title];
    BOOL isExist = NO;
    if ([result next]) {
        isExist = YES;
    }
    [result close];
    return isExist;
}

- (BOOL) ensureParenExist:(NSString*)parentKey
{
    if ([parentKey isEqualToString:@"/"]) {
        return YES;
    }
    if ([self isExistFolderWithTitle:parentKey]) {
        return YES;
    }
    else
    {
        WizFolder* folder = [[WizFolder alloc] init];
        folder.key = parentKey;
        folder.localChanged = WizFolderEditTypeLocalCreate;
        return [self updateFolder:folder];
    }
}

- (BOOL) updateFolder:(WizFolder *)folder
{
    folder.key = [folder.key folderFormat];
    if ([self isExistFolderWithTitle:folder.key]) {
        return [dataBase executeUpdate:@"update Wiz_Location set LOCALCHANGED=? where DOCUMENT_LOCATION=?",[NSNumber numberWithInt:folder.localChanged],folder.key];
    }
    else
    {
        return [dataBase executeUpdate:@"insert into WIZ_LOCATION (DOCUMENT_LOCATION, LOCALCHANGED) values(?,?)",folder.key, [NSNumber numberWithInt:folder.localChanged]];
    }
}
- (BOOL) isLocalFolderDirty
{
    FMResultSet* result = [dataBase executeQuery:@"select count(*) from WIZ_LOCATION where LOCALCHANGED!=0"];
    if ([result next]) {
        NSInteger countOfNew = [result intForColumnIndex:0];
        if (countOfNew) {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    return NO;
}


- (void) folders:(NSMutableSet*)set contentPathAndParent:(NSString*)path
{
    NSString* parent = [path stringByDeletingLastPathComponent];
    if (![set containsObject:parent] && ![parent isEqualToString:@"/"]) {
        [set addObject:parent];
        [self folders:set contentPathAndParent:parent];
    }
}

- (void) ensureFolderAndParent:(NSString*)key existIn:(NSMutableSet*)allFolders willAddFolders:(NSMutableSet*)willAddFolders
{
    if (![key isEqualToString:@"/"] && ![allFolders containsObject:key] && ![willAddFolders containsObject: key]) {
            [willAddFolders addObject:key];
            [self ensureFolderAndParent:[key parentPath] existIn:allFolders willAddFolders:willAddFolders];
        }
}

- (NSSet*) allFoldersByTable
{
    NSMutableSet* folders = [NSMutableSet set];
    FMResultSet* result = [dataBase executeQuery:@"select DOCUMENT_LOCATION , LOCALCHANGED from WIZ_LOCATION"];
    BOOL hasMyNotes = NO;
    while ([result next]) {
        
        NSString* folderKeyStr = [result stringForColumnIndex:0];
//        if ([folderKeyStr hasPrefix:@"/Deleted Items/"] || [folderKeyStr isEqualToString:@"/"]) {
//            continue;
//        }
        WizFolder* folder = [[WizFolder alloc] init];
        folder.key = folderKeyStr;
        if ([folderKeyStr isEqualToString:@"/My Notes/"]) {
            hasMyNotes = YES;
        }
        folder.localChanged = (WizFolderEditType)[result intForColumnIndex:1];
        [folders addObject:folder];
    }
    if (!hasMyNotes) {
        WizFolder* folder = [[WizFolder alloc] init];
        folder.key = @"/My Notes/";
        folder.localChanged = WizFolderEditTypeNomal;
        [folders addObject:folder];
    }
    [result close];
    return folders;
}

- (NSSet*) childFoldersOf:(NSString*)folder
{
    NSSet* allFolders = [self allFolders];
    NSString* parentFolder = [folder copy];
    if([parentFolder hasSuffix:@"/"])
    {
        parentFolder = [parentFolder substringToIndex:parentFolder.length -1];
    }
    //
    NSMutableSet* subFolders = [NSMutableSet set];
    for (WizFolder* each in allFolders) {
        NSString* parentKey = each.parentKey;
        if ([parentKey hasSuffix:@"/"]) {
            parentKey = [parentKey substringToIndex:parentKey.length-1];
        }
        if([[parentKey lowercaseString] isEqualToString:[parentFolder lowercaseString]])
        {
            [subFolders addObject:each];
        }
    }
    WizFolder* pFolder = [[WizFolder alloc] init];
    pFolder.key = folder;
    pFolder.localChanged = WizFolderEditTypeNomal;
    [subFolders addObject:pFolder];
    return subFolders;
}

- (NSSet*) allFolders
{
    NSSet* documentLocations = [self allLocationsForTree];
    NSMutableSet* allFoldersFromTable = [[self allFoldersByTable] mutableCopy];
    
    NSSet* tempFromTable = [allFoldersFromTable copy];
    for (WizFolder* each in tempFromTable) {
        if (each.localChanged == WizFolderEditTypeLocalDeleted) {
            [allFoldersFromTable removeObject:each];
        }
    }
    NSMutableSet* allFolders = [NSMutableSet set];
    for (WizFolder* each in allFoldersFromTable) {
           [allFolders addObject:each.key];
    }
    for (NSString* each in documentLocations) {
        if (![allFolders containsObject:each]) {
            WizFolder* folder = [[WizFolder alloc] init];
            folder.key = each;
            folder.localChanged = WizFolderEditTypeNomal;
            [allFoldersFromTable addObject:folder];
        }
    }
    NSMutableSet* allfoldersKey = [NSMutableSet set];
    for (WizFolder* each in allFoldersFromTable) {
        [allfoldersKey addObject:each.key];
    }
    NSMutableSet* willAddFolderKeys = [NSMutableSet set];
    for (NSString* each in allfoldersKey) {
        if ([each isEqualToString:@"/"]) {
            
        }
        if ([each isEqualToString:@"//"]) {
            
        }
        [self ensureFolderAndParent:[each parentPath] existIn:allfoldersKey willAddFolders:willAddFolderKeys];
    }
    for (NSString* each in willAddFolderKeys) {
        if ([each isEqualToString:@"/"]) {
            continue;
        }
        [allfoldersKey addObject:each];
        WizFolder* folder = [[WizFolder alloc] init];
        folder.key = each;
        folder.localChanged = WizFolderEditTypeLocalCreate;
        [self updateFolder:folder];
        [allFoldersFromTable addObject:folder];
    }
    
    if ([allfoldersKey containsObject:@"/"]) {
        
    }
    return allFoldersFromTable;
}

- (NSArray *)subFolders:(NSString *)preLocation {
    NSMutableArray* folders = [NSMutableArray array];
    FMResultSet* result = [dataBase executeQuery:@"select DOCUMENT_LOCATION , LOCALCHANGED from WIZ_LOCATION where DOCUMENT_LOCATION like ?" , [NSString stringWithFormat:@"%@%%",preLocation]];
    while ([result next]) {
        NSString* folderKeyStr = [result stringForColumnIndex:0];
        if ([folderKeyStr isEqualToString:preLocation])
            continue;
        [folders addObject:folderKeyStr];
    }
    [result close];
    return [NSArray arrayWithArray:folders];
}

- (BOOL) deleteLocalFolder:(NSString *)folderkey
{
    return [dataBase executeUpdate:@"delete from WIZ_LOCATION where DOCUMENT_LOCATION=?",folderkey];
}

- (BOOL) logLocalDeletedFolder:(NSString *)folder
{
    WizFolder* f = [[WizFolder alloc] init];
    f.key = folder;
    f.localChanged = WizFolderEditTypeLocalDeleted;
    return [self updateFolder:f];
}

- (BOOL) clearFolsersData
{
//    wenlin modification start
//    BOOL isSucceed;
    BOOL isSucceed,isSucceed1;
//    wenlin modification end
    isSucceed = [dataBase executeUpdate:@"delete from WIZ_LOCATION where LOCALCHANGED=?",[NSNumber numberWithInt:WizFolderEditTypeLocalDeleted]];
    isSucceed1 = [dataBase executeUpdate:@"update WIZ_LOCATION set LOCALCHANGED=0"];
//    wenlin modification start
//    return isSucceed;
    return isSucceed && isSucceed1;
//    wenlin modification end
}

- (BOOL) isPersonalKb
{
    if (_kbguid) {
        return YES;
    }
    else
    {
        return NO;
    }
}



- (NSMutableDictionary *)folderDocCountWithCache:(BOOL)withCache {
    if (withCache)
        return nil;         //TODO

    NSString* sql = [NSString stringWithFormat:@"select DOCUMENT_LOCATION as DOCUMENT_LOCATION_TEMP, count(*) as DOCUMENT_COUNT from WIZ_DOCUMENT group by DOCUMENT_LOCATION order by DOCUMENT_LOCATION"];
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    FMResultSet* result = [dataBase executeQuery:sql];
    while ([result next]) {
            WizDocumentCount *count= [[WizDocumentCount alloc] init];
            count.docCountBySelf= [[result stringForColumnIndex:1] integerValue];
            count.docCountWithSub= count.docCountBySelf;
            NSString* key = [result stringForColumnIndex:0];
            if (key) {
                [dict setObject:count forKey:key];
            }
    }
    [result close];
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    for (int i = 0; i < dict.count; i++) {
        @autoreleasepool {
            NSString *key = [[dict allKeys] objectAtIndex:i];
            WizDocumentCount *nowModel = [dict objectForKey:key];

            NSString *preLocation = key;
            do {
                preLocation = [self getLocationParent:preLocation];
                if (preLocation == nil)
                    break;
                if ([resultDict objectForKey:preLocation] == nil) {
                    WizDocumentCount *count = [[WizDocumentCount alloc] init];
                    count.docCountBySelf = 0;
                    count.docCountWithSub = 0;
                    [resultDict setObject:count forKey:preLocation];
                }

                WizDocumentCount *model = [resultDict objectForKey:preLocation];
                model.docCountWithSub += nowModel.docCountBySelf;
            } while (preLocation != nil);
        }
    }
    return resultDict;
}

-(NSString *) getLocationParent:(NSString *) location {
    if (location == nil)
        return nil;
    if ([location isEqualToString:@""]|| [location isEqualToString:@"/"])
        return nil;
    NSString * temp = [NSString stringWithFormat:@"/%@",[location trimChar:'/']];
    int index= [temp lastIndexOf:@"/"];
    if (index<0)
        return nil;
    NSString *parent= [temp substringToIndex:index+1];
    return parent;
}


- (void)increaseTagDocumentCount:(NSMutableDictionary *)dict tagGuid:(NSString *)tagGuid{
    WizDocumentCount *model= [dict objectForKey:tagGuid];
    if (model==nil){
        model= [[WizDocumentCount alloc] init];
        model.docCountBySelf=0;
        model.docCountWithSub=0;
        [dict setObject:model forKey:tagGuid];
    }
    model.docCountBySelf++;
    model.docCountWithSub++;
}


- (void) parentTagsByGuid:(NSString*)tagGUid inDict:(NSDictionary*)dict toArray:(NSMutableArray*)array
{
    NSString* parentGuid = [dict objectForKey:tagGUid];
    if (parentGuid && ![parentGuid isEqualToString:InnerWizTagParentNullKey]) {
        [array addObject:parentGuid];
        [self parentTagsByGuid:parentGuid inDict:dict toArray:array];
    }
}

- (NSDictionary *)tagDocCountWithCache:(BOOL)withCache {
    if (withCache)
        return nil;         //TODO
    static NSString* WizTagNull = @"";
    NSString* sql = [NSString stringWithFormat:@"select DOCUMENT_TAG_GUIDS from WIZ_DOCUMENT where  DOCUMENT_LOCATION not like '/Deleted Items/%%'"];
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    FMResultSet* result = [dataBase executeQuery:sql];
    while ([result next]) {
            NSString *guids=[result stringForColumnIndex:0];
            if (!guids) {
                [self increaseTagDocumentCount:dict tagGuid:WizTagNull];
            }
            else if ([guids isEqualToString:WizTagNull]){
                [self increaseTagDocumentCount:dict tagGuid:WizTagNull];
            }
            else if ([guids indexOf:@"*"] != NSNotFound) {
                NSArray *array=[guids componentsSeparatedByString:@"*"];
                for (NSString *str in array) {
                    if (![str isEqualToString:@""]) {
                        [self increaseTagDocumentCount:dict tagGuid:str]; 
                    }
                }
            }
            else
            {
                [self increaseTagDocumentCount:dict tagGuid:guids];
            }
    }
    [result close];
    NSDictionary *tagParentKV=[self tagGuidAndParentTagGuidKV];
    NSArray* keys = [tagParentKV allKeys];
    for (NSString* key in keys) {
        WizDocumentCount* countObject = [dict objectForKey:key];
        NSString* parentKey = [tagParentKV objectForKey:key];
        while (![parentKey isEqualToString:InnerWizTagParentNullKey] && parentKey)  {
            WizDocumentCount* parentCountObject = [dict objectForKey:parentKey];
            if (!parentCountObject) {
                parentCountObject = [[WizDocumentCount alloc] init];
                parentCountObject.docCountBySelf = 0;
                parentCountObject.docCountWithSub = 0;
                [dict setObject:parentCountObject forKey:parentKey];
            }
            parentCountObject.docCountWithSub += countObject.docCountBySelf;
            NSString* newKey = [tagParentKV objectForKey:parentKey];
            if ([newKey isEqualToString:parentKey]) {
                break;
            }
            parentKey = newKey;
        }
    }
    WizDocumentCount* count = [dict objectForKey:WizTagNull];
    if (count) {
        [dict setObject:count forKey:@"WizGroupGuid"];
    }
    return dict;
}
@end
