
//  WizNotificationCenter.m
//  WizIos
//
//  Created by dzpqzb on 12-12-21.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import "WizNotificationCenter.h"
#import "WizGlobalData.h"
#import "WizXmlServer.h"
#import "WizSyncStatueCenter.h"
#import <iostream>
#import <map>
#import <vector>
#import <objc/runtime.h>

static NSString* KeyOfUserInfoAudioStatus = @"KeyOfUserInfoAudioStatus";
static NSString* KeyOfUserInfoErrorData = @"KeyOfUserInfoErrorData";
static NSString* KeyOfUserInfoMessageDatas = @"KeyOfUserInfoMessageDatas";
//
static NSString* KeyOfUserInfoDocumentGuid = @"KeyOfUserInfoDocumentGuid";
static NSString* KeyOfUserInfoKbguid = @"KeyOfUserInfoKbguid";
static NSString* KeyOfUserInfoAccountUserId = @"KeyOfUserInfoAccountUserId";
//
static NSString* KeyOfUserInfoEventStatue = @"KeyOfUserInfoEventStatue";

static NSString* KeyOfUserInfoBizUser = @"KeyOfUserInfoBizUser";

static NSString* KeyOfUserInfoDocumentDisplayModel = @"KeyOfUserInfoDocumentDisplayModel";
//
static NSString* const kWizShotCutData = @"kWizShotCutData";
static NSString* const kWizModifiedShotcutType = @"kWizModifiedShotcutType";
@implementation NSMutableDictionary (WizNotificationUserInfo)

- (void) addShotcutModifiedType:(WizModifiedShotcutType)type
{
    [self setObject:@(type) forKey:kWizModifiedShotcutType];
}

- (void) addAudioStatus:(WizAudioStatus)status
{
    [self setObject:@(status) forKey:KeyOfUserInfoAudioStatus];
}
- (void) addShotcut:(WizShotCut *)shotcut
{
    if (shotcut) {
        [self setObject:shotcut forKey:kWizShotCutData];
    }
}
- (void) addBizUser:(WizBizUser *)user
{
    if (user) {
        [self setObject:user forKey:KeyOfUserInfoBizUser];
    }
}

- (void) addErrorData:(NSError *)error
{
    if (error) {
        [self setObject:error forKey:KeyOfUserInfoErrorData];
    }
}

- (void) addMessageDatas:(NSDictionary *)datas
{
    if (datas) {
        [self setObject:datas forKey:KeyOfUserInfoMessageDatas];
    }
}

- (void) addAccountUserId:(NSString *)accountUserId
{
    if (accountUserId) {
        [self setObject:accountUserId forKey:KeyOfUserInfoAccountUserId];
    }
}

- (void) addKbguid:(NSString *)kbguid
{
    if (kbguid) {
        [self setObject:kbguid forKey:KeyOfUserInfoKbguid];
    }
}

- (void) addDocumentGuid:(NSString *)documentGuid
{
    if (documentGuid) {
        [self setObject:documentGuid forKey:KeyOfUserInfoDocumentGuid];
    }
}

- (void) addEventStatue:(int)event
{
    [self setObject:@(event) forKey:KeyOfUserInfoEventStatue];
}

@end

@implementation NSDictionary (WizNotificationUserInfoParse)


- (int) userInfoEventStatue
{
    return [[self objectForKey:KeyOfUserInfoEventStatue] integerValue];
}
- (WizBizUser*) userInfoBizUser
{
    return  [self objectForKey:KeyOfUserInfoBizUser];
}
- (NSString*) userInfoAccountUserId
{
    return [self objectForKey:KeyOfUserInfoAccountUserId];
}

- (NSString*) userInfoDocumentGuid
{
    return [self objectForKey:KeyOfUserInfoDocumentGuid];
}

- (NSString*) userInfoKbguid
{
    return [self objectForKey:KeyOfUserInfoKbguid];
}

- (NSError*) userInfoErrorData
{
    return [self objectForKey:KeyOfUserInfoErrorData];
}

- (NSDictionary*) userInfoMessageDatas
{
    return [self objectForKey:KeyOfUserInfoMessageDatas];
}

- (WizAudioStatus) userInfoAudioStatus
{
    return (WizAudioStatus)[[self objectForKey:KeyOfUserInfoAudioStatus] intValue];
}

- (WizShotCut*) shotcut
{
    return [self objectForKey:kWizShotCutData];
}

