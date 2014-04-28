//
//  WizAttachmentImage.m
//  WizIphone7
//
//  Created by wzz on 13-11-26.
//  Copyright (c) 2013年 dzpqzb inc. All rights reserved.
//

#import "WizAttachmentImage.h"

//NSString*
float fileSize = 0.0;

@interface WizAttachmentImage()
{
    UIImage* typeImage;
    NSString* timeString;
    NSString* fileSizeString;
}
@end

@implementation WizAttachmentImage
@synthesize fileName = _fileName;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        typeImage = [UIImage imageNamed:@"detail_wav"];
    }
    return self;
}

- (UIImage *)shotImage
{
    timeString = [[NSDate date] stringSql];
    [self setNeedsDisplay];
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *uiImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return uiImage;
}

+ (UIImage *)attachmentImageWithFile:(NSString *)name fileSize:(float)kbSize
{
    fileSize = kbSize;
    WizAttachmentImage* attachmentImage = [[WizAttachmentImage alloc]initWithFrame:CGRectMake(0, 0, 200, 50)];
    attachmentImage.fileName = name;
    return [attachmentImage shotImage];
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath* bezierPath = [UIBezierPath bezierPathWithRect:rect];
//    [WizColorByKind(ColorOfDefaultBackgroud) setFill];
    [[UIColor colorWithHexHex:0xf5f7fb] setFill];
    [bezierPath fill];
    [[UIColor grayColor] setStroke];
    [bezierPath stroke];
    
    [typeImage drawAtPoint:CGPointMake(10, (CGRectGetHeight(self.bounds) - typeImage.size.height)/2.0)];
    
    [[UIColor darkGrayColor] setFill];
    [[UIColor darkGrayColor] setStroke];
    [_fileName drawInRect:CGRectMake(40, 8, CGRectGetWidth(self.bounds) - 50, 16) withFont:[UIFont systemFontOfSize:14]];
    if (fileSize < 1024) {
        fileSizeString = [NSString stringWithFormat:@"，%.2fKB",fileSize];
    }else{
        fileSize = fileSize / 1024.0;
        fileSizeString = [NSString stringWithFormat:@"，%.2fM",fileSize];
    }
    timeString = [timeString stringByAppendingString:fileSizeString];
    [timeString drawAtPoint:CGPointMake(40, 27) withFont:[UIFont systemFontOfSize:10]];
}


@end
