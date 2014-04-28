//
//  WizAppStatueCenter.h
//  WizNote
//
//  Created by dzpqzb on 13-8-2.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WizAppStatueCenter : NSObject
- (void) triggleSyncGroupViewController:(UIViewController*)viewController;
- (void) removeTriggleSyncGroupViewController:(UIViewController*)vc;
- (void) showGlobalErrorMessage:(NSString*)errorMessages;
//
+ (WizAppStatueCenter*) shareInstance;
@end

