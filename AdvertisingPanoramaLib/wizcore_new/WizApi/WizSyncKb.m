//
//  WizSyncKb.m
//  WizIos
//
//  Created by dzpqzb on 12-12-19.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import "WizSyncKb.h"
#import "WizXmlKbServer.h"
#import "WizObject.h"
#import "WizLogger.h"
#import "WizGlobals.h"
//
#import "WizWorkQueue.h"
#import "NSDate-Utilities.h"
#import "WizFileManager.h"
#import "WizNotificationCenter.h"
//
#import "WizWorkQueue.h"
#import "WizEnc.h"
#import "WizXmlAccountServer.h"
//
static float const WizSyncProgressDone = 1.0;

static int const WizDownloadListCount = 50;
static int const WizDownloadObjectSize = 100*1024;
static int const WizSyncUploadObjectSize = 128*1024;

static NSString* const WizFolderLocalVersion = @"WizFolderLocalVersion";


@interface WizSyncKb ()
{
    NSString* accountUserId;
    BOOL  isUploadOnly;
    int userPrivilige;
    BOOL isPersonalKb;
    NSString* localKbGuid;
    
}
@property (nonatomic, strong) WizGroup* group;
@end
@implementation WizSyncKb
@synthesize kbServer;
@synthesize kbDataBase;
@synthesize group = _group;
- (id) initWithUrl:(NSURL *)url token:(NSString *)token_ group:(WizGroup*)group_
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id) initWithUrl:(NSURL *)url
             token:(NSString *)token_
            kbguid:(NSString *)kbguid_
     accountUserId:(NSString *)accountUserId_
           dataBaser:(id<WizInfoDatabaseDelegate>)db 
      isUploadOnly:(BOOL)isUploadOnly_
     userPrivilige:(int)privilige
    isPersonal:(BOOL)isPersonal_
{
    self = [super init];
    if (self) {
        accountUserId = accountUserId_;
        _group = [[WizAccountManager defaultManager] groupFroKbguid:kbguid_ accountUserId:accountUserId];
        kbServer = [[WizXmlKbServer alloc] initWithUrl:url token:token_ kbguid:kbguid_];
        kbDataBase = db;
        isUploadOnly = isUploadOnly_;
        userPrivilige = privilige;
        isPersonalKb = isPersonal_;
        localKbGuid = kbguid_;
    }
    return self;
}

- (BOOL) getAllFolders
{
    [self sendMessage:WizXmlSyncStateWillDownloadFolders process:WizSyncProgressDone];
    int64_t version;
    if (![kbServer getKeyVersion:@"folders" version:&version]) {
        return NO;
    }
    int64_t localVersion = [kbDataBase syncVersion:WizFolderLocalVersion];
    if (localVersion >= version) {
        [self sendMessage:WizXmlSyncStateDownloadFolders process:WizSyncProgressDone];
        return YES;
    }
    
    WizServerObject* foldersServer = [[WizServerObject alloc] init];
    if (![kbServer getValue:foldersServer key:@"folders"]) {
        return NO;
    }
    
    NSMutableDictionary* serverFolderDic = [NSMutableDictionary dictionary];
    if ([foldersServer.data isKindOfClass:[NSString class]]) {
        NSString* fstr = (NSString*)foldersServer.data;
        NSArray* folderS = [fstr componentsSeparatedByString:@"*"];
        for (NSString* each in folderS) {
            if (![each isEqualToString:@""]) {
//                if ([each hasPrefix:@"/Deleted Items/"]) {
//                    continue;
//                }
               [serverFolderDic setObject:@0 forKey:each];
            }
        }
    }
    
    NSMutableDictionary* localFolderDic = [NSMutableDictionary dictionary];
    NSSet* set = [kbDataBase allFolders];
    NSEnumerator* itor = [set objectEnumerator];
    WizFolder* folder = nil;
    while (folder = [itor nextObject]) {
        [localFolderDic setObject:[NSNumber numberWithInt:folder.localChanged] forKey:folder.key];
    }
    
    for (NSString* sf in [serverFolderDic allKeys]) {
        NSNumber* changed = [localFolderDic objectForKey:sf];
        if (changed == nil) {
            WizFolder* folder = [[WizFolder alloc] init];
            folder.key = sf;
            folder.localChanged = WizFolderEditTypeNomal;
            [kbDataBase updateFolder:folder];
        }
        else
        {
            NSInteger changedType = [changed integerValue];
            if (changedType == WizFolderEditTypeLocalDeleted) {
                [kbDataBase deleteLocalFolder:sf];
            }
        }
    }
    NSArray* localAllKeys = [localFolderDic allKeys];
    for (NSString* localFolder in localAllKeys) {
        NSNumber* changed = [serverFolderDic objectForKey:localFolder];
        if (!changed) {
            NSNumber* localChanged = [localFolderDic objectForKey:localFolder];
            if (![localChanged isEqualToNumber:[NSNumber numberWithInt:WizFolderEditTypeLocalCreate]]) {
                [kbDataBase deleteLocalFolder:localFolder];
            }
        }
    }
    [kbDataBase setSyncVersion:WizFolderLocalVersion version:version];
    [self sendMessage:WizXmlSyncStateDownloadFolders process:WizSyncProgressDone];
    return YES;
}

