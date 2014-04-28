//
//  WizNavigationGlobalDelegate.h
//  WizNote
//
//  Created by dzpqzb on 13-7-5.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WizNavigationGlobalDelegate : UIViewController <UINavigationControllerDelegate>
+ (WizNavigationGlobalDelegate*) shareInstance;
@end