- (WizModifiedShotcutType) modifiedShotcutType
{
    return (WizModifiedShotcutType)[self[kWizModifiedShotcutType] intValue];
}

@end

@interface WizWeakObject : NSObject
@property (nonatomic, weak) id object;
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



- (id) init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetSyncAccountMessage:) name:WizXmlSyncEventMessageTypeAccount object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetSyncKbMessage:) name:WizXmlSyncEventMessageTypeKbguid object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetDownloadMessage:) name:WizXmlSyncEventMessageTypeDownload object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetUploadMessage:) name:WizXmlSyncEventMessageTypeUpload object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetGenerateAbstractMessage:) name:WizGeneraterAbstractMessage object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetReflushDocumentCountMessage:) name:WizReflushDocumentCountInFolder object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didModifiedDocument:) name:WizModifiedDocumentMessage object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetSyncMessageMessage:) name:WizSyncWizMessageMessage object:nil];
        //
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetModifiedShotcutMessage:) name:kWizModifiedShotcutMessage object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetMessageChanged:) name:WizMessageChangedMesssage object:nil];
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetMessageUnreadCountChanged:) name:WizMessageCountChangedMessage object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetUserAvartMesssage:) name:WizMessageGetUserAvartImageMessage object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAudioStatusChange:) name:WizNotificationMessageAudioChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetModifiedBizUserMessage:) name:WizMessageWizBizUserModified object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetAutoDownloadMessage:) name:WizAutoDownloadMessage object:nil];
    }
    return self;
}

- (void) didGetModifiedShotcutMessage:(NSNotification*)nc
{
    NSDictionary* userInfo = [nc userInfo];
    WizShotCut* shotcut = [userInfo shotcut];
    NSString* accountUsrid= [userInfo userInfoAccountUserId];
    WizModifiedShotcutType type = [userInfo modifiedShotcutType];
    std::vector<id> array =*[self observerArray:kWizModifiedShotcutMessage];
    for (std::vector<id>::iterator itor = array.begin(); itor != array.end(); itor++) {
        WizWeakObject* obj = *itor;
        id observer = obj.object;
        switch (type) {
            case WizModifiedShotcutTypeAdd:
                SendSelectorToObjectInMainThreadWith2Params(@selector(didAddShotCut:accountUserId:), observer, shotcut, accountUsrid);
                break;
            case WizModifiedShotcutTypeRemove:
                SendSelectorToObjectInMainThreadWith2Params(@selector(didRemoveShotCut:accountUserId:), observer, shotcut, accountUsrid);
                break;
            default:
                break;
        }
    }
}

- (void) didGetModifiedBizUserMessage:(NSNotification*)nc
{
    NSDictionary* userInfo = [nc userInfo];
    WizBizUser* bizuser = [userInfo userInfoBizUser];
    
    std::vector<id> array =*[self observerArray:WizNotificationMessageAudioChanged];
    for (std::vector<id>::iterator itor = array.begin(); itor != array.end(); itor++) {
        WizWeakObject* obj = *itor;
        id observer = obj.object;
        SendSelectorToObjectInMainThread(@selector(didUpdateBizUser:), observer, bizuser);
    }
}

- (void) didAudioStatusChange:(NSNotification*)nc
{
    @synchronized(WizNotificationMessageAudioChanged)
    {
        NSDictionary* userInfo = [nc userInfo];
        WizAudioStatus status = [userInfo userInfoAudioStatus];
        NSString* filePath = [userInfo audioFilePath];
        NSDictionary* datas = [userInfo userInfoMessageDatas];
        NSError* error = [userInfo userInfoErrorData];
        std::vector<id> array =*[self observerArray:WizNotificationMessageAudioChanged];
        for (std::vector<id>::iterator itor = array.begin(); itor != array.end(); itor++) {
            WizWeakObject* object = *itor;
            id observer = object.object;
            switch (status) {
                case WizAudioStatusPlayEnd:
                    SendSelectorToObjectInMainThread(@selector(audioStatusDidChangedToPlayEnd:), observer,filePath);
                    break;
                case WizAudioStatusPlayStart:
                    SendSelectorToObjectInMainThread(@selector(audioStatusDidChangedToPlayStart:), observer, filePath);
                    break;
                case WizAudioStatusRecordEnd:
                    SendSelectorToObjectInMainThread(@selector(audioStatusDidChangedToRecordEnd:), observer, filePath);
                    break;
                case WizAudioStatusRecordFaild:
                    SendSelectorToObjectInMainThread(@selector(audioStatusDidChangedToRecordFaild:), observer, error);
                    break;
                case WizAudioStatusRecordUpdateDatas:
                    SendSelectorToObjectInMainThread(@selector(audioStatusDidChangedToRecordUpdateDatas:), observer, datas);
                    break;
                case WizAudioStatusRecordStart:
                    SendSelectorToObjectInMainThreadWithoutParams(@selector(audioStatusDidChangedToRecordStart), observer);
                    break;
                case WizAudioStatusPlayUpdateDatas:
                    SendSelectorToObjectInMainThread(@selector(audioStatusDidChangedToPalyUpdateDatas:), observer, datas);
                    break;
                default:
                    
                    break;
            }
        }
    }
}

