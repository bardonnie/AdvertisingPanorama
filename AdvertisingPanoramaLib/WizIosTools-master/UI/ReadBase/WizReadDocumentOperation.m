//
//  WizReadDocumentOperation.m
//  WizNote
//
//  Created by dzpqzb on 13-6-19.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizReadDocumentOperation.h"
#import "WizWorkOperation.h"
#import "WizEnc.h"
#import "WizTokenManger.h"
#import "WizSyncKb.h"
#import "WizGlobalError.h"
#import "WizSelectGroupViewController.h"
#import "UIWebView+WizTool.h"
#import "WizCore.h"
#import "UIColor+SSToolkitAdditions.h"

static int WizCheckPasswordTag = 9456;

@implementation WizReadDocumentOperation
@synthesize documentGuid = _documentGuid;
@synthesize accountUserId = _accountUserId;
@synthesize kbguid = _kbguid;
@synthesize passwordTextField = _passwordTextField;
@synthesize delegate = _delegate;
@synthesize checkPasswordCondition = _checkPasswordCondition;
@synthesize userPassword;
- (id) initWithDocumentGuid:(NSString *)documentGuid accountUserId:(NSString *)accountUserId kbguid:(NSString *)kbguid
{
    self = [super init];
    if (self) {
        _accountUserId = accountUserId;
        _documentGuid = documentGuid;
        _kbguid = kbguid;
        _checkPasswordCondition = [[NSCondition alloc] init];
    }
    return self;
}

- (void) onError:(NSError*)error
{
    if ([_delegate respondsToSelector:@selector(didLoadDocumentFaild:error:)]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [_delegate didLoadDocumentFaild:_documentGuid error:error];
        });
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString* buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if (alertView.tag == WizCheckPasswordTag){
        if ([buttonTitle isEqualToString:NSLocalizedString(@"OK", nil)]){
            userPassword=[_passwordTextField text];
            self.checkPasswordResult = WizCheckPasswordResultEnd;
            [self.checkPasswordCondition lock];
            [self.checkPasswordCondition signal];
            [self.checkPasswordCondition unlock];
        } else{
            self.checkPasswordResult = WizCheckPasswordResultCancel;
            [self.checkPasswordCondition lock];
            [self.checkPasswordCondition signal];
            [self.checkPasswordCondition unlock];
        }
    }
}

- (WizDocument*) downloadDocumentInfo:(NSString*)documentGuid error:(NSError**)error
{
    WizTokenAndKapiurl* tokenAndUrl = [[WizTokenManger shareInstance] tokenUrlForAccountUserId:_accountUserId kbguid:_kbguid error:error];
    if (tokenAndUrl == nil) {
        return nil;
    }
    id<WizInfoDatabaseDelegate> db = [WizDBManager getMetaDataBaseForKbguid:_kbguid accountUserId:_accountUserId];
    WizSyncKb* syncKb = [[WizSyncKb alloc] initWithUrl:[NSURL URLWithString:tokenAndUrl.kApiUrl] token:tokenAndUrl.token kbguid:_kbguid accountUserId:_accountUserId dataBaser:db isUploadOnly:NO userPrivilige:0 isPersonal:NO];
    
    WizDocument* document = [[WizDocument alloc] init];
    document.guid = @"xxx";
    if(![syncKb downloadDocumentInfo:documentGuid document:document error:error])
    {
        if (error != NULL) {
            *error = syncKb.kbServer.lastError;
        }
        
        return nil;
    }
    if ([document.guid isEqualToString:@"xxx"]) {
        if (error != NULL) {
           *error = [WizGlobalError notExistDocumentError];
        }
        
        return nil;
    }
    return document;
}

