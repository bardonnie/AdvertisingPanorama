//
//  WizFileManger.m
//  Wiz
//
//  Created by MagicStudio on 12-4-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizFileManager.h"
#import "WizLogger.h"
#import "ZipArchive.h"
#import "WizGlobalError.h"
#import "WizGlobals.h"
#import "WizEnc.h"

#define ATTACHMENTTEMPFLITER @"attchmentTempFliter"
#define EditTempDirectory   @"EditTempDirectory"

static NSString* const WizLocalSaveFileName = @"temp.ziw";
static NSString* const WizDefaultKbguid = @"WizDefaultKbguid";




@implementation WizNewFileManager
@synthesize userPathDict_New_Old;

-(id)init {
    self = [super init];
    if (self){
        self.userPathDict_New_Old=[NSMutableDictionary dictionary];
    }
    return self;
}


- (NSString *)realFilePathOfUserId:(NSString *)accountUserId{
    
    NSString *path;
    @synchronized (self.userPathDict_New_Old) {
        path = [self.userPathDict_New_Old objectForKey:accountUserId];
    }
    if (path != nil)
        return path;

    NSString *guid = [[WizAccountManager defaultManager] userGuidByUserId:accountUserId];
    if (guid!=nil){
        path = [[WizAccountManager defaultManager] localFolderByGuid:guid];
        if (path != nil){
            @synchronized (self.userPathDict_New_Old) {
                [self.userPathDict_New_Old setObject:path forKey:accountUserId];
            }
            return path;
        }
    }

    path = accountUserId;
    [[WizAccountManager defaultManager] updateGuid:accountUserId toLocalFolder:path];
    @synchronized (self.userPathDict_New_Old) {
        [self.userPathDict_New_Old setObject:path forKey:accountUserId];
    }
    return path;
}

- (NSString*) accountPathFor:(NSString*)accountUserId{
    if (accountUserId==nil){
        return [super accountPathFor:accountUserId];
    }
    NSString *userId= [self realFilePathOfUserId:accountUserId];
    return [super accountPathFor:userId];
}
@end


@implementation WizFileManager
//singleton
+ (void) clearTempDirectory
{
     NSString* tempDirectory = NSTemporaryDirectory();
    NSError* error = nil;
    NSArray* array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tempDirectory error:&error];
    if (!error) {
        for (NSString* each in array) {
            NSString* path = [tempDirectory stringByAppendingPathComponent:each];
            if(! [[WizFileManager shareManager] removeDirectoryContent:path error:&error])
            {
                NSLog(@"error %@",error);
            }
            if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
                NSLog(@"error %@",error);
            }
        }
    }
}

+ (id) shareManager;
{
    static WizFileManager* shareManager = nil;
    @synchronized(self)
    {
        if (shareManager == nil) {
            shareManager = [[WizNewFileManager allocWithZone:NULL] init];//[[super allocWithZone:NULL] init];
        }
        return shareManager;
    }
}

+(NSString*) documentsPath
{
    static NSString* documentDirectory= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (nil == documentDirectory) {
            NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            documentDirectory = [paths objectAtIndex:0] ;
        }
    });
    
	return documentDirectory;
}
+ (NSString*) userUIDataPath
{
    static NSString* uiDataPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        uiDataPath = [[self documentsPath] stringByAppendingPathComponent:@"ui_data"];
        [[WizFileManager shareManager] ensurePathExists:uiDataPath];
    });
    return uiDataPath;
}
+ (NSString*) logFilePath
{
    static NSString* logFilePath = nil;
    if (logFilePath == nil) {
        logFilePath = [[WizFileManager documentsPath] stringByAppendingPathComponent:@"log.txt"] ;
    }
    return logFilePath;
}
-(BOOL) ensurePathExists:(NSString*)path
{
	BOOL b = YES;
    if (![self fileExistsAtPath:path])
	{
		NSError* err = nil;
		b = [self createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&err];
		if (!b)
		{
            //            DDLogError(err.description);
		}
	}
	return b;
}
- (BOOL) ensureFileExists:(NSString*)path
{
    if (![self fileExistsAtPath:path]) {
        return [self createFileAtPath:path contents:nil attributes:nil];
    }
    return YES;
}
- (NSString*) accountPathFor:(NSString*)accountUserId
{
    NSString* documentPath = [WizFileManager documentsPath];
    NSString* accountPath = [documentPath stringByAppendingPathComponent:accountUserId];
    [self ensurePathExists:accountPath];
    return accountPath;
}

