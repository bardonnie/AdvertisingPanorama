//
//  WizNotificationCenter.m
//  WizIos
//
//  Created by dzpqzb on 12-12-21.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import "WizNotificationCenter.h"
#import "WizGlobalData.h"
#import "WizXmlServer.h"
#import "BWStatusBarOverlay.h"
#import "WizSyncStatueCenter.h"
#import <iostream>
#import <map>
#import <vector>
#import <objc/runtime.h>

@interface WizWeakObject : NSObject
@property (nonatomic, assign) id object;
@end
@implementation WizWeakObject
@synthesize object;
@end

NSString* const WizModifiedDocumentMessage = @"WizModifiedDocumentMessage";
NSString* const WizUpdateGroupdsMessage = @"WizUpdateGroupdsMessage";
@interface WizNotificationCenter()
{
    std::map<NSString*,std::vector<id> > observerDic;
}
@end
@implementation WizNotificationCenter

void (^SendSelectorToObjectInMainThread)(SEL selector, id observer, id params) = ^(SEL selector, id observer, id params){
    if([observer respondsToSelector:selector])
    {
        if([NSThread isMainThread])
        {
            [observer performSelector:selector withObject:params];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [observer performSelector:selector withObject:params];
            });
        }
    }
    
};

void (^SendSelectorToObjectInMainThreadWith2Params)(SEL selector, id observer, id params, id) = ^(SEL selector, id observer, id params1, id param2){
    if([observer respondsToSelector:selector])
    {
        if([NSThread isMainThread])
        {
            [observer performSelector:selector withObject:params1 withObject:param2];
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                 [observer performSelector:selector withObject:params1 withObject:param2];
            });
        }
    }
    
};

- (id) init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetSyncAccountMessage:) name:WizXmlSyncEventMessageTypeAccount object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetSyncKbMessage:) name:WizXmlSyncEventMessageTypeKbguid object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetDownloadMessage:) name:WizXmlSyncEventMessageTypeDownload object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetGenerateAbstractMessage:) name:WizGeneraterAbstractMessage object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didModifiedDocument:) name:WizModifiedDocumentMessage object:nil];
    }
    return self;
}
- (void) didGetGenerateAbstractMessage:(NSNotification*)nc
{
    @synchronized(self)
    {
    
        NSString* guid = [[nc userInfo] objectForKey:@"guid"];
        std::vector<id>  array = *[self observerArray:WizGeneraterAbstractMessage];
        for (std::vector<id>::iterator itor = array.begin(); itor != array.end(); itor++) {
            WizWeakObject* object = *itor;
            id observer = object.object;
            SendSelectorToObjectInMainThread(@selector(didGenerateAbstract:),observer,guid);
        }
    }
}
- (void) didGetDownloadMessage:(NSNotification*)nc
{
    @synchronized(self)
    {
        NSDictionary* userInfo = [nc userInfo];
        NSString* guid = userInfo[@"guid"];
        NSNumber* event = userInfo[@"event"];
        int state = [event integerValue];
        [self change:guid state:state];
        std::vector<id>  array = *[self observerArray:WizXmlSyncEventMessageTypeDownload];
        for (std::vector<id>::iterator itor = array.begin(); itor != array.end(); itor++) {
            WizWeakObject* object = *itor;
            id each = object.object;
            switch (state) {
                case WizXmlSyncStateStart:
                    SendSelectorToObjectInMainThread(@selector(didDownloadStart:),each,guid);
                    break;
                case WizXmlSyncStateEnd:
                {
                    SendSelectorToObjectInMainThreadWith2Params(@selector(didDownloadObject:withUserInfo:),each,guid,userInfo);
                    SendSelectorToObjectInMainThread(@selector(didDownloadEnd:),each,guid);
                    break;
                }
                case WizXmlSyncStateError:
                {
                    NSError* error = userInfo[@"error"];
                    SendSelectorToObjectInMainThreadWith2Params(@selector(didDownloadFaild:error:),each,guid,error);

                }
                    break;
                default:
                    break;
            }
        }
 
    }
}

