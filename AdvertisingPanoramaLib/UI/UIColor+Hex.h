//
//  UIColor+Hex.h
//  HuiGe
//
//  Created by mac on 13-11-26.
//  Copyright (c) 2013年 trends-china. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIColor_Hex : NSObject

+ (UIColor *)colorWithHex:(long)hexColor;
+ (UIColor *)colorWithHex:(long)hexColor alpha:(float)opacity;

@end