- (NSString*) wizObjectDirectoryPath:(NSString*)objectGuid accountUserId:(NSString*)accountUserId
{
    NSString* accountPath = [self accountPathFor:accountUserId];
    NSString* objectPath = [accountPath stringByAppendingPathComponent:objectGuid];
    [self ensurePathExists:objectPath];
    return objectPath;
}
- (NSString*) wizObjectFilePath:(NSString *)objectGuid accountUserId:(NSString *)accountUserId
{
    NSString* objectPath = [self wizObjectDirectoryPath:objectGuid accountUserId:accountUserId];
    NSString* wizObjectFilePath = [objectPath stringByAppendingPathComponent:WizLocalSaveFileName];

//    if (![[NSFileManager defaultManager] fileExistsAtPath:wizObjectFilePath]) {
//        NSError* error = nil;
//        NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:objectPath error:&error];
//        if (contents && [contents count] && !error) {
//            [self createZipByPath:objectPath];
//            for (NSString* each in contents) {
//                if ([each isEqualToString:WizLocalSaveFileName]) {
//                    continue;
//                }
//                NSError* error = nil;
//                
//                if (![[NSFileManager defaultManager] removeItemAtPath:[objectPath stringByAppendingPathComponent:each] error:&error]) {
//                    DDLogError(@"delete file error %@-%@",objectPath,each);
//                }
//            }
//        }
//    }
    return wizObjectFilePath;
}

- (NSString*) documentIndexFilePath:(NSString *)documentGuid
{
    return [[self wizTempObjectDirectory:documentGuid] stringByAppendingPathComponent:DocumentFileIndexName];
}
- (NSString*) documentMobildeFilePath:(NSString *)documentGuid
{
    return [[self wizTempObjectDirectory:documentGuid] stringByAppendingPathComponent:DocumentFileMobileName];
}

+ (NSString*) userAvatarCacheDirectory
{
    static NSString* userAvatarCacheDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userAvatarCacheDirectory = [[WizFileManager documentsPath] stringByAppendingPathComponent:@"UserRoundAvart"];
        [[WizFileManager shareManager] ensurePathExists:userAvatarCacheDirectory];
        
    });
    return userAvatarCacheDirectory;
    
}

+ (NSString*) globalTempDirectory
{
    NSString* tempDirectory = NSTemporaryDirectory();
    [[WizFileManager shareManager] ensurePathExists:tempDirectory];
    return tempDirectory;
}

- (NSString*) wizTempObjectDirectory:(NSString*)objecguid
{
    NSString* tempDirectory = NSTemporaryDirectory();
    NSString* path = [tempDirectory stringByAppendingPathComponent:objecguid];
    [self ensurePathExists:path];
    return path;
}

- (NSString*) documentIndexFromZiwFile:(NSString*)filePath error:(NSError**)error
{
    NSString* tempPath = [self wizTempObjectDirectory:[WizGlobals genGUID]];
    [self removeDirectoryContent:tempPath error:error];
    [self ensureFileExists:tempPath];
    
    
    if (![self fileExistsAtPath:filePath]) {
        if (error != NULL) {
            *error = [WizGlobalError errorWithLocalizedString:NSLocalizedString(@"source file not found!", nil)];
        }
        return nil;
    }
    if (![self unzipWizObjectData:filePath toPath:tempPath]) {
        if (error != NULL) {
            *error = [WizGlobalError errorWithLocalizedString:NSLocalizedString(@"UnZip file error!", nil)];
        }
        return nil;
    }
    NSString* indexFilePath = [tempPath stringByAppendingPathComponent:DocumentFileIndexName];
    if(![self fileExistsAtPath:indexFilePath])
    {
        if(*error)
        {
            *error = [WizGlobalError errorWithLocalizedString:NSLocalizedString(@"Can not find the index.html afer unziped!", nil)];
        }
        return nil;
    }
    return indexFilePath;
}

- (NSString*) documentIndexFileFroReadingPath:(NSString*)documentGuid  accountUserId:(NSString*)accountUserId error:(NSError**)error
{
    NSString* documentSourcePath = [self wizObjectFilePath:documentGuid accountUserId:accountUserId];
    return [self documentIndexFromZiwFile:documentSourcePath error:error];
}

