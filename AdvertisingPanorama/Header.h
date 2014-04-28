//
//  Header.h
//  AdvertisingPanorama
//
//  Created by mac on 14-2-18.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//



typedef enum
{
    Home,
    Editorial,
    Subject,
    Focus,
    Trend,
    Person,
    Cases,
    Media,
    Tiger,
    Observer
}ViewControllers;

#define USER_ID             @"adp@vip.163.com"
#define USER_PASSWORD       @"pankr2014001"
#define KBGUID              @"5a01e5aa-7391-498f-a4be-34057537cc91"
#define ADVERTISEMENTPART_GUID  @"113a2ef6-662c-4e8d-adff-a9891fc4e2c0"
#define ADVERTISEMENT_GUID      @"4b96c6ae-37cb-40b8-85a0-c24555f326e4"

#pragma mark - localHost

#define LOCALHOST       @"http://apiguanggaodaguan.trends-china.com/Service.ashx?%@"
#define LOCALHOST_NEW   @"http://apiguanggaodaguan.trends-china.com/dowork.aspx?%@"

#pragma mark - userinfo

#define ADD_USER        @"comm=user&action=add&ctype=1&source=%d&name=%@&Pwd=%@&rname=%@"
#define GET_USER        @"comm=user&action=get&userid=%@"
#define VERIFY_USER     @"comm=user&action=verify&name=%@&Pwd=%@"
#define UPDATE_PWD      @"comm=user&action=verify&name=%@&Pwd=%@&newPwd=%@"
#define RETRIEVE_PWD    @"comm=user&action=retrieve_pwd&name=%@&email=%@"
#define BINDE_MAIL      @"comm=user&action=bindemail&userid=%@&email=zhendong.yao@trends-china.com "
#define UPDATE_USER     @"comm=user&action=update&userid=%@&nickname=%@&sex=%@&province=%@&area=%@&headimg=%@"
#define UPLOAD_HEADER   @"comm=user&action=upload_headimg&userid=%@&filename=%@"

#pragma mark - comments

#define POST_COMM       @"comm=comments&action=post&ctype=1&userid=%@&articleid=%@&content=%@"
#define REPLY_COMM      @"comm=comments&action=reply&ctype=1&userid=%@&touserid=%@&commentid=%@&articleid=%@&content=%@"
#define SHOW_COMM       @"comm=comments&action=show&articleid=%@&count=%@&minid=%@"
#define GET_COMM_NUM    @"_action=GetCommentNumByArticleIDs&articleIDs=%@"
#define GET_ALL_COMM    @"_action=GetCommentByUserIdAndArticleId&articleId=%@"

#pragma mark - collect

#define ADD_COLL        @"_action=AddCollect&articleID=%@&userId=%@"
#define CANCEL_COLL     @"_action=CancelCollect&articleID=%@&userId=%@"
#define GET_COLL        @"_action=GetUserCollectListByUserId&userId=%@"
#define IS_COLL         @"_action=IsCollect&userId=%@&articleId=%@"

#pragma mark - feedback

#define POST_FEEDBACK   @""

#pragma mark - QQ

#define APP_KEY         @"801484606"
#define APP_SECRET      @"789b23c8a6eff7841f2a669033e84259"
#define APP_URL         @"http://yingjietongxuntest.trends-china.com/"

#define OAUTH   @"https://open.t.qq.com/cgi-bin/oauth2/authorize?client_id=%@&response_type=code&redirect_uri=%@wap=2&appfrom=ios"

#import <QuartzCore/QuartzCore.h>

#import "WizGlobals.h"
#import "WizAccountManager.h"
#import "WizObject.h"
#import "CommonString.h"
#import "WizLogger.h"
#import "WizSettings.h"

#import "UIDefine.h"

#import "MMDrawerController.h"
#import "UIViewController+MMDrawerController.h"
#import "CBTextView.h"
#import "AFNetworking.h"
#import "UIColor+Hex.h"
#import "PNColor.h"
#import "Animations.h"
#import "SVProgressHUD.h"
#import "DataBase.h"
#import "FileSize.h"
#import "Reachability.h"
#import "WeiboSDK.h"
#import "WXApi.h"
#import "WeiboApi.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#import "SBJson4.h"

#import "AD_RootViewController.h"
#import "AD_AppDelegate.h"
#import "AD_MainViewController.h"
#import "AD_ProgramaViewController.h"
#import "AD_UserCenterViewController.h"
#import "AD_PartViewController.h"
#import "AD_ArticleViewController.h"
#import "AD_CommentViewController.h"
#import "AD_CollectViewController.h"
#import "AD_LoginViewController.h"
#import "AD_RegisterViewController.h"
#import "AD_AboutViewController.h"
#import "AD_SettingViewController.h"
#import "AD_FeedbackViewController.h"
#import "AD_RePwdViewController.h"

#import "AD_NetWork.h"

#import "AD_HomeCell.h"
#import "AD_PartCell.h"




#define WINDOW_WIDTH 246.0f





