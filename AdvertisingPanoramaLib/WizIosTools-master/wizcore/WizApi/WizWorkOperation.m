//
//  WizWorkOperation.m
//  WizNote
//
//  Created by dzpqzb on 13-4-17.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizWorkOperation.h"
#import "WizXmlKbServer.h"
#import "WizTokenManger.h"

#import "WizSyncKb.h"


@interface WizWorkOperation ()
{
}
@end

@implementation WizWorkOperation
@synthesize delegate= _delegate;
- (id) initWithDelegate:(id)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    return self;
}

- (void) sendMessageToDelegate:(NSDictionary*)dictionay
{
    if ([self.delegate respondsToSelector:@selector(onProcessWithMessage:)]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.delegate onProcessWithMessage:dictionay];
        });
    }
}

- (void) start
{
    @autoreleasepool {
        if (self.isCancelled) {
            return;
        }
        if ([self.delegate respondsToSelector:@selector(onStart)]) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate onStart];
            });
        }

        if ([self.delegate respondsToSelector:@selector(onWork)]) {
            NSError* error = [self.delegate onWork];
            if (self.isCancelled) {
                return;
            }
            if (!error) {
                if ([self.delegate respondsToSelector:@selector(onEnd)]) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self.delegate onEnd];
                    });
                }
            }
            else
            {
                if ([self.delegate respondsToSelector:@selector(onError:)]) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self.delegate onError:error];
                    });
                }
            }
        }
        if(self.isCancelled)
        {
                return ;
        }
    }
}

@end

@interface WizSearchAction () <WizWorkDelegate>
@property (nonatomic, strong) WizWorkOperation* workOperation;
@property (nonatomic, copy) NSString* keywords;
@end

@implementation WizSearchAction
@synthesize group = _group;
@synthesize delegate = _delegate;
@synthesize keywords = _keywords;
@synthesize type = _type;
- (id) initWithGroup:(WizGroup *)group delegate:(id<WizSearchActionDelegate>)delegate
{
    self = [super init];
    if (self) {
        _group = group;
        _delegate = delegate;
        _type = WizSearchTypeServer;
    }
    return self;
}
- (void) startSearch:(NSString*)keywords
{
    _keywords = keywords;
    if (self.workOperation) {
        [self.workOperation cancel];
        self.workOperation = nil;
    }
    self.workOperation = [[WizWorkOperation alloc] initWithDelegate:self];
    [[NSOperationQueue searchOperationQueue]  cancelAllOperations];
    [[NSOperationQueue searchOperationQueue] addOperation:self.workOperation];
}
- (void) onStart
{
    
}
- (NSError*) onWork
{
    if ([NSThread currentThread].isCancelled) {
        return nil;
    }
    id<WizInfoDatabaseDelegate> db = [WizDBManager getMetaDataBaseForKbguid:self.group.guid accountUserId:self.group.accountUserId];
    NSArray* array = [db documentsByKey:_keywords];
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.delegate didSearchLocalSucceed:array];
    });
    NSError* error = nil;
    if ([NSThread currentThread].isCancelled) {
        return nil;
    }
    WizTokenAndKapiurl* tokenUrl = [[WizTokenManger shareInstance] tokenUrlForAccountUserId:self.group.accountUserId kbguid:self.group.guid error:&error];
    if ([NSThread currentThread].isCancelled) {
        return nil;
    }
    if (error) {
        return error;
    }
    if (self.type == WizSearchTypeTitle) {
        return nil;
    }
    WizSyncKb* synckb = [[WizSyncKb alloc] initWithUrl:[NSURL URLWithString:tokenUrl.kApiUrl] token:tokenUrl.token kbguid:self.group.guid accountUserId:self.group.accountUserId dataBaser:db isUploadOnly:NO userPrivilige:self.group.userGroup isPersonal:NO];
    if ([NSThread currentThread].isCancelled) {
        return nil;
    }
    array = [synckb searchDocumentOnSearver:_keywords];
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.delegate didSearchOnServerSucceed:array];
    });
    return nil;
}
@end