- (NSString*) documentIndexFileWithEncryptFroReadingPath:(NSString *)documentGuid accountUserId:(NSString *)accountUserId error:(NSError *__autoreleasing *)error
{
    NSString* documentSourcePath = [self wizObjectFilePath:documentGuid accountUserId:accountUserId];
    documentSourcePath=[documentSourcePath stringByAppendingString:@"de"];
    return [self documentIndexFromZiwFile:documentSourcePath error:error];
}
- (BOOL) prepareReadingEnviroment:(NSString*)documentGuid accountUserId:(NSString*)accountUserId
{
    NSString* documentSourcePath = [self wizObjectFilePath:documentGuid accountUserId:accountUserId];
    if (![self fileExistsAtPath:documentSourcePath]) {
        return NO;
    }
    NSString* tempPath = [self wizTempObjectDirectory:documentGuid];
    NSError* error;
    if (![self removeDirectoryContent:tempPath error:&error]) {
        return NO;
    }
    if (![self ensurePathExists:tempPath]) {
        return NO;
    }
    if (!IsWizKMZiwFileEnrypt(documentSourcePath)) {
        if (![self unzipWizObjectData:documentSourcePath toPath:tempPath]) {
            NSLog(@"unzipWizObjectData error %@",tempPath);
            return NO;
        }
    }
    return YES;
}

- (BOOL)prepareReadingEnviromentForCrypted:(NSString *)documentGuid accountUserId:(NSString *)accountUserId {
    NSString* documentSourcePath = [self wizObjectFilePath:documentGuid accountUserId:accountUserId];
    documentSourcePath=[documentSourcePath stringByAppendingString:@"de"];
    if (![self fileExistsAtPath:documentSourcePath]) {
        return NO;
    }
    NSString* tempPath = [self wizTempObjectDirectory:documentGuid];
    NSError* error;
    if ([self fileExistsAtPath:tempPath]) {
        if (![self removeItemAtPath:tempPath error:&error]) {
            DDLogError(@"%@",error.description);
        }
    }
    [self ensurePathExists:tempPath];
    if (![self unzipWizObjectData:documentSourcePath toPath:tempPath]) {
        return NO;
    }
    return YES;
}

- (BOOL) removeFile:(NSString*)path error:(NSError**)error
{
    if ([[WizFileManager defaultManager] fileExistsAtPath:path]) {
        return [self removeItemAtPath:path error:error];
    }
    else
    {
        return YES;
    }
}
- (BOOL) removeDirectoryContent:(NSString*)path error:(NSError**)error
{
    BOOL isDirectory;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]) {
        if (isDirectory) {
            NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:error];
            if ([contents count] == 0) {
                return YES;
            }
            for (NSString* eachPath in contents) {
                NSString* subPath = [path stringByAppendingPathComponent:eachPath];
                BOOL isSubDirectory = NO;
                if (![[NSFileManager defaultManager] fileExistsAtPath:subPath isDirectory:&isSubDirectory]) {
                    continue;
                }
                else
                {
                    if (isSubDirectory) {
                        BOOL isDeleteSubSucceed = [self removeDirectoryContent:subPath error:error];
                        if (isDeleteSubSucceed) {
                            continue;
                        }
                        else
                        {
                            return NO;
                        }
                    }
                    else
                    {
                        BOOL isDeleteFileSucced  = [self removeFile:subPath error:error];
                        if (isDeleteFileSucced ) {
                            continue;
                        }
                        else
                        {
                            return NO;
                        }
                    }
                }
            }
        }
        else
        {
            NSError* er = [[NSError errorWithDomain:WizErrorDomain code:-89 userInfo:nil] copy];
            if (error != NULL && er) {
                *error = er;
            }
            return NO;
        }
    }
    return YES;
}

- (void)resetExperienceUserIdInfo{
    NSString* userid = [[WizAccountManager defaultManager] experienceAccountUserId];
    NSString* dbPath = [[WizFileManager shareManager] metaDataBasePathForAccount: userid kbGuid:nil];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:dbPath];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [WizCore updateUserInfo:userid key:@"isCreateNote" value:NO];
    [WizCore updateUserInfo:userid key:@"isCreateFolder" value:NO];
    [WizCore updateUserInfo:userid key:@"isCreateTag" value:NO];
}

