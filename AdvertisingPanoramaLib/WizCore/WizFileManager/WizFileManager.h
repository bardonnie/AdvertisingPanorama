//
//  WizFileManger.h
//  Wiz
//
//  Created by MagicStudio on 12-4-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define EditTempDirectory   @"EditTempDirectory"

#define  DocumentFileIndexName  @"index.html"
#define  DocumentFileMobileName  @"wiz_mobile.html"
#define  DocumentFileAbstractName  @"wiz_abstract.html"
#define  DocumentFileFullName  @"wiz_full.html"
/**负责整个系统的物理存储，并且提供各种文件的路径。
 
 |-AppDirectory-|
                |-Documents-|-cache.db
                |           |-AccountUserId-|-index.db
                |                           |-kbguid.db
                |                           |-.....
                |                           |-documentguid/temp.wiz
                |
                |
                |-temp      |-guid-/文件信息
                |           |
                |
                |
                |
                |
 
 */
@interface WizFileManager : NSFileManager
+ (NSString*) documentsPath;
+ (NSString*) logFilePath;
+ (id) shareManager;
- (NSString*) accountPathFor:(NSString*)accountUserId;
- (long long) folderTotalSizeAtPath:(NSString*) folderPath;
- (NSInteger) accountCacheSize:(NSString*)accountUserId;
- (BOOL) ensurePathExists:(NSString*)path;
- (BOOL) deleteFile:(NSString*)fileName;

//reading document or attachment
- (NSString*) wizObjectFilePath:(NSString *)objectGuid accountUserId:(NSString *)accountUserId;
- (NSString*) wizObjectDirectoryPath:(NSString*)objectGuid accountUserId:(NSString*)accountUserId;
- (BOOL) prepareForEditingEnviroment:(NSString*)documentguid kbguid:(NSString*)kbguid accountUserID:(NSString*)accountUserId;
- (NSString*) documentIndexFilePath:(NSString*)documentGuid;
- (NSString*) documentMobildeFilePath:(NSString*)documentGuid;
- (NSString*) documentIndexFilesPath:(NSString *)documentGUID;
- (NSString*) attachmentFilePath:(NSString *)attachmentGuid accountUserId:(NSString *)accountUserId;
- (NSString*) wizTempObjectDirectory:(NSString*)objecguid;
- (BOOL) prepareReadingEnviroment:(NSString*)documentGuid accountUserId:(NSString*)accountUserId;
- (NSString*) wizEditTempDirectory:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
//
- (NSString*) editingIndexFilePath:(NSString*)accountUserId kbguid:(NSString*)kbguid;
- (NSString*) editingMobileFilePath:(NSString*)accountUserId kbguid:(NSString*)kbguid;
- (NSString*) editingIndexFilesDirectoryPath:(NSString*)accountUserId kbguid:(NSString*)kbguid;
//
- (BOOL) updateEditingIndexFile:(NSString*)text kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
- (BOOL) updateEditingMobildeFile:(NSString*)text kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
//databasepath
- (NSString*) metaDataBasePathForAccount:(NSString*)accountUserId   kbGuid:(NSString*)kbGuid;
- (NSString*) cacheDbPath;
+ (NSString*) accountDatabasePath;
+ (NSString*) personalInfoDataBasePath:(NSString*)accountUserId;
//
- (BOOL) unzipWizObjectData:(NSString *)ziwFilePath toPath:(NSString *)aimPath;
-(NSString*) createZipByPath:(NSString *)objectPath;
//
+ (NSString*) recordTempPath;
@end
