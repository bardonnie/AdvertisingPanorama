//
//  AD_ArticleViewController.m
//  AdvertisingPanorama
//
//  Created by mac on 14-2-19.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//

#import "AD_ArticleViewController.h"

@interface AD_ArticleViewController ()< WizSyncDownloadDelegate, UIWebViewDelegate>

@end

@implementation AD_ArticleViewController
{
    UIWebView *_articleWebView;
    NSString *_guid;
    UIControl *_reviewView;
    UIControl *_reviewBackControl;
    UITextView *_reviewTextView;
}

- (id)initWithGuid:(NSString *)guid
{
    self = [super init];
    if (self)
    {
        NSLog(@"guid - %@",guid);
        _guid = guid;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *reviewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    reviewBtn.frame = CGRectMake(0, 0, 30, 28);
    reviewBtn.backgroundColor = [UIColor clearColor];
    [reviewBtn setImage:[UIImage imageNamed:@"number"] forState:UIControlStateNormal];
    [reviewBtn addTarget:self action:@selector(reviewBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 3, 15, 10)];
    numberLabel.text = @"11";
    numberLabel.font = [UIFont boldSystemFontOfSize:8];
    numberLabel.textColor = UIColorFromRGB(0xb61527);
    numberLabel.backgroundColor = [UIColor clearColor];
    numberLabel.textAlignment = NSTextAlignmentCenter;
    [reviewBtn addSubview:numberLabel];
    
    UIBarButtonItem *reviewItem = [[UIBarButtonItem alloc] initWithCustomView:reviewBtn];
    self.navigationItem.rightBarButtonItem = reviewItem;
    
    _articleWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, MAIN_WINDOW_WIDTH, NAV_VIEW_HEIGHT-NAV_BAR_HEIGHT)];
    _articleWebView.delegate = self;
    [self.view addSubview:_articleWebView];
    
    UIToolbar *toolView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, NAV_VIEW_HEIGHT-NAV_BAR_HEIGHT, MAIN_WINDOW_WIDTH, NAV_BAR_HEIGHT)];
    toolView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    [self.view bringSubviewToFront:toolView];
    [self.view addSubview:toolView];
    
    // 分享按钮
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(5, 5, 39, 33);
    [shareBtn setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(shareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:shareBtn];
    
    UIButton *collectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    collectBtn.frame = CGRectMake(58, 10, 23, 23);
    [collectBtn setImage:[UIImage imageNamed:@"collect_offRed"] forState:UIControlStateNormal];
    [toolView addSubview:collectBtn];
    
    UIImageView *reviewBackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 8, 210, 28)];
    [reviewBackImageView setImage:[UIImage imageNamed:@"write-frame"]];
    reviewBackImageView.userInteractionEnabled = YES;
    [toolView addSubview:reviewBackImageView];
    
    UITextField *reviewTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, 0, 180, 28)];
    reviewTextField.placeholder = @"写评论";
    reviewTextField.backgroundColor = [UIColor clearColor];
    [reviewBackImageView addSubview:reviewTextField];
    
    NSString *filePathString = [[WizFileManager shareManager] documentIndexFilePath:_guid];
    if (![[WizFileManager shareManager] fileExistsAtPath:filePathString])
    {
        [[WizNotificationCenter shareCenter] addDownloadDelegate:self];
        [[WizSyncCenter shareCenter] downloadDocument:_guid kbguid:KBGUID accountUserId:USER_ID];
    }
    else
    {
        [self didDownloadEnd:_guid];
    }
    
    // 系统通知（键盘出现消失）
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardwillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    _reviewBackControl = [[UIControl alloc] initWithFrame:self.view.frame];
    _reviewBackControl.backgroundColor = [UIColor blackColor];
    _reviewBackControl.alpha = .5;
    _reviewBackControl.hidden = YES;
    [self.view addSubview:_reviewBackControl];
    
    _reviewView = [[UIControl alloc] initWithFrame:CGRectMake(0, 100, MAIN_WINDOW_WIDTH, 145)];
    _reviewView.backgroundColor = [UIColor whiteColor];
    _reviewView.alpha = .9;
    _reviewView.hidden = YES;
    [self.view addSubview:_reviewView];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(10, 10, 35, 28);
    [cancelBtn setImage:[UIImage imageNamed:@"no"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_reviewView addSubview:cancelBtn];
    
    UIImageView *writeReview = [[UIImageView alloc] initWithFrame:CGRectMake(133, 15, 53, 18)];
    [writeReview setImage:[UIImage imageNamed:@"write"]];
    [_reviewView addSubview:writeReview];
    
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    submitBtn.frame = CGRectMake(270, 10, 35, 28);
    [submitBtn setImage:[UIImage imageNamed:@"yes"] forState:UIControlStateNormal];
    [submitBtn addTarget:self action:@selector(submitBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_reviewView addSubview:submitBtn];
    
    _reviewTextView = [[UITextView alloc] initWithFrame:CGRectMake(15, 44, 291, 80)];
    _reviewTextView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"box"]];
    _reviewTextView.font = [UIFont systemFontOfSize:16];
    [_reviewView addSubview:_reviewTextView];
}

- (void)keyboardWillShow:(NSNotification *)sender
{
    _reviewBackControl.hidden = NO;
    _reviewView.hidden = NO;
    
    // 获取系统键盘高
    NSDictionary *dict = [sender userInfo];
    NSValue *value = [dict objectForKey:@"UIKeyboardBoundsUserInfoKey"];
    CGSize keyboardSize = [value CGRectValue].size;
    // 移动工具条上移
    [UIView animateWithDuration:.3 animations:^{
        _reviewView.frame = CGRectMake(0, NAV_VIEW_HEIGHT-145-keyboardSize.height, MAIN_WINDOW_WIDTH, 145);
    }];
    
    [_reviewTextView becomeFirstResponder];
}

- (void)keyboardwillHide:(NSNotification *)sender
{
    _reviewView.hidden = YES;
    _reviewBackControl.hidden = YES;
}

- (void)cancelBtnClick
{
    [_reviewTextView resignFirstResponder];
}

- (void)submitBtnClick
{
    [_reviewTextView resignFirstResponder];
}

- (void)shareBtnClick:(UIButton *)sender
{
    NSLog(@"分享");
}

- (void)reviewBtnClick
{
    NSLog(@"--");
}

- (void)didDownloadEnd:(NSString *)guid
{
    NSLog(@"guid -- %@",guid);
    if ([guid isEqualToString:_guid]) {
        NSString *filePathString = [[WizFileManager shareManager] documentIndexFilePath:guid];
        if (![[WizFileManager shareManager] fileExistsAtPath:filePathString])
        {
            [[WizFileManager shareManager] prepareReadingEnviroment:guid accountUserId:USER_ID];
        }
        
        NSURL *articleFileURL = [NSURL fileURLWithPath:filePathString];
        NSURLRequest *articleFileURLRequest = [NSURLRequest requestWithURL:articleFileURL];
        [_articleWebView loadRequest:articleFileURLRequest];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
