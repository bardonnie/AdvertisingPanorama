//
//  WizOpenApiLoginViewController.m
//  WizNote
//
//  Created by CHJK on 13-5-16.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "WizOpenApiLoginViewController.h"
#import "NSString+SSToolkitAdditions.h"
#import "MBProgressHUD.h"

@interface WizOpenApiLoginViewController ()
{
    UIBarButtonItem* itemBack;
    UIBarButtonItem* itemReload;
}
@end

@implementation WizOpenApiLoginViewController
@synthesize webView;
@synthesize delegate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        webView = [[UIWebView alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initNavigationBar];
    webView.userInteractionEnabled = YES;
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    webView.contentMode = UIViewContentModeScaleAspectFit;
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.webView];
}
- (void) dismissViewController
{
    [self.delegate willDismissOpenApiViewController:self];
}
- (void)initNavigationBar {
    self.navigationItem.title = NSLocalizedString(@"Login", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:WizStrCancel style:UIBarButtonItemStyleBordered target:self action:@selector(dismissViewController)];
    self.view.backgroundColor = WizColorByKind(ColorOfDefaultBackgroud);
    UIBarButtonItem* flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    itemBack = [UIBarButtonItem itemWithImage:WizImageByKind(ImageIphoneLoginIconBack) target:self action:@selector(webViewBack)];
    itemReload = [UIBarButtonItem itemWithImage:WizImageByKind(ImageIphoneLoginIconFresh) target:self action:@selector(webViewReload)];
    self.toolbarItems=@[flexibleItem,itemBack,flexibleItem,itemReload,flexibleItem];
}

-(void) webViewBack{
    if (self.webView.canGoBack)
        [self.webView goBack];
}

-(void) webViewReload{
    [self.webView reload];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.toolbarHidden = YES;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    webView.frame = self.view.bounds;

    NSURL* url = nil;
    NSString *urlstr=[NSString stringWithFormat:@"http://api.wiz.cn/?p=wiz&c=snspage&plat=ios&l=%@",[WizGlobals localLanguageKey]];
    url = [[NSURL alloc] initWithString:urlstr];
    NSURLRequest* req = [[NSURLRequest alloc] initWithURL:url];
    [webView loadRequest:req];
    self.navigationController.toolbarHidden = NO;
}

- (BOOL)webView:(UIWebView *)webView1 shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *url=[[request URL] absoluteString];
    NSString *prefix=@"http://as.wiz.cn/wizas/htmlpages/wiznote_oauth_success.html?";
    if ([url hasPrefix:prefix]){
        NSString *para=[[url substringWithRange:NSMakeRange([prefix length], url.length-prefix.length)] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSArray *paras=[para componentsSeparatedByString:@"&"];

        NSString *username=@"";
        NSString *password=@"";
//        NSString *loginType=@"";

        for (NSString *str in paras){
            NSArray *kv= [str componentsSeparatedByString:@"="];
            if ([[kv objectAtIndex:0] isEqualToString:@"user_id"]){
                username=[kv objectAtIndex:1];
            } else if ([[kv objectAtIndex:0] isEqualToString:@"access_token"]){
                password=[NSString stringWithBase64String:[kv objectAtIndex:1]];
            } else if ([[kv objectAtIndex:0] isEqualToString:@"login_type"]){
//                loginType=[kv objectAtIndex:1];
            }
        }

        WizVerifyAccountOperation* verifyOperation = [[WizVerifyAccountOperation alloc]initWithAccount:username password:password];
        verifyOperation.delegate = self;
        [[NSOperationQueue backGroupQueue] addOperation:verifyOperation];
        WizLogAction(WizUserActionLogin);
        return NO;
    }

    return YES;
}


- (void)checkBackEnable
{
    if ([self.webView canGoBack]) {
        itemBack.enabled = YES;
    }else{
        itemBack.enabled = NO;
    }
}


- (void)webViewDidStartLoad:(UIWebView *)webView1 {
    [MBProgressHUD showHUDAddedTo:self.webView animated:YES];
    [self checkBackEnable];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView1 {
    [MBProgressHUD hideHUDForView:self.webView animated:YES];
    [self checkBackEnable];
}

- (void)webView:(UIWebView *)webView1 didFailLoadWithError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.webView animated:YES];
    [self checkBackEnable];
}


- (void)didVerifyAccountFailed:(NSError *)error {

}

- (void)didVerifyAccountSucceed:(NSString *)userId password:(NSString *)password kbguid:(NSString *)kbguid userGuid:(NSString *)userGuid {
    [[WizAccountManager defaultManager] setExperiencing:NO];
    userId = [userId lowercaseString];
    [[WizAccountManager defaultManager]updateAccount:userId password:password personalKbguid:nil userGuid:userGuid];
    [[WizAccountManager defaultManager]registerActiveAccount:userId];
    [WizGlobals setAccountInfo:WizStrUserNew];
    [self.delegate willDismissOpenApiViewController:self];
    [self.delegate willSelectAccount:userId];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ([WizGlobals WizDeviceIsPad]) {
        return YES;
    }
    else
    {
        return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
    }
}

@end
