//
//  WizDataBase.m
//  WizIos
//
//  Created by dzpqzb on 12-12-20.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import "WizDataBase.h"
static int const WizMetaDataBaseVersion = 3;

@implementation WizDataBase

- (void) dealloc
{
    [dataBase closeOpenResultSets];
    [dataBase close];
}

- (id) initWithPath:(NSString *)dbPath modelName:(NSString *)modelName
{
    self = [super init];
    if (self) {
        dataBase = [[FMDatabase alloc] initWithPath:dbPath];
        BOOL willUpdateDbModel = [self shouldUpdateDatabaseModel:dbPath];
        if (![dataBase open]) {
            return nil;
        }
        
        if (willUpdateDbModel) {
            if ([dataBase constructDataBaseModel:modelName]) {
                [[NSUserDefaults standardUserDefaults] setInteger:self.currentVersion forKey:dbPath];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }
    return self;
}

- (BOOL) addColoumnByModelName:(NSString *)modelName
{
    return [dataBase constructDataBaseModel:modelName];
}

- (BOOL) shouldUpdateDatabaseModel:(NSString *)dbPath
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:dbPath]) {
        return YES;
    }
    else
    {
        int version = [[NSUserDefaults standardUserDefaults] integerForKey:dbPath];
        if (version != self.currentVersion) {
            return YES;
        }
        return NO;
    }
}
- (int) currentVersion
{
    return 1;
}
@end
