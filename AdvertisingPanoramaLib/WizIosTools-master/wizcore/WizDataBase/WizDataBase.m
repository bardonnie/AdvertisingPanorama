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
        if (![dataBase open]) {
            return nil;
        }
        NSString* path = [[NSBundle mainBundle] pathForResource:modelName ofType:@"plist"];
        NSString* md5 = [WizGlobals fileMD5:path];
        if (![[NSFileManager defaultManager] fileExistsAtPath:dbPath] || (![md5 isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:dbPath]])) {
            if ([dataBase constructDataBaseModel:modelName]) {
                [[NSUserDefaults standardUserDefaults] setObject:md5 forKey:dbPath];
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

- (int) currentVersion
{
    return 1;
}
@end
