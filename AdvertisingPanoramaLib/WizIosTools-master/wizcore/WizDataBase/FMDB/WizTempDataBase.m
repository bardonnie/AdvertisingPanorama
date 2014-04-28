//
//  WizTempDataBase.m
//  Wiz
//
//  Created by wiz on 12-6-17.
//
//

#import "WizTempDataBase.h"
#import "WizFileManager.h"
#import "WizAccountManager.h"
#import "NSDate+WizTools.h"
static NSString* const WizTempMetaKeySyncVersion = @"WizTempMetaKeySyncVersion";
static NSString* const WizMessageVersion = @"MESSAGE_VERSION";
static NSString* const WizTempMetaKeySelectMessageGroup = @"WizTempMetaKeySelectMessageGroup";

@interface NSString (WizSqlGenerate)
+ (NSString*) deleteSql:(NSString*)tableName whereArray:(NSArray*)whereFields decorate:(NSString*)decorate;
+ (NSString*) selecteSql:(NSString*)tableName whereArray:(NSArray*)whereFields decorate:(NSString*)decorate;
+ (NSString*) updateSql:(NSString*)tableName setFields:(NSArray*)setFields whereArray:(NSArray*)whereFields;
@end

@implementation NSString (WizSqlGenerate)
+ (NSString*) updateSql:(NSString *)tableName setFields:(NSArray *)setFields whereArray:(NSArray *)whereFields
{
    NSMutableString* sql = [NSMutableString stringWithFormat:@"update %@ set ", tableName];
    int count = [setFields count];
    for (int i = 0 ; i< count; ++i) {
        [sql appendFormat:@" %@=?", [setFields objectAtIndex:i]];
        if (i < count -1 ) {
            [sql appendString:@","];
        }
    }
    
    return [sql appendingWhereFileds:whereFields decorate:nil];
}
- (NSString*) appendingWhereFileds:(NSArray*)whereFields decorate:(NSString*)decorate
{
    NSMutableString* sql = [self mutableCopy];
    if ([whereFields count]) {
        [sql appendString:@" where "];
    }
    NSInteger count = [whereFields count];
    for (int i = 0; i < count ; ++i) {
        [sql appendFormat:@"%@=? ",[whereFields objectAtIndex:i]];
        if (i != count -1) {
            [sql appendString:@" and "];
        }
    }
    if (decorate) {
        [sql appendFormat:@" %@",decorate];
    }
    return sql;
}
- (NSString*) appendingInBracketsString:(NSString*)str repeatCount:(int)count
{
    NSMutableString* sql = [self mutableCopy];
    [sql appendString:@"("];
    for (int i = 0; i < count; ++i) {
        [sql appendString:str];
        if (i < count -1) {
            [sql appendString:@","];
        }
    }
    [sql appendString:@")"];
    return sql;
}

- (NSString*) appendingInBracketsStrings:(NSArray*)strings
{
    NSMutableString* sql = [self mutableCopy];
    [sql appendString:@"("];
    int count = [strings count];
    for (int i = 0; i < count; ++i) {
        [sql appendString:strings[i]];
        if (i < count -1) {
            [sql appendString:@","];
        }
    }
    [sql appendString:@")"];
    return sql;
}

+ (NSString*) insertSql:(NSString*) tableName columns:(NSArray*)array
{
    NSString* sql = [self stringWithFormat:@"insert into %@  ", tableName];
    sql = [sql appendingInBracketsStrings:array];
    sql = [sql stringByAppendingString:@"  values"];
    sql = [sql appendingInBracketsString:@"?" repeatCount:[array count]];
    return sql;
}

+ (NSString*) selecteSql:(NSString*)tableName whereArray:(NSArray*)whereFields decorate:(NSString*)decorate
{
    NSString* sql = [NSString stringWithFormat:@"select * from %@ ", tableName];
    return [sql appendingWhereFileds:whereFields decorate:decorate];
}
+ (NSString*) deleteSql:(NSString*)tableName whereArray:(NSArray*)whereFields decorate:(NSString*)decorate
{
    NSMutableString* sql =[NSMutableString stringWithFormat: @"delete from %@ ",tableName];
    return [sql appendingWhereFileds:whereFields decorate:decorate];
}

@end
static NSString* const WizSearchTableName = @"WIZ_SEARCH_1";
static NSString* const WizSearchColumnAccountUserId = @"ACCOUNTUSERID";
static NSString* const WizSearchColumnCount = @"COUNT";
static NSString* const WizSearchColumnDate = @"DATE";
static NSString* const WizSearchColumnKeyWords= @"KEYWORDS";
static NSString* const WizSearchColumnType=@"TYPE";
static NSString* const WizSearchColumnKbguid = @"KBGUID";
static NSString* const WizSearchColumnFolder= @"FOLDER";
static NSString* const WizSearchColumnTagGuids = @"TAGGUIDS";

