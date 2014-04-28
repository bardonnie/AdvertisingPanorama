//
//  UINavigationController+WizNavigationController.h
//  WizNote
//
//  Created by wzz on 13-5-17.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (WizNavigationController)
- (void)addTarge:(id)target action:(SEL)seletor;
- (void)removeTarget:(id)target;
@end
