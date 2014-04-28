//
//  WizBizServerLoginViewController.m
//  WizIphone7
//
//  Created by wzz on 13-11-28.
//  Copyright (c) 2013年 dzpqzb inc. All rights reserved.
//

#import "WizBizServerLoginViewController.h"
#import "UIWebView+WizTool.h"
#import "CIALBrowserViewController.h"

@interface WizBizServerLoginViewController ()<UITextFieldDelegate,UIWebViewDelegate>
{
    UITextField* addressField;
    UIButton* confirmButton;
    UILabel* explainLable;
    UIWebView* detailView;
    UIScrollView* scrollView;
}
@end

@implementation WizBizServerLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if (!DEVICE_VERSION_BELOW_7) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
    }
    return self;
}

- (void)loadView
{
    CGRect rect = CGRectLoadViewFrame;
    scrollView = [[UIScrollView alloc]initWithFrame:rect];
    scrollView.contentSize = CGSizeMake(CGRectGetWidth(rect), CGRectGetHeight(rect)+1);
    self.view = scrollView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTitle:WizStrCancel target:self action:@selector(quitTheViewController)];
    self.view.backgroundColor = [UIColor colorWithHexHex:0xf4f4f4];
	// Do any additional setup after loading the view.
    addressField = [[UITextField alloc]initWithFrame:CGRectMake(0, 14, CGRectGetWidth(self.view.bounds), 44)];
    addressField.backgroundColor = [UIColor whiteColor];
    addressField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIView* leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, CGRectGetHeight(addressField.frame))];
    leftView.backgroundColor = [UIColor clearColor];
    addressField.leftView = leftView;
    addressField.delegate = self;
    addressField.leftViewMode = UITextFieldViewModeAlways;
    addressField.placeholder = NSLocalizedString(@"Enterprise private server address", nil);
    [self.view addSubview:addressField];
    explainLable = [[UILabel alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(addressField.frame) + 5, CGRectGetWidth(self.view.bounds) - 32, 42)];
    explainLable.numberOfLines = 0;
    explainLable.text = NSLocalizedString(@"Comment: Please contact the administrator of your company or organization to get a private server.", nil);
    explainLable.textColor = [UIColor colorWithHexHex:0x7e8995];
    explainLable.font = [UIFont systemFontOfSize:12];
    explainLable.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:explainLable];
    confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmButton setBackgroundImage:[UIImage imageNamed:@"icon_bizLoginConfirm"] forState:UIControlStateNormal];
    [confirmButton setTitle:WizStrConfirm forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmButton.frame = CGRectMake(CGRectGetWidth(self.view.bounds) - 94, CGRectGetMaxY(explainLable.frame), 82, 32);
    confirmButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.view addSubview:confirmButton];
    
    UIView* lineView = [[UIView alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(confirmButton.frame) + 16, CGRectGetWidth(self.view.frame) - 20, 0.5)];
    lineView.backgroundColor = [UIColor colorWithHexHex:0xe4e4e4];
    [self.view addSubview:lineView];
    
    detailView = [[UIWebView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame), CGRectGetWidth(self.view.bounds), 700)];
    detailView.delegate = self;
    detailView.scrollView.scrollEnabled = NO;
    detailView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:detailView];
    [self loadDetails];
}


- (void)loadDetails
{
    NSString* resourcePath = [[[NSBundle mainBundle]resourcePath] stringByAppendingPathComponent:@"introduce_biz"];
    NSString* htmlPath = [resourcePath stringByAppendingPathComponent:@"introl.html"];
    if (htmlPath && ![htmlPath isEqualToString:@""]) {
        NSString* content = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
        if ([WizGlobals isChineseEnviroment]) {
            htmlPath = [htmlPath stringByAppendingString:@"?lang=zh"];
        }else{
            htmlPath =[htmlPath stringByAppendingString:@"?lang=en"];
        }
        [detailView loadHTMLString:content baseURL:[NSURL URLWithString:htmlPath]];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGFloat webViewHeight = webView.scrollView.contentSize.height;
    webView.frame = CGRectSetHeight(webView.frame, webViewHeight);
    scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(webView.frame) + 50);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSURL* requestURL = [[request URL] absoluteURL];
        CIALBrowserViewController* browserVC = [[CIALBrowserViewController alloc]initWithURL:requestURL];
        browserVC.isViewAttachment = NO;
        browserVC.enabledSafari = YES;
        WizNavigationViewController* browserNavCon = [[WizNavigationViewController alloc]initWithRootViewController:browserVC];
//        [self presentModalViewController:browserNavCon animated:YES];
        [self presentViewController:browserNavCon animated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
        }];
        return NO;
    }
    return YES;
}

- (void)quitTheViewController
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [detailView setNeedsDisplay];
}

//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//{
//    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
//    [detailView setNeedsDisplay];
//}

@end