static NSString* const WizMessageTableNmae = @"WIZ_MESSAGE";
static NSString* const  WizMessageColumnDocumentGuid = @"MESSAGE_DOCUMENT_GUID";
static NSString* const  WizMessageColumnDtCreated = @"MESSAGE_DT_CREATED";
static NSString* const  WizMessageColumnBizGuid = @"MESSAGE_BIZ_GUID";
static NSString* const  WizMessageColumnEmailSendStatus = @"MESSAGE_EMAIL_STATUS";
static NSString* const  WizMessageColumnKbGuid = @"MESSAGE_KB_GUID";
static NSString* const  WizMessageColumnMessageId = @"MESSAGE_ID";
static NSString* const  WizMessageColumnMessageNote = @"MESSAGE_NOTE";
static NSString* const  WizMessageColumnMessageType = @"MESSAGE_MESSAGE_TYPE";
static NSString* const  WizMessageColumnReadStatus = @"MESSAGE_READ_STATUS";
static NSString* const  WizMessageColumnReceiverAlias = @"MESSAGE_RECEIVER_ALIAS";
static NSString* const  WizMessageColumnReceiverGuid = @"MESSAGE_RECEIVER_GUID";
static NSString* const  WizMessageColumnReceiverId = @"MESSAGE_RECEIVER_ID";
static NSString* const  WizMessageColumnSenderAlias = @"MESSAGE_SENDER_ALIAS";
static NSString* const  WizMessageColumnSenderGuid = @"MESSAGE_SENDER_GUID";
static NSString* const  WizMessageColumnSenderId = @"MESSAGE_SENDER_ID";
static NSString* const  WizMessageColumnSmsSendStatus = @"MESSAGE_SMS_STATUS";
static NSString* const  WizMessageColumnTitle = @"MESSAGE_TITLE";
static NSString* const  WizMessageColumnBody = @"MESSAGE_BODY";
static NSString* const  WizMessageColumnLocalChanged = @"LOCALCHANGED";


static NSString* const  WizBizUserTableName = @"WIZ_BIZ_USER";
static NSString* const  WizBizUserID = @"WIZ_BIZ_USER_ID";
static NSString* const  WizBizUserALIAS = @"WIZ_BIZ_USER_ALIAS";
static NSString* const  WizBizUserPinyin = @"WIZ_BIZ_USER_PINYIN";
static NSString* const  WizBizUserGuid = @"WIZ_BIZ_USER_GUID";
static NSString* const  WizBizUserBizGuid = @"WIZ_BIZ_USER_BIZGUID";

static NSString* const  WizSelectedMessageGroupKbGuid = @"WizSelectedMessageGroupKbGuid";





static const int WizTempDataBaseVersion = 10;
@implementation WizTempDataBase
- (int) currentVersion
{
    return WizTempDataBaseVersion;
}
- (BOOL) isAbstractExist:(NSString*)documentGuid
{
    BOOL ret;
        FMResultSet* result = [dataBase executeQuery:@"select * from WIZ_ABSTRACT where ABSTRACT_GUID is ?",documentGuid];
        if ([result next]) {
            ret =  YES;
        }
        else
        {
            ret = NO;
        }
        [result close];

    return ret;
}
- (BOOL) updateAbstract:(NSString*)text imageData:(NSData*)imageData guid:(NSString*)guid type:(NSString*)type kbguid:(NSString*)kbguid
{
    BOOL ret;
    if ([self isAbstractExist:guid]) {
            ret =[dataBase executeUpdate:@"update WIZ_ABSTRACT set ABSTRACT_TYPE=?, ABSTRACT_TEXT=?, ABSTRACT_IMAGE=?, GROUP_KBGUID=?,DT_MODIFIED=? where ABSTRACT_GUID=?", type, text, imageData,kbguid, [[NSDate date] stringSql], guid];
    }
    else
    {
            ret =[dataBase executeUpdate:@"insert into WIZ_ABSTRACT (ABSTRACT_GUID ,ABSTRACT_TYPE, ABSTRACT_TEXT, ABSTRACT_IMAGE, GROUP_KBGUID,DT_MODIFIED) values(?, ?, ?, ?, ?, ?)",guid,type,text,imageData,kbguid,[[NSDate date] stringSql]];
    }
    return ret;
}


- (WizAbstract*) abstractOfDocument:(NSString *)documentGUID
{
    WizAbstract* abs = nil;
        FMResultSet* result = [dataBase executeQuery:@"select ABSTRACT_TEXT, ABSTRACT_IMAGE from WIZ_ABSTRACT where ABSTRACT_GUID=?",documentGUID];
        if ([result next]) {
             WizAbstract* local = [[WizAbstract alloc] init];
            local.text = [result stringForColumnIndex:0];
            local.image = [UIImage imageWithData:[result dataForColumnIndex:1]];
            abs = local;
        }
        [result close];
    return abs;
}
- (BOOL) deleteAbstractByGUID:(NSString *)documentGUID
{
    BOOL ret;
    ret = [dataBase executeUpdate:@"delete from WIZ_ABSTRACT where ABSTRACT_GUID=?",documentGUID];
    return ret;
}
- (BOOL) deleteAbstractsByAccountUserId:(NSString *)accountUserID
{
    BOOL isSucceess;
        isSucceess = [dataBase executeUpdate:@"delete from WIZ_ABSTRACT where GROUP_KBGUID=?",accountUserID];
    return isSucceess;
}
- (BOOL) clearCache
{
    return YES;
}