- (void) didGetUserAvartMesssage:(NSNotification*)nc
{
    @synchronized(WizMessageGetUserAvartImageMessage)
    {
        NSDictionary* userInfo = [nc userInfo];
        NSString* userGuid = userInfo[@"user_guid"];
        UIImage* userAvart = userInfo[@"Avart"];
        if (!userGuid || !userAvart) {
            return;
        }
        std::vector<id> array =*[self observerArray:WizMessageGetUserAvartImageMessage];
        for (std::vector<id>::iterator itor = array.begin(); itor != array.end(); itor++) {
            WizWeakObject* object = *itor;
            id observer = object.object;
            SendSelectorToObjectInMainThreadWith2Params(@selector(didGetUserAvart:forUserGuid:),observer,userAvart, userGuid);
        }
    }
}


- (void) didGetMessageChanged:(NSNotification*)nc
{
    @synchronized(WizMessageChangedMesssage)
    {
        NSDictionary* userInfo = [nc userInfo];
        NSString* accountUserId = userInfo[WizNotificationUserInfoAccountUserId];
        NSString* messageId = userInfo[@"messageid"] ;
        //
        std::vector<id>  array = *[self observerArray:WizMessageChangedMesssage];
        for (std::vector<id>::iterator itor = array.begin(); itor != array.end(); itor++) {
            WizWeakObject* object = *itor;
            id observer = object.object;
            SendSelectorToObjectInMainThreadWith2Params(@selector(didMessageChange:accountUserId:),observer,messageId, accountUserId);
        }
    }
}


- (void) didGetMessageUnreadCountChanged:(NSNotification*)nc
{
    @synchronized(WizMessageCountChangedMessage)
    {
        NSDictionary* userInfo = [nc userInfo];
        NSString* accountUserId = userInfo[WizNotificationUserInfoAccountUserId];
        //
        std::vector<id>  array = *[self observerArray:WizMessageCountChangedMessage];
        for (std::vector<id>::iterator itor = array.begin(); itor != array.end(); itor++) {
            WizWeakObject* object = *itor;
            id observer = object.object;
            SendSelectorToObjectInMainThread(@selector(didWizMessageUnreadCountChanged:),observer,accountUserId);
        }
    }
}

- (void) didGetSyncMessageMessage:(NSNotification*)nc
{
    @synchronized(WizSyncWizMessageMessage)
    {
        NSDictionary* userInfo = [nc userInfo];
        NSString* accountUserId = userInfo[WizNotificationUserInfoAccountUserId];
        NSInteger statue = [userInfo[@"state"] integerValue];
        //
        std::vector<id>  array = *[self observerArray:WizSyncWizMessageMessage];
        for (std::vector<id>::iterator itor = array.begin(); itor != array.end(); itor++) {
            WizWeakObject* object = *itor;
            id observer = object.object;
            
            switch (statue) {
                case WizXmlSyncStateStart:
                    SendSelectorToObjectInMainThread(@selector(didSyncMessageStart:),observer,accountUserId);
                    break;
                case WizXmlSyncStateEnd:
                    SendSelectorToObjectInMainThread(@selector(didSyncMessageEnd:), observer,accountUserId);
                    break;
                case WizXmlSyncStateError:
                {
                    NSError* error = userInfo[@"error"];
                    SendSelectorToObjectInMainThreadWith2Params(@selector(didSyncMessageFaild:error:), observer, accountUserId, error);
                    break;
                }
                default:
                    break;
            }
        }
    }
}

