//
//  WizCore.m
//  WizNote
//
//  Created by dzpqzb on 13-5-10.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizCore.h"
#import "WizFileManager.h"
#import "WizDBManager.h"
#import "WizSyncKb.h"
#import "WizTokenManger.h"
#import "DDAbstractDatabaseLogger.h"
#import "DDLog.h"

#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"

//experience_file_note_0_english
NSArray* (^WizIntroduceFilesPath)(void) = ^{
    
    int count  =2;
    NSString* languageKey = [WizGlobals localLanguageKey];
    if([languageKey hasPrefix:@"zh-"])
    {
        languageKey = @"chinese";
    }
    else if ([languageKey isEqualToString:@"english"])
    {
        languageKey = @"english";
    }
    else
    {
        languageKey = @"english";
    }
    NSString* namePrefix = @"experience_file_note";
    NSMutableArray* array = [NSMutableArray array];
    for(int i = 0 ; i < count ; ++i)
    {
        NSString* fileName  = [NSString stringWithFormat:@"%@_%d_%@",namePrefix,i, [languageKey lowercaseString]];
        NSString* path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"ziw"];
        if(path)
        {
            [array addObject:path];
        }
    }
    return array;
};

static NSString* const WizReportAccountUserId = @"iosreport@wiz.cn";
static NSString* const WizReportPassword = @"system32";
static NSString* const WizReportKbguid = @"9cb3dbd6-315b-4452-ad4f-69d276976fe0";

//
void UncaughtExceptionHandler(NSException *exception)
{
    [[NSNotificationCenter defaultCenter] postNotificationName:WizCrashHanppend  object:nil];
    NSArray *arr = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    
    NSString *urlStr = [NSString stringWithFormat:@"错误详情:%@,%@,%@, \n%@\n --------------------------\n%@\n>---------------------\n%@",
                        [[UIDevice currentDevice] systemName]
                        ,[[UIDevice currentDevice] systemVersion]
                        ,[WizGlobals wizNoteVersion], name,reason,[arr componentsJoinedByString:@"\n"]];
    DDSyncCLogError(@"%@",urlStr);
    [[WizSettings defaultSettings] setAppCrash:YES];
    
}


@implementation WizCore
+ (BOOL) deleteTag:(NSString*)tagGuid kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId
{
    id<WizInfoDatabaseDelegate> db = [WizDBManager getMetaDataBaseForKbguid:kbguid accountUserId:accountUserId];
    WizTag* tag = [db tagFromGuid:tagGuid];
    BOOL succeed = NO;
    if (tag) {
        NSArray* documents = [db documentsByTag:tagGuid];
        for (WizDocument* each in documents) {
            each.tagGuids = [each.tagGuids stringByReplacingOccurrencesOfString:tagGuid withString:@""];
            if (![db updateDocument:each]){
                return NO;
            }
        }
        if (![db deleteTag:tagGuid]){
            return NO;
        }
        if (![db addDeletedGUIDRecord:tagGuid type:WizObjectTypeTag]) {
            return NO;
        }
        succeed = YES;
    }
    NSArray* subTags = [db subTagsByParentGuid:tagGuid];
    if ([subTags count]){
        for (WizTag* each in subTags) {
            succeed = [self deleteTag:each.guid kbguid:kbguid accountUserId:accountUserId];
        }
    }
    return succeed;
}

