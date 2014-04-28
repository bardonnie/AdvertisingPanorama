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
#import "WizNotificationCenter.h"
//database version
static int const WizInfoDataBaseVersion = 7;
//
//
//
//
static NSString* const KeyOfSyncVersion         =               @"SYNC_VERSION";
static NSString* const  KeyOfSyncVersionDocument        =@"DOCUMENT";
static NSString* const  KeyOfSyncVersionDeletedGuid=     @"DELETED_GUID";
static NSString* const  KeyOfSyncVersionAttachment=      @"ATTACHMENT";
static NSString* const  KeyOfSyncVersionTag=             @"TAG";
//
//
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

- (void) clearDocumentAbstractCache:(NSString*)documentGuid type:(WizGenerateAbstractType)type
{
    WizGenAbstractWorkObject* work = [[WizGenAbstractWorkObject alloc] init];
    NSString* accountUserId = [dataBase.databasePath stringByDeletingLastPathComponent];
    accountUserId = [accountUserId lastPathComponent];
    work.accountUserId = accountUserId;
    work.docGuid = documentGuid;
    work.type = type;
    [[WizWorkQueue genAbstractQueue] addWorkObject:work];
}

- (void) sendMessageEditDocumentType:(int)type  documentGuid:(NSString*)guid
{
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
    [userInfo setObject:[NSNumber numberWithInt:type] forKey:@"type"];
    [userInfo setObject:guid forKey:@"guid"];
    [[NSNotificationCenter defaultCenter] postNotificationName:WizModifiedDocumentMessage object:nil userInfo:userInfo];
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

- (NSArray*) documentsArrayWithWhereFiled:(NSString*)where arguments:(NSArray*)args
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
        doc.localChanged = [result intForColumnIndex:12];
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
    return [self documentsArrayWithWhereFiled:@"where DOCUMENT_LOCATION not like '/Deleted Items/%'  order by max(DT_CREATED, DT_MODIFIED) desc limit 0, 200" arguments:nil];
}

- (NSArray*) documentForUpload
{
    return [self documentsArrayWithWhereFiled:@"where LOCAL_CHANGED !=0 and DOCUMENT_LOCATION not like '/Deleted Items/%' " arguments:nil];
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


- (NSArray*) documentsByKey:(NSString *)keywords
{
    NSString* sqlWhere = [NSString stringWithFormat:@"%@%@%@",@"%",keywords,@"%"];
    return [self documentsArrayWithWhereFiled:@"where DOCUMENT_TITLE like ? and DOCUMENT_LOCATION not like '/Deleted Items/%' order by max(DT_CREATED, DT_MODIFIED) desc limit 0, 100" arguments:[NSArray arrayWithObject:sqlWhere]];
}

- (NSArray*) documentsByLocation:(NSString *)parentLocation
{
    return [self documentsArrayWithWhereFiled:@"where DOCUMENT_LOCATION=? order by max(DT_CREATED, DT_MODIFIED) desc" arguments:[NSArray arrayWithObject:parentLocation]];
}

- (NSArray*) documentsByTag:(NSString *)tagGUID
{
    NSString* sqlWhere = [NSString stringWithFormat:@"%@%@%@",@"%",tagGUID,@"%"];
    return [self documentsArrayWithWhereFiled:@"where DOCUMENT_TAG_GUIDS like ? and DOCUMENT_LOCATION not like '/Deleted Items/%' order by max(DT_CREATED, DT_MODIFIED) desc" arguments:[NSArray arrayWithObject:sqlWhere]];
}
- (NSArray*) documentsForCache:(NSInteger)duration
{
    NSDate* date = [NSDate dateWithDaysBeforeNow:duration];
    return [self documentsArrayWithWhereFiled:@"where DT_MODIFIED >= ? and SERVER_CHANGED=1 order by DT_MODIFIED" arguments:[NSArray arrayWithObjects:[date stringSql], nil]];
}

- (WizDocument*) documentForClearCacheNext
{
    return [[self documentsArrayWithWhereFiled:@"where  SERVER_CHANGED=0 and LOCAL_CHANGED=0 order by DT_MODIFIED asc limit 0,1" arguments:nil] lastObject];
}
- (BOOL) updateDocument:(WizDocument *)doc
{
    WizDocument* docExist = [self documentFromGUID:doc.guid];
    BOOL ret;
    if (docExist)
    {
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
                [self sendMessageEditDocumentType:WizModifiedDocumentTypeLocalUpdate documentGuid:doc.guid];
            }
            else
            {
                [self sendMessageEditDocumentType:WizModifiedDocumentTypeServerUpdate documentGuid:doc.guid];
            }
        }
        [self clearDocumentAbstractCache:doc.guid type:WizGenerateAbstractTypeDelete];
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
                [self sendMessageEditDocumentType:WizModifiedDocumentTypeLocalInsert documentGuid:doc.guid];
            }
            else
            {
                [self sendMessageEditDocumentType:WizModifiedDocumentTypeServerInsert documentGuid:doc.guid];
            }
        }
    }
    return ret;
}

