//
//  WizCommentViewController.m
//  WizIphone7
//
//  Created by dzpqzb on 13-9-11.
//  Copyright (c) 2013年 dzpqzb inc. All rights reserved.
//

#import "WizCommentViewController.h"
#import "WizTokenManger.h"
#import "SVProgressHUD.h"
#import "WizNetworkEngine.h"
@interface WizCommentViewController () <UIWebViewDelegate>
{
    UIWebView* _commentWebView;
}
@end

@implementation WizCommentViewController
@synthesize group;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) loadView
{
    _commentWebView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    _commentWebView.delegate = self;
    self.view = _commentWebView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
- (void) webViewDidStartLoad:(UIWebView *)webView
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading comments...", nil)];
}
- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [SVProgressHUD dismiss];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        NSError* error = nil;
        NSURL* url = [[WizNetworkEngine shareEngine] commentUrlWithAccountUserId:self.group.accountUserId kbguid:self.group.guid documentGuid:self.documentGuid error:&error];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (!url || error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }
            else
            {
                NSURLRequest* requst = [NSURLRequest requestWithURL:url];
                [_commentWebView loadRequest:requst];
            }
        });
    });
   
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