+ (WizEditingDocument* ) handleURL:(NSURL*)openURL{
    
    NSError* error = nil;
    NSString* accountUserId = [[WizAccountManager defaultManager]activeAccountUserId];
    WizGroup* group = [[WizAccountManager defaultManager]groupFroKbguid:nil accountUserId:accountUserId];
    
    NSString* documentSourcePath;
    if (DEVICE_VERSION_BELOW_7) {
        documentSourcePath = [[[openURL absoluteString] substringFromIndex:24] URLDecodedString];
    }else{
        documentSourcePath = [[[openURL absoluteString] substringFromIndex:15] URLDecodedString];
    }
    NSString* documentMobileFilePath = [[WizFileManager shareManager] editingMobileFilePath:group.accountUserId kbguid:group.guid];
    NSString* documentIndexFilePath = [[WizFileManager shareManager] editingIndexFilePath:group.accountUserId kbguid:group.guid];
//    NSString* fileType = [[openURL absoluteString]fileType];
    WizEditingDocument* editingDoc = nil;
    editingDoc = [[WizEditingDocument alloc]init];
    editingDoc.guid = [WizGlobals genGUID];
    editingDoc.isNewNote = NO;
    editingDoc.title = [[[documentSourcePath fileName] componentsSeparatedByString:@"."]objectAtIndex:0];
    [editingDoc loadDefaultValue];
    NSString* documentString = @"<html><body></body><html>";
    if (![self writeFileTo:@[documentIndexFilePath,documentMobileFilePath] withContent:documentString error:&error]) {
        return nil;
    }
    if(![[WizSettings defaultSettings]setLastEditingDocument:editingDoc accountUserId:accountUserId kbguid:group.guid])
    {
        return nil;
    }
    
//    if ([self editableForFileType:fileType]) {
//        
//        if (![self writeFileTo:@[documentMobileFilePath,documentIndexFilePath] fromFileAtPath:documentSourcePath])
//        {
//            return nil;
//        }
//        if (![[WizFileManager shareManager] removeFile:documentSourcePath error:&error]) {
//            return nil;
//        }
//    }

    if (![self makeFileAsAttachmentAtPath:documentSourcePath ForGroup:group]) {
        return nil;
    }
    return editingDoc;
}

+ (BOOL) handleOpenURL:(NSURL*)openURL
{
    NSError* error = nil;
    NSString* accountUserId = [[WizAccountManager defaultManager]activeAccountUserId];
    WizGroup* group = [[WizAccountManager defaultManager]groupFroKbguid:nil accountUserId:accountUserId];
    NSString* documentSourcePath = [[[openURL absoluteString] substringFromIndex:24] URLDecodedString];    
    NSString* documentMobileFilePath = [[WizFileManager shareManager] editingMobileFilePath:group.accountUserId kbguid:group.guid];
    NSString* documentIndexFilePath = [[WizFileManager shareManager] editingIndexFilePath:group.accountUserId kbguid:group.guid];
    NSString* fileType = [[openURL absoluteString]fileType];
    if (![[WizSettings defaultSettings] lastEditingDocumentForAccountUserId:accountUserId kbguid:nil]) {
        WizEditingDocument* editingDoc = nil;
        editingDoc = [[WizEditingDocument alloc]init];
        editingDoc.guid = [WizGlobals genGUID];
        editingDoc.isNewNote = NO;
        editingDoc.title = [[[documentSourcePath fileName] componentsSeparatedByString:@"."]objectAtIndex:0];
        [editingDoc loadDefaultValue];
        NSString* documentString = @"<html><body></body><html>";
        if (![self writeFileTo:@[documentIndexFilePath,documentMobileFilePath] withContent:documentString error:&error]) {
            return NO;
        }
        if(![[WizSettings defaultSettings]setLastEditingDocument:editingDoc accountUserId:accountUserId kbguid:group.guid])
        {
            return NO;
        }
        if ([self editableForFileType:fileType]) {
            
            if (![self writeFileTo:@[documentMobileFilePath,documentIndexFilePath] fromFileAtPath:documentSourcePath])
            {
                return NO;
            }
            if (![[WizFileManager shareManager] removeFile:documentSourcePath error:&error]) {
                return NO;
            }
        }else if([WizGlobals checkAttachmentTypeIsImage:fileType]){
            NSString* documentIndexFileDirectory = [[WizFileManager shareManager] editingIndexFilesDirectoryPath:group.accountUserId kbguid:group.guid];
            NSString* imageName = [[WizGlobals genGUID] stringByAppendingFormat:@".%@",fileType];
            
            float defalutWidth = [[WizSettings defaultSettings] photoQulity];
            NSString* toPath = [documentIndexFileDirectory stringAppendingPath:imageName];
            UIImage* image = [UIImage imageWithContentsOfFile:documentSourcePath];
            [image compressedImageWidth:defalutWidth];
            NSData* imageData = UIImageJPEGRepresentation(image, 1.0);
            if (![imageData writeToFile:toPath options:NSDataWritingAtomic error:&error]) {
                return NO;
            }
            NSString* relativePath = [NSString stringWithFormat:@"index_files/%@",imageName];
            NSString* documentString = [NSString stringWithFormat:@"<html><body><img src=\"%@\" width=\"320\" height=\"320\" style=\"width: 300px; height: auto; \" class=\"\"></body><html>",relativePath];
            if (![self writeFileTo:@[documentIndexFilePath,documentMobileFilePath] withContent:documentString error:&error]) {
                return NO;
            }
            if (![[WizFileManager shareManager] removeFile:documentSourcePath error:&error]) {
                return NO;
            }
        }else{
            if (![self makeFileAsAttachmentAtPath:documentSourcePath ForGroup:group]) {
                return NO;
            }
        }
    }else{
        if (![self makeFileAsAttachmentAtPath:documentSourcePath ForGroup:group]) {
            return NO;
        }    }
//    if ([[[WizAccountManager defaultManager]activeKbGuid] isEqualToString:WizStrActiveKbGuidForSettings]) {
//        [[WizIPhoneRootViewController defaultRoot] dismissModalViewControllerAnimated:NO];
//    }
//    [[WizIPhoneRootViewController defaultRoot]selecteDefaultAccount];
    return YES;
}