- (BOOL) downloadDocument:(NSString*)documentGuid error:(NSError**)error
{
    WizTokenAndKapiurl* tokenAndUrl = [[WizTokenManger shareInstance] tokenUrlForAccountUserId:_accountUserId kbguid:_kbguid error:error];
    if (tokenAndUrl == nil) {
//        wenlin annotation bug-4 start
//        if (error != NULL) {
//            *error = [WizGlobalError tokenUnActiveError];
//        }
//        wenlin annotation bug-4 end
        return NO;
    }
    id<WizInfoDatabaseDelegate> db = [WizDBManager getMetaDataBaseForKbguid:_kbguid accountUserId:_accountUserId];
    WizSyncKb* syncKb = [[WizSyncKb alloc] initWithUrl:[NSURL URLWithString:tokenAndUrl.kApiUrl] token:tokenAndUrl.token kbguid:_kbguid accountUserId:_accountUserId dataBaser:db isUploadOnly:NO userPrivilige:0 isPersonal:NO];
    NSString* objectPath = [[WizFileManager shareManager] wizObjectFilePath:_documentGuid accountUserId:_accountUserId];
    if (![syncKb downloadDocument:self.documentGuid filePath:objectPath]) {
        if (error != NULL) {
           *error = syncKb.kbServer.lastError;
        }
        
        return NO;
    }
    return YES;
}
- (void)checkPassword
{
    UIAlertView* prompt= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Please enter password!", @"")
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                          otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    prompt.alertViewStyle = UIAlertViewStyleSecureTextInput;
    prompt.tag = WizCheckPasswordTag;
    _passwordTextField = [prompt textFieldAtIndex:0];
    [prompt show];
    return ;
}