- (BOOL) getAllValuesOfKey:(NSString*)key retObject:(WizServerObject*)retObject
{
    int64_t localVersion = [kbDataBase syncVersion:key];
    int64_t serverVersion = 0;
    if (![kbServer getKeyVersion:key version:&serverVersion]) {
        DDLogError(@"get key version %@",kbServer.lastError);
        return NO;
    }
    if (localVersion < serverVersion) {
        if (![kbServer getValue:retObject key:key]) {
            DDLogError(@"get key version %@",kbServer.lastError);
            return NO;
        }
    }
    return YES;
}

- (BOOL) getAllKMUsersList
{
    NSString* key = [NSString stringWithFormat:@"biz_users/%@",_group.bizGuid];
    WizServerObject* serverObject = [WizServerObject new];
    if (![self getAllValuesOfKey:key retObject:serverObject]) {
        return NO;
    }
    if (serverObject.data) {
    }
    return YES;
}
- (BOOL) updateDocuments:(NSArray*)documents
{
    if ([documents count] == 0) {
        return YES;
    }
    for (WizDocument* docServer in documents) {
        WizDocument* documentLocal = [kbDataBase documentFromGUID:docServer.guid];
        if (documentLocal == nil || ![documentLocal.dataMd5 isEqualToString:docServer.dataMd5]) {
            docServer.serverChanged = 1;
            docServer.localChanged = 0;
        }
        else
        {
            docServer.serverChanged = documentLocal.serverChanged;
            docServer.localChanged = documentLocal.localChanged;
        }
        [kbDataBase updateDocument:docServer];
    }
    [self sendMessageEditDocumentType:WizModifiedDocumentsTypeServerInsert];
    return YES;
}

- (void) sendMessageEditDocumentType:(int)type
{
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
    [userInfo setObject:[NSNumber numberWithInt:type] forKey:@"type"];
    if (kbServer.kbguid == nil || isPersonalKb) {
        [userInfo setObject:WizGlobalPersonalKbguid forKey:WizNotificationUserInfoKbguid];
    }else{
        [userInfo setObject:kbServer.kbguid forKey:WizNotificationUserInfoKbguid];
    }
    [userInfo setObject:accountUserId forKey:WizNotificationUserInfoAccountUserId];
    [[NSNotificationCenter defaultCenter] postNotificationName:WizModifiedDocumentMessage object:nil userInfo:userInfo];
}


