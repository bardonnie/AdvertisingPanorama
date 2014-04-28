//
//  WizSyncKbThread.m
//  WizIos
//
//  Created by dzpqzb on 12-12-20.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import "WizSyncKbThread.h"
#import "WizWorkQueue.h"
#import "WizSyncKb.h"
#import "WizSettings.h"
#import "WizTokenManger.h"
#import "WizNotificationCenter.h"
#import "WizGlocalError.h"
@interface WizSyncKbThread ()

@end

@implementation WizSyncKbThread

- (void) dealloc
{
    
}
- (void) main
{
        while (true) {
           @autoreleasepool { 
            WizSyncKbWorkObject* object = [[WizWorkQueue kbSyncWorkQueue] workObject];
            if (nil != object) {
                if (!object.token || !object.kApiUrl) {
                    NSError* error = nil;
                    WizTokenAndKapiurl* tokenUrl = [[WizTokenManger shareInstance] tokenUrlForAccountUserId:object.accountUserId kbguid:object.kbguid error:&error];
                    if (tokenUrl == nil) {
                        [WizNotificationCenter OnSyncErrorStatue:object.kbguid messageType:WizXmlSyncEventMessageTypeKbguid error:[WizGlocalError noNetWorkError]];
                        continue;
                    }
                    object.token = tokenUrl.token;
                    object.kApiUrl = tokenUrl.kApiUrl;
                    object.kbguid = tokenUrl.guid;
                }
                id<WizInfoDatabaseDelegate> db = nil;
                if (object.isPersonal) {
                    db = [WizDBManager getMetaDataBaseForKbguid:nil accountUserId:object.accountUserId];;
                }
                else
                {
                    db = [WizDBManager getMetaDataBaseForKbguid:object.kbguid accountUserId:object.accountUserId];
                }
                WizSyncKb* syncKb = [[WizSyncKb alloc] initWithUrl:[NSURL URLWithString:object.kApiUrl]token:object.token kbguid:object.kbguid accountUserId:object.accountUserId dataBaser:db isUploadOnly:object.isUploadOnly userPrivilige:object.userPrivilige isPersonal:object.isPersonal];
                if (![syncKb sync]) {
                    if (syncKb.kbServer.isStop) {
                        [[WizWorkQueue kbSyncWorkQueue] removeAllWorkObject];
                    }
                }
                
                [[WizWorkQueue kbSyncWorkQueue] removeWorkObject:object];
                
                if (object.isPersonal) {
                    [[WizSyncCenter shareCenter]autoDownloadDocumentByKbguid:nil accountUserId:object.accountUserId];
                    [[WizSettings defaultSettings] setLastUpdate:nil accountUserId:object.accountUserId];
                }
                else
                {
                    [[WizSyncCenter shareCenter]autoDownloadDocumentByKbguid:nil accountUserId:object.accountUserId];
                    [[WizSettings defaultSettings] setLastUpdate:object.kbguid accountUserId:object.accountUserId];
                }
            }
            else
            {
                [NSThread sleepForTimeInterval:0.5];
            }
        }
    }
}
@end


@interface WizSyncKbOperation : NSOperation
@property (nonatomic, strong) WizGroup* group;
@property (nonatomic, assign) BOOL isPersonal;
@property (nonatomic, assign) BOOL isUploadOnly;
@end

@implementation WizSyncKbOperation
@synthesize group = _group;
@synthesize isPersonal = _isPersonal;
@synthesize isUploadOnly = _isUploadOnly;

- (id) initWithGroup:(WizGroup*)group personal:(BOOL)ps uploadOnly:(BOOL)uo
{
    self = [super init];
    if (self) {
        _group = group;
        _isUploadOnly = uo;
        _isPersonal = ps;
    }
    return self;
}

- (void) main
{
    @autoreleasepool {
        
    }
}

@end