- (void) didGetGenerateAbstractMessage:(NSNotification*)nc
{
    @synchronized(WizGeneraterAbstractMessage)
    {
        
        NSDictionary* userInfo = [nc userInfo];
        WizAbstract* abstract = [[nc userInfo] objectForKey:@"abstract"];
        NSString* kbguid = [userInfo userInfoKbguid];
        NSString* accountUserId = [userInfo userInfoAccountUserId];
        std::vector<id>  array = *[self observerArray:WizGeneraterAbstractMessage];
        for (std::vector<id>::iterator itor = array.begin(); itor != array.end(); itor++) {
            WizWeakObject* object = *itor;
            id observer = object.object;
            SendSelectorToObjectInMainThreadWith3Params(@selector(didGenerateAbstract:kbguid:accountUserId:),observer,abstract,kbguid,accountUserId);
        }
    }
}
- (void) didGetReflushDocumentCountMessage:(NSNotification*)nc
{
    @synchronized(WizReflushDocumentCountInFolder)
    {

        NSString* guid = [[nc userInfo] objectForKey:@"guid"];
        std::vector<id>  array = *[self observerArray:WizReflushDocumentCountInFolder];
        for (std::vector<id>::iterator itor = array.begin(); itor != array.end(); itor++) {
            WizWeakObject* object = *itor;
            id observer = object.object;
            SendSelectorToObjectInMainThread(@selector(willReflushDocumentCountForGroup:),observer,guid);
        }
    }
}


-(void)didGetUploadMessage:(NSNotification *)nc{
//    @synchronized(WizXmlSyncEventMessageTypeUpload)
//    {
//        NSDictionary* userInfo = [nc userInfo];
//        NSString* guid = userInfo[@"guid"];
//        NSString* kbguid = userInfo[WizNotificationUserInfoKbguid];
//        NSString* accountUserId = userInfo[WizNotificationUserInfoAccountUserId];
//        WizDocument* document = userInfo[@"document"];
//        int state = [userInfo userInfoEventStatue];
//        
//        [self change:guid state:state];
//        std::vector<id>  array = *[self observerArray:WizXmlSyncEventMessageTypeUpload];
//        for (std::vector<id>::iterator itor = array.begin(); itor != array.end(); itor++) {
//            WizWeakObject* object = *itor;
//            id each = object.object;
//            switch (state) {
//                case WizXmlSyncStateStart:
//                    SendSelectorToObjectInMainThread(@selector(didUploadStart:),each,guid);
//                    break;
//                case WizXmlSyncStateEnd:
//                {
//                    SendSelectorToObjectInMainThreadWith2Params(@selector(didUploadObject:withUserInfo:),each,guid,userInfo);
//                    SendSelectorToObjectInMainThreadWith3Params(@selector(didUploadSuccess:kbguid:accountUserId:),each,document,kbguid,accountUserId);
//                    break;
//                }
//                case WizXmlSyncStateError:
//                {
//                    NSError* error = userInfo[@"error"];
//                    SendSelectorToObjectInMainThreadWith2Params(@selector(didUploadFaild:error:),each,guid,error);
//                }
//                    break;
//                default:
//                    break;
//            }
//        }
//
//    }
}

- (void) didGetDownloadMessage:(NSNotification*)nc
{
    @synchronized(WizXmlSyncEventMessageTypeDownload)
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
    @synchronized(WizModifiedDocumentMessage)
    {
        NSDictionary* userInfo = [nc userInfo];
        int type = [userInfo[@"type"] integerValue];
        NSString* guid = userInfo[@"guid"];
        WizDocument* document = userInfo[@"document"];
        NSString* accountUserId = [userInfo objectForKey:WizNotificationUserInfoAccountUserId];
//        if (document) {
//            document = [document copy];
//        }
        
        NSString* kbguid = [userInfo objectForKey:WizNotificationUserInfoKbguid];
        std::vector<id>  array = *[self observerArray:WizModifiedDocumentMessage];
        
        
        for (std::vector<id>::iterator itor = array.begin(); itor != array.end(); itor++) {
            WizWeakObject* object = *itor;
            id each= object.object;
            
            switch (type) {
                case WizModifiedDocumentTypeDeleted:
                    SendSelectorToObjectInMainThreadWith3Params(@selector(didDeletedDocument:kbguid:accountUserId:),each,guid,kbguid,accountUserId);
                    break;
//                case WizModifiedDocumentTypeServerUpdate:
//                    SendSelectorToObjectInMainThreadWith3Params(@selector(didUpdateDocumentOnServer:kbguid:accountUserId:),each, document, kbguid,accountUserId);
//                    break;
                case WizModifiedDocumentTypeLocalInsert:
                    SendSelectorToObjectInMainThreadWith3Params(@selector(didInserteDocumentOnLocal:kbguid:accountUserId:),each, document, kbguid,accountUserId);
                    break;
                case WizModifiedDocumentTypeLocalUpdate:
                    SendSelectorToObjectInMainThreadWith3Params(@selector(didUpdateDocumentOnLocal:kbguid:accountUserId:),each, document, kbguid,accountUserId);
                    break;
                case WizModifiedDocumentsTypeServerInsert:
                    SendSelectorToObjectInMainThreadWith2Params(@selector(didInserteDocumentsOnServerKbguid:accountUserId:),each, kbguid,accountUserId);
                    break;
                case WizModifiedDocumentTypeDataReady:
//                    SendSelectorToObjectInMainThreadWith3Params(@selector(didDocumentDataReady:kbguid:accountUserId:),each,guid,kbguid,accountUserId);
                    break;
                case WizModifiedDocumentTypeDataDirty:
//                    SendSelectorToObjectInMainThreadWith3Params(@selector(didDocumentDataDirty:kbguid:accountUserId:),each,guid,kbguid,accountUserId);
                    break;
                default:
                    break;
            }
        }
    }
        
    
}