+ (BOOL)writeFileTo:(NSArray*)paths fromFileAtPath:(NSString*)sourceFilePath
{
    NSError* error = nil;
    NSFileHandle* fromFileHandle = [NSFileHandle fileHandleForReadingAtPath:sourceFilePath];
    NSData* sourceData = [fromFileHandle readDataToEndOfFile];
    NSString* htmlString = [[NSString alloc]initWithData:sourceData encoding:NSUTF8StringEncoding];
    [fromFileHandle closeFile];
    return [self writeFileTo:paths withContent:htmlString error:&error];
}

+ (BOOL)writeFileTo:(NSArray*)paths withContent:(NSString*)contentString error:(NSError **)error
{
    for (NSString* toPath in paths) {
        for (NSString* toPath in paths) {
            if ([[WizFileManager shareManager]ensurePathExists:toPath]) {
                if(![contentString writeToFile:toPath useUtf8Bom:NO error:error])
                {
                    return NO;
                }
            }else{
                return NO;
            }
        }
    }
    return YES;
}

+ (BOOL)makeFileAsAttachmentAtPath:(NSString*)sourcePath ForGroup:(WizGroup*)group
{
    NSError* error = nil;
    WizEditingDocument* editingDoc = [[WizSettings defaultSettings]lastEditingDocumentForAccountUserId:group.accountUserId kbguid:group.guid];
    NSMutableArray* attachmentArray = editingDoc.addedAttachments;
    WizAttachment* attachment = [[WizAttachment alloc] init];
    attachment.guid = [WizGlobals genGUID];
    attachment.localChanged = WizEditAttachmentTypeChanged;
    attachment.dateModified = [NSDate date];
    attachment.title = [sourcePath fileName];
    attachment.detail = @"";
    attachment.serverChanged = NO;
    attachment.documentGuid = editingDoc.guid;
    [attachmentArray addObject:attachment];
    NSString* attachmentDirectory = [[WizFileManager shareManager] wizObjectDirectoryPath:attachment.guid accountUserId:group.accountUserId];
    NSString* attachmentPath = [attachmentDirectory stringByAppendingPathComponent:attachment.title];
    if (![[WizFileManager shareManager] moveItemAtPath:sourcePath toPath:attachmentPath error:&error]) {
        DDLogError(@"move attachment error %@  !",error);
        return NO;
    }
    NSString* zipFilePath = [[WizFileManager shareManager] createZipByPath:attachmentDirectory];
    if (zipFilePath) {
        attachment.dataMd5 = [WizGlobals fileMD5:zipFilePath];
        if (![[WizFileManager shareManager] removeItemAtPath:attachmentPath error:nil]) {
            DDLogError(@"delete attachment error %@",attachmentPath);
            return NO;
        }
    }else{
        return NO;
    }
    if (![[WizSettings defaultSettings]setLastEditingDocument:editingDoc addedAttachments:attachmentArray deletedAttachments:nil accountUserId:group.accountUserId kbguid:group.guid]) {
        return NO;
    }
    return YES;
}

