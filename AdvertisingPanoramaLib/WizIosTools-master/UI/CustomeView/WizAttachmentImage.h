//
//  WizAttachmentImage.h
//  WizIphone7
//
//  Created by wzz on 13-11-26.
//  Copyright (c) 2013年 dzpqzb inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WizAttachmentImage : UIView
@property (nonatomic, strong)NSString* fileName;
+ (UIImage*)attachmentImageWithFile:(NSString*)name fileSize:(float)kbSize;
@end
