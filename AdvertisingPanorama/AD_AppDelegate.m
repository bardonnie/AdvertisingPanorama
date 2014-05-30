//
//  AD_AppDelegate.m
//  AdvertisingPanorama
//
//  Created by mac on 14-2-18.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//


#define TOKEN_URL   @"http://apiguanggaodaguan.trends-china.com/dowork.aspx?_action=GetWizLoginInfoByUserIDAndPassword&userid=%@&password=%@"

#import "AD_AppDelegate.h"
#import "AD_NetWork.h"
#include <sys/xattr.h>


@interface AD_AppDelegate ()< WeiboSDKDelegate, WXApiDelegate, WeiboRequestDelegate,WeiboAuthDelegate, AD_NetWorkDelegate>

@end

@implementation AD_AppDelegate
{
    AD_ArticleViewController *_articleVc;
}

@synthesize rootNav = _rootNav;
@synthesize mainNav = _mainNav;
@synthesize userCenterNav = _userCenterNav;
@synthesize programaNav = _programaNav;
@synthesize wizDocArray = _wizDocArray;
@synthesize wbapi;


- (void)downloadFinish:(NSData *)data
{
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    if ([[dic objectForKey:@"message"] isEqual:@"success"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:[dic objectForKey:@"token"] forKey:@"token"];
    }
    NSLog(@"dic - %@",dic);
}

- (void)downloadFaild
{
    
}

#pragma mark - Setting the Extended Attribute on iOS 5.0.1

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    const char* filePath = [[URL path] fileSystemRepresentation];
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    // 分享组件
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:@"3333429973"];
    
    [WXApi registerApp:@"wx5b46214afc6bd2a9"];
    
    [[AD_NetWork shareNetWork] startDownloadWithURL:[NSString stringWithFormat:TOKEN_URL,USER_ID,USER_PASSWORD]];
    [AD_NetWork shareNetWork].delegate = self;
        
    // 腾讯微博分享
    if(self->wbapi == nil)
    {
        self->wbapi = [[WeiboApi alloc] initWithAppKey:APP_KEY andSecret:APP_SECRET andRedirectUri:APP_URL] ;
    }
    
    [[AD_NetWork shareNetWork] addWizObserver];

    if (IOS7_OR_LATER) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigation_bar_64"] forBarMetrics:UIBarMetricsDefault];
    }
    else
    {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigation_bar"] forBarMetrics:UIBarMetricsDefault];
    }
    [application setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSLog(@"path - %@",paths);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    [self addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:documentsDirectory]];

    AD_MainViewController *mainViewController = [[AD_MainViewController alloc] init];
    _mainNav = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    
    AD_ProgramaViewController *programaViewController = [[AD_ProgramaViewController alloc] init];
    _programaNav = [[UINavigationController alloc] initWithRootViewController:programaViewController];
    
    AD_UserCenterViewController *userCenterViewController = [[AD_UserCenterViewController alloc] init];
    _userCenterNav = [[UINavigationController alloc] initWithRootViewController:userCenterViewController];
    
    MMDrawerController *drawerController = [[MMDrawerController alloc] initWithCenterViewController:_mainNav leftDrawerViewController:programaViewController rightDrawerViewController:userCenterViewController];
    _rootNav = [[AD_RootViewController alloc] initWithRootViewController:drawerController];
    
    [drawerController setMaximumLeftDrawerWidth:WINDOW_WIDTH];
    [drawerController setMaximumRightDrawerWidth:WINDOW_WIDTH];
    [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"everLaunched01"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"everLaunched01"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch01"];
        
        UIControl *guideControl = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, MAIN_WINDOW_WIDTH, MAIN_WINDOW_HEIGHT)];
        [guideControl addTarget:self action:@selector(guideControlClick:) forControlEvents:UIControlEventTouchDown];
        if (MAIN_WINDOW_HEIGHT == 480) {
            guideControl.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"guide"]];
        }
        else
        {
            guideControl.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"guide_5"]];
        }
        [drawerController.view addSubview:guideControl];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"OffLine"];
        
        [[NSUserDefaults standardUserDefaults] setValue:@"1000" forKey:@"userID"];
    }
    else{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch01"];
        NSLog(@"--2");
    }
    
    self.window.rootViewController = _rootNav;
    
    _articleVc = [[AD_ArticleViewController alloc] init];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)guideControlClick:(UIControl *)sender
{
    NSLog(@"sender - %@",sender);
    [UIView animateWithDuration:1 animations:^{
        [sender removeFromSuperview];
    }];
}

#pragma mark - sso
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [WeiboSDK handleOpenURL:url delegate:self]|[WXApi handleOpenURL:url delegate:self] || [wbapi handleOpenURL:url];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
