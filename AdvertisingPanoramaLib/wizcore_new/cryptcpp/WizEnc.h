//
//  WizEnc.h
//  WizNote
//
//  Created by WeiShijun on 13-4-15.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#ifndef __WizNote__WizEnc__
#define __WizNote__WizEnc__

#ifdef __cplusplus
extern "C"
{
#endif
    
enum WizDecryptZiwResult
{
    wizDone,
    wizInvalidPassword,
    wizInvalidArguments,
    wizCannotOpenSrcFile,
    wizCannotWriteFile,
    wizNotEncrypted,
    wizUnknownError,
};



enum WizDecryptZiwResult WizDecryptZiw_NS(NSString* n, NSString* e, NSString* decrypted_d, NSString* password, NSString* encryptedZiwFileName, NSString* decryptedZiwFileName);
enum WizDecryptZiwResult WizDecryptZiw(const char* N, const char* e, const char* decrypted_d, const char* password, const char* encryptedZiwFileName, const char* decryptedZiwFileName);

extern   BOOL IsWizKMZiwFileEnrypt(NSString* filePath);
#ifdef __cplusplus
}
#endif

#endif /* defined(__WizNote__WizEnc__) */
