//
//  WizObjec.h
//  WizIos
//
//  Created by dzpqzb on 12-12-19.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>


extern  NSString* const WizObjectTypeDocument;
extern  NSString* const WizObjectTypeTag;
extern  NSString* const WizObjectTypeAttachment;

@protocol WizObject <NSObject>
- (void) fromWizServerObject:(id)obj;
@optional
- (int) version;
@optional
- (NSDictionary*) toWizServerObject;
@end
@interface WizObject : NSObject <WizObject>
@property (nonatomic, strong) NSString* guid;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, assign) int version;
@end

@interface WizDictionayObject  : NSObject <WizObject>

@end

@interface WizLoginData : WizDictionayObject
- (NSString*) token;
- (NSString*) kapiUrl;
- (NSString*) kbguid;
- (NSDictionary*) userAttributes;
@end

@interface WizAllVersionData : WizDictionayObject
- (int64_t) documentVersion;
- (int64_t) tagVersion;
- (int64_t) attachmentVersion;
- (int64_t) deletedGuidVersion;
@end
@interface WizServerObjectsArray : NSObject<WizObject>
@property (nonatomic, strong) NSMutableArray* array;
@end
@interface WizServerTagsArray : WizServerObjectsArray
@end
@interface WizServerDocumentsArray : WizServerObjectsArray
@end
@interface WizServerAttachmentsArray :  WizServerObjectsArray
@end
@interface WizServerDeletedGuidsAarray : WizServerObjectsArray
@end
@interface WizServerGroupsArray : WizServerObjectsArray
@end
@interface WizServerObject : NSObject<WizObject>
@property (nonatomic, strong, readonly) id data;
@end

@interface WizServerVersionObject : NSObject<WizObject>
@property (nonatomic,  readonly) int64_t version;
@end
//
enum WizEditDocumentType {
    WizEditDocumentTypeNoChanged = 0,
    WizEditDocumentTypeAllChanged = 1,
    WizEditDocumentTypeInfoChanged =2
};
@interface WizDocument : WizObject <NSCopying>
@property (nonatomic, strong) NSString* location;
@property (nonatomic, strong) NSString* url;
@property (nonatomic, strong) NSDate* dateCreated;
@property (nonatomic, strong) NSDate* dateModified;
@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) NSString* fileType;
@property (nonatomic, strong) NSString* tagGuids;
@property (nonatomic, strong) NSString* dataMd5;
@property (nonatomic, assign) BOOL serverChanged;
@property (nonatomic, assign) enum WizEditDocumentType localChanged;
@property (nonatomic, assign) BOOL bProtected;
@property (nonatomic, assign) int attachmentCount;
@property (nonatomic, assign) float   gpsLatitude;
@property (nonatomic, assign)     float   gpsLongtitude;
@property (nonatomic, assign)     float   gpsAltitude;
@property (nonatomic, assign)     float   gpsDop;
@property (nonatomic, assign) int nReadCount;
@property (nonatomic, strong) NSString* gpsAddress;
@property (nonatomic, strong) NSString* gpsCountry;
@property (nonatomic, strong) NSString* gpsLevel1;
@property (nonatomic, strong) NSString* gpsLevel2;
@property (nonatomic, strong) NSString* gpsLevel3;
@property (nonatomic, strong) NSString* gpsDescription;
@property (nonatomic, strong) NSString* ownerName;
@property (nonatomic, strong) NSString* keyWords;
- (void) loadDefaultValue;
@end


@interface WizTag : WizObject
@property (nonatomic, strong) NSString* parentGUID;
@property (nonatomic, strong) NSString* detail;
@property (nonatomic, strong) NSString* namePath;
@property (nonatomic, strong) NSDate*   dateInfoModified;
@property (nonatomic, assign) NSInteger localChanged;
@end

enum  WizEditAttachmentType{
    WizEditAttachmentTypeDeleted = -2,
    WizEditAttachmentTypeTempChanged = -1,
    WizEditAttachmentTypeNoChanged  = 0,
    WizEditAttachmentTypeChanged    = 1,

    };
@interface WizAttachment : WizObject
@property (nonatomic, strong)     NSString* type;
@property (nonatomic, strong)     NSString* dataMd5;
@property (nonatomic, strong)     NSString* detail;
@property (nonatomic, strong)     NSDate*     dateModified;
@property (nonatomic, strong)     NSString* documentGuid;
@property (assign) BOOL      serverChanged;
@property (assign) int localChanged;
- (id) initWithFilePath:(NSString*)filePath;
@end

@interface WizDeletedGuid : WizObject
@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) NSDate* dateDeleted;
@end

@interface WizServerData : NSObject <WizObject>
@property (nonatomic, strong, readonly) NSData* data;
@property (nonatomic, strong) NSString* partMd5;
@property (nonatomic, assign) BOOL isEof;
@property (nonatomic, assign) int64_t objSize;
@end



