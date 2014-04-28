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
@implementation WizTempDataBase

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
- (BOOL) isExistSearchByKey:(NSString*)keywords kbguid:(NSString*)kbguid
{
    FMResultSet* result = [dataBase executeQuery:@"select * from WIZ_SEARCH where KEYWORDS=? and KBGUID=?",keywords,kbguid];
    BOOL ret = NO;
    if ([result next]) {
        ret = YES;
    }
    [result close];
    return ret;
}

- (BOOL) updateWizSearch:(WizSearch *)search
{
    
    if ([self isExistSearchByKey:search.keyWords kbguid:search.kbguid]) {
        return [dataBase executeUpdate:@"update WIZ_SEARCH set COUNT=？, DATE=?, TYPE=? where KEYWORDS=? and KBGUID=?",[NSNumber numberWithInt:search.count],[search.dateSearched stringSql],[NSNumber numberWithInt:search.type],search.keyWords, search.kbguid];
    }
    else
    {
        return [dataBase executeUpdate:@"insert into WIZSEARCH (COUNT, DATE, TYPE, KEYWORDS, KBGUID) values(?,?,?,?,?)",[NSNumber numberWithInt:search.count],[search.dateSearched stringSql],[NSNumber numberWithInt:search.type],search.keyWords, search.kbguid];
    }
}
- (NSArray*) allSearchByKbguid:(NSString *)kbguid
{
    NSMutableArray* array = [NSMutableArray array];
    FMResultSet* result = [dataBase executeQuery:@"select * from WIZ_SEARCH where KBGUID=?",kbguid];
    while ([result next]) {
        WizSearch* search = [[WizSearch alloc] init];
        search.kbguid = kbguid;
        search.keyWords = [result stringForColumn:@"KEYWORDS"];
        search.count = [result intForColumn:@"COUNT"];
        search.type = [result intForColumn:@"TYPE"];
        search.dateSearched = [[result stringForColumn:@"DATE"] dateFromSqlTimeString];
        [array addObject:search];
    }
    [result close];
    return array;
}

//- (WizSearch*) searchDataFromDb:(NSString*)keywords
//{
//    __block WizSearch* search = nil;
//    [self.queue inDatabase:^(FMDatabase *db) {
//        FMResultSet* searchData = [db executeQuery:@"select SEARCH_NOTE_COUNT, SEARCH_EDIT_DATE,SEARCH_KEYWORDS, SEARCH_ISLOCAL from Wiz_Search where SEARCH_KEYWORDS = ?",keywords];
//        if ([searchData next]) {
//            WizSearch* search_ = [[WizSearch alloc] init];
//            search_.nNotesNumber = [searchData intForColumnIndex:0];
//            search_.searchDate = [searchData dateForColumnIndex:1];
//            search_.keyWords = [searchData stringForColumnIndex:2];
//            search_.isSearchLocal = [searchData boolForColumnIndex:3];
//            search = [search_ autorelease];
//        }
//     [searchData close];
//    }];
//    return search;
//}
//- (BOOL) updateWizSearch:(NSString *)keywords notesNumber:(NSInteger)notesNumber isSerchLocal:(BOOL)isSearchLocal
//{
//    __block BOOL isSuccess;
//    if ([self searchDataFromDb:keywords]) {
//        [self.queue inDatabase:^(FMDatabase *db) {
//            isSuccess = [db executeUpdate:@"update Wiz_Search set SEARCH_NOTE_COUNT=?, SEARCH_EDIT_DATE=?, SEARCH_ISLOCAL=? where SEARCH_KEYWORDS = ?",[NSNumber numberWithInteger:notesNumber], [[NSDate date] stringSql], [NSNumber numberWithBool:isSearchLocal], keywords];
//        }];
//    }
//    else
//    {
//        [self.queue inDatabase:^(FMDatabase *db) {
//            isSuccess = [db executeUpdate:@"insert into Wiz_Search (SEARCH_NOTE_COUNT, SEARCH_EDIT_DATE, SEARCH_ISLOCAL,SEARCH_KEYWORDS) values(?,?,?,?)",[NSNumber numberWithInteger:notesNumber], [[NSDate date] stringSql], [NSNumber numberWithBool:isSearchLocal], keywords];
//        }];
//    }
//    return isSuccess;
//}
//
- (BOOL) deleteWizSearch:(NSString *)keywords kbguid:(NSString *)kbguid
{
    return [dataBase executeUpdate:@"delete from Wiz_Search where SEARCH_KEYWORDS=? and KBGUID=?",keywords, kbguid];
}
//
//- (NSArray*) allWizSearchs
//{
//    __block NSMutableArray* allSearchs = [NSMutableArray array];
//    [self.queue inDatabase:^(FMDatabase *db) {
//        FMResultSet* searchDatas = [db executeQuery:@"select SEARCH_NOTE_COUNT, SEARCH_EDIT_DATE,SEARCH_KEYWORDS, SEARCH_ISLOCAL from Wiz_Search"];
//        while ([searchDatas next]) {
//            WizSearch* search_ = [[WizSearch alloc] init];
//            search_.nNotesNumber = [searchDatas intForColumnIndex:0];
//            search_.searchDate = [[searchDatas stringForColumnIndex:1] dateFromSqlTimeString];
//            search_.keyWords = [searchDatas stringForColumnIndex:2];
//            search_.isSearchLocal = [searchDatas boolForColumnIndex:3];
//            [allSearchs addObject:search_];
//            [search_ release];
//        }
//    }];
//    return allSearchs;
//}
@end