+ (BOOL)editableForFileType:(NSString*)fileType
{
    if ([WizGlobals checkAttachmentTypeIsHtml:fileType]||[WizGlobals checkAttachmentTypeIsTxt:fileType]) {
        return YES;
    }
    return NO;
}

+ (void) initWizApp
{
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
//    [WizPurchaseManager shareInstance];
    NSString* str = [NSString stringWithFormat:@"%@active",[WizGlobals wizDeviceName]];
    WizLogAction(str);
    MULTIBACK(^{
        [WizFileManager clearTempDirectory];
    });
    [WizSyncCenter shareCenter];
    
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
   
    static DDFileLogger* fileLogger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fileLogger = [[DDFileLogger alloc] init];
        fileLogger.maximumFileSize = 1024* 1024;
        fileLogger.logFileManager.maximumNumberOfLogFiles = 1;
    });
    [DDLog addLogger:fileLogger];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        if ([[WizSettings defaultSettings] appCrash]) {
            NSArray* array = [fileLogger.logFileManager sortedLogFilePaths];
            for (NSString* filepPath in array) {
                NSMutableDictionary* dicionary = [NSMutableDictionary dictionaryWithCapacity:4];
                NSString* deviceName = [WizGlobals wizDeviceName];
                NSString* deiveVersion = [NSString stringWithFormat:@"%f", [WizGlobals WizDeviceVersion]];
                [dicionary setObject:[NSString stringWithFormat:@"Crash Report %@:%@",deviceName, deiveVersion] forKey:DataTypeUpdateDocumentTitle];
                if(![WizCore uploadFile:filepPath toAccountUserId:WizReportAccountUserId  password:WizReportPassword kbguid:WizReportKbguid attributes:dicionary])
                {
                }
            }
        }
        [[WizSettings defaultSettings] setAppCrash:NO];
    });
}

+ (BOOL) uploadFile:(NSString*)filePath toAccountUserId:(NSString*)accountUserId password:(NSString*)password kbguid:(NSString*)kbguid attributes:(NSDictionary*)attributes
{
    NSError* error = nil;
    NSString* fileType = [filePath fileType];
    
    WizDocument* document = [[WizDocument alloc] init];
    [document loadDefaultValue];
    [document updatePropertyFromDictionary: attributes];
    document.localChanged = WizEditDocumentTypeAllChanged;
    
    NSString* documentDir = [[WizFileManager shareManager] wizObjectDirectoryPath:document.guid accountUserId:accountUserId];
    NSString* documentAminPath = [documentDir stringByAppendingPathComponent:@"index.html"];
    if ([[fileType lowercaseString] isEqualToString:[@"txt" lowercaseString]]) {
    
         if(![[WizFileManager defaultManager] copyItemAtPath:filePath toPath:documentAminPath error:&error])
         {
             NSLog(@"%@",error);
             return NO;
         }
    }
    [[WizFileManager shareManager] createZipByPath:documentDir clean:YES];
   
    NSString* documentPath = [[WizFileManager shareManager] wizObjectFilePath:document.guid accountUserId:accountUserId];
    document.dataMd5 = [WizGlobals fileMD5:documentPath];
    
    WizTokenAndKapiurl* tokenUrl = [[WizTokenManger shareInstance] tokenUrlForAccountUserId:accountUserId password:password kbguid:kbguid error:&error];
    if (!tokenUrl) {
        return NO;
    }
    WizSyncKb* synckb = [[WizSyncKb alloc] initWithUrl:[NSURL URLWithString:tokenUrl.kApiUrl] token:tokenUrl.token kbguid:kbguid accountUserId:accountUserId dataBaser:nil isUploadOnly:NO userPrivilige:0 isPersonal:NO];
    //
    if (![synckb uploadDocument:document filePath:documentPath])
    {
        return NO;
    }
    [[WizFileManager shareManager] removeDirectory:documentDir error:&error];
    return YES;
}