- (BOOL) getAllDocuments:(int64_t)serverVersion
{
    int64_t localVersion = [kbDataBase documentVersion];
    if (localVersion < serverVersion) {
        [self sendMessage:WizXmlSyncStateWillDownloadDocuments process:WizSyncProgressDone];
    }
    else
    {
        return YES;
    }
    while (localVersion < serverVersion) {
        WizServerDocumentsArray* documentsArray = [[WizServerDocumentsArray alloc] init];
        if (![kbServer getDocumentsList:documentsArray first:localVersion+1 count:WizDownloadListCount]) {
            return NO;
        }
        [self updateDocuments:documentsArray.array];
        int64_t version = [documentsArray version];
        localVersion = version == 0? serverVersion : version;
        [kbDataBase setDocumentVersion:localVersion];
        [self sendMessage:WizXmlSyncStateDownloadDocumentListWithProcess process:(float)localVersion/(float)serverVersion];
    }
    [self sendMessage:WizXmlSyncStateDownloadDocumentList process:WizSyncProgressDone];
    [[WizSyncCenter shareCenter]startAutoDownloadForAccount:accountUserId];
    return YES;
}
- (BOOL) updateTags:(NSArray*)tags
{
    for (WizTag* tag in tags) {
        tag.localChanged = NO;
        [kbDataBase updateTag:tag];
    }
    return YES;
}
- (BOOL) getAllTags:(int64_t)serverVersion
{
    int64_t localVersion = [kbDataBase tagVersion];
    if (localVersion < serverVersion) {
        [self sendMessage:WizXmlSyncStateWillDownloadTags process:WizSyncProgressDone];
    }
    else
    {
        return YES;
    }
    while (localVersion < serverVersion) {
        WizServerTagsArray* tagsArray = [[WizServerTagsArray alloc] init];
        if (![kbServer getTagsList:tagsArray first:localVersion+1 count:WizDownloadListCount]) {
            return NO;
        }
        [self updateTags:tagsArray.array];
        int64_t version = [tagsArray version];
        localVersion = version == 0 ? serverVersion:version;
        [kbDataBase setTagVersion:localVersion];
    }
   [self sendMessage:WizXmlSyncStateDownloadTagList process:WizSyncProgressDone]; 
    return YES;
}

- (BOOL) updateLocalDeletedGuids:(NSArray*)array
{
    for (WizDeletedGuid* each in array) {
        if ([each.type isEqualToString:WizObjectTypeAttachment]) {
            [kbDataBase deleteAttachment:each.guid logDeleteRecord:NO];
        }
        else if ([each.type isEqualToString:WizObjectTypeDocument])
        {
            [kbDataBase deleteDocument:each.guid];
        }
        else if ([each.type isEqualToString:WizObjectTypeTag])
        {
            [kbDataBase deleteTag:each.guid];
        }
    }
    return YES;
}

- (BOOL) getAllDeletedGuids:(int64_t)serverVersion
{
    int64_t localVersion = [kbDataBase deletedGUIDVersion];
    if (isPersonalKb) {
        localVersion = 0;
    }
    if (localVersion < serverVersion) {
        [self sendMessage:WizXmlSyncStateWillDownloadDeletedList process:1.0];
    }
    else
    {
        return YES;
    }
    
    if ([kbDataBase documentCount] < 1) {
        [kbDataBase setDeletedGUIDVersion:serverVersion];
        return YES;
    }
    while (localVersion < serverVersion) {
        WizServerDeletedGuidsAarray* deletedGuidsArray = [[WizServerDeletedGuidsAarray alloc] init];
        if (![kbServer getDeletedGuidsList:deletedGuidsArray first:localVersion+1 count:WizDownloadListCount]) {
            return NO;
        }
        [self updateLocalDeletedGuids:deletedGuidsArray.array];
        int64_t version = [deletedGuidsArray version];
        localVersion = version ==0 ? serverVersion:version;
        [kbDataBase setDeletedGUIDVersion:localVersion];
    }
    [self sendMessage:WizXmlSyncStateDownloadDeletedList process:WizSyncProgressDone];
    return YES;
}
- (BOOL) updateAttachments:(NSArray*)attachments
{
    for (WizAttachment* attachment in attachments) {
        WizAttachment* localAttachment = [kbDataBase attachmentFromGUID:attachment.guid];
        if (localAttachment == nil || ![localAttachment.dataMd5 isEqualToString:attachment.dataMd5]) {
            attachment.serverChanged = 1;
            attachment.localChanged = 0;
        }
        [kbDataBase updateAttachment:attachment];
    }
    return YES;
}
- (BOOL) getAllAttachments:(int64_t)serverVersion
{
    int64_t localVersion = [kbDataBase attachmentVersion];
    if (localVersion < serverVersion) {
        [self sendMessage:WizXmlSyncStateWillDownloadAttachments process:1.0];
    }
    else
    {
        return YES;
    }
    while (localVersion < serverVersion) {
        WizServerAttachmentsArray* attachmentsArray = [[WizServerAttachmentsArray alloc] init];
        if (![kbServer getAttachmentsList:attachmentsArray first:localVersion+1 count:WizDownloadListCount]) {
            return NO;
        }
        [self updateAttachments:attachmentsArray.array];
        int64_t version = [attachmentsArray version];
        localVersion = version <=0 ? serverVersion:version;
        [kbDataBase setAttachmentVersion:localVersion];
    }
    [self sendMessage:WizXmlSyncStateDownloadAttachmentList process:1.0];
    return YES;
}