enum WizGroupUserRightAdmin {
    WizGroupUserRightAdmin = 0,
    WizGroupUserRightSuper = 10 ,
    WizGroupUserRightEditor = 50,
    WizGroupUserRightAuthor = 100,
    WizGroupUserRightReader = 1000,
    WizGroupUserRightNone = 10000,
    WizGroupUserRightAll = -1
};

static NSString* const WizGroupTypePersonal = @"WizGroupTypePersonal";
static NSString* const WizGroupTypeGlobal   = @"WizGroupTypeGlobal";

extern NSString* const KeyOfKbKbguid;
extern NSString* const KeyOfKbType;
extern NSString* const KeyOfKbName;
extern NSString* const KeyOfKbUserGroup;
extern NSString* const KeyOfKbDateCreated;
extern NSString* const KeyOfKbDateModified;
extern NSString* const KeyOfKbRoleCreated;
extern NSString* const KeyOfKbSeo;
extern NSString* const KeyOfKbOwnerName;
extern NSString* const KeyOfKbNote;
extern NSString* const KeyOfKbAccountUserId;


@interface WizGroup : WizObject
@property (nonatomic, strong) NSString * accountUserId;
@property (nonatomic, strong) NSDate * dateCreated;
@property (nonatomic, strong) NSDate * dateModified;
@property (nonatomic, strong) NSDate * dateRoleCreated;
@property (nonatomic, strong) NSString * kbId;
@property (nonatomic, strong) NSString * kbNote;
@property (nonatomic, strong) NSString * kbSeo;
@property (nonatomic, strong) NSString * kbType;
@property (nonatomic, strong) NSString * ownerName;
@property (nonatomic, strong) NSString * roleNote;
@property (nonatomic, strong) NSString * serverUrl;
@property (nonatomic, assign) NSInteger userGroup;
@property (nonatomic, assign) NSInteger  orderIndex;
@property (nonatomic, strong) NSString* kApiurl;
@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) NSString* bizName;
@end

//query object
@interface WizQueryDocument: WizObject
@property (nonatomic, strong) NSString* dataMd5;
@property (nonatomic, strong) NSString* infoMd5;
@property (nonatomic, strong) NSString* paramMd5;
@property (nonatomic, strong) NSDate* dtDataModified;
@property (nonatomic, strong) NSDate* dtInfoModified;
@property (nonatomic, strong) NSDate* dtParamModified;
@end

@interface WizQueryAttachment : WizObject

@end
@interface WizQuerayDocumentDictionay : WizDictionayObject
- (WizQueryDocument*) queryDocumentForGuid:(NSString*)guid;
@end

@interface WizQuerayAttachmentDictionay : WizDictionayObject

@end

typedef enum {
    WizUserPriviligeTypeAdmin = 0,
   WizUserPriviligeTypeSuper = 10,
    WizUserPriviligeTypeEditor = 50,
    WizUserPriviligeTypeAuthor = 100,
    WizUserPriviligeTypeReader = 1000,
    WizUserPriviligeTypeNone = 10000,
    WizUserPriviligeTypeDefaultGroup = -1
}WizUserPriviligeType;

@interface WizUserPrivilige : NSObject
+ (BOOL) canUploadDeletedList:(int)privilige;
+ (BOOL) canUploadTags:(int)privilige;
+ (BOOL) canUploadDocuments:(int)privilige;
+ (BOOL) canDownloadList:(int)privilige;
+ (BOOL) canNewNote:(int)privilige;
+ (BOOL) canEditNote:(WizDocument*)doc privilige:(int)privilige accountUserId:(NSString*)accountUserId;
@end

enum WizFolderEditType {
    WizFolderEditTypeNomal = 0,
    WizFolderEditTypeLocalCreate =1,
    WizFolderEditTypeLocalDeleted =-1
};

@interface WizFolder : NSObject
@property (nonatomic, strong) NSString* key;
@property (nonatomic, assign ,getter = getParentKey) NSString* parentKey;
@property (nonatomic, assign) enum WizFolderEditType localChanged;
@end

@interface WizAccount : NSObject
@property (nonatomic, strong) NSString* accountUserId;
@property (nonatomic, strong) NSString* personalKbguid;
@property (nonatomic, strong) NSString* password;
@end

@interface WizAbstract : NSObject
@property (nonatomic, strong) NSString* guid;
@property (nonatomic, strong) NSString* text;
@property (nonatomic, strong) UIImage* image;
@end

enum WizSearchType {
    WizSearchTypeTitle = 0,
    WizSearchTypeServer = 1
};

@interface WizSearch : NSObject
@property (nonatomic, strong) NSString* kbguid;
@property (nonatomic, strong) NSString* keyWords;
@property (nonatomic, strong) NSDate* dateSearched;
@property (nonatomic, assign) enum WizSearchType type;
@property (nonatomic, assign) NSInteger count;
@end

enum  WizModifiedDocumentType{
    WizModifiedDocumentTypeDeleted,
    WizModifiedDocumentTypeLocalInsert,
    WizModifiedDocumentTypeServerInsert,
    WizModifiedDocumentTypeLocalUpdate,
    WizModifiedDocumentTypeServerUpdate
};