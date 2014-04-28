//
//  WizXmlKbServer.h
//  WizIos
//
//  Created by dzpqzb on 12-12-19.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import "WizXmlServer.h"

/**Do the net works about kb. It packs some fundamental method of the kb works. like upload data and download data of document.
 This class need a kbguid, token , server url.
 */
@interface WizXmlKbServer : WizXmlServer
@property (nonatomic, readonly, strong) NSString* kbguid;
@property (nonatomic, strong, readonly) NSString* token;
/**初始化函数，传入服务器url和token，以及需要同步的kbguid
 */
- (id) initWithUrl:(NSURL *)url token:(NSString*)token_ kbguid:(NSString*)kbguid_;
/**获取所有基本对象的服务器version
 */
- (BOOL) getAllVersion:(WizAllVersionData*)data;
/**When using the key-value mechanism, use this method to get the value from server.
 */
- (BOOL) getValue:(WizServerObject*)retObj key:(NSString*)key;
/**Get the key version from server
 */
- (BOOL) getKeyVersion:(NSString*)key version:(int64_t* const)version;
/**Set the key version into server
 */
- (BOOL) setServerValue:(id)value forKey:(NSString*)key serverVersion:(int64_t* const) version;
- (BOOL) getTagsList:(WizServerTagsArray*)tags first:(int64_t)first count:(int64_t)count;
- (BOOL) getDocumentsList:(WizServerDocumentsArray*)documents first:(int64_t)first count:(int64_t)count;
- (BOOL) getDeletedGuidsList:(WizServerDeletedGuidsAarray*)deletedGuids first:(int64_t)first count:(int64_t)count;
- (BOOL) getAttachmentsList:(WizServerAttachmentsArray*)attachments first:(int64_t)first count:(int64_t)count;
- (BOOL) getDocumentsListByKey:(WizServerDocumentsArray*) documents keywords:(NSString*)keywords;
- (BOOL) postTagList:(NSArray*) tagArray;
- (BOOL) postDeletedGuidsList:(NSArray*)deletedGuidsArray;
- (BOOL) postDocumentInfo:(WizDocument*)doc withData:(BOOL)isWithData;
- (BOOL) postAttachmentInfo:(WizAttachment*)attachment;
- (BOOL) downloadDocumentsQueryList:(WizQuerayDocumentDictionay*)documentsDicionary byGuids:(NSArray*)guids;
- (BOOL) downloadAttachmentsQueryList:(WizQuerayAttachmentDictionay*)attachmentsArray byGuids:(NSArray*)guids;
- (BOOL) postWizObjectData:(NSData*)data
                   objSize:(int64_t)objSize
                objDataMd5:(NSString*)objDataMd5
                   objType:(NSString*)type
                   objGuid:(NSString*)objGuid
                 partCount:(int64_t)partCount
                    partSN:(int64_t)partSN;
- (BOOL) downloadWizObjectData:(NSString*)objGuid
                       objType:(NSString*)objType
                      startPos:(int64_t)startPos
                    requstSize:(int64_t)requestSize
                       retData:(WizServerData*)serverData;

@end