+ (BOOL) deletedFolder:(NSString*)folder group:(WizGroup*)group
{
    id<WizInfoDatabaseDelegate> db = [WizDBManager getMetaDataBaseForKbguid:group.guid accountUserId:group.accountUserId];
    NSSet* allChild = [db childFoldersOf:folder];
    for (WizFolder* eachFolder in allChild) {
        @autoreleasepool {
            NSArray* documents = [db documentsByLocation:eachFolder.key];
            NSString* folderKey = eachFolder.key;
            if ([folderKey hasPrefix:@"/"]) {
                folderKey = [folderKey substringFromIndex:1];
            }
            for (WizDocument* document in documents) {
                document.location = [WizDeletedItemsKey stringByAppendingPathComponent:folderKey];
                document.dateModified = [NSDate date];
                document.localChanged = WizEditDocumentTypeInfoChanged;
                [db updateDocument:document];
            }
            eachFolder.localChanged = WizFolderEditTypeLocalDeleted;
            [db updateFolder:eachFolder];
        }
    }
    return YES;
}

+ (BOOL) wizReductionFolder:(NSString*)folder group:(WizGroup*)group
{
    id<WizInfoDatabaseDelegate> db = [WizDBManager getMetaDataBaseForKbguid:group.guid accountUserId:group.accountUserId];
    NSSet* allChild = [db childFoldersOf:folder];
    for (WizFolder* eachFolder in allChild) {
        @autoreleasepool {
            NSArray* documents = [db documentsByLocation:eachFolder.key];
            NSString* folderKey = eachFolder.key;
            if ([folderKey hasPrefix:WizDeletedItemsKey]) {
                folderKey = [folderKey substringFromIndex:WizDeletedItemsKey.length-1];
            }
            for (WizDocument* document in documents) {
                document.location =folderKey;
                document.dateModified = [NSDate date];
                document.localChanged = WizEditDocumentTypeInfoChanged;
                [db updateDocument:document];
            }
            eachFolder.localChanged = WizFolderEditTypeLocalDeleted;
            [db updateFolder:eachFolder];
            eachFolder.key = folderKey;
            eachFolder.localChanged = WizFolderEditTypeLocalCreate;
            [db updateFolder:eachFolder];
        }
    }
    return YES;
}

+ (BOOL) deleteDocument:(NSString*)documentGuid group:(WizGroup*)group
{
   id<WizInfoDatabaseDelegate> db = [WizDBManager getMetaDataBaseForKbguid:group.guid accountUserId:group.accountUserId];
    WizDocument* document = [db documentFromGUID:documentGuid];
    
    NSString* folderKey = [document.location copy];
    if ([folderKey hasPrefix:@"/"]) {
        folderKey = [folderKey substringFromIndex:1];
    }
    document.location = [WizDeletedItemsKey stringByAppendingPathComponent:folderKey];
    document.dateModified = [NSDate date];
    document.localChanged = WizEditDocumentTypeInfoChanged;
    [db updateDocument:document];
    return YES;

}

+ (BOOL) deleteDocumentForever:(NSString*)documentGuid group:(WizGroup*)group
{
    id<WizInfoDatabaseDelegate> db = [WizDBManager getMetaDataBaseForKbguid:group.guid accountUserId:group.accountUserId];
    [db deleteDocument:documentGuid];
    [db addDeletedGUIDRecord:documentGuid type:WizObjectTypeDocument];
    NSString* documentDir = [[WizFileManager shareManager] wizObjectDirectoryPath:documentGuid accountUserId:group.accountUserId];
    [[WizFileManager shareManager] removeDirectory:documentDir error:nil];
    
    NSArray* attachments = [db attachmentsByDocumentGUID:documentGuid];
    for (WizAttachment* eachAttach in attachments) {
        NSString* attachmentDir = [[WizFileManager shareManager]wizObjectDirectoryPath:eachAttach.guid accountUserId:group.accountUserId];
        [[WizFileManager shareManager]removeDirectory:attachmentDir error:nil];
    }
    return YES;
}