- (BOOL) postAllFolders
{
    if (![kbDataBase isLocalFolderDirty]) {
        return YES;
    }
    NSSet* set = [kbDataBase allFolders];
    NSString* value = [NSString string];
    NSMutableSet* allFlders = [NSMutableSet set];
    
    for (WizFolder* each in set) {
        if (each.localChanged != WizFolderEditTypeLocalDeleted) {
            [allFlders addObject:each.key];
        }
    }
    NSSet* documentFolders = [kbDataBase allLocationsForTree];
    for (NSString* each in documentFolders) {
        [allFlders addObject:each];
    }
    for (NSString* each in allFlders) {
        value = [value stringByAppendingFormat:@"%@*",each];
    }
    if ([value hasSuffix:@"*"]) {
        value = [value substringToIndex:value.length-1];
    }
    int64_t serverVersion = 0;
    if (![kbServer setServerValue:value forKey:@"folders" serverVersion:&serverVersion]) {
        return NO;
    }
    [kbDataBase setSyncVersion:WizFolderLocalVersion version:serverVersion];
//    [kbDataBase clearFolsersData];
    for (NSString* each in allFlders) {
        WizFolder* folder = [[WizFolder alloc] init];
        folder.key = each;
        folder.localChanged = WizFolderEditTypeNomal;
        [kbDataBase updateFolder:folder];
    }
    return YES;
}
- (BOOL) doSync
{
    if (isUploadOnly) {
        [self sendMessage:WizXmlSyncStateWillUploadAllChanges process:1.0];
    }
    if (![WizUserPrivilige canDownloadList:userPrivilige]) {
        return YES;
    }
    WizAllVersionData* data = [[WizAllVersionData alloc] init];
    if (![kbServer getAllVersion:data]) {
        return NO;
    }
    //
    if (kbServer.isStop) {
        return NO;
    }

    if ([WizUserPrivilige canUploadDeletedList:userPrivilige]) {
        if (![self uploadAllDeletedGuids]) {
            DDLogError(@"uploadAllDeletedGuids error ! %@",kbServer.kbguid);
            return NO;
        }
        //
        if (kbServer.isStop) {
            return NO;
        }
    }
    //
    if (![self getAllDeletedGuids:data.deletedGuidVersion]) {
        DDLogError(@"download deletdGuids error ! %@",kbServer.kbguid);
        return NO;
    }
    [self sendMessage:WizXmlSyncStateDownloadDeletedList process:1.0];
    //
    if (kbServer.isStop) {
        return NO;
    }
    if (isPersonalKb) {
        if (![self getAllFolders]) {
            return NO;
        }
        //
        if (kbServer.isStop) {
            return NO;
        }
    }
    //
    
    //
    if ([WizUserPrivilige canUploadTags:userPrivilige]) {
        if (![self uploadAllTags]) {
            DDLogError(@"upload all tags error ! %@",kbServer.kbguid);
            return NO;
        }
        //
        if (kbServer.isStop) {
            return NO;
        }
        //
    }
    if ([WizUserPrivilige canUploadDocuments:userPrivilige]) {
        
        if (![self uploadAllDocuments]) {
            DDLogError(@"upload all documents error ! %@",kbServer.kbguid);
            return NO;
        }
        //
        if (kbServer.isStop) {
            return NO;
        }
        //
        
        if (![self uploadAllAttachments]) {
            DDLogError(@"upload all attachments error ! %@",kbServer.kbguid);
            return NO;
        }
        //
        if (kbServer.isStop) {
            return NO;
        }
        //
    }
    
    if (isUploadOnly) {
        if (![self postAllFolders]) {
            return NO;
        }
        //
        if (kbServer.isStop) {
            return NO;
        }
        [self sendMessage:WizXmlSyncStateDidUploadAllChanges process:WizSyncProgressDone];
        return YES;
    }
    if (![self getAllTags:data.tagVersion]) {
        DDLogError(@"get all  tags error ! %@",kbServer.kbguid);
        return NO;
    }
    
    //
    if (kbServer.isStop) {
        return NO;
    }
    //
    if (![self getAllDocuments:data.documentVersion]) {
        DDLogError(@"get all documents error ! %@",kbServer.kbguid);
        return NO;
    }
    //
    if (kbServer.isStop) {
        return NO;
    }
    if (isPersonalKb) {
        if (![self postAllFolders]) {
            return NO;
        }
        //
        if (kbServer.isStop) {
            return NO;
        }
        //
    }
    if (![self getAllAttachments:data.attachmentVersion]) {
        DDLogError(@"get all attachments error ! %@",kbServer.kbguid);
        return NO;
    }
    //
    if (kbServer.isStop) {
        return NO;
    }
    //
    return YES;
}

