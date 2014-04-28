//
//  WizDBManager.m
//  WizUIDesign
//
//  Created by dzpqzb on 13-1-13.
//  Copyright (c) 2013年 cn.wiz. All rights reserved.
//

#import "WizDBManager.h"
#import "WizFileManager.h"
#import "WizInfoDb.h"
#import "WizTempDataBase.h"
#import "WizGlobalData.h"

@interface WizDBManager ()
@property (nonatomic, strong) NSMutableArray* modelArray;

@end

@implementation WizDBManager
@synthesize modelArray= _array;
- (id) init
{
    self = [super init];
    if (self) {
        _array = [NSMutableArray array];
    }
    return self;
}
+ (id) shareInstance
{
    static WizDBManager* dbManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       dbManager = [WizGlobalData shareInstanceFor:[WizDBManager class]];
    });
    return dbManager;
}
+ (void) addAddtionModelName:(NSString *)name
{
    NSAssert(name, @"plist is null");
    [[[WizDBManager shareInstance] modelArray] addObject:name];
}
+ (id<WizInfoDatabaseDelegate>) getMetaDataBaseForKbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId
{
    NSString* dbPath = [[WizFileManager shareManager] metaDataBasePathForAccount:accountUserId kbGuid:kbguid];
    NSAssert(dbPath, @"dbPath is null");
    @synchronized(dbPath)
    {
        WizInfoDb* db = [[WizInfoDb alloc] initWithPath:dbPath modelName:@"WizDataBaseModel"];
        static NSMutableDictionary* dbModel = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dbModel = [NSMutableDictionary dictionary]; 
        });
        @synchronized(dbModel)
        {
            NSString* dbVersion = [dbModel objectForKey:dbPath];
            if (!dbVersion) {
                NSArray* array = [[[WizDBManager shareInstance] modelArray] copy];
                for (NSString* each in array) {
                    [db addColoumnByModelName:each];
                }
                [dbModel setObject:@"version" forKey:dbPath];
            }
        }
        return db;
    }
    
}

+ (id<WizTemporaryDataBaseDelegate>) temoraryDataBase
{
    NSString* dbPath = [[WizFileManager shareManager]  cacheDbPath];
    WizTempDataBase* temp = [[WizTempDataBase alloc] initWithPath:dbPath modelName:@"WizTempDataBaseModel"];
    return temp;
}
@end