+ (BOOL) deleteFolderForever:(NSString *)folder group:(WizGroup *)group
{
    id<WizInfoDatabaseDelegate> db = [WizDBManager getMetaDataBaseForKbguid:group.guid accountUserId:group.accountUserId];
    NSSet* allChild = [db childFoldersOf:folder];
    for (WizFolder* eachFolder in allChild) {
        @autoreleasepool {
            NSArray* documents = [db documentsByLocation:eachFolder.key];
            for (WizDocument* document in documents) {
                [db deleteDocument:document.guid];
                [db addDeletedGUIDRecord:document.guid type:WizObjectTypeDocument];
                NSString* documentDir = [[WizFileManager shareManager] wizObjectDirectoryPath:document.guid accountUserId:group.accountUserId];
                [[WizFileManager shareManager] removeDirectory:documentDir error:nil];
            }
            eachFolder.localChanged = WizFolderEditTypeLocalDeleted;
            [db updateFolder:eachFolder];
        }
    }
    return YES;
}

+ (BOOL) addAttachmentFromZiw:(NSString*)filePath toAccountUserId:(NSString*)accountUserId kbguid:(NSString*)kbguid withAttachmentAttribute:(NSDictionary*)attributes
{
    WizAttachment* attachment = [[WizAttachment alloc] init];
    
    if (attachment) {
        [attachment setValuesForKeysWithDictionary:attributes];
    }
    attachment.guid = [WizGlobals genGUID];
    NSString* dataMd5 = [WizGlobals fileMD5:filePath];
    attachment.dataMd5 = dataMd5;
    if (!attachment.dateModified) {
        attachment.dateModified = [NSDate date];
    }
    attachment.localChanged = WizEditAttachmentTypeChanged;
    NSString* toDocumentPath = [[WizFileManager shareManager] wizObjectFilePath:attachment.guid accountUserId:accountUserId];
    NSError* error = nil;
    if (![[WizFileManager shareManager] copyItemAtPath:filePath toPath:toDocumentPath error:&error]) {
        DDLogError(@"move item error when create html file %@",error);
        return NO;
    }
    
    id<WizInfoDatabaseDelegate> db = [WizDBManager getMetaDataBaseForKbguid:kbguid accountUserId:accountUserId];
    return  [db updateAttachment:attachment];
}

//
+ (NSString*) addDocumentFromZiw:(NSString*)filePath toAccountUserId:(NSString*)accountUserId kbguid:(NSString*)kbguid withDocumentAttribute:(NSDictionary*)attributes
{
    WizDocument* document = [[WizDocument alloc] init];
    [document loadDefaultValue];
    document.localChanged = WizEditDocumentTypeAllChanged;
    document.title = [filePath fileName];
    document.serverChanged = NO;
    if (attributes) {
        [document updatePropertyFromDictionary:attributes];
    }
    document.ownerName = [[WizAccountManager defaultManager] activeAccountUserId];
    NSString* dataMd5 = [WizGlobals fileMD5:filePath];
    document.dataMd5 = dataMd5;
    
    NSString* toDocumentPath = [[WizFileManager shareManager] wizObjectFilePath:document.guid accountUserId:accountUserId];
    NSError* error = nil;
    if (![[WizFileManager shareManager] copyItemAtPath:filePath toPath:toDocumentPath error:&error]) {
        DDLogError(@"move item error when create html file %@",error);
        return nil;
    }
    
    id<WizInfoDatabaseDelegate> db = [WizDBManager getMetaDataBaseForKbguid:kbguid accountUserId:accountUserId];
    [db updateDocument:document];
    return document.guid;
}

