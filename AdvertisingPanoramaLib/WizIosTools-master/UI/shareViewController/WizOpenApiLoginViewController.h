//
//  WizOpenApiLoginViewController.h
//  WizNote
//
//  Created by CHJK on 13-5-16.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WizOpenApiLoginViewController;
@protocol WizSelectAccountDelegate <NSObject>
- (void) willSelectAccount:(NSString*)accountUserId;
- (void) willDismissOpenApiViewController:(WizOpenApiLoginViewController*)openViewController;
@end

@interface WizOpenApiLoginViewController : UIViewController <UIWebViewDelegate,WizVerifyAccountDelegate>

@property (nonatomic, strong) UIWebView * webView;
@property (nonatomic, strong ) id <WizSelectAccountDelegate> delegate;

@end