- (std::vector<id>* const) observerArray:(NSString*)type
{
        std::map<NSString*,std::vector<id> >::iterator itor = observerDic.find(type);
        if (itor == observerDic.end()) {
            std::vector<id> array;
            observerDic[type] = array;
            itor = observerDic.insert(observerDic.begin(), std::map<NSString*, std::vector<id> >::value_type(type, array));
        }
        return &(itor->second);
}
+ (id) shareCenter
{
    static WizNotificationCenter* nocenter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        nocenter = [WizGlobalData shareInstanceFor:[WizNotificationCenter class]];
    });
    return nocenter;
}

- (void) sendUpdateGroupsNotification:(NSString*)accountUserId
{
    std::vector<id>  array = *[self observerArray:WizUpdateGroupdsMessage];
    for (std::vector<id>::iterator itor = array.begin(); itor != array.end(); itor++) {
        WizWeakObject* object = *itor;
        id each= object.object;
        SendSelectorToObjectInMainThread(@selector(didUpdateGroups:),each,accountUserId);
    }

}

- (void) didModifiedDocument:(NSNotification*)nc
{
        NSDictionary* userInfo = [nc userInfo];
        int type = [userInfo[@"type"] integerValue];
        NSString* guid = userInfo[@"guid"];
        std::vector<id>  array = *[self observerArray:WizModifiedDocumentMessage];
        for (std::vector<id>::iterator itor = array.begin(); itor != array.end(); itor++) {
            WizWeakObject* object = *itor;
            id each= object.object;
            
            switch (type) {
                case WizModifiedDocumentTypeDeleted:
                    SendSelectorToObjectInMainThread(@selector(didDeletedDocument:),each,guid);
                    break;
                case WizModifiedDocumentTypeServerUpdate:
                    SendSelectorToObjectInMainThread(@selector(didUpdateDocumentOnServer:),each,guid);
                    break;
                case WizModifiedDocumentTypeLocalInsert:
                    SendSelectorToObjectInMainThread(@selector(didInserteDocumentOnLocal:),each,guid);
                    break;
                case WizModifiedDocumentTypeLocalUpdate:
                    SendSelectorToObjectInMainThread(@selector(didUpdateDocumentOnLocal:),each,guid);
                    break;
                case WizModifiedDocumentTypeServerInsert:
                    SendSelectorToObjectInMainThread(@selector(didInserteDocumentOnServer:),each,guid);
                    break;
                default:
                    break;
            }
        }
 
    
}