- (BOOL) removeDirectory:(NSString*)path error:(NSError**)error
{
    BOOL isDirectory;
    [self resetExperienceUserIdInfo];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]) {
        if (isDirectory) {
            NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:error];
            if (!contents) {
                return NO;
            }
            for (NSString* eachPath in contents) {
                NSString* subPath = [path stringByAppendingPathComponent:eachPath];
                BOOL isSubDirectory = NO;
                if (![[NSFileManager defaultManager] fileExistsAtPath:subPath isDirectory:&isSubDirectory]) {
                    continue;
                }
                else
                {
                    if (isDirectory) {
                        BOOL isDeleteSubSucceed = [self removeDirectory:subPath error:error];
                        if (isDeleteSubSucceed) {
                            continue;
                        }
                        else
                        {
                            return NO;
                        }
                    }
                    else
                    {
                        BOOL isDeleteFileSucced  = [self removeFile:subPath error:error];
                        if (isDeleteFileSucced ) {
                            continue;
                        }
                        else
                        {
                            return NO;
                        }
                    }
                }
            }
            return [[NSFileManager defaultManager] removeItemAtPath:path error:error];
        }
        else
        {
            if (error != NULL) {
               *error = [NSError errorWithDomain:WizErrorDomain code:-89 userInfo:nil];
            }
            
            return NO;
        }
    }
    return YES;
}

-(BOOL) deleteFile:(NSString*)fileName
{
	NSError* err = nil;
    BOOL b= YES;
    if ([self fileExistsAtPath:fileName]) {
       	b = [self removeItemAtPath:fileName error:&err];
        if (!b && err)
        {
            [WizGlobals reportError:err];
        }
    }
	//
	return b;
}
//

- (BOOL) doUnZipWizObjectData:(NSString *)ziwFilePath toPath:(NSString *)aimPath
{
    ZipArchive* zip = [[ZipArchive alloc] init];
    [zip UnzipOpenFile:ziwFilePath];
    BOOL zipResult = [zip UnzipFileTo:aimPath overWrite:YES];
    if (!zipResult) {
        NSLog(@"error !");
    }
    [zip UnzipCloseFile];
    return zipResult;
}

- (BOOL) unzipWizObjectData:(NSString *)ziwFilePath toPath:(NSString *)aimPath
{
    @synchronized(ziwFilePath)
    {
        if (![self doUnZipWizObjectData:ziwFilePath toPath:aimPath]) {
            return [self doUnZipWizObjectData:ziwFilePath toPath:aimPath];
        }
        else
        {
            return YES;
        }
    }
}

-(BOOL) addToZipFile:(NSString*) directory directoryName:(NSString*)name zipFile:(ZipArchive*) zip
{
    NSArray* selectedFile = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:nil];
    
    for(NSString* each in selectedFile) {
        BOOL isDir;
        NSString* path = [directory stringByAppendingPathComponent:each];
        if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir)
        {
            [self addToZipFile:path directoryName:[NSString stringWithFormat:@"%@/%@",name,each] zipFile:zip];
        }
        else
        {
            if(![zip addFileToZip:path newname:[NSString stringWithFormat:@"%@/%@",name,each]])
            {
                return NO;
            }
        }
    }
    return YES;
}
-(NSString*) createZipByPath:(NSString *)objectPath
{
    NSArray* selectedFile = [self contentsOfDirectoryAtPath:objectPath error:nil];
    NSString* zipPath = [objectPath stringByAppendingPathComponent:WizLocalSaveFileName];
    ZipArchive* zip = [[ZipArchive alloc] init];
    BOOL ret;
    ret = [zip CreateZipFile2:zipPath];
    for(NSString* each in selectedFile) {
        BOOL isDir;
        if ([each isEqualToString:WizLocalSaveFileName]) {
            continue;
        }
        NSString* path = [objectPath stringByAppendingPathComponent:each];
        if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir)
        {
            [self addToZipFile:path directoryName:each zipFile:zip];
        }
        else
        {
            ret = [zip addFileToZip:path newname:each];
        }
    }
    
    [zip CloseZipFile2];
    if(!ret) zipPath =nil;
    return zipPath;
}

- (BOOL) createZipByPath:(NSString*)filePath clean:(BOOL)isclean
{
    BOOL succusses = [self createZipByPath:filePath] != nil;
    if (isclean) {
        NSError* error = nil;
        NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:&error];
        if (contents && [contents count] && !error) {
            for (NSString* each in contents) {
                if ([each isEqualToString:WizLocalSaveFileName]) {
                    continue;
                }
                NSError* error = nil;

                if (![[NSFileManager defaultManager] removeItemAtPath:[filePath stringByAppendingPathComponent:each] error:&error]) {
                    DDLogError(@"delete file error %@-%@",filePath,each);
                }
            }
        }
    }
    return succusses;
}

