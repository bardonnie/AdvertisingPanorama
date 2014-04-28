//
//  UIWebView+WizWebViewAddition.m
//  WizNote
//
//  Created by wzz on 13-5-31.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "UIWebView+WizWebViewAddition.h"
#import "Reachability.h"

@implementation UIWebView (WizWebViewAddition)
- (void)noNetworkConnection
{
//    NSString* text = NSLocalizedString(@"The internet connection appears to be offline.", nil);
    if (![Reachability reachabilityWithHostname:@"www.wiz.cn"].isReachable) {
//        UIView* noNetWorkView = [WizUIGlobals WizNoContentPromptView:CGRectSetOrigin(self.frame, CGPointZero) image:WizImageByKind(ImageOfNoMessages) text:text detailText:nil];//[WizUIGlobals WizNoMessageView:CGRectSetOrigin(self.frame, CGPointZero) text:text detailText:nil];[
//        [self addSubview:noNetWorkView];
        return ;
    }
}
@end