- (void) sendMessage:(int)event process:(float)process
{
    NSString* kb = nil;
    if (isPersonalKb) {
        kb = WizGlobalPersonalKbguid;
    }
    else
    {
        kb = kbServer.kbguid;
    }
    if (event == WizXmlSyncStateError) {
        [WizNotificationCenter OnSyncErrorStatue:kb messageType:WizXmlSyncEventMessageTypeKbguid error:kbServer.lastError];
    }
    else
    {

        if (event == WizXmlSyncStateEnd) {
            if (isUploadOnly) {
                process = 2.0;
            }
            else
            {
                process = 1.0;
            }
        }
        [WizNotificationCenter OnSyncState:kb event:event messageType:WizXmlSyncEventMessageTypeKbguid process:process];
    }
}
- (BOOL) sync
{
    @autoreleasepool {
        [self sendMessage:WizXmlSyncStateStart process:0.0];
        if (![self doSync]) {
            [self sendMessage:WizXmlSyncStateError process:0.0];
            return NO;
        }
        [self sendMessage:WizXmlSyncStateEnd process:1.0];
    }
    return YES;
}




- (BOOL) downloadObject:(NSString*)objectGuid type:(NSString*)objType path:(NSString*)downloadToPath
{
    
    NSString* downloadTempPath = [[WizFileManager documentsPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.ziw",[WizGlobals genGUID]]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadTempPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:downloadTempPath error:nil];
    }
    if (![[NSFileManager defaultManager] createFileAtPath:downloadTempPath contents:nil attributes:nil])
    {
        DDLogError(@"can't create file %@",downloadTempPath);
        return  NO;
    }
    //
    NSFileHandle* fileHandler = [NSFileHandle fileHandleForWritingAtPath:downloadTempPath];
    [fileHandler seekToFileOffset:0];
    BOOL eof = NO;
    while(!eof)
    {
        @autoreleasepool {
            int64_t startPos = [fileHandler seekToEndOfFile];
            WizServerData* serverData = [[WizServerData alloc] init];
            if (![kbServer downloadWizObjectData:objectGuid objType:objType startPos:startPos requstSize:WizDownloadObjectSize retData:serverData]) {
                [fileHandler closeFile];
                [[NSFileManager defaultManager] removeItemAtPath:downloadTempPath error:nil];
                return NO;
            }
            NSData* dData = serverData.data;
            [fileHandler writeData:dData];
            eof = serverData.isEof;
        }
    }
    [fileHandler closeFile];
    //
    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadToPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:downloadToPath error:nil];
    }
    NSError* error = nil;
    if (![[NSFileManager defaultManager] moveItemAtPath:downloadTempPath toPath:downloadToPath error:&error]) {
        [[NSFileManager defaultManager] removeItemAtPath:downloadTempPath error:nil];
        DDLogError(@"download done but move file error %@",downloadToPath);
        return NO;
    }
    [[NSFileManager defaultManager] removeItemAtPath:downloadTempPath error:nil];
    //
    if ([WizGlobals fileLength:downloadTempPath] == 0) {
        NSLog(@"Download failed %@",downloadTempPath);
        return NO;
    }
    return YES;
}

