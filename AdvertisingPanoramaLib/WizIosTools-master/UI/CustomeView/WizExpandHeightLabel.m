//
//  WizExpandHeightLabel.m
//  WizNote
//
//  Created by dzpqzb on 13-4-15.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizExpandHeightLabel.h"

@implementation WizExpandHeightLabel

- (void) setText:(NSString *)text
{
    [super setText:text];
    float width = CGRectGetWidth(self.bounds);
    if (width < 3) {
        width = [WizGlobals WizDeviceIsPad]? 800: 400;
    }
    CGSize theStringSize = [self.text sizeWithFont:self.font
                                 constrainedToSize:CGSizeMake(width, 1000)
                                     lineBreakMode:self.lineBreakMode];
    float height = theStringSize.height > 1 ? theStringSize.height : 20;
    height += 20;
    CGRect rect  = CGRectSetHeight(self.frame, height);
    self.frame = rect;
}

@end