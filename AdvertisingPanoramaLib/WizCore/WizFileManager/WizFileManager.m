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
#import "WizGlobals.h"

#define ATTACHMENTTEMPFLITER @"attchmentTempFliter"
#define EditTempDirectory   @"EditTempDirectory"

static NSString* const WizLocalSaveFileName = @"temp.ziw";
static NSString* const WizDefaultKbguid = @"WizDefaultKbguid";

@implementation WizFileManager
//singleton

+ (id) shareManager;
{
    static WizFileManager* shareManager = nil;
    @synchronized(self)
    {
        if (shareManager == nil) {
            shareManager = [[super allocWithZone:NULL] init];
        }
        return shareManager;
    }
}

//
+(NSString*) documentsPath
{
    static NSString* documentDirectory= nil;
    if (nil == documentDirectory) {
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentDirectory = [paths objectAtIndex:0] ;
    }
	return documentDirectory;
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
            //            WizLogError(err.description);
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

    if (![[NSFileManager defaultManager] fileExistsAtPath:wizObjectFilePath]) {
        NSError* error = nil;
        NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:objectPath error:&error];
        if (contents && [contents count] && !error) {
            [self createZipByPath:objectPath];
            for (NSString* each in contents) {
                if ([each isEqualToString:WizLocalSaveFileName]) {
                    continue;
                }
                NSError* error = nil;
                
                if (![[NSFileManager defaultManager] removeItemAtPath:[objectPath stringByAppendingPathComponent:each] error:&error]) {
                    WizLogError(@"delete file error %@-%@",objectPath,each);
                }
            }
        }
    }
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

- (NSString*) wizTempObjectDirectory:(NSString*)objecguid
{
    NSString* tempDirectory = NSTemporaryDirectory();
    NSString* path = [tempDirectory stringByAppendingPathComponent:objecguid];
    [self ensurePathExists:path];
    return path;
}

- (BOOL) prepareReadingEnviroment:(NSString*)documentGuid accountUserId:(NSString*)accountUserId
{
    NSString* documentSourcePath = [self wizObjectFilePath:documentGuid accountUserId:accountUserId];
    if (![self fileExistsAtPath:documentSourcePath]) {
        NSLog(@"======No");
        return NO;
    }
    NSString* tempPath = [self wizTempObjectDirectory:documentGuid];
    NSError* error;
    if ([self fileExistsAtPath:tempPath]) {
        if (![self removeItemAtPath:tempPath error:&error]) {
            WizLogError(error.description);
            NSLog(@"delete error %@---- %@",tempPath, error);
        }
    }
    [self ensurePathExists:tempPath];
    if (![self unzipWizObjectData:documentSourcePath toPath:tempPath]) {
        NSLog(@"unzipWizObjectData error %@",tempPath);
        return NO;
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
- (BOOL) unzipWizObjectData:(NSString *)ziwFilePath toPath:(NSString *)aimPath
{

    ZipArchive* zip = [[ZipArchive alloc] init];
    [zip UnzipOpenFile:ziwFilePath];
    BOOL zipResult = [zip UnzipFileTo:aimPath overWrite:YES];
    [zip UnzipCloseFile];
    return zipResult;
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
    if (kbGuid == nil) {
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
    if (content) {
        NSString* fileName = [content lastObject];
        return [objectPath stringByAppendingPathComponent:fileName];
    }
    return nil;
}
- (NSString*) wizEditTempDirectory:(NSString *)kbguid accountUserId:(NSString *)accountUserId
{
    NSString* accountPath = [self accountPathFor:accountUserId];
    if (kbguid == nil) {
        kbguid = WizDefaultKbguid;
    }
    NSString* tempEditPath = [accountPath stringByAppendingPathComponent:kbguid];
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
    NSString* indexFilesPath = [editingPath stringByAppendingPathComponent:@"index_files"];
    [self ensurePathExists:indexFilesPath];
    return indexFilesPath;
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
            //        WizLogError(error.description);
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

+ (NSString*) recordTempPath
{
    return [[WizFileManager documentsPath] stringByAppendingPathComponent:@"audio.wav"];
}
@end
