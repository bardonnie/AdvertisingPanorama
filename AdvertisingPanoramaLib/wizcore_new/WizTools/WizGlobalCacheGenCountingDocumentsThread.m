//
//  WizGlobalCacheGenCountingDocumentsThread.m
//  WizNote
//
//  Created by dzpqzb on 13-7-12.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//
#import "WizGlobalCache.h"
#import "WizGlobalCacheGenCountingDocumentsThread.h"


//获取目录中的笔记条目
@implementation WizGlobalCacheGenCountingDocumentsThread

- (void) main
{
    while (true) {
        @autoreleasepool {
            WizCountWorkObject* obj = [[WizWorkQueue countingDocumentsQueue] workObject];
            if (obj != nil && [WizAccountManager defaultManager].activeKbGuid != nil) {
                if ([obj.kbguid isEqualToString:[WizAccountManager defaultManager].activeKbGuid]){
                    NSString* kbguid = [obj.kbguid isEqualToString:WizGlobalPersonalKbguid]?nil:obj.kbguid;
                    id<WizInfoDatabaseDelegate> db = [WizDBManager getMetaDataBaseForKbguid:kbguid accountUserId:obj.accountUserId];
                    NSDictionary *tagDic=[db tagDocCountWithCache:NO];
                    NSDictionary *folderDic=[db folderDocCountWithCache:NO];
                    [[WizGlobalCache shareInstance] setFolderCountDictionary:folderDic tagDic:tagDic kbguid:obj.kbguid accountUserId:obj.accountUserId];
                    [[WizWorkQueue countingDocumentsQueue] removeWorkObject:obj];
                } else {
//                [NSThread sleepForTimeInterval:0.5];
                    sleep(10);
                }
            } else {
//                [NSThread sleepForTimeInterval:0.5];
                sleep(3);
            }
        }
    }
}

@end
