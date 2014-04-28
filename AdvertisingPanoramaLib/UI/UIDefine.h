//
//  HWT_UIDefine.h
//  HuiWuTong
//
//  Created by mac on 13-11-18.
//  Copyright (c) 2013年 trends-china. All rights reserved.
//


// 判断系统版本
#define IOS7_OR_LATER   ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

// 屏幕高度
#define     MAIN_WINDOW_HEIGHT      ([[UIScreen mainScreen] bounds].size.height)

// 屏幕宽度
#define     MAIN_WINDOW_WIDTH       ([[UIScreen mainScreen] bounds].size.width)

// 导航栏高度
#define     NAV_BAR_HEIGHT      44.0f

// 选项卡高度
#define     TAB_BAR_HEIGHT      49.0f

// 状态栏高
#define     STATUS_BAR_HEIGHT   20.0f

// 选择控制器高度
#define     SEGMENTED_CONTROL_HEIGHT    28.0f

// 导航栏and状态栏
#define     STATUS_BAR_AND_NAV_BAR_HEIGHT   64.0f

// 确定空间位置高
#define     SPACE_HEIGHT    (IOS7_OR_LATER?(MAIN_WINDOW_HEIGHT):(MAIN_WINDOW_HEIGHT-NAV_BAR_HEIGHT-STATUS_BAR_HEIGHT))

// 判断系统版本-->确定Y坐标
#define IOS7_OR_LATER_Y   (IOS7_OR_LATER?(NAV_BAR_HEIGHT+STATUS_BAR_HEIGHT):NAV_BAR_HEIGHT)

// 确定视图高度(无Tabbar)
#define     NAV_VIEW_HEIGHT     (MAIN_WINDOW_HEIGHT-NAV_BAR_HEIGHT-STATUS_BAR_HEIGHT)

// 确定视图高度(有Tabbar)
#define     NAV_TAB_VIEW_HEIGHT     (MAIN_WINDOW_HEIGHT-NAV_BAR_HEIGHT-TAB_BAR_HEIGHT-STATUS_BAR_HEIGHT)

// 确定视图高度(无Tabbar 无Navbar)
#define     IOS7_MAINVIEW_HEIGHT     (IOS7_OR_LATER?MAIN_WINDOW_HEIGHT:(MAIN_WINDOW_HEIGHT-STATUS_BAR_HEIGHT))

// 键盘高度
#define     KEYBOARD_HEIGHT     216.0f

// 显示状态栏
#define IOS7_STATUS_BAR_HEIGHT (IOS7_OR_LATER?STATUS_BAR_HEIGHT:0)


// 颜色转换
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]











