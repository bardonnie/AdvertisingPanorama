//
//  WizInterfaceEngine.m
//  WizNote
//
//  Created by wzz on 13-4-3.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizInterfaceEngine.h"
#import "UIColor+SSToolkitAdditions.h"
static WizThemeType WizGlobalThemeType = WizThemeTypeBlue;
static NSString* WizGlobalThemeFilePath = @"";
@interface WizInterfaceEngine ()
+ (NSDictionary*) interfaceFileContent;
@end

 NSString* (^WizThemTypeKey)(WizThemeType) = ^(WizThemeType type)
{
    switch(type)
    {
            case WizThemeTypeBlue:
            return KeyOfWizThemeBlue;
            default:
            return KeyOfWizThemeBlue;
    }
};

UIImage* (^WizImageByTheme)(WizThemeType , NSString* kind) = ^(WizThemeType type, NSString* kind)
{
    NSString* imageName = [[[WizInterfaceEngine interfaceFileContent] objectForKey:WizThemTypeKey(type)] objectForKey:kind];
    UIImage* image = [UIImage imageNamed:imageName];
    return image;
};


UIImage* (^WizImageByKind)(NSString*kind) = ^(NSString*kind)
{
    return WizImageByTheme(WizGlobalThemeType, kind);
};

UIColor* (^WizColorByTheme)(WizThemeType , NSString* kind) = ^(WizThemeType type, NSString* kind)
{
    NSString* str = [[[WizInterfaceEngine interfaceFileContent]objectForKey:WizThemTypeKey(type)]objectForKey:kind];
    CGRectSetHeight(CGRectZero, 100);
    return  [UIColor colorWithHex:str];
};

NSString* (^WizStringByKind)(NSString* kind) = ^(NSString* kind)
{
    return [[[WizInterfaceEngine interfaceFileContent]objectForKey:WizThemTypeKey(WizGlobalThemeType)]objectForKey:kind];
};

UIColor* (^WizColorByKind)(NSString*kind) = ^(NSString* kind)
{
    return WizColorByTheme(WizGlobalThemeType,kind);
};

UIColor* (^WizColorPatternByKind)(NSString* kind) = ^(NSString* kind)
{
    UIImage* image = WizImageByKind(kind);
    return [UIColor colorWithPatternImage:image];
};

NSArray* (^WizArrayByTheme)(WizThemeType, NSString*kind) = ^ (WizThemeType type, NSString* kind)
{
    return [[[WizInterfaceEngine interfaceFileContent]objectForKey:WizThemTypeKey(type)]objectForKey:kind];
};

NSArray* (^WizArrayByKind)(NSString*kind) =^ (NSString*kind)
{
    return WizArrayByTheme(WizGlobalThemeType,kind);
};

UIImage* (^WizImageAttachmentByKind)(NSString*kind) = ^(NSString* fileType)
{
    NSString* imageName = [NSString stringWithFormat:@"detail_%@",[fileType lowercaseString]];
    UIImage* image = [UIImage imageNamed:imageName];
    if (!image) {
        image = [UIImage imageNamed:@"detail_others"];
    }
    return image;
};



NSArray* (^WizImagesArrayByKind)(NSString*kind) = ^(NSString* kind)
{
    NSArray* images = WizArrayByKind(kind);
    NSMutableArray* array = [NSMutableArray new];
    for(NSString* each in images)
    {
        UIImage* image = [UIImage imageNamed:each];
        if(image)
        {
            [array addObject:image];
        }
    }
    return array;
};

@implementation WizInterfaceEngine
+ (void) loadInterfaceTheme:(WizThemeType)type
{
    
}
+ (NSDictionary*) interfaceFileContent
{
    
    static NSDictionary* interfaceFileContent =  nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        interfaceFileContent = [NSDictionary dictionaryWithContentsOfFile:WizGlobalThemeFilePath];
    });
    return interfaceFileContent;
}

+ (UIImage*)navigationBackgroundImage:(WizThemeType)type
{
    return  WizImageByTheme(type, NavigationBackgroudImage);
}

+ (UIImage*)viewBackgroundImage:(WizThemeType)type
{
    return WizImageByTheme(type,GroupViewBackgroundImage);
}

+ (UIImage*)toolBarBackgroundImage:(WizThemeType)type
{
    return WizImageByTheme(type, ToolBarBackgroundImage);
}


+ (void)loadInterfaceTheme:(WizThemeType)type themeFileName:(NSString*)name
{
    WizGlobalThemeType = type;
    WizGlobalThemeFilePath = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"];
}

+ (NSArray *)imagesArrayForKind:(NSString *)kind
{
    NSMutableArray* imageArray = [NSMutableArray array];
    NSArray* nameArray = WizArrayByKind(kind);
    for (NSString* each in nameArray) {
        UIImage* image = [UIImage imageNamed:each];
        if (image) {
            [imageArray addObject:image];
        }
    }
    return imageArray;
}
@end
