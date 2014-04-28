//
//  WizGlobalCacheGenDocumentAbstractThread.m
//  WizNote
//
//  Created by dzpqzb on 13-7-12.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizGlobalCacheGenDocumentAbstractThread.h"
#import "MKNetworkEngine.h"
#import "WizTokenManger.h"
//
#import "WizNetworkEngine.h"

static float const WizAbstractImageWidthPad =  211;
static float const WizAbstractImageHeightPad = 69;
//

@interface WizGlobalCacheGenDocumentAbstractThread () <WizModifiedDcoumentDelegate>
{
    id<WizTemporaryDataBaseDelegate> db;
    MKNetworkEngine* cacheEngine;
}
@end



@implementation WizGlobalCacheGenDocumentAbstractThread

- (void) clearAbstract:(NSString*)documentGuid kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId
{
    [db deleteAbstractByGUID:documentGuid];
    [[WizGlobalCache shareInstance] clearCacheForDocument:documentGuid kbguid:kbguid accountUserId:accountUserId];
}


- (void) reloadAbstract:(WizGenAbstractWorkObject*)workObject
{
    @autoreleasepool {
        if (workObject.type == WizGenerateAbstractTypeDelete) {
            [self clearAbstract:workObject.docGuid kbguid:workObject.kbguid accountUserId:workObject.accountUserId];
        }
        else if (workObject.type == WizGenerateAbstractTypeReload)
        {
            [self clearAbstract:workObject.docGuid kbguid:workObject.kbguid accountUserId:workObject.accountUserId];
            WizAbstract*  abstract = [self generateAbstract:workObject.docGuid accountUserId:workObject.accountUserId];
            if (abstract != nil) {
                [db updateAbstract:abstract.text imageData:[abstract.image compressedData] guid:workObject.docGuid type:@"" kbguid:@""];
            }
            if (abstract != nil) {
                [[WizGlobalCache shareInstance] addAbstract:abstract forDocumentGuid:workObject.docGuid kbguid:workObject.kbguid accountUserId:workObject.accountUserId];
            }
        }
        else
        {
            WizAbstract* abstract = [db abstractOfDocument:workObject.docGuid];
            if (!abstract) {
                abstract = [self generateAbstract:workObject.docGuid accountUserId:workObject.accountUserId];
                if (abstract != nil) {
                    [db updateAbstract:abstract.text imageData:[abstract.image compressedData] guid:workObject.docGuid type:@"" kbguid:@""];
                }
            }
            if (abstract != nil) {
                [[WizGlobalCache shareInstance] addAbstract:abstract forDocumentGuid:workObject.docGuid kbguid:workObject.kbguid accountUserId:workObject.accountUserId];
            }
        }
    }
}


- (id) init
{
    self = [super init];
    if (self){
        db = [WizDBManager temporaryDataBase];
        [[WizNotificationCenter shareCenter] addModifiedDocumentObserver:self];
    }
    return self;
}


- (WizAbstract*) getAbstractFromServer:(NSString*)documentGuid kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId
{
    
//    NSDictionary* dic = [[WizNetworkEngine shareEngine] abstractData:documentGuid kbguid:kbguid accountUserId:accountUserId];
//    NSLog(@"%@",dic);
    return nil;
}

- (WizAbstract*) generateAbstract:(NSString*)documentGuid accountUserId:(NSString*)accountUserId
{
    
    if (![[WizFileManager shareManager] prepareReadingEnviroment:documentGuid accountUserId:accountUserId])
    {
        return nil;
    }
    NSString* sourceFilePath = [[WizFileManager shareManager] documentIndexFilePath:documentGuid];
    if (![[NSFileManager defaultManager] fileExistsAtPath:sourceFilePath]) {
        return nil;
    }
    NSString* abstractText = nil;
    if ([WizGlobals fileLength:sourceFilePath] < 1024*1024) {
        
        NSString* sourceStr = [NSString stringWithContentsOfFile:sourceFilePath
                                                    usedEncoding:nil
                                                           error:nil];
        if (sourceStr.length > 1024*50) {
            sourceStr = [sourceStr substringToIndex:1024*50];
        }
        NSString* destStr = [sourceStr htmlToText:200];
        destStr = [destStr stringReplaceUseRegular:@"&(.*?);|\\s|/\n" withString:@""];
        if (destStr == nil || [destStr isEqualToString:@""]) {
            destStr = @"";
        }
        if (WizDeviceIsPad) {
            NSRange range = NSMakeRange(0, 150);
            if (destStr.length <= 150) {
                range = NSMakeRange(0, destStr.length);
            }
            abstractText = [destStr substringWithRange:range];
        }
        else
        {
            NSRange range = NSMakeRange(0, 70);
            if (destStr.length <= 70) {
                range = NSMakeRange(0, destStr.length);
            }
            abstractText = [destStr substringWithRange:range];
        }
    }
    else
    {
        NSLog(@"the file name is %@",sourceFilePath);
    }
    NSString* sourceImagePath = [[WizFileManager shareManager] documentIndexFilesPath:documentGuid];
    NSArray* imageFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sourceImagePath  error:nil];
    NSString* maxImageFilePath = nil;
    int maxImageSize = 0;
    for (NSString* each in imageFiles) {
        NSArray* typeArry = [each componentsSeparatedByString:@"."];
        if ([WizGlobals checkAttachmentTypeIsImage:[typeArry lastObject]]) {
            NSString* sourceImageFilePath = [sourceImagePath stringByAppendingPathComponent:each];
            int fileSize = [WizGlobals fileLength:sourceFilePath];
            if (fileSize > maxImageSize && fileSize < 1024*1024) {
                maxImageFilePath = sourceImageFilePath;
            }
        }
    }
    UIImage* compassImage = nil;
    
    if (maxImageFilePath && ![[maxImageFilePath fileName] hasPrefix:WizRecordAttachmentNamePrefix]) {
        float compassWidth= 140;
        float compassHeight = 140;
        UIImage* image = [[UIImage alloc] initWithContentsOfFile:maxImageFilePath];
        
        if ([WizGlobals WizDeviceIsPad]) {
            compassHeight = WizAbstractImageHeightPad;
            compassWidth = WizAbstractImageWidthPad;
        }
        if (nil != image)
        {
            if (image.size.height >= compassHeight && image.size.width >= compassWidth) {
                compassImage = [image wizCompressedImageWidth:compassWidth height:compassHeight];
            }
        }
    }
    
    if (abstractText == nil) {
        abstractText = @"";
    }
    if ([[maxImageFilePath fileName] hasPrefix:@"wiz:open_record_attachment:iphone:ipad__"]) {
        compassImage = nil;
    }
    WizAbstract* abstract = [[WizAbstract alloc] init];
    abstract.guid = documentGuid;
    abstract.text = abstractText;
    abstract.image = compassImage;
    return abstract;
}

- (void) main
{
    while (true)
    {
        @autoreleasepool {
            WizGenAbstractWorkObject* workObject = [[WizWorkQueue genAbstractQueue] workObject];
            if (workObject != nil) {
//                [self getAbstractFromServer:workObject.docGuid kbguid:workObject.kbguid accountUserId:workObject.accountUserId];
                [self reloadAbstract:workObject];
                [[WizWorkQueue genAbstractQueue] removeWorkObject:workObject];
            }
            else
            {
                sleep(10);//100
            }
        }
    }
}
@end

