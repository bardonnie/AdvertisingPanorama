//
//  WizObjec.h
//  WizIos
//
//  Created by dzpqzb on 12-12-19.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
//
typedef enum {
    WizProTypeNone = 0,
    WizProTypeLevel1 =1,
    WizProTypeLevel2 =2,
    WizProTypeLevel3 = 3
}WizProType;

typedef enum {
    
    CWizDocumentsSortedTypeByTitleAsc = 1,
    CWizDocumentsSortedTypeByModifiedDateAsc,
    CWizDocumentsSortedTypeByModifiedDateDesc,
    CWizDocumentsSortedTypeByTitleDesc,
    CWizDocumentsSortedTypeByCreatedDateAsc,
    CWizDocumentsSortedTypeByCreatedDateDesc
} CWizDocumentsSortedType;


static NSString* const  DataTypeUpdateDocumentGUID          =       @"document_guid";
static NSString* const DataTypeUpdateDocumentTitle          =       @"document_title";
static NSString* const DataTypeUpdateDocumentLocation       =       @"document_location";
static NSString* const DataTypeUpdateDocumentDataMd5        =       @"data_md5";
static NSString* const DataTypeUpdateDocumentZipDataMd5     =       @"document_zip_md5";
static NSString* const DataTypeUpdateDocumentUrl            =       @"document_url";
static NSString* const DataTypeUpdateDocumentTagGuids       =       @"document_tag_guids";
static NSString* const DataTypeUpdateDocumentDateCreated    =       @"dt_created";
static NSString* const DataTypeUpdateDocumentDateModified   =       @"dt_modified";
static NSString* const DataTypeUpdateDocumentType           =       @"document_type";
static NSString* const DataTypeUpdateDocumentFileType       =       @"document_filetype";
static NSString* const DataTypeUpdateDocumentAttachmentCount=       @"document_attachment_count";
static NSString* const DataTypeUpdateDocumentLocalchanged   =       @"document_localchanged";
static NSString* const DataTypeUpdateDocumentServerChanged  =       @"document_serverchanged";
static NSString* const DataTypeUpdateDocumentProtected      =       @"document_protect";
static NSString* const DataTypeUpdateDocumentGPS_LATITUDE   =       @"gps_latitude";
static NSString* const DataTypeUpdateDocumentGPS_LONGTITUDE =       @"gps_longitude";
static NSString* const DataTypeUpdateDocumentGPS_ALTITUDE   =       @"GPS_ALTITUDE";
static NSString* const DataTypeUpdateDocumentGPS_DOP        =       @"GPS_DOP";
static NSString* const DataTypeUpdateDocumentGPS_ADDRESS    =       @"GPS_ADDRESS";
static NSString* const DataTypeUpdateDocumentGPS_COUNTRY    =       @"GPS_COUNTRY";
static NSString* const DataTypeUpdateDocumentGPS_LEVEL1     =       @"GPS_LEVEL1";
static NSString* const DataTypeUpdateDocumentGPS_LEVEL2     =       @"GPS_LEVEL2";
static NSString* const DataTypeUpdateDocumentGPS_LEVEL3     =       @"GPS_LEVEL3";
static NSString* const DataTypeUpdateDocumentGPS_DESCRIPTION=       @"GPS_DESCRIPTION";
static NSString* const DataTypeUpdateDocumentREADCOUNT      =       @"READCOUNT";
static NSString* const DataTypeUpdateDocumentOwner          =       @"document_owner";
static NSString* const DataTypeUpdateDocumentKeyWords       =       @"document_keywords";
//
#define DataTypeUpdateAttachmentDescription     @"attachment_description"
#define DataTypeUpdateAttachmentDocumentGuid    @"attachment_document_guid"
#define DataTypeUpdateAttachmentGuid            @"attachment_guid"
#define DataTypeUpdateAttachmentTitle           @"attachment_name"
#define DataTypeUpdateAttachmentDataMd5         @"data_md5"
#define DataTypeUpdateAttachmentDateModified    @"dt_data_modified"
#define DataTypeUpdateAttachmentInfoDateModified @"dt_info_modified"
#define DataTypeUpdateAttachmentServerChanged   @"sever_changed"
#define DataTypeUpdateAttachmentLocalChanged    @"local_changed"