- (BOOL) updateWizSearch:(WizSearch *)search
{
    
    NSString* kbguid = search.kbguid;
    if (!kbguid) {
        kbguid = WizGlobalPersonalKbguid;
    }
    if ([self searchDataFromDb:search.keyWords kbguid:search.kbguid accountUserId:search.accountUserId]) {
        NSString* sql = [NSString updateSql:WizSearchTableName setFields:@[WizSearchColumnAccountUserId, WizSearchColumnCount, WizSearchColumnDate, WizSearchColumnFolder, WizSearchColumnKbguid, WizSearchColumnKeyWords, WizSearchColumnTagGuids, WizSearchColumnType] whereArray:@[WizSearchColumnKeyWords, WizSearchColumnKbguid, WizSearchColumnAccountUserId]];
        return [dataBase executeUpdate:sql,
                search.accountUserId,
                [NSNumber numberWithInt:search.count],
                [search.dateSearched stringSql],
                search.folder,
                kbguid,
                search.keyWords,
                search.tagGuids,
                [NSNumber numberWithInt:search.type],
                search.keyWords,
                search.kbguid,
                search.accountUserId];
    }
    else
    {
        NSString* sql = [NSString stringWithFormat:@"insert into %@  (%@,%@,%@,%@,%@,%@,%@,%@) values(?,?,?,?,?,?,?,?)", WizSearchTableName,
                         WizSearchColumnTagGuids,
                         WizSearchColumnKeyWords,
                         WizSearchColumnKbguid,
                         WizSearchColumnFolder,
                         WizSearchColumnAccountUserId,
                         WizSearchColumnType,
                         WizSearchColumnCount,
                         WizSearchColumnDate];
        return [dataBase executeUpdate:sql,
                search.tagGuids,
                search.keyWords,
                kbguid,
                search.folder,
                search.accountUserId,
                [NSNumber numberWithInt:search.type],
                [NSNumber numberWithInt:search.count],
                [search.dateSearched stringSql]
                ];
    }
}
- (NSArray*) searchArrayFromFMResultSet:(FMResultSet*)searchData
{
    NSMutableArray* array = [NSMutableArray array];
    while ([searchData next]) {
        WizSearch* search = [[WizSearch alloc] init];
        search.count = [searchData intForColumn:WizSearchColumnCount];
        search.accountUserId = [searchData stringForColumn:WizSearchColumnAccountUserId];
        search.kbguid = [searchData stringForColumn:WizSearchColumnKbguid];
        search.dateSearched = [[searchData stringForColumn:WizSearchColumnDate]  dateFromSqlTimeString];
        search.keyWords = [searchData stringForColumn:WizSearchColumnKeyWords];
        search.folder = [searchData stringForColumn:WizSearchColumnFolder];
        search.tagGuids = [searchData stringForColumn:WizSearchColumnTagGuids];
        search.type = [searchData intForColumn:WizSearchColumnType];
        [array addObject:search];
    }
    [searchData close];
    return array;
}
- (NSArray*) allSearchByKbguid:(NSString *)kbguid accountUserId:(NSString*)accountUserId
{
    if (!kbguid) {
        kbguid = WizGlobalPersonalKbguid;
    }
    NSString* sql = [NSString selecteSql:WizSearchTableName whereArray:@[WizSearchColumnKbguid, WizSearchColumnAccountUserId] decorate:[NSString stringWithFormat:@" order by %@ desc",WizSearchColumnDate]];
    FMResultSet* result = [dataBase executeQuery:sql,kbguid, accountUserId];
    return [self searchArrayFromFMResultSet:result];
}

- (WizSearch*) searchDataFromDb:(NSString*)keywords kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId
{
    if (!kbguid) {
        kbguid = WizGlobalPersonalKbguid;
    }
    NSString* sql = [NSString selecteSql:WizSearchTableName whereArray:@[WizSearchColumnKeyWords, WizSearchColumnKbguid, WizSearchColumnAccountUserId] decorate:[NSString stringWithFormat:@" order by %@",WizSearchColumnDate]];
    FMResultSet* searchData = [dataBase executeQuery:sql, keywords, kbguid, accountUserId];
    return [[self searchArrayFromFMResultSet:searchData] lastObject];
}
//

- (BOOL) deleteWizSearch:(NSString *)keywords kbguid:(NSString *)kbguid accountUserId:(NSString*)accountUserId
{
    if (!kbguid) {
        kbguid = WizGlobalPersonalKbguid;
    }
    NSString* sql = [NSString deleteSql:WizSearchTableName whereArray:@[WizSearchColumnKeyWords, WizSearchColumnKbguid, WizSearchColumnAccountUserId] decorate:nil];
    return [dataBase executeUpdate:sql, keywords, kbguid, accountUserId];
}

- (BOOL) deleteAllWizSearchKbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId
{
    if (!kbguid) {
        kbguid = WizGlobalPersonalKbguid;
    }
    NSString* sql = [NSString deleteSql:WizSearchTableName whereArray:@[WizSearchColumnKbguid, WizSearchColumnAccountUserId] decorate:nil];
    return [dataBase executeUpdate:sql, kbguid, accountUserId];
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
- (BOOL) isExistMessage:(int64_t)messageID
{
    if ([self messageFromId:messageID]) {
        return YES;
    }
    else
    {
        return NO;
    }
}
- (BOOL) updateMessage:(WizMessage *)message
{
    BOOL succedd = NO;
    if ([self isExistMessage:message.messageId]) {
        
        NSString* sql = [NSString updateSql:WizMessageTableNmae
                                  setFields:@[WizMessageColumnBizGuid,WizMessageColumnDocumentGuid, WizMessageColumnDtCreated, WizMessageColumnEmailSendStatus, WizMessageColumnKbGuid,WizMessageColumnMessageNote,WizMessageColumnMessageType,WizMessageColumnReadStatus,WizMessageColumnReceiverAlias,WizMessageColumnReceiverGuid,WizMessageColumnReceiverId,WizMessageColumnSenderAlias,WizMessageColumnSenderGuid,WizMessageColumnSenderId,WizMessageColumnSmsSendStatus,WizMessageColumnTitle,WizMessageColumnBody,WizMessageColumnLocalChanged]
                                 whereArray:@[WizMessageColumnMessageId]];
        succedd = [dataBase executeUpdate:sql,
                message.bizGuid,
                message.documentGuid,
                [message.dtCreated stringSql],
                @(message.emailSendStatus),
                message.kbGuid,
                message.messageNote,
                @(message.messageType),
                @(message.readStatus),
                message.receiverAlias,
                message.receiverGuid,
                message.receiverId,
                message.senderAlias,
                message.senderGuid,
                message.senderId,
                @(message.smsSendStatus),
                message.title,
                message.body,
                [NSNumber numberWithInt:message.localChanged],
                @(message.messageId)];
        
    }
    else
    {
        NSString* sql = [NSString insertSql:WizMessageTableNmae
                                    columns:@[WizMessageColumnBizGuid,WizMessageColumnDocumentGuid, WizMessageColumnDtCreated, WizMessageColumnEmailSendStatus, WizMessageColumnKbGuid,WizMessageColumnMessageNote,WizMessageColumnMessageType,WizMessageColumnReadStatus,WizMessageColumnReceiverAlias,WizMessageColumnReceiverGuid,WizMessageColumnReceiverId,WizMessageColumnSenderAlias,WizMessageColumnSenderGuid,WizMessageColumnSenderId,WizMessageColumnSmsSendStatus,WizMessageColumnTitle,WizMessageColumnBody,WizMessageColumnLocalChanged,WizMessageColumnMessageId]];
        succedd =  [dataBase executeUpdate:sql, message.bizGuid,
                                            message.documentGuid,
                                            [message.dtCreated stringSql],
                                            @(message.emailSendStatus),
                                            message.kbGuid,
                                            message.messageNote,
                                            @(message.messageType),
                                            @(message.readStatus),
                                            message.receiverAlias,
                                            message.receiverGuid,
                                            message.receiverId,
                                            message.senderAlias,
                                            message.senderGuid,
                                            message.senderId,
                                            @(message.smsSendStatus),
                                            message.title,
                                            message.body,
                                            [NSNumber numberWithInt:message.localChanged],
                                            @(message.messageId)];
    }
    if (succedd) {
       [[NSNotificationCenter defaultCenter] postNotificationName:WizMessageChangedMesssage object:nil userInfo:@{WizNotificationUserInfoAccountUserId:message.receiverId, @"messageid":[NSString stringWithFormat:@"%lld",message.messageId]}];
    }
    return succedd;
}
- (BOOL) updateMessages:(NSArray *)array
{
    BOOL succeed = YES;
    for (WizMessage* each in array) {
        succeed = [self updateMessage:each];
    }
    return succeed;
}

- (BOOL) messageLocalChanged:(WizMessage*)message
{
    message.localChanged = 1;
    return YES;
}

- (BOOL) deleteMessage:(WizMessage*)message
{
    if ([self isExistMessage:message.messageId]) {
        NSString* sql = [NSString deleteSql:WizMessageTableNmae whereArray:@[WizMessageColumnMessageId] decorate:nil];
        if ([dataBase executeUpdate:sql,@(message.messageId)]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:WizMessageChangedMesssage object:nil userInfo:@{WizNotificationUserInfoAccountUserId:message.receiverId, @"messageid":[NSString stringWithFormat:@"%lld",message.messageId]}];
            return YES;
        }
    }
    return NO;
}

