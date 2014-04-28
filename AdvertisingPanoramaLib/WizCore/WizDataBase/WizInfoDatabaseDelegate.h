//
//  WizInfoDatabaseDelegate.h
//  WizIos
//
//  Created by dzpqzb on 12-12-20.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizObject.h"
@class WizTag;
@class WizDocument;
@class WizAttachment;
@protocol WizInfoDatabaseDelegate <NSObject>
@optional
// version
- (int64_t) documentVersion;
- (BOOL) setDocumentVersion:(int64_t)ver;
//
- (BOOL) setDeletedGUIDVersion:(int64_t)ver;
- (int64_t) deletedGUIDVersion;
//
- (int64_t) tagVersion;
- (BOOL) setTagVersion:(int64_t)ver;
//
- (int64_t) attachmentVersion;
- (BOOL) setAttachmentVersion:(int64_t)ver;
- (BOOL) setSyncVersion:(NSString*)type  version:(int64_t)ver;
- (int64_t) syncVersion:(NSString*)type;
//
- (BOOL) addDeletedGUIDRecord: (NSString*)guid type:(NSString*)type;
- (BOOL) deleteAttachment:(NSString *)attachGuid;
- (BOOL) deleteTag:(NSString*)tagGuid;
- (BOOL) deleteLocalTag:(NSString*)tagGuid;

- (BOOL) deleteDocument:(NSString*)documentGUID;

//document
- (WizDocument*) documentFromGUID:(NSString*)documentGUID;
- (BOOL) updateDocument:(WizDocument*) doc;
- (BOOL) updateDocuments:(NSArray *)documents;
- (NSArray*) recentDocuments;
- (NSArray*) documentsByTag: (NSString*)tagGUID;
- (NSArray*) documentsByKey: (NSString*)keywords;
- (NSArray*) documentsByLocation: (NSString*)parentLocation;
- (NSArray*) documentsByKey:(NSString *)keywords fromLocation:(NSString*)location;
- (NSArray*) documentsByKey:(NSString *)keywords fromTag:(NSString*)tagGuid;

- (NSArray*) documentForUpload;
- (NSArray*) documentsForCache:(NSInteger)duration;
- (WizDocument*) documentForClearCacheNext;
- (WizDocument*) documentForDownloadNext;
- (WizDocument*) nextDocumentForDownloadByDuraion:(NSInteger)duration;
- (NSArray*) documentForDownload:(NSInteger)duration;

- (BOOL) setDocumentServerChanged:(NSString*)guid changed:(BOOL)changed;
- (BOOL) setDocumentLocalChanged:(NSString*)guid  changed:(enum WizEditDocumentType)changed;
- (BOOL) changedDocumentTags:(NSString*)documentGuid  tags:(NSString*)tags;
//tag
- (NSArray*) allTagsForTree;
- (NSDictionary*) tagTreeDictionary;
- (NSDictionary*) tagPathDictionary;
- (BOOL) updateTag: (WizTag*) tag;
- (BOOL) updateTags: (NSArray*) tags;
- (NSArray*) tagsForUpload;
- (int) fileCountOfTag:(NSString *)tagGUID;
- (WizTag*) tagFromGuid:(NSString *)guid;
- (NSString*) tagAbstractString:(NSString*)guid;
- (BOOL) setTagLocalChanged:(NSString*)guid changed:(BOOL)changed;
- (BOOL) isExistTagWithTitle:(NSString*)title;
//attachment
-(NSArray*) attachmentsByDocumentGUID:(NSString*) documentGUID;
- (BOOL) setAttachmentLocalChanged:(NSString *)attchmentGUID changed:(BOOL)changed;
- (BOOL) setAttachmentServerChanged:(NSString *)attchmentGUID changed:(BOOL)changed;
- (BOOL) updateAttachment:(WizAttachment*)attachment;
- (BOOL) updateAttachments:(NSArray *)attachments;
- (NSArray*) attachmentsForUpload;
- (WizAttachment*) attachmentFromGUID:(NSString *)guid;
//
- (NSArray*) deletedGUIDsForUpload;
- (BOOL) clearDeletedGUIDs;

//folder
- (BOOL) updateLocations:(NSArray*) locations;
- (NSSet*) allLocationsForTree;
- (int) fileCountOfLocation:(NSString *)location;
- (int) filecountWithChildOfLocation:(NSString*) location;
- (NSString*) folderAbstractString:(NSString*)folderKey;
//
- (BOOL) isLocalFolderDirty;
- (BOOL) updateFolder:(WizFolder*)folder;
- (BOOL) deleteLocalFolder:(NSString*)folderkey;
- (BOOL) isExistFolderWithTitle:(NSString*)title;
- (NSSet*) allFolders;
- (BOOL) logLocalDeletedFolder:(NSString*)folder;
- (BOOL) clearFolsersData;

//
- (BOOL) isPersonalKb;
@end