- (void) didGetSyncKbMessage:(NSNotification*)nc
{
        NSDictionary* userInfo = [nc userInfo];
        NSString* guid = userInfo[@"guid"];
        NSNumber* event = userInfo[@"event"];
        int state = [event integerValue];
        if (guid) {
            [self change:guid state:state];
        }
        NSNumber* process = userInfo[@"process"];
        float currentProcess;
        if (process == nil) {
            currentProcess = 0;
        }
        else
        {
            currentProcess = [process floatValue];
        }
        std::vector<id>  array = *[self observerArray:WizXmlSyncEventMessageTypeKbguid];
        for (std::vector<id>::iterator itor = array.begin(); itor != array.end(); itor++) {
            WizWeakObject* object = *itor;
            id each= object.object;
            switch (state) {
                case WizXmlSyncStateStart:
                    SendSelectorToObjectInMainThread(@selector(didSyncKbStart:), each, guid);
                    break;
                case WizXmlSyncStateEnd:
                {
                    NSNumber* process = userInfo[@"process"];
                    if ([process floatValue] == 2.0) {
                        SendSelectorToObjectInMainThread(@selector(didUploadEnd:),each,guid);
                    }
                    else
                    {
                        SendSelectorToObjectInMainThread(@selector(didSyncKbEnd:), each, guid);
                    }
                }
                    break;
                case WizXmlSyncStateError:
                {
                    NSError* error = userInfo[@"error"];
                    SendSelectorToObjectInMainThreadWith2Params(@selector(didSyncKbFaild:error:),each,guid,error);
                    break;
                }
                case WizXmlSyncStateDownloadTagList:
                    SendSelectorToObjectInMainThread(@selector(didSyncKbDownloadTags:),each,guid);
                    break;
                case WizXmlSyncStateDownloadDocumentListWithProcess:
                    
                    if ([each respondsToSelector:@selector(didSyncKbDownloadDocuments:process:)]) {
                        if ([NSThread isMainThread]) {
                            [each didSyncKbDownloadDocuments:guid process:currentProcess];
                        }
                        else
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [each didSyncKbDownloadDocuments:guid process:currentProcess];
                            });
                        }
                    }

                    break;
                case WizXmlSyncStateDownloadFolders:
                    SendSelectorToObjectInMainThread(@selector(didSyncKbDownloadFolders:),each, guid);
                    break;
                case WizXmlSyncStateDownloadDeletedList:
                    SendSelectorToObjectInMainThread(@selector(didSyncKbDownloadDeletedGuids:),each,guid);
                    break;
                case WizXmlSyncStateDownloadAttachmentList:
                    SendSelectorToObjectInMainThread(@selector(didSyncKbDownloadAttachmentsList:),each,guid);
                    break;
                default:
                    break;
            }
        }
        
 
}
- (void) change:(NSString*)guid state:(int)event
{
    [[WizSyncStatueCenter shareInstance] changedKey:guid statue:event];
}

- (void) didGetSyncAccountMessage:(NSNotification*)nc
{
        NSDictionary* userInfo = [nc userInfo];
        NSString* guid = userInfo[@"guid"];
        NSNumber* event = userInfo[@"event"];
        int state = [event integerValue];
        [self change:guid state:state];
        std::vector<id>  array = *[self observerArray:WizXmlSyncEventMessageTypeAccount];
        for (std::vector<id>::iterator itor = array.begin(); itor != array.end(); itor++) {
            WizWeakObject* object = *itor;
            id each = object.object;
            switch (state) {
                case WizXmlSyncStateStart:
                    SendSelectorToObjectInMainThread(@selector(didSyncAccountStart:),each,guid);
                    break;
                case WizXmlSyncStateEnd:
                    SendSelectorToObjectInMainThread(@selector(didSyncAccountSucceed:),each,guid);
                    break;
                case WizXmlSyncStateError:
                    SendSelectorToObjectInMainThread(@selector(didSyncAccountFaild:),each,guid);
                    break;
                default:
                    break;
            }
        }
}

- (void) removeObserver:(id)observer
{
        for (std::map<NSString*,std::vector<id> >::iterator itor = observerDic.begin(); itor != observerDic.end(); itor++) {
            for (std::vector<id>::iterator obItor = itor->second.begin();obItor != itor->second.end();) {
                WizWeakObject* weakObj = *obItor;
                if ([weakObj.object isEqual:observer]) {
                    obItor = itor->second.erase(obItor);
                }
                else
                {
                    obItor++;
                }
            }
            
        }
}

- (void) removeObserver:(id)observer forMessage:(NSString*)messageType
{
        std::map<NSString*,std::vector<id> >::iterator itor = observerDic.find(messageType);
        for (std::vector<id>::iterator i = itor->second.begin(); i != itor->second.end(); ){
            WizWeakObject* weakObj = *i;
            if ([weakObj.object isEqual:observer]) {
                i = itor->second.erase(i);
            }
            else
            {
                i++;
            }
        } 
}

- (void) removeDownloadObserver:(id)observer
{
    [self removeObserver:observer forMessage:WizXmlSyncEventMessageTypeDownload];
}