extern  NSString* const WizObjectTypeDocument;
extern  NSString* const WizObjectTypeTag;
extern  NSString* const WizObjectTypeAttachment;

@protocol WizObject <NSObject>
- (void) fromWizServerObject:(id)obj;
@optional
- (int64_t) version;
@optional
- (NSDictionary*) toWizServerObject;
@end
@interface WizObject : NSObject <WizObject>
@property (nonatomic, strong) NSString* guid;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, assign) int64_t version;
@end

@interface WizDictionayObject  : NSObject <WizObject>

@end

@interface WizLoginData : WizDictionayObject
- (NSString*) token;
- (NSString*) kapiUrl;
- (NSString*) kbguid;
- (NSDictionary*) userAttributes;
- (NSString *) userGuid;
@end


@interface WizCertData : WizDictionayObject
- (NSString*) n;
- (NSString*) e;
- (NSString*) encrypted_d;
- (NSString*) hint;

-(NSDictionary *)dict;
-(void) setDict:(NSDictionary *)dictionary;
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
typedef enum  {
    WizEditDocumentTypeNoChanged = 0,
    WizEditDocumentTypeAllChanged = 1,
    WizEditDocumentTypeInfoChanged =2
}WizEditDocumentType;
@interface WizDocument : WizObject <NSCopying>
@property (nonatomic, strong) NSString* location; //目录名
@property (nonatomic, strong) NSString* url;    //
@property (nonatomic, strong) NSDate* dateCreated; //创建日期
@property (nonatomic, strong) NSDate* dateModified; //修改日期
@property (nonatomic, strong) NSString* type;   //
@property (nonatomic, strong) NSString* fileType; //
@property (nonatomic, strong) NSString* tagGuids; //*分隔
@property (nonatomic, strong) NSString* dataMd5; //
@property (nonatomic, assign) BOOL serverChanged; //服务器是否有更改
@property (nonatomic, assign) WizEditDocumentType localChanged; //本地是否有更改
@property (nonatomic, assign) BOOL bProtected;  //密码保护
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
@property (nonatomic, strong) NSString* ownerName;  //创建人
@property (nonatomic, strong) NSString* keyWords;   //
@property (nonatomic, assign, readonly) BOOL isInDeletedBox;    //是否本地删除
- (void) loadDefaultValue;
- (void) setTagGuidsFromTagArray:(NSArray*)array;
- (void) updatePropertyFromDictionary:(NSDictionary*)dic;
@end


@interface WizTag : WizObject
@property (nonatomic, strong) NSString* parentGUID;
@property (nonatomic, strong) NSString* detail;
@property (nonatomic, strong) NSString* namePath;
@property (nonatomic, strong) NSDate*   dateInfoModified;
@property (nonatomic, assign) NSInteger localChanged;
- (void) loadDefaultValue;
@end

typedef  enum  {
    WizEditAttachmentTypeDeleted = -2,
    WizEditAttachmentTypeTempChanged = -1,
    WizEditAttachmentTypeNoChanged  = 0,
    WizEditAttachmentTypeChanged    = 1,

    }WizEditAttachmentType;
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
@property (nonatomic, assign) NSInteger orderIndex;
@property (nonatomic, strong) NSString* kApiurl;
@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) NSString* bizGuid;
@property (nonatomic, strong) NSString* mywizEmail;
@property (nonatomic, strong) NSString* bizName;
@property (nonatomic, assign, readonly) BOOL isBiz;
- (BOOL) isEqualToGroup:(WizGroup*)group;
-(BOOL) isPrivateKB;
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