-(NSString*) getZipByDictionaryPath:(NSString *)objectPath
{
    NSString* zipPath = [objectPath stringByAppendingPathComponent:WizLocalSaveFileName];
    return zipPath;
}


- (long long) fileSizeAtPath:(NSString*) filePath{
    if ([self fileExistsAtPath:filePath]){
        return [[self attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}
- (long long) folderTotalSizeAtPath:(NSString*) folderPath{
    if (![self fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[self subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        if ([fileName isEqualToString:@"index.db"]) {
            continue;
        }
        if ([fileName isEqualToString:@"tempAbs.db"]) {
            continue;
        }
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize;
}
- (NSString*) getDocumentFilePath:(NSString *)documentFileName documentGUID:(NSString *)documentGuid
{
    NSString* objectPath = [self wizTempObjectDirectory:documentGuid];
    return [objectPath stringByAppendingPathComponent:documentFileName];
}

- (NSString*) documentIndexFilesPath:(NSString *)documentGUID
{
    NSString* objectPath = [self wizTempObjectDirectory:documentGUID];
    return [objectPath stringByAppendingPathComponent:@"index_files"];
}

- (NSInteger) accountCacheSize:(NSString *)accountUserId
{
    NSString* accountPath = [self accountPathFor:accountUserId];
    return [self folderTotalSizeAtPath:accountPath];
}
//
- (NSString*) settingDataBasePath
{
    NSString* path = [WizFileManager documentsPath];
    return [path stringByAppendingPathComponent:@"settings.db"];
}

- (NSString*) cacheDbPath
{
    NSString* path = [WizFileManager documentsPath];
    return [path stringByAppendingPathComponent:@"cache.db"];
}
- (NSString*) metaDataBasePathForAccount:(NSString *)accountUserId kbGuid:(NSString *)kbGuid
{
    NSString* accountPath = [self accountPathFor:accountUserId];
    if (kbGuid == nil || [kbGuid isEqualToString:WizGlobalPersonalKbguid]) {
        return [accountPath stringByAppendingPathComponent:@"index.db"];
    }
    return [accountPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",kbGuid]];
}

- (NSString*) tempDataBatabasePath:(NSString *)accountUserId
{
    NSString* accountPath = [self accountPathFor:accountUserId];
    return [accountPath stringByAppendingPathComponent:@"abstract.db"];
}

- (NSString*) attachmentFilePath:(NSString *)attachmentGuid accountUserId:(NSString *)accountUserId
{
    NSString* objectPath = [self wizTempObjectDirectory:attachmentGuid];
    NSArray* content  = [self contentsOfDirectoryAtPath:objectPath error:nil];
    if ([content count]) {
        NSString* fileName = [content lastObject];
        return [objectPath stringByAppendingPathComponent:fileName];
    }
    return nil;
}
- (NSString*) wizEditTempDirectory:(NSString *)kbguid accountUserId:(NSString *)accountUserId
{
    NSString* accountPath = [self accountPathFor:accountUserId];
//    if (kbguid == nil) {
//        kbguid = WizDefaultKbguid;
//    }
    //全局只存在一个编辑的文档
    NSString* tempEditPath = accountPath;
    [self ensurePathExists:tempEditPath];
    NSString* editPath = [tempEditPath stringByAppendingPathComponent:@"editing"];
    [self ensurePathExists:editPath];
    return editPath;
}

- (BOOL) updateEditingIndexFile:(NSString *)text kbguid:(NSString *)kbguid accountUserId:(NSString *)accountUserId
{
    NSString* editingIndexFile = [[self wizEditTempDirectory:kbguid accountUserId:accountUserId] stringByAppendingPathComponent:DocumentFileIndexName];
    return [text writeToFile:editingIndexFile atomically:YES encoding:NSUTF16StringEncoding error:nil];
}

- (BOOL) updateEditingMobildeFile:(NSString *)text kbguid:(NSString *)kbguid accountUserId:(NSString *)accountUserId
{
    NSString* editingIndexFile = [[self wizEditTempDirectory:kbguid accountUserId:accountUserId] stringByAppendingPathComponent:DocumentFileMobileName];
    return [text writeToFile:editingIndexFile atomically:YES encoding:NSUTF16StringEncoding error:nil];
    
}

- (NSString*) editingIndexFilePath:(NSString *)accountUserId kbguid:(NSString *)kbguid
{
    NSString* editingPath = [self wizEditTempDirectory:kbguid accountUserId:accountUserId];
    return [editingPath stringByAppendingPathComponent:DocumentFileIndexName];
}

- (NSString*) editingIndexFilesDirectoryPath:(NSString *)accountUserId kbguid:(NSString *)kbguid
{
    NSString* editingPath = [self wizEditTempDirectory:kbguid accountUserId:accountUserId];
    [self ensurePathExists:[editingPath stringByAppendingPathComponent:@"index_files"]];
    return [editingPath stringByAppendingPathComponent:@"index_files"];
}

- (NSString*) editingMobileFilePath:(NSString *)accountUserId kbguid:(NSString *)kbguid
{
    NSString* editingPath = [self wizEditTempDirectory:kbguid accountUserId:accountUserId];
    return [editingPath stringByAppendingPathComponent:DocumentFileMobileName];
}

- (BOOL) prepareForEditingEnviroment:(NSString *)documentGuid kbguid:(NSString *)kbguid accountUserID:(NSString *)accountUserId
{
    NSString* documentSourcePath = [self wizObjectFilePath:documentGuid accountUserId:accountUserId];
    if (![self fileExistsAtPath:documentSourcePath]) {
        return NO;
    }
    NSString* tempPath = [self wizEditTempDirectory:kbguid accountUserId:accountUserId];
    NSError* error;
    if ([self fileExistsAtPath:tempPath]) {
        if (![self removeItemAtPath:tempPath error:&error]) {
            //        DDLogError(error.description);
            return NO;
        }
    }
    [self ensurePathExists:tempPath];
    if (![self unzipWizObjectData:documentSourcePath toPath:tempPath]) {
        return NO;
    }
    return YES;
}

+ (NSString*) personalInfoDataBasePath:(NSString*)accountUserId
{
    return [[[WizFileManager shareManager] accountPathFor:accountUserId] stringByAppendingPathComponent:@"index.db"];
}

+ (NSString*) accountDatabasePath
{

    return [[WizFileManager documentsPath] stringByAppendingPathComponent:@"account.db"];
}
+ (BOOL) moveDirectory:(NSString*)path toDirectory:(NSString*)toPath strategy:(WizFileMoveStrategy)strategy error:(NSError**)error
{
    if (strategy == WizFileMoveStrategyCover) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:toPath]) {
            if (![[NSFileManager defaultManager] removeItemAtPath:toPath error:error]) {
                NSLog(@"error %@",*error);
            }
        }
        return [[NSFileManager defaultManager] moveItemAtPath:path toPath:toPath error:error];
    }
    else if (strategy == WizFileMoveStrategyMerge)
    {
        NSArray* fileContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:error];
        for (NSString* eachPath in fileContents) {
            NSString* subSourcePath = [path stringByAppendingPathComponent:eachPath];
            NSString* subToPath = [toPath stringByAppendingPathComponent:eachPath];
            BOOL isDirectory;
            if ([[NSFileManager defaultManager] fileExistsAtPath:subToPath isDirectory:&isDirectory]) {
                if (!isDirectory) {
                    [[NSFileManager defaultManager] removeItemAtPath:subToPath error:error];
                    [[NSFileManager defaultManager] moveItemAtPath:subSourcePath toPath:subToPath error:error];
                }
                else
                {
                    BOOL isSourceDirectory;
                    if ([[NSFileManager defaultManager] fileExistsAtPath:subSourcePath isDirectory:&isSourceDirectory] ) {
                        if (isSourceDirectory) {
                            if (![self moveDirectory:subSourcePath toDirectory:subToPath strategy:strategy error:error]) {
                                return NO;
                            }
                        }
                    }
                    else
                    {
                        if (error != NULL) {
                           *error = [NSError errorWithDomain:@"wiz.cn.file" code:-56 userInfo:nil];
                        }
                        
                        return NO;
                    }
                }
            }
            else
            {
               [[NSFileManager defaultManager] moveItemAtPath:subSourcePath toPath:subToPath error:error]; 
            }
        }
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (NSString*) recordTempPath
{
    return [[WizFileManager documentsPath] stringByAppendingPathComponent:@"audio.wav"];
}
@end