- (void) addObserver:(id)observer forMessage:(NSString*)messageType
{
        std::map<NSString*,std::vector<id> >::iterator itor = observerDic.find(messageType);
        if (itor == observerDic.end()) {
            std::vector<id> array;
            observerDic[messageType] = array;
            itor = observerDic.insert(observerDic.begin(), std::map<NSString*, std::vector<id> >::value_type(messageType, array));
        }
        for (std::vector<id>::iterator i = itor->second.begin(); i != itor->second.end(); i++) {
            WizWeakObject* weakObj = *i;
            if ([weakObj.object isEqual:observer]) {
                return;
            }
        }
        WizWeakObject* object = [[WizWeakObject alloc] init];
        object.object = observer;
        itor->second.push_back(object);
}

- (void) addSyncAccountObserver:(id<WizSyncAccountDelegate>)observer
{

    @synchronized(WizXmlSyncEventMessageTypeAccount)
    {
       [self addObserver:observer forMessage:WizXmlSyncEventMessageTypeAccount]; 
    }
    
}
- (void) addSyncKbObserver:(id<WizSyncKbDelegate>)observer
{
    @synchronized(WizXmlSyncEventMessageTypeKbguid)
    {
       [self addObserver:observer forMessage:WizXmlSyncEventMessageTypeKbguid]; 
    }
    
}

- (void) addDownloadDelegate:(id<WizSyncDownloadDelegate>)observer
{
    @synchronized(WizXmlSyncEventMessageTypeDownload)
    {
        [self addObserver:observer forMessage:WizXmlSyncEventMessageTypeDownload]; 
    }
   
}
- (void) addGenerateAbstractObserver:(id<WizGenerateAbstractDelegate>)observer
{
    @synchronized(WizGeneraterAbstractMessage)
    {
       [self addObserver:observer forMessage:WizGeneraterAbstractMessage]; 
    }
    
}

- (void) addModifiedDocumentObserver:(id<WizModifiedDcoumentDelegate>)observer
{
    @synchronized(WizModifiedDocumentMessage)
    {
        [self addObserver:observer forMessage:WizModifiedDocumentMessage]; 
    }
   
}

- (void) addGroupUpdateObserver:(id<WizGroupUpdateDelegate>)observer
{
    @synchronized(WizUpdateGroupdsMessage)
    {
        [self addObserver:observer forMessage:WizUpdateGroupdsMessage];
    }
}

+ (void) OnSyncState:(NSString *)guid event:(int)event messageType:(NSString *)messageType otherInfo:(NSDictionary*)dic
{
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    if (guid) {
        [userInfo setObject:guid forKey:@"guid"];
    }
    [userInfo setObject:[NSNumber numberWithInt:event] forKey:@"event"];
    [userInfo addEntriesFromDictionary:dic];
    [[NSNotificationCenter  defaultCenter] postNotificationName:messageType  object:nil userInfo:userInfo];
}

+ (void) OnSyncErrorStatue:(NSString*)guid messageType:(NSString*)messageType error:(NSError*)error
{
    if (guid == nil) {
        guid = WizGlobalPersonalKbguid;
    }
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    if (error) {
        [dic setObject:error forKey:@"error"];
    }
    [WizNotificationCenter OnSyncState:guid event:WizXmlSyncStateError messageType:messageType otherInfo:dic];
}


+ (void) OnSyncState:(NSString *)guid event:(int)event messageType:(NSString *)messageType  process:(float)process
{
    [WizNotificationCenter OnSyncState:guid event:event messageType:messageType otherInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:process] forKey:@"process"]];
}

+ (void) OnSyncKbState:(NSString*)kbguid event:(int)event process:(int)process
{
    [WizNotificationCenter OnSyncState:kbguid event:event messageType:WizXmlSyncEventMessageTypeKbguid process:process];
}

@end