typedef enum  {
    WizFolderEditTypeNomal = 0,
    WizFolderEditTypeLocalCreate =1,
    WizFolderEditTypeLocalDeleted =-1
}WizFolderEditType;

@interface WizFolder : NSObject
@property (nonatomic, strong) NSString* key;
@property (nonatomic, assign ,getter = getParentKey) NSString* parentKey;
@property (nonatomic, assign) WizFolderEditType localChanged;
@end

@interface WizAccount : NSObject
@property (nonatomic, strong) NSString* accountUserId;
@property (nonatomic, strong) NSString* userGuid;
@property (nonatomic, strong) NSString* personalKbguid;
@property (nonatomic, strong) NSString* password;
@property (nonatomic, assign, readonly) NSString* type;
@property (nonatomic, assign, readonly) NSString* userTypeAlertText;
@property (nonatomic, assign, readonly) WizProType  userProLevel;
@property (nonatomic, assign, readonly) NSString* displayName;
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
@property (nonatomic, strong) NSString* accountUserId;
@property (nonatomic, strong) NSString* folder;
@property (nonatomic, strong) NSString* tagGuids;
- (id) initWithKeyWords:(NSString*)keyWords
                  count:(NSInteger)count
                 kbguid:(NSString*)kbguid
          accountUserId:(NSString*)accountUserId
                   type:(enum WizSearchType)type
               tagguids:(NSString*)tagguids
                 folder:(NSString*)folder;
@end

enum  WizModifiedDocumentType{
    WizModifiedDocumentTypeDeleted,
    WizModifiedDocumentTypeLocalInsert,
    WizModifiedDocumentsTypeServerInsert,
    WizModifiedDocumentTypeLocalUpdate,
    WizModifiedDocumentTypeServerUpdate,
    WizModifiedDocumentTypeDataReady,
    WizModifiedDocumentTypeDataDirty
};

@interface WizDocumentCount:NSObject
@property (nonatomic, assign) NSInteger docCountBySelf;
@property (nonatomic, assign) NSInteger docCountWithSub;
@end

typedef  enum{
    WizMessageTypeNormalAt = 0,
    WizMessageTypeModifiedDocument = 1,
    WizMessageTypeComment = 10,
    WizMessageTypeLocalTask = 10000,
    WizMessageTypeAllType = 10001,
}WizMessageType;

typedef enum{
   WizMessageSendStatusNoNeedSend = 0,
    WizMessageSendStatusSended = 1,
    WizMessageSendStatusUnSended = 2
}WizMessageSendStatus;

typedef enum{
    WizMessageReadStatusUnRead = 0,
    WizMessageReadStatusReaded = 1
}WizMessageReadStatus;

@interface WizMessage : NSObject
@property (nonatomic, assign) int64_t messageId;
@property (nonatomic, strong) NSString* bizGuid;
@property (nonatomic, strong) NSString* kbGuid;
@property (nonatomic, strong) NSString* documentGuid;
@property (nonatomic, strong) NSString* senderGuid;
@property (nonatomic, strong) NSString* senderId;
@property (nonatomic, strong) NSString* senderAlias;
@property (nonatomic, strong)  NSString* receiverGuid;
@property (nonatomic, strong) NSString* receiverAlias;
@property (nonatomic, strong) NSString* receiverId;
@property (nonatomic, assign) int64_t version;
@property (nonatomic, assign) WizMessageType messageType;
@property (nonatomic, assign) WizMessageSendStatus emailSendStatus;
@property (nonatomic, assign) WizMessageSendStatus smsSendStatus;
@property (nonatomic, assign) WizMessageReadStatus readStatus;
@property (nonatomic, strong) NSDate* dtCreated;
@property (nonatomic, strong) NSString* messageNote;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* body;
@property (nonatomic, strong) NSDate* taskEndDate;
@property (nonatomic, assign) NSInteger localChanged;
- (BOOL) saveChanges;
@end