+ (BOOL) addDocumentFromHtml:(NSString*)filePath toAccountUserId:(NSString*)accountUserId kbguid:(NSString*)kbguid
{
    
    WizDocument* document = [[WizDocument alloc] init];
    [document loadDefaultValue];
    document.localChanged = WizEditDocumentTypeInfoChanged;
    document.title = [filePath fileName];
    document.serverChanged = NO;
    
    NSString* tempGuid = [WizGlobals genGUID];
    NSString* tempPath = [[WizFileManager shareManager] wizObjectDirectoryPath:tempGuid accountUserId:accountUserId];
    NSString* toPath = [tempPath stringByAppendingPathComponent:@"index.html"];
    NSError* error = nil;
    if (![[WizFileManager shareManager] copyItemAtPath:filePath toPath:toPath error:&error]) {
        DDLogError(@"error %@",error);
        return NO;
    }
    NSString* ziwPath = [[WizFileManager shareManager] createZipByPath:tempPath];
    if(!ziwPath)
    {
        DDLogError(@"create ziw error when new html file");
        return NO;
    }
    else
    {
        if( [WizCore addDocumentFromZiw:ziwPath toAccountUserId:accountUserId kbguid:kbguid withDocumentAttribute:[document toWizServerObject]])
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }
}

+ (NSString*) introduceFileTitle:(NSString*)filePath
{
    NSString* name = [filePath fileName];
    if ([name indexOf:@"0"] != NSNotFound) {
        return  NSLocalizedString(@"Welcome to WizNote", nil);
    }
    else if ([name indexOf:@"1"] != NSNotFound)
    {
        return NSLocalizedString(@"Talk with your WizNote — Use WizNote public account in wechat", nil);
    }
    else
    {
        return WizStrNoTitle;
    }
}
+ (void) addIntroduceTags:(NSArray*)tagNames ToAccount:(NSString*)accountUserId kbguid:(NSString*)kbguid
{
    id<WizInfoDatabaseDelegate> db  = [WizDBManager getMetaDataBaseForKbguid:kbguid accountUserId:accountUserId];
    for (NSString* name in tagNames) {
        WizTag* tag = [[WizTag alloc] init];
        [tag loadDefaultValue];
        tag.title = name;
        tag.localChanged = 1;
        [db updateTag:tag];
    }
}

+ (void) addIntroduceTagsToAccount:(NSString*)accountUserId kbguid:(NSString*)kbguid
{
//    NSArray* tagNames = @[
//                          NSLocalizedString(@"Meeting", nil),
//                          NSLocalizedString(@"Journal", nil),
//                          NSLocalizedString(@"Photos", nil),
//                          NSLocalizedString(@"Peoples", nil)];
    NSArray* tagNames = @[NSLocalizedString(@"Todo", nil),
                          NSLocalizedString(@"Important", nil),
                          NSLocalizedString(@"Inspiration", nil)];
    [self addIntroduceTags:tagNames ToAccount:accountUserId kbguid:kbguid];
}

+ (void) addIntroduceFolders:(NSArray*)folders ToAccount:(NSString*)accountUserId kbguid:(NSString*)kbguid
{
    id<WizInfoDatabaseDelegate> db  = [WizDBManager getMetaDataBaseForKbguid:kbguid accountUserId:accountUserId];
    for (NSString* name in folders) {
        WizFolder* folder = [[WizFolder alloc] init];
        folder.key = name;
        folder.localChanged = WizFolderEditTypeLocalCreate;
        [db updateFolder:folder];
    }
}

+ (void) addIntroduceFoldersToAccount:(NSString*)accountUserId kbguid:(NSString*)kbguid
{
//    NSArray* folders = @[NSLocalizedString(@"/My Journals/", nil),
//                         NSLocalizedString(@"/Favorit Weibo/", nil),
//                         NSLocalizedString(@"/My Tasks/", nil),
//                         NSLocalizedString(@"/Collection/Learning/", nil),
//                         NSLocalizedString(@"/Collection/Work/", nil)];
    NSArray* folders = @[NSLocalizedString(@"/Work Notes/", nil),
                         NSLocalizedString(@"/Work Notes/Work Log/", nil),
                         NSLocalizedString(@"/Work Notes/Learning Materials/", nil),
                         NSLocalizedString(@"/Life Notes/", nil)
//                         ,NSLocalizedString(@"/My Notes/", nil)
                         ];
    [self addIntroduceFolders:folders ToAccount:accountUserId kbguid:kbguid];
    
}