- (BOOL) downloadDocument:(NSString*)documentGuid filePath:(NSString*)downloadFilePath
{
    if (![self downloadObject:documentGuid type:WizObjectTypeDocument path:downloadFilePath]) {
        DDLogError(@"download document data error ! %@", documentGuid);
        return NO;
    }
    [kbDataBase setDocumentServerChanged:documentGuid changed:NO];
    return YES;
}

- (BOOL) downloadAttachment:(NSString *)attachmentGuid filePath:(NSString *)downloadFilePath
{
    if (![self downloadObject:attachmentGuid type:WizObjectTypeAttachment path:downloadFilePath]) {
        DDLogError(@"download attachment data error ! %@", attachmentGuid);
        return NO;
    }
    [kbDataBase setAttachmentServerChanged:attachmentGuid changed:NO];
    return YES;
}


- (BOOL) uploadObject:(NSString*)objGuid type:(NSString*)objType filePath:(NSString*)uploadFilePath fileMd5:(NSString*)fileMd5
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:uploadFilePath]) {
        DDLogError(@"file not exist at %@", uploadFilePath);
        return NO;
    }
    
    //
    NSFileHandle* fileHandler = [NSFileHandle fileHandleForReadingAtPath:uploadFilePath];
    int64_t fileSize = [fileHandler seekToEndOfFile];
    if (fileSize == 0) {
        [fileHandler closeFile];
        return NO;
    }
    
    if (fileSize >= 30 * 1024 * 1024) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FileSizeLimit"];
        if (![[NSUserDefaults standardUserDefaults] synchronize]) {
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        return NO;
    }
    
    [fileHandler seekToFileOffset:0];
    //
    int64_t partCount = fileSize % WizSyncUploadObjectSize == 0 ? fileSize/WizSyncUploadObjectSize : fileSize/WizSyncUploadObjectSize +1;
    int64_t partSN = 0;
    bool hasNext = true;
    while (hasNext) {
        @autoreleasepool{
            NSData* data = [fileHandler readDataOfLength:WizSyncUploadObjectSize];
            int64_t currentPos = [fileHandler offsetInFile];
            if (currentPos == fileSize || data.length != WizSyncUploadObjectSize) {
                hasNext = false;
            }
            if (data.length != WizSyncUploadObjectSize) {
                partSN = partCount -1;
            }
            else
            {
                partSN = currentPos/WizSyncUploadObjectSize -1;
            }
            if (![kbServer postWizObjectData:data objSize:fileSize objDataMd5:fileMd5 objType:objType objGuid:objGuid partCount:partCount partSN:partSN]) {
                [fileHandler closeFile];
                DDLogError(@"upload error %@",kbServer.lastError);
                return NO;
            }
        }
    }
    [fileHandler closeFile];
    return YES;
}

- (BOOL) uploadDocument:(WizDocument*)doc filePath:(NSString*)filePath
{
    BOOL isWithData = NO;
    if (doc.localChanged == WizEditDocumentTypeAllChanged) {
        isWithData = YES;
        NSString* fileMd5 = [WizGlobals fileMD5:filePath];
        doc.dataMd5 = fileMd5;
        if (![self uploadObject:doc.guid type:WizObjectTypeDocument filePath:filePath fileMd5:fileMd5]) {
            DDLogError(@"upload document data error ");
            return NO;
        }
    }
    if (![kbServer postDocumentInfo:doc withData:isWithData]) {
        if (doc.localChanged == WizEditDocumentTypeInfoChanged) {
            doc.localChanged = WizEditDocumentTypeAllChanged;
            BOOL uploadAgain =[self uploadDocument:doc filePath:filePath];
            if (!uploadAgain) {
                return NO;
            }
        }
        else
        {
//            TODO wenlin 不定时bug。在修改笔记的群组位置之后笔记不能同步到服务器中
            DDLogError(@"post document info error %@ %@",doc.guid, doc.title);
            return NO;
        }
        
        
    }
    [kbDataBase setDocumentLocalChanged:doc.guid changed:WizEditDocumentTypeNoChanged];
    
    NSMutableDictionary* userInfo = [NSMutableDictionary new];
    
//    [userInfo addDocumentGuid:doc.guid];
    [userInfo setObject:doc forKey:@"document"];
    
//    [userInfo addAccountUserId:self.group.accountUserId];
    if (accountUserId) {
        [userInfo setObject:accountUserId forKey:WizNotificationUserInfoAccountUserId];
    }
    if (![self.group isPrivateKB]) {
        [userInfo setObject:localKbGuid forKey:WizNotificationUserInfoKbguid];
    }
    else
    {
//        [userInfo addKbguid:WizGlobalPersonalKbguid];
        [userInfo setObject:WizGlobalPersonalKbguid forKey:WizNotificationUserInfoKbguid];
    }
    //
    [WizNotificationCenter OnSyncState:doc.guid event:WizXmlSyncStateEnd messageType:WizXmlSyncEventMessageTypeUpload otherInfo:userInfo];
    return YES;
}

