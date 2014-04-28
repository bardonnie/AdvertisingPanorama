//
//  FMDatabase+WizDb.m
//  WizIos
//
//  Created by dzpqzb on 12-12-20.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import "FMDatabase+WizDb.h"
#import "FMDatabase.h"
#import "NSString+WizString.h"
#import "FMDatabaseAdditions.h"
static NSString* const PRIMARAY_KEY = @"PRIMARAY_KEY";
@implementation FMDatabase (WizDb)

- (NSDictionary*) createTableModel:(NSDictionary*)data  tableName:(NSString*)tableName
{
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    NSMutableString* createTableSql = [NSMutableString stringWithFormat:@"CREATE TABLE %@ (", tableName];
    for (NSString* column in [data allKeys])
    {
        NSString* columnType = [data valueForKey:column];
        if ([column isEqualToString:PRIMARAY_KEY]) {
            continue;
        }
        NSString* columnSql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ %@;",tableName ,column, columnType];
        [dictionary setObject:columnSql forKey:column];
        [createTableSql appendFormat:@"%@ %@,", column, columnType];
    }
    NSString* primaryKey = [data valueForKey:PRIMARAY_KEY];
    if (!primaryKey) {
        int lastIndex = [createTableSql  lastIndexOf:@","];
        if (NSNotFound != lastIndex) {
            [createTableSql deleteCharactersInRange:NSMakeRange(lastIndex, 1)];
        }
        [createTableSql appendString:@")"];
    }
    else
    {
        [createTableSql appendFormat:@" primary key (%@));",primaryKey];
    }
    
    [dictionary setObject:createTableSql forKey:tableName];
    return dictionary;
}

- (NSDictionary*) getDataBaseStructFromFile:(NSString*)modelName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:modelName ofType:@"plist"];
    NSDictionary* dic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSMutableDictionary* ret = [NSMutableDictionary dictionary];
    for (NSString* table in [dic allKeys]) {
        [ret setObject:[self createTableModel:[dic valueForKey:table] tableName:table] forKey:table];
    }
    return ret;
}

- (BOOL) constructDataBaseModel:(NSString*)modelName
{
    NSDictionary* model = [self getDataBaseStructFromFile:modelName];
    for (NSString* tableName in [model allKeys])
    {
        NSString* table  = [tableName trim];
        NSDictionary*  conten = [model valueForKey:table];
        if ([self tableExists:table]) {
            for (NSString* columnName in [conten allKeys])
            {
                NSString* column = [columnName trim];
                if ([column isEqualToString:table])
                {
                    continue;
                }
                if (![self columnExists:column inTableWithName:table])
                {
                    if (![self executeUpdate:[conten valueForKey:columnName]])
                    {
                        return NO;
                    }
                }
            }
        }
        else
        {
            if (![self executeUpdate:[conten valueForKey:tableName]]) {
                return NO;
            } ;
        }
    }
    return YES;
}
@end
