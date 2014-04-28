//
//  AD_AppDelegate.h
//  AdvertisingPanorama
//
//  Created by mac on 14-2-18.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AD_AppDelegate : UIResponder <UIApplicationDelegate>
{
    AD_RootViewController *_rootNav;
    UINavigationController *_mainNav;
    UINavigationController *_userCenterNav;
    UINavigationController *_programaNav;
    
    NSMutableArray *_wizDocArray;
    WeiboApi *wbapi;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) AD_RootViewController *rootNav;
@property (strong, nonatomic) UINavigationController *mainNav;
@property (strong, nonatomic) UINavigationController *userCenterNav;
@property (strong, nonatomic) UINavigationController *programaNav;
@property (strong, nonatomic) NSMutableArray *wizDocArray;
@property (strong, nonatomic) WeiboApi *wbapi;


@end
