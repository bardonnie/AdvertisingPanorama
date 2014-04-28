//
//  UIViewController+WIzHidden.m
//  WizNote
//
//  Created by dzpqzb on 13-7-5.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "UIViewController+WIzHidden.h"
@interface UIViewController (WizNavigationController)
- (void) wizPopNavigationController;
@end
@implementation UIViewController(WizNavigationController)

- (void) wizPopNavigationController
{
    if (self.navigationController.presentingViewController && self.navigationController.viewControllers.count == 1) {
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

@end


@implementation UIViewController (WIzHidden)
- (void) addRightToolbarItems:(NSArray*)items
{
    
//    NSMutableArray* array = [NSMutableArray new];
//    //
//    NSArray* toolbarItems = self.toolbarItems;
//    if ([toolbarItems count] && [self.toolbarItems[0] tag] == backItemTag && self.toolbarItems.count > 1) {
//                [array addObjectsFromArray:[toolbarItems subarrayWithRange:NSMakeRange(0, 2)]];
//    }
//    else
//    {
//        UIBarButtonItem* flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//        UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithImage:WizImageByKind(ImageOfCustomerBackBarButton) landscapeImagePhone:WizImageByKind(ImageOfCustomerBackBarButton) style:UIBarButtonItemStyleDone target:self action:@selector(wizPopNavigationController)];
//        backItem.tag = backItemTag;
//        [array addObject:backItem];
//        [array addObject:flexItem];
//    }
//    [array addObjectsFromArray:items];
//    self.toolbarItems  = array;
}

- (void) addPopNaviagtionToolbarItem:(UIViewController*)contentViewController
{
//    
//    UIBarButtonItem* flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithImage:WizImageByKind(ImageOfCustomerBackBarButton) landscapeImagePhone:WizImageByKind(ImageOfCustomerBackBarButton) style:UIBarButtonItemStyleDone target:contentViewController action:@selector(wizPopNavigationController)];
//    NSMutableArray* items = [NSMutableArray new];
//    backItem.tag = backItemTag;
//    if (contentViewController.toolbarItems && contentViewController.toolbarItems.count) {
//        UIBarButtonItem* item = contentViewController.toolbarItems[0];
//        if (item.tag == backItemTag) {
//            return;
//        }
//        else
//        {
//            NSMutableArray* array = [NSMutableArray arrayWithArray:contentViewController.toolbarItems];
//            [array insertObject:flexItem atIndex:0];
//            [array insertObject:backItem atIndex:0];
//            
//            contentViewController.toolbarItems = array;
//        }
//    }
//    else
//    {
//        contentViewController.toolbarItems = @[backItem, flexItem];
//    }
}

@end