- (void) didGetSyncKbMessage:(NSNotification*)nc
{
    @synchronized(WizXmlSyncEventMessageTypeKbguid)
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
                        if (iPad) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"WizXmlSyncEventMessageTypeKbguid_SyncKbEnd" object:guid];
                        }else{
                            SendSelectorToObjectInMainThread(@selector(didSyncKbEnd:), each, guid);
                        }
                        
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
//                case WizXmlSyncStateDownloadDeletedList:
//                    SendSelectorToObjectInMainThread(@selector(didSyncKbDownloadDeletedGuids:),each,guid);
//                    break;
//                case WizXmlSyncStateDownloadAttachmentList:
//                    SendSelectorToObjectInMainThread(@selector(didSyncKbDownloadAttachmentsList:),each,guid);
//                    break;
//                    //
//                case WizXmlSyncStateWillDownloadAttachments:
//                    SendSelectorToObjectInMainThread(@selector(willSyncKbDownloadAttachmentsList:),each,guid);
//                    break;
//                case WizXmlSyncStateWillDownloadDocuments:
//                    SendSelectorToObjectInMainThread(@selector(willSyncKbDownloadDocuments:),each,guid);
//                    break;
//                case WizXmlSyncStateWillDownloadTags:
//                    SendSelectorToObjectInMainThread(@selector(willSyncKbDownloadTags:),each,guid);
//                    break;
//                case WizXmlSyncStateWillDownloadFolders:
//                    SendSelectorToObjectInMainThread(@selector(willSyncKbDownloadFolders:),each,guid);
//                    break;
//                case WizXmlSyncStateWillDownloadDeletedList:
//                    SendSelectorToObjectInMainThread(@selector(willSyncKbDownloadDelegatedGuids:),each,guid);
//                    break;
//                case WizXmlSyncStateWillUploadDocuments:
//                    SendSelectorToObjectInMainThread(@selector(willSyncKbUploadDocuments:),each,guid);
//                    break;
//                case WizXmlSyncStateWillUploadAttachments:
//                    SendSelectorToObjectInMainThread(@selector(willSyncKbUploadAttachments:),each,guid);
//                    break;
//                case WizXmlSyncStateWillUploadTagsList:
//                    SendSelectorToObjectInMainThread(@selector(willSyncKbUploadTags:),each,guid);
//                    break;
//                case WizXmlSyncStateWillUploadDeletedList:
//                    SendSelectorToObjectInMainThread(@selector(willSyncKbUploadDeletedList:),each,guid);
//                    break;
//                    //
//                case WizXmlSyncStateWillUploadAllChanges:
//                    SendSelectorToObjectInMainThread(@selector(willSyncKbUploadAllChanges:),each,guid);
//                    break;
//                case WizXmlSyncStateDidUploadAllChanges:
//                    SendSelectorToObjectInMainThread(@selector(didSyncKbUploadAllChanges:),each,guid);
//                    break;
                default:
                    break;
            }
        }
    }
}