@interface WizServerMessageArray : WizServerObjectsArray

@end

@interface WizBizUser : NSObject
@property (nonatomic, strong) NSString* guid;
@property (nonatomic, strong) NSString* userId;
@property (nonatomic, strong) NSString* alias;
@property (nonatomic, strong) NSString* aliasPinyin;
@property (nonatomic, strong) NSString* bizGuid;
@end


static NSString* const WizUserTaskModelName = @"WIZ_USER_TASK";
static NSString* const WizUserTaskModelColumnGUID = @"WIZ_USER_TASK_GUID";
static NSString* const WizUserTaskModelColumnDtCreated = @"WIZ_USER_TASK_DT_CREATED";
static NSString* const WizUserTaskModelColumnDtDeadline = @"WIZ_USER_TASK_DT_DEADLINE";
static NSString* const WizUserTaskModelColumnAccountUserId = @"WIZ_USER_TASK_USERID";
static NSString* const WizUserTaskModelColumnKbGuid = @"WIZ_USER_TASK_KBGUID";
static NSString* const WizUserTaskModelColumnDocumentGuid = @"WIZ_USER_TASK_DOCUMENT_GUID";
static NSString* const WizUserTaskModelColumnBizGuid = @"WIZ_USER_TASK_BIZ_GUID";
static NSString* const WizUserTaskModelColumnTitle = @"WIZ_USER_TASK_TITLE";
static NSString* const WizUserTaskModelColumnBody = @"WIZ_USER_TASK_BODY";


@interface WizUserTask : NSObject
@property (nonatomic, strong) NSString* guid;
@property (nonatomic, strong) NSDate* dtCreated;
@property (nonatomic, strong) NSDate* dtDeadline;
@property (nonatomic, strong) NSString* accountUserId;
@property (nonatomic, strong) NSString* kbguid;
@property (nonatomic, strong) NSString* documentGuid;
@property (nonatomic, strong) NSString* bizGuid;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* body;
@end


@interface WizKBIdentifyObject : NSObject
@property (nonatomic, strong) NSString* accountUserId;
@property (nonatomic, strong) NSString* kbguid;
@end

//
static NSString* const kWizShotcutTableName = @"WIZ_SHOTCUT";
static NSString* const kWizShotcutDocumentGuid = @"DOCUMENT_GUID";
static NSString* const kWizShotcutGroupGuid = @"GROUP_GUID";
static NSString* const kWizShotcutAccountUserId = @"ACCOUNT_USERID";
static NSString* const kWizShotcutLocalChanged = @"LOCAL_CHANGED";
static NSString* const kWizShotcutDateModified = @"DT_MODIFIED";
//
@interface WizShotCutInner : NSObject
@property (nonatomic, strong) NSString* documentGuid;
@property (nonatomic, strong) NSString* groupGuid;
@property (nonatomic, strong) NSString* accountUserId;
@property (nonatomic, strong) NSDate* dateModified;
@property (nonatomic, assign) BOOL localChanged;
@end

@interface WizShotCut : NSObject
@property (nonatomic, strong) WizDocument* document;
@property (nonatomic, strong) WizGroup* group;
@property (nonatomic, strong) NSDate* lastModifiedDate;
@end

@interface WizShotCutCache : NSObject
- (NSMutableArray*) allShotCutOfAccountUserId:(NSString*)accountUserId;
- (BOOL) addShotCut:(WizShotCut*)shotCut;
- (BOOL) deleteShotCut:(WizShotCut*)shotcut;
- (BOOL) isShotCutWithDocumentExist:(NSString*)shotcut accountUserId:(NSString*)accountUserId;
+ (id) shareInstance;
- (WizShotCut*) shotCutByAccountUserId:(NSString*)accountUserId Kbguid:(NSString*)kbguid documentGuid:(NSString*)docGuid;
@end;