- (BOOL) deleteMessages:(NSArray*)messagesArray
{
    for (WizMessage* each in messagesArray) {
        if (![self deleteMessage:each]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL) isMessagesDataDirty:(NSString*)accountUserId
{
    NSString* sql = [NSString stringWithFormat:@"select count(*) from %@", WizMessageTableNmae];
    FMResultSet* result = [dataBase executeQuery:sql];
    int64_t count = 0;
    if ([result next]) {
        count= [result intForColumnIndex:0];
    }
    [result close];
    if (count == 0) {
        return NO;
    }
    else
{
    return YES;
}
}

- (NSArray*) messagesForLocalChanged:(NSString *)accountUserId
{
    NSString* sql = [NSString selecteSql:WizMessageTableNmae whereArray:@[WizMessageColumnReceiverId,WizMessageColumnLocalChanged] decorate:nil];
    FMResultSet* result = [dataBase executeQuery:sql,accountUserId,[NSNumber numberWithInt:1]];
    return [self messageArrayFromFMResult:result];
}

- (NSArray*) messageArrayFromFMResult:(FMResultSet*)result
{
    NSMutableArray* array = [NSMutableArray new];
    while ([result next]) {
        WizMessage* message = [[WizMessage alloc] init];
        message.messageId = [result longLongIntForColumn:WizMessageColumnMessageId];
        message.bizGuid = [result stringForColumn:WizMessageColumnBizGuid];
        message.documentGuid = [result stringForColumn:WizMessageColumnDocumentGuid];
        message.dtCreated = [[result stringForColumn:WizMessageColumnDtCreated] dateFromSqlTimeString];
        message.emailSendStatus = [result intForColumn:WizMessageColumnEmailSendStatus];
        message.kbGuid = [result stringForColumn:WizMessageColumnKbGuid];
        message.messageNote = [result stringForColumn:WizMessageColumnMessageNote];
        message.messageType = [result intForColumn:WizMessageColumnMessageType];
        message.readStatus = [result intForColumn:WizMessageColumnReadStatus];
        message.receiverAlias = [result stringForColumn:WizMessageColumnReceiverAlias];
        message.receiverGuid = [result stringForColumn:WizMessageColumnReceiverGuid];
        message.receiverId = [result stringForColumn:WizMessageColumnReceiverId];
        message.senderAlias = [result stringForColumn:WizMessageColumnSenderAlias];
        message.senderGuid = [result stringForColumn:WizMessageColumnSenderGuid];
        message.senderId = [result stringForColumn:WizMessageColumnSenderId];
        message.smsSendStatus = [result longLongIntForColumn:WizMessageColumnSmsSendStatus];
        message.title = [result stringForColumn:WizMessageColumnTitle];
        message.body = [result stringForColumn:WizMessageColumnBody];
        message.localChanged = [result intForColumn:WizMessageColumnLocalChanged];
        [array addObject:message];
    }
    [result close];
    return array;
}


- (WizMessage*) messageFromId:(int64_t)messageId
{
    NSString* sql = [NSString selecteSql:WizMessageTableNmae whereArray:@[WizMessageColumnMessageId] decorate:nil];
    FMResultSet* resutl = [dataBase executeQuery:sql, @(messageId)];
    return [[self messageArrayFromFMResult:resutl] lastObject];
}

- (NSArray*) messagesByReciverAccountUserId:(NSString*)accountUserId
{
    NSString* sql = [NSString selecteSql:WizMessageTableNmae whereArray:@[WizMessageColumnReceiverId] decorate:[NSString stringWithFormat:@" order by %@ desc limit 0, 400", WizMessageColumnDtCreated]];
    FMResultSet* result = [dataBase executeQuery:sql,accountUserId];
    return [self messageArrayFromFMResult:result];
}

- (NSArray*) messagesByReciverAccountUserId:(NSString*)accountUserId SenderGroupKbGuid:(NSString*)kbguid
{
    if (kbguid == nil || [kbguid isEqualToString:@""]) {
        return [self messagesByReciverAccountUserId:accountUserId];
    }
    NSString* sql = [NSString selecteSql:WizMessageTableNmae whereArray:@[WizMessageColumnReceiverId,WizMessageColumnKbGuid] decorate:[NSString stringWithFormat:@" order by %@ desc limit 0, 400", WizMessageColumnDtCreated]];
    FMResultSet* result = [dataBase executeQuery:sql,accountUserId,kbguid];
    return [self messageArrayFromFMResult:result];
}

- (NSArray*) messagesByReciverAccountUserId:(NSString *)accountUserId messageType:(WizMessageType)messageType
{
    NSString* sql = [NSString selecteSql:WizMessageTableNmae whereArray:@[WizMessageColumnReceiverId,WizMessageColumnMessageType] decorate:[NSString stringWithFormat:@" order by %@ desc limit 0, 400", WizMessageColumnDtCreated]];
    FMResultSet* result = [dataBase executeQuery:sql,accountUserId,@(messageType)];
    return [self messageArrayFromFMResult:result];
}

- (NSArray*) messagesByReciverAccountUserId:(NSString *)accountUserId SenderGroupKbGuid:(NSString *)kbguid messageType:(WizMessageType)messageType
{
    if (messageType == WizMessageTypeAllType) {
        return [self messagesByReciverAccountUserId:accountUserId SenderGroupKbGuid:kbguid];
    }
    if (kbguid == nil || [kbguid isEqualToString:@""]) {
        return [self messagesByReciverAccountUserId:accountUserId messageType:messageType];
    }
    NSString* sql = [NSString selecteSql:WizMessageTableNmae whereArray:@[WizMessageColumnReceiverId,WizMessageColumnKbGuid,WizMessageColumnMessageType] decorate:[NSString stringWithFormat:@" order by %@ desc limit 0, 400", WizMessageColumnDtCreated]];
    FMResultSet* result = [dataBase executeQuery:sql,accountUserId,kbguid,@(messageType)];
    return [self messageArrayFromFMResult:result];
}

- (BOOL) updateAllUnreadMessageToReaded:(NSString*)accountUserId SenderGroupKbGuid:(NSString*)kbguid
{
    NSString* sql = [NSString updateSql:WizMessageTableNmae setFields:@[WizMessageColumnReadStatus] whereArray:@[WizMessageColumnReceiverId,WizMessageColumnKbGuid,WizMessageColumnReadStatus]];
    return [dataBase executeUpdate:sql,@(WizMessageReadStatusReaded),accountUserId,kbguid,@(WizMessageReadStatusUnRead)];
}

- (BOOL) updateAllUnreadMessageToReaded:(NSString*)accountUserId messageType:(WizMessageType)messageType
{
    NSString* sql = [NSString updateSql:WizMessageTableNmae setFields:@[WizMessageColumnReadStatus] whereArray:@[WizMessageColumnReceiverId,WizMessageColumnMessageType,WizMessageColumnReadStatus]];
    return [dataBase executeUpdate:sql,@(WizMessageReadStatusReaded),accountUserId,@(messageType),@(WizMessageReadStatusUnRead)];
}

- (BOOL) updateAllUnreadMessageToReaded:(NSString*)accountUserId
{
    NSString* sql = [NSString updateSql:WizMessageTableNmae setFields:@[WizMessageColumnReadStatus] whereArray:@[WizMessageColumnReceiverId,WizMessageColumnReadStatus]];
    return [dataBase executeUpdate:sql,@(WizMessageReadStatusReaded),accountUserId,@(WizMessageReadStatusUnRead)];
}

- (BOOL) updateAllUnreadMessageToReaded:(NSString*)accountUserId SenderGroupKbGuid:(NSString*)kbguid messageType:(WizMessageType)messageType
{
    BOOL succeed = NO;
    if ((!kbguid || [kbguid isEqualToString:@""]) && messageType == WizMessageTypeAllType) {
        succeed = [self updateAllUnreadMessageToReaded:accountUserId];
    }else if (!kbguid || [kbguid isEqualToString:@""]) {
        succeed = [self updateAllUnreadMessageToReaded:accountUserId messageType:messageType];
    }else if (messageType == WizMessageTypeAllType) {
        succeed = [self updateAllUnreadMessageToReaded:accountUserId SenderGroupKbGuid:kbguid];
    }else{
        NSString* sql = [NSString updateSql:WizMessageTableNmae setFields:@[WizMessageColumnReadStatus] whereArray:@[WizMessageColumnReceiverId,WizMessageColumnKbGuid,WizMessageColumnMessageType,WizMessageColumnReadStatus]];
        succeed = [dataBase executeUpdate:sql,@(WizMessageReadStatusReaded),accountUserId,kbguid,@(messageType),@(WizMessageReadStatusUnRead)];
    }
    if (succeed) {
        [[NSNotificationCenter defaultCenter] postNotificationName:WizMessageChangedMesssage object:nil userInfo:@{WizNotificationUserInfoAccountUserId:accountUserId}];
    }
    return succeed;
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
	return [self setMeta:WizTempMetaKeySyncVersion key:type value:verString];
}
- (int64_t) syncVersion:(NSString*)type
{
    NSString* verString = [self getMeta:WizTempMetaKeySyncVersion withKey:type];
    if (verString) {
        return [verString longLongValue];
    }
    return 0;
}

- (void) setSelectedMessageGroup:(NSString*)groupKbGuid forAccount:(NSString *)accountUserId
{
    NSString* key = WizSyncVersionKeyByUserId(accountUserId);
    [self setMeta:WizTempMetaKeySelectMessageGroup key:key value:groupKbGuid];
}
- (NSString*)getSelectedMessageGroupKbGuidForAccount:(NSString *)accountUserId
{
    NSString* key = WizSyncVersionKeyByUserId(accountUserId);
    return [self getMeta:WizTempMetaKeySelectMessageGroup withKey:key];
}

NSString* (^WizSyncVersionKeyByUserId)(NSString*)= ^(NSString* userId)
{
    NSDictionary* dic = [[WizSettings defaultSettings] accountAttributes:userId];
    return [WizMessageVersion stringByAppendingFormat:@"%@",[dic userGuid]];
};

- (int64_t) messageVersionForAccount:(NSString*)accountUserId
{
    NSString* keyString = WizSyncVersionKeyByUserId(accountUserId);
    return [self syncVersion:keyString];
}

- (BOOL) setMessageVesion:(int64_t)ver forAccount:(NSString*)accountUserId
{
    NSString* keyString = WizSyncVersionKeyByUserId(accountUserId);
    return [self setSyncVersion:keyString version:ver];
}


- (int64_t) messageCountOfWhereField:(NSString*)filed
{
    NSString* sql = [NSString stringWithFormat:@"select count(*) from %@ where %@",WizMessageTableNmae, filed];
    int64_t count = 0;
    FMResultSet* resutl = [dataBase executeQuery:sql];
    if ([resutl next]) {
        count = [resutl longLongIntForColumnIndex:0];
    }
    return count;
}
- (int64_t) messageTotalCountOfAccountUserId:(NSString*)userId
{
    return [self messageCountOfWhereField:[NSString stringWithFormat:@"%@='%@'",WizMessageColumnReceiverId,userId]];
}
- (int64_t) messageUnreadCountOfAccountUserId:(NSString*)userId type:(WizMessageType)type
{
    switch (type) {
        case WizMessageTypeAllType:
            return [self messageCountOfWhereField:[NSString stringWithFormat:@"%@='%@' and %@=%d",WizMessageColumnReceiverId,userId, WizMessageColumnReadStatus, WizMessageReadStatusUnRead]];
            break;
        case WizMessageTypeModifiedDocument:
        case WizMessageTypeNormalAt:
            return [self messageCountOfWhereField:[NSString stringWithFormat:@"%@='%@' and %@=%d and %@=%d",WizMessageColumnReceiverId,userId, WizMessageColumnMessageType,type, WizMessageColumnReadStatus, WizMessageReadStatusUnRead]];
            break;
            
        default:
            return 0;
            break;
    }
}

- (int64_t) messageUnreadCountOfAccountUserId:(NSString*)userId kbguid:(NSString*)kbguid type:(WizMessageType)type
{
    switch (type) {
        case WizMessageTypeAllType:
            return [self messageCountOfWhereField:[NSString stringWithFormat:@"%@='%@' and %@='%@' and %@=%d",WizMessageColumnReceiverId,userId,WizMessageColumnKbGuid,kbguid, WizMessageColumnReadStatus, WizMessageReadStatusUnRead]];
            break;
        case WizMessageTypeModifiedDocument:
        case WizMessageTypeNormalAt:
            return [self messageCountOfWhereField:[NSString stringWithFormat:@"%@='%@' and %@='%@' and %@=%d and %@=%d",WizMessageColumnReceiverId,userId,WizMessageColumnKbGuid,kbguid, WizMessageColumnReadStatus, type, WizMessageColumnReadStatus, WizMessageReadStatusUnRead]];
            break;
            break;
            
        default:
            return 0;
            break;
    }
}
NSString* (^WizUnreadCountMessageKeyUserIdType)(NSString*,WizMessageType) = ^(NSString*userId, WizMessageType type){
    return [NSString stringWithFormat:@"messageCount %@ %d",userId,type];
};

NSString* (^WizUnreadCountMessageKeyUserIdKbguidType)(NSString*,NSString*, WizMessageType) = ^(NSString*userId, NSString* kbguid,WizMessageType type){
    return [NSString stringWithFormat:@"messageCount %@ %@%d",userId,kbguid,type];
};

- (NSSet*) allNotificatedKMByReciver:(NSString*)accountUserID
{
    NSString* sql = [NSString stringWithFormat:@"select distinct %@ from %@ where %@ = '%@'", WizMessageColumnKbGuid,  WizMessageTableNmae,WizMessageColumnReceiverId, accountUserID];
    FMResultSet* result = [dataBase executeQuery:sql];
    NSMutableSet* set = [NSMutableSet set];
    while ([result next]) {
        NSString* str = [result stringForColumn:WizMessageColumnKbGuid];
        if (str) {
            [set addObject:str];
        }
    }
    return set;
}


- (NSDictionary*) unreadCountDictionary:(NSString*)accountUserId
{
    NSMutableSet* typeSet = [NSMutableSet set];
    [typeSet addObject:@(WizMessageTypeAllType)];
    [typeSet addObject:@(WizMessageTypeModifiedDocument)];
    [typeSet addObject:@(WizMessageTypeNormalAt)];
    
    NSMutableDictionary* dic = [NSMutableDictionary new];
    for (NSNumber* each in typeSet) {
        WizMessageType type = [each integerValue];
        int64_t count = [self messageUnreadCountOfAccountUserId:accountUserId type:type];
        [dic setObject:@(count) forKey:WizUnreadCountMessageKeyUserIdType(accountUserId,type)];
    }
    NSSet* allKbguid = [self allNotificatedKMByReciver:accountUserId];
    for (NSString* kbguid in allKbguid ) {
        for (NSNumber* each in typeSet) {
            WizMessageType type = [each integerValue];
            int64_t count = [self messageUnreadCountOfAccountUserId:accountUserId kbguid:kbguid type:type];
            [dic setObject:@(count) forKey:WizUnreadCountMessageKeyUserIdKbguidType(accountUserId,kbguid,type)];
        }
    }
    return dic;
}
- (NSArray*) bizUsersByBizGuid:(NSString*)bizGuid
{
    return [self bizUsersFromFMResult:[dataBase executeQuery:[NSString selecteSql:WizBizUserTableName whereArray:@[WizBizUserBizGuid] decorate:nil], bizGuid]];
}

- (NSArray*) allBizUsers
{
    return [self bizUsersFromFMResult:[dataBase executeQuery:[NSString selecteSql:WizBizUserTableName whereArray:nil decorate:nil]]];
}
- (NSArray*) bizUsersFromFMResult:(FMResultSet*)reslt
{
    NSMutableArray* array = [NSMutableArray new];
    while ([reslt next]) {
        WizBizUser* user =[ WizBizUser new];
        user.userId = [reslt stringForColumn:WizBizUserID];
        user.guid = [reslt stringForColumn:WizBizUserGuid];
        user.aliasPinyin =[reslt stringForColumn:WizBizUserPinyin];
        user.alias = [reslt stringForColumn:WizBizUserALIAS];
        user.bizGuid = [reslt stringForColumn:WizBizUserBizGuid];
        [array addObject:user];
    }
    [reslt close];
    return array;
}

- (WizBizUser*) bizUserFromGuid:(NSString*)guid userBizGuid:(NSString*)userBizGuid
{
    NSString* sql = [NSString selecteSql:WizBizUserTableName whereArray:@[WizBizUserBizGuid,WizBizUserID] decorate:nil];
    FMResultSet* result = [dataBase executeQuery:sql, guid,userBizGuid];
    return [[self bizUsersFromFMResult:result] lastObject];
}

- (WizBizUser*) bizUserFromUserId:(NSString*)userId userBizGuid:(NSString*)userBizGuid
{
    NSString* sql = [NSString selecteSql:WizBizUserTableName whereArray:@[WizBizUserID,WizBizUserBizGuid] decorate:nil];
    FMResultSet* result = [dataBase executeQuery:sql, userId,userBizGuid];
    return [[self bizUsersFromFMResult:result] lastObject];
}


- (BOOL) isWizBizUserExists:(WizBizUser*)bizUser
{
//    if ([self bizUserFromGuid:bizUser.guid userBizGuid:bizUser.userId]) {
    if ([self bizUserFromGuid:bizUser.bizGuid userBizGuid:bizUser.userId]) {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL) deleteWizBizUser:(NSString*)kbguid{
    NSString *sql = [NSString deleteSql:WizBizUserTableName whereArray:@[WizBizUserBizGuid] decorate:nil];
    return [dataBase executeUpdate:sql,kbguid];
}

- (BOOL) updateWizBizUser:(WizBizUser *)bizUser
{
    if ([self isWizBizUserExists:bizUser]) {
        NSString* sql = [NSString updateSql:WizBizUserTableName setFields:@[WizBizUserALIAS, WizBizUserID, WizBizUserPinyin, WizBizUserBizGuid] whereArray:@[WizBizUserID]];
        return [dataBase executeUpdate:sql, bizUser.alias,
                bizUser.userId,
                bizUser.aliasPinyin,
                bizUser.bizGuid,
                bizUser.userId];
    }
    else
    {
        NSString* sql = [NSString insertSql:WizBizUserTableName columns:@[WizBizUserALIAS, WizBizUserGuid, WizBizUserID, WizBizUserPinyin,WizBizUserBizGuid]];
        return [dataBase executeUpdate:sql, bizUser.alias, bizUser.guid, bizUser.userId, bizUser.aliasPinyin, bizUser.bizGuid];
    }
   
    NSMutableDictionary* userInfo = [NSMutableDictionary new];
    [userInfo addBizUser:bizUser];
    [[NSNotificationCenter defaultCenter] postNotificationName:WizMessageWizBizUserModified object:nil userInfo:userInfo];

}

- (NSArray*) userTasksFromFMResult:(FMResultSet*)result
{
    NSMutableArray* array = [NSMutableArray array];
    while ([result next]) {
        WizUserTask* userTask = [[WizUserTask alloc] init];
        [userTask setValuesForKeysWithDictionary:[result resultDictionary]];
        [array addObject:userTask];
    }
    [result close];
    return array;
}

- (WizUserTask*) userTaskFromGuid:(NSString*)guid
{
    NSString* sql = [NSString selecteSql:WizUserTaskModelName  whereArray:@[WizUserTaskModelColumnGUID] decorate:nil];
    FMResultSet* result = [dataBase executeQuery:sql, guid];
    return [[self userTasksFromFMResult:result] lastObject];
}


- (WizUserTask*) userTaskFromDocumentGuid:(NSString*)guid
{
    NSString* sql = [NSString selecteSql:WizUserTaskModelName  whereArray:@[WizUserTaskModelColumnDocumentGuid] decorate:nil];
    FMResultSet* result = [dataBase executeQuery:sql, guid];
    return [[self userTasksFromFMResult:result] lastObject];
}

- (NSArray*) allUserTasksByAccountUserId:(NSString*)accountUserId
{
    NSString* sql = [NSString selecteSql:WizUserTaskModelName whereArray:@[WizUserTaskModelColumnAccountUserId] decorate:[NSString stringWithFormat:@"order by %@ desc limit 0, 400", WizUserTaskModelColumnDtCreated]];
    FMResultSet* result = [dataBase executeQuery:sql, accountUserId];
    return [self userTasksFromFMResult:result];
}
- (NSArray*) shotcutFromFMResult:(FMResultSet*)result
{
    NSMutableArray* array = [NSMutableArray array];
    while ([result next]) {
        WizShotCutInner* inner = [[WizShotCutInner alloc] init];
        [inner setValuesForKeysWithDictionary:[result resultDictionary]];
        [array addObject:inner];
    }
    [result close];
    return array;
}

- (BOOL) isShotCutExist:(WizShotCutInner*)shotcut
{
    NSString* sql = [NSString selecteSql:kWizShotcutTableName whereArray:@[kWizShotcutAccountUserId, kWizShotcutDocumentGuid, kWizShotcutGroupGuid] decorate:nil];
    NSString* groupguid = shotcut.groupGuid;
    if (!groupguid) {
        groupguid = WizGlobalPersonalKbguid;
    }
    FMResultSet* result = [dataBase executeQuery:sql, shotcut.accountUserId, shotcut.documentGuid, groupguid];
    NSArray* array = [self shotcutFromFMResult:result];
    return array.count?YES:NO;
}
- (BOOL) updateWizShotcut:(WizShotCutInner*)shotcut
{
    NSString* sql = nil;
    if ([self isShotCutExist:shotcut]) {
         sql = [NSString updateSql:kWizShotcutTableName setFields:@[kWizShotcutLocalChanged, kWizShotcutDateModified] whereArray:@[kWizShotcutAccountUserId, kWizShotcutDocumentGuid, kWizShotcutGroupGuid]];
    }
    else
    {
        sql = [NSString insertSql:kWizShotcutTableName columns:@[kWizShotcutLocalChanged,kWizShotcutDateModified ,kWizShotcutAccountUserId, kWizShotcutDocumentGuid, kWizShotcutGroupGuid]];
    }
    NSString* groupguid = shotcut.groupGuid;
    if (!groupguid) {
        groupguid = WizGlobalPersonalKbguid;
    }
    return  [dataBase executeUpdate:sql withArgumentsInArray:@[@(shotcut.localChanged), [[NSDate date]stringSql], shotcut.accountUserId, shotcut.documentGuid,groupguid]];
}
- (NSArray*) allShotCutOfAccountUserId:(NSString*)accountUserId
{
    NSString* sql = [NSString selecteSql:kWizShotcutTableName whereArray:@[kWizShotcutAccountUserId] decorate:[NSString stringWithFormat:@" order by %@ desc", kWizShotcutDateModified]];
    return [self shotcutFromFMResult:[dataBase executeQuery:sql, accountUserId]];
}

- (NSArray*) allShotCuts
{
    return [self shotcutFromFMResult:[dataBase executeQuery:[NSString selecteSql:kWizShotcutTableName whereArray:nil decorate:[NSString stringWithFormat:@" order by %@ desc", kWizShotcutDateModified]]]];
}
- (BOOL) deleteWizShotcut:(NSString*)accountUserId groupguid:(NSString*)groupguid documentGuid:(NSString*)documentGuid
{
    NSString* deleteSql = [NSString deleteSql:kWizShotcutTableName whereArray:@[kWizShotcutAccountUserId, kWizShotcutDocumentGuid, kWizShotcutGroupGuid] decorate:nil];
    if (!groupguid) {
        groupguid = WizGlobalPersonalKbguid;
    }
    return [dataBase executeUpdate:deleteSql withArgumentsInArray:@[accountUserId, documentGuid, groupguid]];
}


- (BOOL) isWizUserTaskExists:(NSString*)bizUserGuid
{
    if ([self userTaskFromGuid:bizUserGuid]) {
        return YES;
    }
    else
    {
        return NO;
    }
}
- (BOOL) updateWizUserTask:(WizUserTask *)usertask
{
    
    if ([self isWizUserTaskExists:usertask.guid]) {
        NSString* sql = [NSString updateSql:WizUserTaskModelName setFields:@[WizUserTaskModelColumnTitle, WizUserTaskModelColumnKbGuid,WizUserTaskModelColumnDtDeadline, WizUserTaskModelColumnDtCreated, WizUserTaskModelColumnDocumentGuid, WizUserTaskModelColumnBody, WizUserTaskModelColumnBizGuid, WizUserTaskModelColumnAccountUserId] whereArray:@[WizUserTaskModelColumnGUID]];
        return [dataBase executeUpdate:sql,
                usertask.title,
                usertask.kbguid,
                [usertask.dtDeadline stringSql],
                [usertask.dtCreated stringSql],
                usertask.documentGuid,
                usertask.body,
                usertask.bizGuid,
                usertask.accountUserId,
                usertask.guid];
    }
    else
    {
        NSString* sql = [NSString insertSql:WizUserTaskModelName columns:@[WizUserTaskModelColumnTitle, WizUserTaskModelColumnKbGuid,WizUserTaskModelColumnDtDeadline, WizUserTaskModelColumnDtCreated, WizUserTaskModelColumnDocumentGuid, WizUserTaskModelColumnBody, WizUserTaskModelColumnBizGuid, WizUserTaskModelColumnAccountUserId, WizUserTaskModelColumnGUID]];
        return [dataBase executeUpdate:sql,
                usertask.title,
                usertask.kbguid,
                [usertask.dtDeadline stringSql],
                [usertask.dtCreated stringSql],
                usertask.documentGuid,
                usertask.body,
                usertask.bizGuid,
                usertask.accountUserId,
                usertask.guid];
    }
}



@end