- (void)didGetAutoDownloadMessage:(NSNotification*)nc
{
    @synchronized(WizAutoDownloadMessage){
        NSDictionary* userInfo = [nc userInfo];
        NSString* guid = userInfo[@"guid"];
        NSNumber* event = userInfo[@"event"];
        int state = [event integerValue];
        NSNumber* count = userInfo[KeyOfDownloadNotesCount];
        [self change:guid state:state];
        std::vector<id>  array = *[self observerArray:WizAutoDownloadMessage];
        for (std::vector<id>::iterator itor = array.begin(); itor != array.end(); itor++) {
            WizWeakObject* object = *itor;
            id each = object.object;
            switch (state) {
                case WizAutoDownloadThreadStateStart:
                    SendSelectorToObjectInMainThread(@selector(didBeginAutoDownload:),each,guid);
                    break;
                case WizAutoDownloadThreadStateEnd:
                    SendSelectorToObjectInMainThreadWith2Params(@selector(didEndAutoDownload:count:),each,guid,count);
                    break;
                default:
                    break;
            }
        }

    }
}

- (void) change:(NSString*)guid state:(int)event
{
    [[WizSyncStatueCenter shareInstance] changedKey:guid statue:event];
}

- (void) didGetSyncAccountMessage:(NSNotification*)nc
{
    @synchronized(WizXmlSyncEventMessageTypeAccount)
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
- (void) addUploadDelegate:(id<WizSyncUploadDelegate>)observer
{
    @synchronized(WizXmlSyncEventMessageTypeUpload)
    {
        [self addObserver:observer forMessage:WizXmlSyncEventMessageTypeUpload];
    }

}
- (void) addGenerateAbstractObserver:(id<WizGenerateAbstractDelegate>)observer
{
    @synchronized(WizGeneraterAbstractMessage)
    {
       [self addObserver:observer forMessage:WizGeneraterAbstractMessage]; 
    }
    
}
- (void) addReflushDocumentCountObserver:(id<WizReflushDocumentCountDelegate>)observer
{
    @synchronized(WizReflushDocumentCountInFolder)
    {
       [self addObserver:observer forMessage:WizReflushDocumentCountInFolder];
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

- (void) addMessageChangedObserver:(id<WizMessageChangedProtocol>)observer
{
    @synchronized(WizMessageChangedMesssage)
    {
        [self addObserver:observer forMessage:WizMessageChangedMesssage];
    }
}

- (void) addSyncWizMessageObserver:(id<WizMessageSyncProtocol>)observer
{
    @synchronized(WizSyncWizMessageMessage)
    {
        [self addObserver:observer forMessage:WizSyncWizMessageMessage];
    }
}

- (void) addUserAvartImageObserver:(id<WizSetUserAvartProtocol>)observer
{
    @synchronized(WizMessageGetUserAvartImageMessage)
    {
        [self addObserver:observer forMessage:WizMessageGetUserAvartImageMessage];
    }
}

- (void) addAudioStatusChangedObserver:(id<WizAudioStatusChangedProtocol>)observer
{
    @synchronized(WizNotificationMessageAudioChanged)
    {
        [self addObserver:observer forMessage:WizNotificationMessageAudioChanged];
    }
}

- (void) addBizUserModifiedObserver:(id<WizBizUserModifiedProtocol>)observer
{
    @synchronized(WizMessageWizBizUserModified)
    {
        [self addObserver:observer forMessage:WizMessageWizBizUserModified];
    }
}

- (void) addModifiedShotcutObserver:(id<WizModifiedShotcutProtocol>)observer
{
    @synchronized(kWizModifiedShotcutMessage)
    {
        [self addObserver:observer forMessage:kWizModifiedShotcutMessage];
    }
}
- (void) addMssageUnreadCountChangedObserver:(id<WizMessageCountChangeProtocol>)observer
{
    @synchronized(WizMessageCountChangedMessage)
    {
        [self addObserver:observer forMessage:WizMessageCountChangedMessage];
    }
}

- (void)addAutoDownloadObserver:(id<WizAutoDownloadDelegate>)observer
{
    @synchronized(WizAutoDownloadMessage)
    {
        [self addObserver:observer forMessage:WizAutoDownloadMessage];
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

+ (void) OnSyncMessageAccountUserId:(NSString*)accountUserId event:(int)event error:(NSError*)error
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:1];
    dic[WizNotificationUserInfoAccountUserId] = accountUserId;
    dic[@"state"]=@(event);
    if (error) {
        dic[@"error"] = error;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:WizSyncWizMessageMessage object:nil userInfo:dic];
}
@end