- (BOOL) setDocumentLocalChanged:(NSString *)guid changed:(enum WizEditDocumentType)changed
{
    BOOL ret;
        ret = [dataBase executeUpdate:@"update WIZ_DOCUMENT set LOCAL_CHANGED=? where DOCUMENT_GUID= ?",[NSNumber numberWithInt:changed],guid];;
    return ret;
}
- (BOOL) setDocumentServerChanged:(NSString *)guid changed:(BOOL)changed
{
    BOOL ret;
    ret=  [dataBase executeUpdate:@"update WIZ_DOCUMENT set SERVER_CHANGED=? where DOCUMENT_GUID= ?",[NSNumber numberWithInt:changed],guid];
    return ret;
}
- (NSArray*) tagsArrayWithWhereField:(NSString*)where   args:(NSArray*)args
{
    if (nil == where) {
        where = @"";
    }
    NSString* sql = [NSString stringWithFormat:@"select TAG_GUID, TAG_PARENT_GUID, TAG_NAME, TAG_DESCRIPTION  ,LOCALCHANGED, DT_MODIFIED from WIZ_TAG %@",where];
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
    return [[self tagsArrayWithWhereField:@"where TAG_GUID=?" args:[NSArray arrayWithObject:guid]] lastObject];
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

- (NSString*) tagPath:(WizTag*)tag tagDic:(NSDictionary*)tagDic
{
    NSLog(@"tag title is %@",tag.title);
    if (!tag.parentGUID || [tag.parentGUID isEqualToString:@""]) {
        return [@"/" stringAppendingPath:tag.title];
    }
    else
    {
        WizTag* parentTag = [tagDic objectForKey:tag.parentGUID];
        NSString* parentPath = [self tagPath:parentTag tagDic:tagDic];
        return [parentPath stringAppendingPath:tag.title];
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
        [tagTree setObject:guid forKey:tagPath ];
    }
    return tagTree;
}

- (NSDictionary*) tagPathDictionary
{
    NSDictionary* dic = [self tagTreeDictionary];
    return [NSDictionary dictionaryWithObjects:[dic allKeys] forKeys:[dic allValues]];
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
    return [self attachmentsWithWhereFiled:@"where LOCAL_CHANGED>?" args:@[@0]];
}

- (BOOL) setAttachmentLocalChanged:(NSString *)attchmentGUID changed:(BOOL)changed
{
    BOOL ret;
        ret = [dataBase executeUpdate:@"update WIZ_DOCUMENT_ATTACHMENT set LOCAL_CHANGED=? where ATTACHMENT_GUID=?",[NSNumber numberWithBool:changed], attchmentGUID];
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

- (NSArray*) deletedGuidWithWhereField:(NSString*)whereField args:(NSArray*)args
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

- (NSArray*) deletedGUIDsForUpload
{
    return [self deletedGuidWithWhereField:nil args:nil];
}

- (BOOL) clearDeletedGUIDs
{
    BOOL ret;
    ret= [dataBase executeUpdate:@"delete from WIZ_DELETED_GUID"];
    return ret;
}
- (BOOL) deleteAttachment:(NSString *)attachGuid
{
    BOOL ret;
        ret= [dataBase executeUpdate:@"delete  from WIZ_DOCUMENT_ATTACHMENT where ATTACHMENT_GUID=?",attachGuid];
    return ret;
}

- (BOOL) deleteDocument:(NSString *)documentGUID
{
    BOOL ret;
    ret= [dataBase executeUpdate:@"delete  from WIZ_DOCUMENT where DOCUMENT_GUID=?",documentGUID];
    if (ret) {
        [self sendMessageEditDocumentType:WizModifiedDocumentTypeDeleted documentGuid:documentGUID];
        [self addDeletedGUIDRecord:documentGUID type:WizObjectTypeDocument];
    }
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

- (BOOL) updateFolder:(WizFolder *)folder
{
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
    FMResultSet* result = [dataBase executeQuery:@"select count(*) from WIZ_LOCATION where LOCALCHANGED=1"];
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
- (NSSet*) allFolders
{
    NSMutableSet* folders = [NSMutableSet set];
    FMResultSet* result = [dataBase executeQuery:@"select DOCUMENT_LOCATION , LOCALCHANGED from WIZ_LOCATION"];
    BOOL hasMyNotes = NO;
    while ([result next]) {
        WizFolder* folder = [[WizFolder alloc] init];
        NSString* folderKeyStr = [result stringForColumnIndex:0];
        folder.key = folderKeyStr;
        if ([folderKeyStr isEqualToString:@"/My Notes/"]) {
            hasMyNotes = YES;
        }
        folder.localChanged = [result intForColumnIndex:1];
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
    BOOL isSucceed;
    isSucceed = [dataBase executeUpdate:@"delete from WIZ_LOCATION where LOCALCHANGED=?",[NSNumber numberWithInt:WizFolderEditTypeLocalDeleted]];
    isSucceed = [dataBase executeUpdate:@"update WIZ_LOCATION set LOCALCHANGED=0"];
    return isSucceed;
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

@end
