//
//  WizReadDocumentOperation.h
//  WizNote
//
//  Created by dzpqzb on 13-6-19.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol WizLoadDocumentOperationDelegate <NSObject>
- (void) didLoadDocumentStart:(WizDocument*) document;
- (void) didLoadDocumentFaild:(NSString*)documentGuid error:(NSError*)error;
- (void) didLoadDocumentSucceed:(NSString*)documentGuid path:(NSString*)documentFilePath;
- (void) didLoadDocumentUserCancel:(NSString*)documentGuid;
- (BOOL) canLoadDocument:(NSString*)documentGuid;
@end


typedef enum {
    WizCheckPasswordResultStart =1000,
    WizCheckPasswordResultEnd ,
    WizCheckPasswordResultCancel,
    WizCheckPasswordResultSucceed,
    WizCheckPasswordResultFaild
}WizCheckPasswordResult;



@interface WizReadDocumentOperation : NSOperation <UIAlertViewDelegate>
@property (nonatomic, strong) NSString* documentGuid;
@property (nonatomic, strong) NSString* accountUserId;
@property (nonatomic, strong) NSString* kbguid;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, weak) id<WizLoadDocumentOperationDelegate> delegate;
@property (nonatomic, strong) NSCondition* checkPasswordCondition;
@property (atomic, assign) WizCheckPasswordResult checkPasswordResult;
@property (atomic, strong) NSString* userPassword;
- (id) initWithDocumentGuid:(NSString*)documentGuid accountUserId:(NSString*)accountUserId kbguid:(NSString*)kbguid;
@end