- (WizCheckPasswordResult) checkUserPassword:(NSError**)error;
{
    BOOL checkPasswordEnd = NO;
    int checkount = 0;
    while (!checkPasswordEnd) {
        MULTIMAIN(^{
            [self checkPassword];
        });
        [self.checkPasswordCondition lock];
        [self.checkPasswordCondition wait];
        [self.checkPasswordCondition unlock];
        if (self.checkPasswordResult !=WizCheckPasswordResultCancel) {
            BOOL willRefreshCert = NO;
            if (checkount > 0) {
                willRefreshCert = YES;
            }
            WizCertData *certData= [[WizAccountManager defaultManager] certData:willRefreshCert];
            checkount++;
            NSString *objectFile = [[WizFileManager shareManager] wizObjectFilePath:self.documentGuid accountUserId:self.accountUserId];
            NSString *decryptedObjectFile=[NSString stringWithFormat:@"%@de",objectFile];
            NSError *error;
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            if ([fileMgr fileExistsAtPath:decryptedObjectFile])
                [fileMgr removeItemAtPath:decryptedObjectFile error:&error];
            enum WizDecryptZiwResult result = WizDecryptZiw_NS(certData.n,certData.e,certData.encrypted_d,userPassword,objectFile,decryptedObjectFile);
            if (result == wizInvalidPassword) {
                checkPasswordEnd = NO;
            }
            else if (result == wizDone)
            {
                checkPasswordEnd = YES;
            }
            else
            {
                if (error != NULL) {
                    error =[NSError errorWithDomain:WizErrorDomain code:result userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Decrypt Error!", nil)}];
                }
                return WizCheckPasswordResultFaild;
            }
        }
        else
        {
//            checkPasswordEnd = YES;
            return WizCheckPasswordResultCancel;
        }
    }
    return WizCheckPasswordResultSucceed;
}
- (BOOL) prepareLoadingFile:(WizDocument*)document error:(NSError**)error
{
    WizFileManager* fm = [WizFileManager shareManager];
    NSString* documentZiwFile = [fm wizObjectFilePath:self.documentGuid accountUserId:_accountUserId];
    if ([WizGlobals fileLength:documentZiwFile] == 0) {
        if (error != NULL) {
           *error = [WizGlobalError unzipFileError];
        }
        
        return NO;
    }
    if (document.bProtected){
        if ([self checkUserPassword:error]) {
            if([fm prepareReadingEnviromentForCrypted:document.guid accountUserId:self.accountUserId])
            {
                return YES;
            }
            else
            {
                if(error != NULL)
                {
                   *error = [WizGlobalError unzipFileError]; 
                }
                
                return NO;
            }
        }
        else
        {
            if(error != NULL)
            {
               *error = [WizGlobalError unzipFileError]; 
            }
            
            return NO;
        }
    }
    else
    {
        if( [fm prepareReadingEnviroment:document.guid accountUserId:self.accountUserId])
        {
            return YES;
        }
        else
        {
            if (error != NULL) {
               *error = [WizGlobalError unzipFileError];
            }
            
            return NO;
        }
    }
    return NO;
}

- (void) main
{
//    NSLog(@"WizReadDocumentOperation start");
    @autoreleasepool {
        id<WizInfoDatabaseDelegate> db = [WizDBManager getMetaDataBaseForKbguid:_kbguid accountUserId:_accountUserId];
        WizDocument* document = [db documentFromGUID:_documentGuid];
        NSError* error = nil;
        if (!document) {
            if ([db isDeletedGuidExist:self.documentGuid]) {
                [self onError:[NSError errorWithDomain:WizErrorDomain code:-34 userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Note is deleted", nil)}]];
                return;
            }
            document = [self downloadDocumentInfo:self.documentGuid error:&error];
            if (!document) {
                if (!error) {
                    error =[WizGlobalError notExistDocumentError];
                    
                }
                [self onError:error];
                return;
            }
        }
        
        if (document) {
            if ([_delegate respondsToSelector:@selector(didLoadDocumentStart:)]) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [_delegate didLoadDocumentStart:document];
                });
            }
        }
        
        if (document.serverChanged) {
            if (![self downloadDocument:document.guid error:&error]) {
                [self onError:error];
                return;
            }
        }
        BOOL canLoad = NO;
        if ([_delegate respondsToSelector:@selector(canLoadDocument:)]) {
            canLoad = [_delegate canLoadDocument:_documentGuid];
        }
        else
        {
            canLoad = NO;
        }
        if (!canLoad) {
            return;
        }
        WizFileManager* fm = [WizFileManager shareManager];
        NSString* documentZiwFile = [fm wizObjectFilePath:self.documentGuid accountUserId:_accountUserId];
        if ([WizGlobals fileLength:documentZiwFile] == 0) {
            [self onError:[WizGlobalError unzipFileError]];
            return;
        }
        NSString* documentIndexFilePath = nil;
        
        if (document.bProtected){
            WizCheckPasswordResult result = [self checkUserPassword:&error];
            if (result == WizCheckPasswordResultSucceed) {
                NSError* error = nil;
                documentIndexFilePath = [[WizFileManager shareManager] documentIndexFileWithEncryptFroReadingPath:document.guid accountUserId:_accountUserId error:&error];
                if (!documentIndexFilePath || error) {
                    [self onError:error];
                    return ;
                }
            }
            else if (result == WizCheckPasswordResultCancel)
            {
                if ([_delegate respondsToSelector:@selector(didLoadDocumentUserCancel:)]) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [_delegate didLoadDocumentUserCancel:_documentGuid];
                    });
                    return;
                }
            }
            else
            {
                [self onError:error];
                return;
            }
        }
        else
        {
            NSError* error = nil;
            documentIndexFilePath = [[WizFileManager shareManager] documentIndexFileFroReadingPath:document.guid accountUserId:_accountUserId error:&error];
            if (!documentIndexFilePath || error) {
                [self onError:error];
                return ;
            }
        }
        if ([_delegate respondsToSelector:@selector(didLoadDocumentSucceed:path:)]) {
            MULTIMAIN(^{
                [_delegate didLoadDocumentSucceed:_documentGuid path:documentIndexFilePath];
            });
        }
    }
}


@end

