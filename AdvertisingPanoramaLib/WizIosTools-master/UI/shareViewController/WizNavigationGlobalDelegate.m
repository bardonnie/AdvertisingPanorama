//
//  WizNavigationGlobalDelegate.m
//  WizNote
//
//  Created by dzpqzb on 13-7-5.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizNavigationGlobalDelegate.h"
#import "WizTagsListViewController.h"
#import "WizFoldersListViewController.h"
#import "WizIphoneReadViewController.h"
#import "WizAllNoteViewController.h"
#import "WizFolderTreeViewController.h"
#import "WizTagTreeViewController.h"
#import "SelectFloderView.h"
#import "UIViewController+WIzHidden.h"
#import "WizSelectTagViewController.h"
#import "WizMessagesViewController.h"
#import "WizSelectGroupViewController.h"
#import "WizEditNoteNavigationViewController.h"
#import "WizSearchHistoryViewController.h"
#import "WizSearchResultViewController.h"
#import "WizSelectFolderViewController.h"

@implementation WizNavigationGlobalDelegate
+ (WizNavigationGlobalDelegate*) shareInstance
{
    static WizNavigationGlobalDelegate* shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [WizNavigationGlobalDelegate new];
    });
    return shareInstance;
}

- (void) navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController isKindOfClass:[WizAllNoteViewController class]]) {
        [navigationController setToolbarHidden:YES animated:YES];
        [navigationController setNavigationBarHidden:NO animated:YES];
    }
    else if ([viewController isKindOfClass:[WizFolderTreeViewController class]])
    {
        [navigationController setToolbarHidden:YES animated:YES];
        [navigationController setNavigationBarHidden:NO animated:YES];
    }
    else if ([viewController isKindOfClass:[WizTagTreeViewController class]])
    {
        [navigationController setToolbarHidden:YES animated:YES];
        [navigationController setNavigationBarHidden:NO animated:YES];
    }
    else if ([viewController isKindOfClass:[WizFoldersListViewController class]])
    {
        [navigationController setToolbarHidden:YES animated:YES];
        [navigationController setNavigationBarHidden:NO animated:YES];
    }
    else if ([viewController isKindOfClass:[WizTagsListViewController class]])
    {
        [navigationController setToolbarHidden:YES animated:YES];
        [navigationController setNavigationBarHidden:NO animated:YES];
    }
    else if ([viewController isKindOfClass:[WizIphoneReadViewController class]])
    {
        [navigationController setToolbarHidden:NO animated:YES];
        [navigationController setNavigationBarHidden:NO animated:YES];
    }
    else if ([viewController isKindOfClass:[DocumentInfoViewController class]])
    {
        [navigationController setNavigationBarHidden:NO animated:YES];
        [navigationController setToolbarHidden:YES animated:YES];
    }
    else if ([viewController isKindOfClass:[SelectFloderView class]])
    {
        [navigationController setToolbarHidden:YES animated:YES];
        [navigationController setNavigationBarHidden:NO animated:YES];
    }
    else if ([viewController isKindOfClass:[WizSelectTagViewController class]])
    {
        [navigationController setToolbarHidden:YES animated:YES];
        [navigationController setNavigationBarHidden:NO animated:YES];
    }
    else if ([viewController isKindOfClass:[WizSelectFolderViewController class]])
    {
        [navigationController setToolbarHidden:YES animated:YES];
        [navigationController setNavigationBarHidden:NO animated:YES];
    }
   
    else if ([viewController isKindOfClass:[WizMessagesViewController class]])
    {
        [navigationController setToolbarHidden:YES animated:YES];
        [navigationController setNavigationBarHidden:NO animated:YES];
        
    }
    else if ([viewController isKindOfClass:[WizEditViewController class]])
    {
        [navigationController setToolbarHidden:YES animated:YES];
        [navigationController setNavigationBarHidden:NO animated:YES];
    }
    else if ([viewController isKindOfClass:[WizSearchHistoryViewController class]])
    {
        [navigationController setToolbarHidden:YES animated:YES];
        [navigationController setNavigationBarHidden:NO animated:YES];
    }
    else if ([viewController isKindOfClass:[WizSearchResultViewController class]])
    {
        [navigationController setToolbarHidden:YES animated:YES];
        [navigationController setNavigationBarHidden:NO animated:YES];
    }
    else if ([viewController isKindOfClass:[WizSelectGroupViewController class]])
    {
        [navigationController setToolbarHidden:YES animated:YES];
        [navigationController setNavigationBarHidden:NO animated:YES];
    }
}
@end