- (BOOL) uploadDocument:(WizDocument*)doc filePath:(NSString *)filePath serverQuery:(WizQuerayDocumentDictionay*)queryDic
{
    WizQueryDocument* serverDoc = [queryDic queryDocumentForGuid:doc.guid];
    if (serverDoc == nil) {
        return  [self uploadDocument:doc filePath:filePath];
    }
    else
    {
        if (![doc.dateModified isLaterThanDate:serverDoc.dtDataModified]) {
//            doc.guid = [WizGlobals genGUID];
//            NSString* desPath = [[WizFileManager shareManager] wizObjectFilePath:doc.guid accountUserId:accountUserId];
//            if (![[NSFileManager defaultManager] copyItemAtPath:filePath toPath:desPath error:nil]) {
//                DDLogError(@"copy file error when create complict copy file!");
//                return NO;
//            }
//            [kbDataBase updateDocument:doc];
            return  [self uploadDocument:doc filePath:filePath];
        }
        else
        {
            return  [self uploadDocument:doc filePath:filePath];
        }
    }
    

}

- (BOOL) uploadAllDocuments
{
    NSArray* uploadDocuments = [kbDataBase documentForUpload];
    if ([uploadDocuments count] == 0) {
        return YES;
    }
    [self sendMessage:WizXmlSyncStateWillUploadDocuments process:WizSyncProgressDone];
    NSMutableArray* guids = [NSMutableArray array];
    for (WizDocument* doc in uploadDocuments) {
        [guids addObject:doc.guid];
    }
    WizQuerayDocumentDictionay* docQueryDic = [[WizQuerayDocumentDictionay alloc] init];
    if (![kbServer downloadDocumentsQueryList:docQueryDic byGuids:guids]) {
        return NO;
    }
    for (WizDocument* doc in uploadDocuments) {
        NSString* filePath = [[WizFileManager shareManager] wizObjectFilePath:doc.guid accountUserId:accountUserId];;
        if (![self uploadDocument:doc filePath:filePath serverQuery:docQueryDic]) {
            if (kbServer.isStop) {
                return NO;
            }
            else
            {
                continue;
            }
        }
    }
    [self sendMessage:WizXmlSyncStateUploadDocument process:WizSyncProgressDone];
    return YES;
}


- (BOOL) uploadAttachment:(WizAttachment*)attachment filePath:(NSString*)filePath
{
    NSString* fileMd5 = [WizGlobals fileMD5:filePath];
    if (![self uploadObject:attachment.guid type:@"attachment" filePath:filePath fileMd5:fileMd5]) {
        if (attachment.serverChanged == YES && attachment.localChanged != 0) {
            [kbDataBase setAttachmentLocalChanged:attachment.guid changed:WizEditAttachmentTypeNoChanged];
        }
        DDLogError(@"upload attachment data error %@ %@",attachment.guid, attachment.title);
        return NO;
    }
    if (![kbServer postAttachmentInfo:attachment]) {
        DDLogError(@"upload attachment info error %@ %@",attachment.guid, attachment.title);
        return NO;
    }
    if (![kbDataBase setAttachmentLocalChanged:attachment.guid changed:WizEditAttachmentTypeNoChanged]) {
        DDLogError(@"set attachment localChanged error %@",attachment.guid);
        return NO;
    }
    return YES;
}

