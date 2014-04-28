//
//  WizXmlKbServer.m
//  WizIos
//
//  Created by dzpqzb on 12-12-19.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import "WizXmlKbServer.h"
#import "WizGlobals.h"
@implementation WizXmlKbServer
@synthesize token = _token;
@synthesize kbguid = _kbguid;
- (void) addCommontParams:(NSMutableDictionary *)postParams
{
    [super addCommontParams:postParams];
    if (self.token) {
        [postParams setObject:self.token forKey:@"token"];
    }
    if (self.kbguid) {
        [postParams setObject:self.kbguid forKey:@"kb_guid"];
    }
}
- (id) initWithUrl:(NSURL *)url token:(NSString *)token_ kbguid:(NSString *)kbguid_
{
    self = [super initWithUrl:url];
    if (self) {
        _token = token_;
        _kbguid = kbguid_;
    }
    return self;
}

- (BOOL) getAllVersion:(WizAllVersionData*)data
{
    NSMutableDictionary* postParams = [NSMutableDictionary dictionaryWithCapacity:5];
    return [self callXmlRpc:postParams methodKey:SyncMethod_DownloadAllObjectVersion retObj:data];
}
- (BOOL) getObjectList:(id<WizObject>)list first:(int64_t)first count:(int64_t)count  methodKey:(NSString*)methodKey
{
    NSMutableDictionary* postParams = [NSMutableDictionary dictionaryWithCapacity:2];
    [postParams setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    [postParams setObject:[NSNumber numberWithInt:first] forKey:@"version"];
    return [self callXmlRpc:postParams methodKey:methodKey retObj:list];
}

- (BOOL) getTagsList:(WizServerTagsArray*)tags first:(int64_t)first count:(int64_t)count
{
    return [self getObjectList:tags first:first count:count methodKey:SyncMethod_DownloadAllTags];
}

- (BOOL) getDocumentsList:(WizServerDocumentsArray *)documents first:(int64_t)first count:(int64_t)count
{
    return [self getObjectList:documents first:first count:count methodKey:SyncMethod_DownloadDocumentList];
}
- (BOOL) getDeletedGuidsList:(WizServerDeletedGuidsAarray *)deletedGuids first:(int64_t)first count:(int64_t)count
{
    return [self getObjectList:deletedGuids first:first count:count methodKey:SyncMethod_DownloadDeletedList];
}

- (BOOL) getAttachmentsList:(WizServerAttachmentsArray *)attachments first:(int64_t)first count:(int64_t)count
{
    return [self getObjectList:attachments first:first count:count methodKey:SyncMethod_DownloadAttachmentList];
}


- (BOOL) postTagList:(NSArray *)tagArray
{
    NSMutableArray* array = [NSMutableArray array];
    for (WizTag* each in tagArray) {
        NSDictionary* tag = each.toWizServerObject;
        [array addObject:tag];
    }
    NSMutableDictionary* postParams = [NSMutableDictionary dictionaryWithCapacity:5];
    [postParams setObject:array forKey:@"tags"];
    return [self callXmlRpc:postParams methodKey:SyncMethod_PostTagList retObj:nil];
}

- (BOOL) postDeletedGuidsList:(NSArray *)deletedGuidsArray
{
    NSMutableArray* array = [NSMutableArray array];
    for (WizDeletedGuid* each in deletedGuidsArray) {
        NSDictionary* deletedGuis = each.toWizServerObject;
        [array addObject:deletedGuis];
    }
    NSMutableDictionary* postParams = [NSMutableDictionary dictionaryWithCapacity:5];
    [postParams setObject:array forKey:@"deleteds"];
    return [self callXmlRpc:postParams methodKey:SyncMethod_UploadDeletedList retObj:nil];
}
- (BOOL) postDocumentInfo:(WizDocument *)doc withData:(BOOL)isWithData
{
    NSMutableDictionary* postParams = [NSMutableDictionary dictionaryWithDictionary:doc.toWizServerObject];
    [postParams setObject:[NSNumber numberWithBool:isWithData] forKey:@"with_document_data"];
    return [self callXmlRpc:postParams methodKey:SyncMethod_DocumentPostSimpleData retObj:nil];
}

- (BOOL) postAttachmentInfo:(WizAttachment *)attachment
{
    NSMutableDictionary* postParams = [NSMutableDictionary dictionaryWithDictionary:attachment.toWizServerObject];
    [postParams setObject:attachment.dataMd5                        forKey:@"attachment_zip_md5"];
    [postParams setObject:[NSNumber numberWithInt:1]    forKey:@"attachment_info"];
    [postParams setObject:[NSNumber numberWithInt:1]    forKey:@"attachment_data"];
    return [self callXmlRpc:postParams methodKey:SyncMethod_AttachmentPostSimpleData retObj:nil];
}

- (BOOL) postWizObjectData:(NSData *)data
                   objSize:(int64_t)objSize
                objDataMd5:(NSString *)objDataMd5
                   objType:(NSString *)type
                   objGuid:(NSString *)objGuid
                 partCount:(int64_t)partCount
                    partSN:(int64_t)partSN
{
    NSMutableDictionary* postParams = [NSMutableDictionary dictionary];
    // @()转换对象
    [postParams setObject:@(objSize) forKey:@"obj_size"];
    [postParams setObject:[NSNumber numberWithInt:partCount] forKey:@"part_count"];
    [postParams setObject:[NSNumber numberWithInt:partSN] forKey:@"part_sn"];
    [postParams setObject:[NSNumber numberWithInt:data.length] forKey:@"part_size"];
    //
    [postParams setObject:data forKey:@"data"];
    //
    [postParams setObject:objDataMd5 forKey:@"obj_md5"];
    [postParams setObject:objGuid forKey:@"obj_guid"];
    [postParams setObject:type forKey:@"obj_type"];
    //
    NSString* dataMd5 = [WizGlobals md5:data];
    [postParams setObject:dataMd5 forKey:@"part_md5"];
    
    return [self callXmlRpc:postParams methodKey:SyncMethod_UploadObject retObj:nil];
}

- (BOOL) downloadWizObjectData:(NSString *)objGuid objType:(NSString *)objType startPos:(int64_t)startPos requstSize:(int64_t)requestSize retData:(WizServerData *)serverData
{
    NSMutableDictionary* postParams = [NSMutableDictionary dictionary];
    [postParams setObject:objGuid forKey:@"obj_guid"];
    [postParams setObject:objType forKey:@"obj_type"];
    [postParams setObject:[NSNumber numberWithInt:startPos] forKey:@"start_pos"];
    [postParams setObject:[NSNumber numberWithInt:requestSize] forKey:@"part_size"];
    return [self callXmlRpc:postParams methodKey:SyncMethod_DownloadObject retObj:serverData];
}

- (BOOL) downloadDocumentsQueryList:(WizQuerayDocumentDictionay*)documentsQuery byGuids:(NSArray *)guids
{
    NSMutableDictionary* postParams = [NSMutableDictionary dictionary];
    [postParams setObject:guids forKey:@"document_guids"];
    return [self callXmlRpc:postParams methodKey:SyncMethod_DownloadDocumentListByGuids retObj:documentsQuery];
}

- (BOOL) downloadAttachmentsQueryList:(WizQuerayAttachmentDictionay *)attachmentsArray byGuids:(NSArray *)guids
{
    NSMutableDictionary* postParams = [NSMutableDictionary dictionary];
    [postParams setObject:guids forKey:@"attachment_guids"];
    return [self callXmlRpc:postParams methodKey:SyncMethod_DownloadAttachmentListByGuids retObj:attachmentsArray];
}

- (BOOL) getDocumentsListByKey:(WizServerDocumentsArray *)documents keywords:(NSString *)keywords
{
    NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[postParams setObject:keywords forKey:@"key"];
	[postParams setObject:[NSNumber numberWithInt:200] forKey:@"count"];
	[postParams setObject:[NSNumber numberWithInt:0] forKey:@"first"];
    return [self callXmlRpc:postParams methodKey:SyncMethod_DocumentsByKey retObj:documents];
}

- (BOOL) getValue:(WizServerObject *)retObj key:(NSString *)key
{
    NSMutableDictionary* postParams = [NSMutableDictionary dictionary];
    [postParams setObject:key forKey:@"key"];
    return [self callXmlRpc:postParams methodKey:SyncMethod_KbGetValue retObj:retObj];
}

- (BOOL) getKeyVersion:(NSString *)key version:(int64_t* const )version
{
    NSMutableDictionary* postParams = [NSMutableDictionary dictionary];
    [postParams setObject:key forKey:@"key"];
    WizServerVersionObject* versionObject = [[WizServerVersionObject alloc] init];
    BOOL ret = [self callXmlRpc:postParams methodKey:SyncMethod_KbGetValueVersion retObj:versionObject];
    if (ret) {
        int64_t ver = versionObject.version;
        *version = ver;
    }
    return ret;
}

- (BOOL) setServerValue:(id)value forKey:(NSString *)key serverVersion:(int64_t *const)version
{
    NSMutableDictionary* postParams = [NSMutableDictionary dictionary];
    [postParams setObject:key forKey:@"key"];
    [postParams setObject:value forKey:@"value_of_key"];
    WizServerVersionObject* versionObject = [[WizServerVersionObject alloc] init];
    if ([self callXmlRpc:postParams methodKey:SyncMethod_KbSetValue retObj:versionObject]) {
        *version = versionObject.version;
        return YES;
    }
    else
    {
        return NO;
    }
}

@end
