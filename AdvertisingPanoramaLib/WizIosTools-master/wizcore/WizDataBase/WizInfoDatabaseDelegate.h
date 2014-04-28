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
- (BOOL) setInsertedExperienceData:(BOOL)inserted;
- (BOOL) isInsertedExperienceData;
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
- (BOOL) deleteAttachment:(NSString *)attachGuid logDeleteRecord:(BOOL)needLog;
- (BOOL) deleteTag:(NSString*)tagGuid;
- (BOOL) deleteLocalTag:(NSString*)tagGuid;
- (BOOL) isDeletedGuidExist:(NSString*)guid;
- (BOOL) deleteDocument:(NSString*)documentGUID;

//document
- (WizDocument*) randomDocument;
- (int64_t) documentCount;
- (WizDocument*) documentFromGUID:(NSString*)documentGUID;
- (BOOL) updateDocument:(WizDocument*) doc;
- (BOOL) updateDocuments:(NSArray *)documents;
- (NSArray*) recentDocuments;
- (NSArray*) documentsByTag: (NSString*)tagGUID;
- (NSArray*) documentsAndSubTagDocumentsByTag: (NSString*)tagGUID;
- (NSArray *) subTags:(NSString *)preTagGuid;
- (NSMutableArray*) documentsByKey: (NSString*)keywords;
- (NSMutableArray*) documentsArrayWithWhereFiled:(NSString*)where arguments:(NSArray*)args;
- (NSArray*) documentsByLocation: (NSString*)parentLocation;
- (NSArray*) documentsAndSubFolderDocumentsByLocation: (NSString*)parentLocation;
- (NSArray*) documentsByKey:(NSString *)keywords fromLocation:(NSString*)location;
- (NSArray*) documentsByKey:(NSString *)keywords fromTag:(NSString*)tagGuid;
- (NSArray*) documentsByGroupTag;
- (NSArray*) documentForUpload;
- (NSArray*) documentsForCache:(NSInteger)duration;
- (WizDocument*) documentForClearCacheNext;
- (WizDocument*) documentForDownloadNext;
- (WizDocument*) nextDocumentForDownloadByDuraion:(NSInteger)duration;
- (NSArray*) documentForDownload:(NSInteger)duration;
- (NSArray*) documentsForDownloadByDuration:(NSInteger)duration exceptGuids:(NSString*)docGuids;

- (BOOL) setDocumentServerChanged:(NSString*)guid changed:(BOOL)changed;
- (BOOL) setDocumentLocalChanged:(NSString*)guid  changed:(WizEditDocumentType)changed;
- (BOOL) changedDocumentTags:(NSString*)documentGuid  tags:(NSString*)tags;
//tag
- (NSArray*) allTagsForTree;
- (NSDictionary*) tagTreeDictionary;
- (NSDictionary*) tagPathDictionary;
- (NSDictionary*) tagPathDictionaryNew;
- (BOOL) updateTag: (WizTag*) tag;
- (BOOL) updateTags: (NSArray*) tags;
- (NSArray*) tagsForUpload;
- (int) fileCountOfTag:(NSString *)tagGUID;
- (WizTag*) tagFromGuid:(NSString *)guid;
- (NSString*) tagAbstractString:(NSString*)guid;
- (BOOL) setTagLocalChanged:(NSString*)guid changed:(BOOL)changed;
- (BOOL) isExistTagWithTitle:(NSString*)title;
- (NSArray*) subTagsByParentGuid:(NSString*)parentGuid;
- (NSDictionary *) tagGuidAndParentTagGuidKV;

//attachment
- (int)getAttachmentCountByDocmentGuid:(NSString*)docGuid;
-(NSArray*) attachmentsByDocumentGUID:(NSString*) documentGUID;
- (BOOL) setAttachmentLocalChanged:(NSString *)attchmentGUID changed:(WizEditAttachmentType)type;
- (BOOL) setAttachmentServerChanged:(NSString *)attchmentGUID changed:(BOOL)changed;
- (BOOL) updateAttachment:(WizAttachment*)attachment;
- (BOOL) updateAttachments:(NSArray *)attachments;
- (NSArray*) attachmentsForUpload;
- (WizAttachment*) attachmentFromGUID:(NSString *)guid;
- (NSMutableArray*) deletedGUIDsForUpload;
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
- (NSArray*) subFolders:(NSString *)preLocation;
- (BOOL) logLocalDeletedFolder:(NSString*)folder;
- (BOOL) clearFolsersData;

//
- (BOOL) isPersonalKb;
- (NSMutableDictionary *)folderDocCountWithCache:(BOOL)withCache;
- (NSDictionary *)tagDocCountWithCache:(BOOL)withCache;
//
- (NSSet*) childFoldersOf:(NSString*)folder;
@end
