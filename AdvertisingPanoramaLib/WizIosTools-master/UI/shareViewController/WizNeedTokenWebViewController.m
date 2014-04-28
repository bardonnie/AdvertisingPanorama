//
//  WizNeedTokenWebViewController.m
//  WizNote
//
//  Created by wzz on 13-5-14.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizNeedTokenWebViewController.h"
#import "UIWebView+WizTool.h"
#import "WizTokenManger.h"
#import "UIWebView+WizWebViewAddition.h"
#import "MBProgressHUD.h"

@interface WizNeedTokenWebViewController ()<UIWebViewDelegate>
{
    UIWebView* _webView;
}
@property (nonatomic, strong) NSString* token;
@end

@implementation WizNeedTokenWebViewController
@synthesize accountUserId;
@synthesize kbGuid;
@synthesize urlString;
@synthesize token;

- (void)dealloc
{
    _webView.delegate = nil;
    [_webView stopLoading];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _webView = [[UIWebView alloc] init];
    }
    return self;
}

- (void)loadView
{
    _webView.frame = [[UIScreen mainScreen]bounds];
    self.view = _webView;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([WizGlobals WizDeviceIsPad]) {
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithTitle:WizStrCancel target:self.navigationController action:@selector(dismissModalViewControllerAnimated:)];
    }else{
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:WizImageByKind(BarIconCancel) target:self.navigationController action:@selector(dismissModalViewControllerAnimated:)];
    }
    _webView.delegate = self;
    [_webView noNetworkConnection];
    [_webView prapareForEdit];
    [_webView loadReadJavaScript];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSError* error = nil;
        self.token = [[WizTokenManger shareInstance] tokenUrlForAccountUserId:self.accountUserId kbguid:self.kbGuid error:&error].token;
        MULTIMAIN(^(void) {
            if (urlString && ![urlString isEqualToString:@""] && self.token && ![self.token isEqualToString:@""]) {
                urlString = [urlString stringByReplacingOccurrencesOfString:WizNeedTokenStringIdentify withString:token];
                NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
                [_webView loadRequest:request];
            }
        });
    });
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSArray* contents = [webView decodeJsCmd:[[request URL] absoluteString]];
    if ([contents count]) {
        NSString* identify = [contents objectAtIndex:0];
        if ([identify isEqualToString:WizNotCmdSuccessCreateGroup]) {
            [[WizSyncCenter shareCenter] syncAccount:self.accountUserId password:[[WizAccountManager defaultManager]activeAccountPassword] isGroup:YES isUploadOnly:NO currentKbGUID:nil];
            return NO;
        }
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [MBProgressHUD showHUDAddedTo:_webView animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hideHUDForView:_webView animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ([WizGlobals WizDeviceIsPad]) {
        return YES;
    }else{
        return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
    }
    return NO;
}
@end