- (BOOL) uploadAttachment:(WizAttachment*)attachment filePath:(NSString*)filePath serverQuery:(WizQuerayAttachmentDictionay*)attachQueryDic
{
    return [self uploadAttachment:attachment filePath:filePath];
}

- (BOOL) uploadAllAttachments
{
    NSArray* uploadAttachments = [kbDataBase attachmentsForUpload];
    if ([uploadAttachments count] == 0) {
        return YES;
    }
    [self sendMessage:WizXmlSyncStateWillUploadAttachments process:WizSyncProgressDone];
    NSMutableArray* guids = [NSMutableArray array];
    for (WizAttachment* attach in uploadAttachments) {
        [guids addObject:attach.guid];
    }
    WizQuerayAttachmentDictionay* attachmentQueryDic = [[WizQuerayAttachmentDictionay alloc] init];
    if (![kbServer downloadAttachmentsQueryList:attachmentQueryDic byGuids:guids]) {
        return NO;
    }
    for (WizAttachment* attachment in uploadAttachments) {
        NSString* filePath = [[WizFileManager shareManager] wizObjectFilePath:attachment.guid accountUserId:accountUserId];
        if (![self uploadAttachment:attachment filePath:filePath serverQuery:attachmentQueryDic]) {
            if (kbServer.isStop) {
                return NO;
            }
            else
            {
                continue;
            }
        }
        
    }
    [self sendMessage:WizXmlSyncStateUploadAttachment process:WizSyncProgressDone];
    return YES;
}

- (BOOL) uploadAllDeletedGuids
{
    NSMutableArray* deletedGuids = [kbDataBase deletedGUIDsForUpload];
    if ([deletedGuids count] == 0) {
        return YES;
    }
   [self sendMessage:WizXmlSyncStateWillUploadDeletedList process:WizSyncProgressDone];
    while ([deletedGuids count]) {
        NSArray* subGuids = nil;
        if ([deletedGuids count] > 50) {
            subGuids = [deletedGuids subarrayWithRange:NSMakeRange(0, 50)];
        }
        else
        {
            subGuids = [deletedGuids copy];
        }
        if (![kbServer postDeletedGuidsList:subGuids]) {
            return NO;
        }
        else
        {
            [deletedGuids removeObjectsInArray:subGuids];
        }
    }
    [kbDataBase clearDeletedGUIDs];
    [self sendMessage:WizXmlSyncStateDownloadDeletedList process:WizSyncProgressDone];
    return YES;
}

- (BOOL) uploadAllTags
{
    NSArray* tags = [kbDataBase tagsForUpload];
    if ([tags count] == 0) {
        return YES;
    }
    [self sendMessage:WizXmlSyncStateWillUploadTagsList process:WizSyncProgressDone];
    if (![kbServer postTagList:tags]) {
        return NO;
    }
    else
    {
        for (WizTag* tag in tags) {
            if (![kbDataBase setTagLocalChanged:tag.guid changed:NO]) {
                DDLogError(@"set tag Localchanged error ! %@ %@",tag.guid,tag.title);
                return NO;
            }
        }
        [self sendMessage:WizXmlSyncStateUploadTagList process:WizSyncProgressDone];
        return YES;
    }
}

- (NSArray*) searchDocumentOnSearver:(NSString *)keyWords
{
    WizServerDocumentsArray* documents = [[WizServerDocumentsArray alloc] init];
    if (![kbServer getDocumentsListByKey:documents keywords:keyWords]) {
        return nil;
    }
    [self updateDocuments:documents.array];
    return documents.array;
}

- (BOOL) downloadDocumentInfo:(NSString*)guid document:(WizDocument*)document error:(NSError *__autoreleasing *)error
{
    BOOL succeed = [kbServer getDocumentData:guid info:YES param:YES retObject:document];
    if (succeed) {
        [self updateDocuments:@[document]];
    }
    else
    {
        if (error != NULL) {
            *error = kbServer.lastError;
        }
    }
    return succeed;
}

@end

