//
//  WizSyncKb.h
//  WizIos
//
//  Created by dzpqzb on 12-12-19.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizXmlKbServer.h"
#import "WizInfoDb.h"
@protocol WixSyncDatabaseDelegate <NSObject>

@end

/**The class packaging the method sync a kb.
 
 */
@interface WizSyncKb : NSObject
@property (nonatomic, strong, readonly) WizXmlKbServer* kbServer;
@property (nonatomic, strong, readonly) WizInfoDb* kbDataBase;
- (id) initWithUrl:(NSURL *)url
             token:(NSString *)token_
            kbguid:(NSString *)kbguid_
     accountUserId:(NSString *)accountUserId_
         dataBaser:(id<WizInfoDatabaseDelegate>)db
      isUploadOnly:(BOOL)isUploadOnly_
     userPrivilige:(int)privilige
        isPersonal:(BOOL)isPersonal_;
//
/**begin sync
 */
- (BOOL) sync;
/**download document
 @param documentGuid the guid of document
 @param downloadFilePath the file path of document
 
 */
- (BOOL) downloadDocument:(NSString*)documentGuid
                 filePath:(NSString*)downloadFilePath;
- (BOOL) downloadAttachment:(NSString*)attachmentGuid
                   filePath:(NSString*)downloadFilePath;
- (NSArray*) searchDocumentOnSearver:(NSString*)keyWords;
- (BOOL) downloadDocumentInfo:(NSString*)guid document:(WizDocument*)document error:(NSError**)error;
- (BOOL) uploadDocument:(WizDocument*)doc filePath:(NSString*)filePath;
@end
