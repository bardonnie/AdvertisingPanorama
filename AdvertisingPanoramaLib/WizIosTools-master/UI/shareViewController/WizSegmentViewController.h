//
//  WizSegmentViewController.h
//  WizSegmentViewController
//
//  Created by dzpqzb on 13-3-18.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WizSegmentViewController : UIViewController
- (id) initWithChildViewController:(NSArray*)viewControllers titles:(NSArray*)titles;
- (void) setViewControllers:(NSArray*)vcs titles:(NSArray*)titles;
@end
