//
//  UIViewController+WIzHidden.h
//  WizNote
//
//  Created by dzpqzb on 13-7-5.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (WIzHidden)
- (void) addRightToolbarItems:(NSArray*)items;
- (void) addPopNaviagtionToolbarItem:(UIViewController*)contentViewController;
@end