+ (BOOL) addIntroduceDataToAccount:(NSString *)accountUserId kbguid:(NSString *)kbguid
{
    id<WizInfoDatabaseDelegate> db = [WizDBManager getMetaDataBaseForKbguid:kbguid accountUserId:accountUserId];
    if (![db isInsertedExperienceData]) {
        NSArray* introduceFiles = WizIntroduceFilesPath();
        for (NSString* filePath in introduceFiles)
        {
            NSString* title = [self introduceFileTitle:filePath];
            NSDictionary* attributes = @{DataTypeUpdateDocumentTitle: title};
            if (![WizCore addDocumentFromZiw:filePath toAccountUserId:accountUserId kbguid:nil withDocumentAttribute:attributes])
            {
                DDLogError(@"init introduce file error %@",filePath);
            }
        }
        [self addIntroduceFoldersToAccount:accountUserId kbguid:kbguid];
        [self addIntroduceTagsToAccount:accountUserId kbguid:kbguid];
        [db setInsertedExperienceData:YES];
    }
    return YES;
}


+ (BOOL) addIntroduceFolders:(NSArray*)folders tagNames:(NSArray*)tagNames toAccount:(NSString *)accountUserId kbguid:(NSString *)kbguid
{
    NSArray* introduceFiles = WizIntroduceFilesPath();
    for (NSString* filePath in introduceFiles)
    {
        NSString* title = [self introduceFileTitle:filePath];
        NSDictionary* attributes = @{DataTypeUpdateDocumentTitle: title};
        if (![WizCore addDocumentFromZiw:filePath toAccountUserId:accountUserId kbguid:nil withDocumentAttribute:attributes])
        {
            DDLogError(@"init introduce file error %@",filePath);
        }
    }
    [self addIntroduceFolders:folders ToAccount:accountUserId kbguid:kbguid];
    [self addIntroduceTags:tagNames ToAccount:accountUserId kbguid:kbguid];
    return YES;
}

+ (BOOL)markAllMessageReaded:(NSString *)accountUserId kbguid:(NSString *)kbguid messageType:(WizMessageType)messageType
{
    id<WizTemporaryDataBaseDelegate> dataBase = [WizDBManager temporaryDataBase];
    return [dataBase updateAllUnreadMessageToReaded:accountUserId SenderGroupKbGuid:kbguid messageType:messageType];
}

+ (void) saveAccount:(NSString *)accountUserId password:(NSString *)password{
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:accountUserId,@"accountUserId"
                         ,password, @"password",nil];
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"accountUserIdAndPassword"];
    BOOL b = [[NSUserDefaults standardUserDefaults] synchronize];
    if (!b) {
        [self saveAccount:accountUserId password:password];
    }
}

+ (NSDictionary *) accountIdAndPassword{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"accountUserIdAndPassword"];
    return dic;
}

+ (BOOL) newUserInfoFromKey:(NSString*) key{
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

+ (void)updateUserInfo:(NSString*)userId key:(NSString*) key value:(BOOL)isOK{
    NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:[NSString stringWithFormat:@"userid=%@",userId]] mutableCopy];
    if (!dic) {
        dic = [[NSMutableDictionary alloc] init];
    }
    [dic setValue:[NSNumber numberWithBool:isOK] forKey:key];
    
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:[NSString stringWithFormat:@"userid=%@",userId]];
    BOOL ok = [[NSUserDefaults standardUserDefaults] synchronize];
    if (!ok){
        [self updateUserInfo:userId key:key value:isOK];
    }
}

+ (BOOL) userInfo:(NSString*)userId key:(NSString*) key{
    NSMutableDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"userid=%@",userId]];
    return [[dic objectForKey:key] boolValue];
}

@end
