//
//  AD_NetWork.h
//  AdvertisingPanorama
//
//  Created by mac on 14-2-19.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AD_NetWorkDelegate <NSObject>

- (void)downloadFinish:(NSData *)data;
- (void)downloadFaild;

@end

@interface AD_NetWork : NSObject< WizSyncKbDelegate, WizSyncDownloadDelegate, WizGenerateAbstractDelegate>

@property (weak, nonatomic) __weak id< AD_NetWorkDelegate> delegate;
@property (strong, nonatomic) NSString *tmpPath;
@property (strong, nonatomic) NSArray *wizDocArray;

+ (AD_NetWork *)shareNetWork;
+ (NSArray *)addProgramaArray;
- (void)startDownloadWithURL:(NSString *)url;
- (void)addWizObserver;
- (void)updateAccount;
- (void)offLineDownload;
- (void)qqPostRequest;

- (NSArray *)requestPart:(NSString *)partGuid;

@end
