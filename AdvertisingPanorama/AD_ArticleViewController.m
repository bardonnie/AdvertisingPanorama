//
//  AD_ArticleViewController.m
//  AdvertisingPanorama
//
//  Created by mac on 14-2-19.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//

#import "AD_ArticleViewController.h"

@interface AD_ArticleViewController ()< WizSyncDownloadDelegate, UIWebViewDelegate, AD_NetWorkDelegate, UIGestureRecognizerDelegate>

@end

@implementation AD_ArticleViewController
{
    UIWebView *_articleWebView;
    NSString *_guid;
    NSString *_title;
    NSString *_shareUrl;
    UIControl *_reviewView;
    UIControl *_reviewBackControl;
    UITextView *_reviewTextView;
    UIView *_shareView;
    UIControl *_shareControl;
    UILabel *_numberLabel;
    UIButton *_collectBtn;
    BOOL _isCollect;
    
    AD_NetWork *_network;
    AD_AppDelegate *_delegate;
}


- (void)dealloc
{
    [[WizNotificationCenter shareCenter]removeObserver:self];
}

- (id)initWithGuid:(NSString *)guid WithTitle:(NSString *)title AndShareUrl:(NSString *)shareUrl
{
    self = [super init];
    if (self)
    {
        NSLog(@"guid - %@",guid);
        NSLog(@"title - %@",shareUrl);
        _guid = [NSString stringWithString:guid];
        _title = [NSString stringWithString:title];
        _shareUrl = [NSString stringWithString:shareUrl];
        
        [[WizNotificationCenter shareCenter] addDownloadDelegate:self];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self cancelBtnClick];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    _delegate = [UIApplication sharedApplication].delegate;
    
    _network = [[AD_NetWork alloc] init];
    _network.delegate = self;
    
    UIButton *reviewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    reviewBtn.frame = CGRectMake(0, 0, 30, 28);
    reviewBtn.backgroundColor = [UIColor clearColor];
    [reviewBtn setImage:[UIImage imageNamed:@"number"] forState:UIControlStateNormal];
    [reviewBtn addTarget:self action:@selector(reviewBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    _numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 3, 15, 10)];
    _numberLabel.text = @"11";
    _numberLabel.font = [UIFont boldSystemFontOfSize:8];
    _numberLabel.textColor = UIColorFromRGB(0xb61527);
    _numberLabel.backgroundColor = [UIColor clearColor];
    _numberLabel.textAlignment = NSTextAlignmentCenter;
    [reviewBtn addSubview:_numberLabel];
    
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
    shareBtn.frame = CGRectMake(0, 0, 44, 44);
    [shareBtn setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(shareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:shareBtn];
    
    // 收藏按钮
    _collectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _collectBtn.frame = CGRectMake(44, 0, 44, 44);
    [_collectBtn setImage:[UIImage imageNamed:@"collect_offRed"] forState:UIControlStateNormal];
    [_collectBtn addTarget:self action:@selector(collectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:_collectBtn];
    
    // 评论视图背景图片
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
        [[WizSyncCenter shareCenter] downloadDocument:_guid kbguid:KBGUID accountUserId:USER_ID];
        [SVProgressHUD showWithStatus:@"正在加载..."];
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
    
    _shareControl = [[UIControl alloc] initWithFrame:self.view.frame];
    _shareControl.backgroundColor = [UIColor blackColor];
    _shareControl.alpha = .5;
    _shareControl.hidden = YES;
    [_shareControl addTarget:self action:@selector(shareControlClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_shareControl];
    
    _shareView = [[UIView alloc] initWithFrame:CGRectMake(0, NAV_VIEW_HEIGHT, MAIN_WINDOW_WIDTH, 147)];
    _shareView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_share"]];
    [self.view addSubview:_shareView];
    
    NSArray *shareImageArray = [[NSArray alloc] initWithObjects:@"wechat", @"friend", @"sina_share", @"tencent_share", nil];
    NSArray *shareNameArray = [[NSArray alloc] initWithObjects:@"微信", @"朋友圈", @"新浪微博", @"腾讯微博", nil];
    for (int i = 0; i<4; i++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(16+80*i, 20, 48, 48);
        [btn setImage:[UIImage imageNamed:[shareImageArray objectAtIndex:i]] forState:UIControlStateNormal];
        btn.tag = 1000+i;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_shareView addSubview:btn];
        
        UILabel *shareNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(16+80*i, 70, 48, 30)];
        shareNameLabel.text = [shareNameArray objectAtIndex:i];
        shareNameLabel.backgroundColor = [UIColor clearColor];
        shareNameLabel.font = [UIFont systemFontOfSize:12];
        shareNameLabel.textAlignment = NSTextAlignmentCenter;
        shareNameLabel.textColor = [UIColor grayColor];
        [_shareView addSubview:shareNameLabel];
    }
    
    UIButton *shareCancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareCancelBtn.frame = CGRectMake(0, 103, MAIN_WINDOW_WIDTH, 44);
    [shareCancelBtn setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [shareCancelBtn addTarget:self action:@selector(shareCancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_shareView addSubview:shareCancelBtn];
    
    [_network startDownloadWithURL:[NSString stringWithFormat:LOCALHOST_NEW,[NSString stringWithFormat:GET_COMM_NUM,_guid]]];
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"userID"] intValue] > 1000)
    {
        [_network startDownloadWithURL:[NSString stringWithFormat:LOCALHOST_NEW,[NSString stringWithFormat:IS_COLL,[[NSUserDefaults standardUserDefaults] valueForKey:@"userID"],_guid]]];
        [SVProgressHUD showWithStatus:@"正在加载"];
    }
    _isCollect = NO;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    float width = webView.frame.size.width;
    NSString* scriptName =@"Read";
    NSString *path = [[NSBundle mainBundle] pathForResource:scriptName ofType:@"js"];
    
    NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [webView stringByEvaluatingJavaScriptFromString:jsCode];
    NSString* cmd = [NSString stringWithFormat: @"ResizeImages(%f);",width];
    [webView stringByEvaluatingJavaScriptFromString:cmd];
    // 全屏显示
    //  [web stringByEvaluatingJavaScriptFromString:@"Touch()"];
    //    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    //    [self.view addGestureRecognizer:singleTap];
    //    //这个可以加到任何控件上,比如你只想响应WebView，我正好填满整个屏幕
    //    singleTap.delegate = self;
    //    singleTap.cancelsTouchesInView = NO;
    NSLog(@"webViewDidFinishLoad");
}

-(void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    if (self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBarHidden = NO;
    }
    else
    {
        self.navigationController.navigationBarHidden = YES;
    }
    CGPoint point = [sender locationInView:self.view];
    NSLog(@"handleSingleTap!pointx:%f,y:%f",point.x,point.y);
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
    _reviewTextView.text = @"";
}

- (void)submitBtnClick
{
    if ([_reviewTextView.text isEqual:@""])
    {
        [SVProgressHUD showErrorWithStatus:@"请输入评论内容" duration:1];
    }
    else
    {
        [_reviewTextView resignFirstResponder];
        [_network startDownloadWithURL:[NSString stringWithFormat:LOCALHOST,[NSString stringWithFormat:POST_COMM,[[NSUserDefaults standardUserDefaults] valueForKey:@"userID"], _guid, _reviewTextView.text]]];
    }
}

#pragma mark - networkDelegate
- (void)downloadFinish:(NSData *)data
{
    NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"data - %@",[[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding]);
    
    if ([dataDic objectForKey:@"Data"])
    {
        _numberLabel.text = [NSString stringWithFormat:@"%@",[[dataDic objectForKey:@"Data"] objectForKey:@"CommentID"]];
        _reviewTextView.text = @"";
        [SVProgressHUD showSuccessWithStatus:@"评论成功" duration:1];
    }
    else if ([self isPureInt:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]])
    {
        _numberLabel.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    else if ([[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] isEqual:@"收藏成功"])
    {
        _isCollect = YES;
        [_collectBtn setImage:[UIImage imageNamed:@"collect_red"] forState:UIControlStateNormal];
        [SVProgressHUD showSuccessWithStatus:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] duration:1];
    }
    else if ([[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] isEqual:@"取消收藏成功"])
    {
        _isCollect = NO;
        [_collectBtn setImage:[UIImage imageNamed:@"collect_offRed"] forState:UIControlStateNormal];
        [SVProgressHUD showSuccessWithStatus:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] duration:1];
    }
    else if ([[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] isEqual:@"True"])
    {
        _isCollect = YES;
        [_collectBtn setImage:[UIImage imageNamed:@"collect_red"] forState:UIControlStateNormal];
    }
}

- (void)downloadFaild
{
    [SVProgressHUD showErrorWithStatus:@"请连接网络" duration:1];
}

- (void)shareCancelBtnClick:(UIButton *)sender
{
    _shareControl.hidden = YES;
    [Animations moveDown:_shareView andAnimationDuration:0.2 andWait:YES andLength:147];
}

- (void)shareBtnClick:(UIButton *)sender
{
    NSLog(@"分享");
    _shareControl.hidden = NO;
    [Animations moveUp:_shareView andAnimationDuration:0.2 andWait:YES andLength:147];
    [Animations moveDown:_shareView andAnimationDuration:0.2 andWait:YES andLength:5.0];
    [Animations moveUp:_shareView andAnimationDuration:0.1 andWait:YES andLength:5.0];
}

- (void)shareControlClick:(UIControl *)sender
{
    _shareControl.hidden = YES;
    [Animations moveDown:_shareView andAnimationDuration:0.2 andWait:YES andLength:147];
}

- (void)collectBtnClick:(UIButton *)sender
{
    [SVProgressHUD showWithStatus:@""];
    if (_isCollect == NO) {
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"userID"] intValue] > 1000)
        {
            [_network startDownloadWithURL:[NSString stringWithFormat:LOCALHOST_NEW,[NSString stringWithFormat:ADD_COLL, _guid,[[NSUserDefaults standardUserDefaults] valueForKey:@"userID"]]]];
        }
        else
        {
            AD_AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
            [SVProgressHUD showErrorWithStatus:@"登陆后才能收藏！" duration:2];
            AD_LoginViewController *loginViewController = [[AD_LoginViewController alloc] init];
            [delegate.rootNav pushViewController:loginViewController animated:YES];
        }
    }
    else
    {
        [_network startDownloadWithURL:[NSString stringWithFormat:LOCALHOST_NEW,[NSString stringWithFormat:CANCEL_COLL, _guid,[[NSUserDefaults standardUserDefaults] valueForKey:@"userID"]]]];
    }
}

- (void)reviewBtnClick
{
    NSLog(@"--");
    AD_CommentViewController *commentViewController = [[AD_CommentViewController alloc] initWithGuid:_guid];
    [self.navigationController pushViewController:commentViewController animated:YES];
}

#define BUFFER_SIZE 1024 * 100

- (void)btnClick:(UIButton *)sender
{
    NSLog(@"tag - %d",sender.tag);
    
    if (sender.tag == 1000 || sender.tag == 1001)
    {
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = @"广告大观";
        message.description = _title;
        [message setThumbImage:[UIImage imageNamed:@"shareImage"]];
        
        WXWebpageObject *webPage = [WXWebpageObject object];
        webPage.webpageUrl = _shareUrl;
        
        message.mediaObject = webPage;
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.message = message;
        
        if (sender.tag == 1000) {
            req.scene = WXSceneSession;
            [WXApi sendReq:req];
        }
        else if (sender.tag == 1001)
        {
            req.scene = WXSceneTimeline;
            [WXApi sendReq:req];
        }
    }
    else if (sender.tag == 1002)
    {
        WBMessageObject *message = [WBMessageObject message];
        message.text = _title;
        
        WBImageObject *image = [WBImageObject object];
        image.imageData = UIImageJPEGRepresentation([self screenShot:_articleWebView], 1.0);
        message.imageObject = image;
        
        WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
        
        [WeiboSDK sendRequest:request];
    }
    else
    {
        NSLog(@"---授权%d",[_delegate.wbapi isAuthed]);
        NSLog(@"---过期%d",[_delegate.wbapi isAuthorizeExpired]);
        if (![_delegate.wbapi isAuthed] || [_delegate.wbapi isAuthorizeExpired])
        {
            [_delegate.wbapi loginWithDelegate:self andRootController:self];
        }
        else
        {
            [self onAddPic];
        }
    }
}

- (void)didDownloadEnd:(NSString *)guid
{
    NSLog(@"guid -- %@",guid);
    [SVProgressHUD showSuccessWithStatus:@"加载成功"];
    if ([guid isEqualToString:_guid]) {
        NSString *file=  [[NSString alloc]init ];
        if ([[WizFileManager shareManager] prepareReadingEnviroment:guid accountUserId:USER_ID])
        {
            file =[[WizFileManager shareManager] documentIndexFilePath:guid];
        }
        if (file == nil) {
            NSLog(@"file == nil");
        }
        NSURL *url = [NSURL fileURLWithPath:file];
        NSURLRequest *articleFileURLRequest = [NSURLRequest requestWithURL:url];
        [_articleWebView loadRequest:articleFileURLRequest];
    }
}

- (UIImage *)screenShot:(UIWebView *)webView
{
    UIGraphicsBeginImageContext(((UIScrollView *)[[[webView.subviews objectAtIndex:0] subviews] objectAtIndex:0]).frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    [((UIScrollView *)[[[webView.subviews objectAtIndex:0] subviews] objectAtIndex:0]).layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (BOOL)isPureInt:(NSString *)string
{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

#pragma mark - WeiboAuthDelegate
/**
 * @brief   授权成功后的回调
 * @param   INPUT   wbapi 成功后返回的WeiboApi对象，accesstoken,openid,refreshtoken,expires 等授权信息都在此处返回
 * @return  无返回
 */
- (void)DidAuthFinished:(WeiboApi *)wbapi_
{
    NSString *str = [[NSString alloc]initWithFormat:@"accesstoken = %@\r openid = %@\r appkey=%@ \r appsecret=%@\r", wbapi_.accessToken, wbapi_.openid, wbapi_.appKey, wbapi_.appSecret];
    
    NSLog(@"result = %@",str);
    [self onAddPic];
}

- (void)onAddPic
{
    UIImage *pic = [self screenShot:_articleWebView];
    NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"json",@"format",
                                   _title, @"content",
                                   pic, @"pic",
                                   nil];
    [_delegate.wbapi requestWithParams:params apiName:@"t/add_pic" httpMethod:@"POST" delegate:self];
}


/**
 * @brief   接口调用成功后的回调
 * @param   INPUT   data    接口返回的数据
 * @param   INPUT   request 发起请求时的请求对象，可以用来管理异步请求
 * @return  无返回
 */
- (void)didReceiveRawData:(NSData *)data reqNo:(int)reqno
{
    NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    //[NSString stringWithCharacters:[data bytes] length:[data length]];
    if (![[resultDic objectForKey:@"errcode"] intValue])
    {
        [SVProgressHUD showSuccessWithStatus:@"分享成功" duration:1];
    }
    NSLog(@"result = %@",resultDic);
}
/**
 * @brief   接口调用失败后的回调
 * @param   INPUT   error   接口返回的错误信息
 * @param   INPUT   request 发起请求时的请求对象，可以用来管理异步请求
 * @return  无返回
 */
- (void)didFailWithError:(NSError *)error reqNo:(int)reqno
{
    NSString *str = [[NSString alloc] initWithFormat:@"refresh token error, errcode = %@",error.userInfo];
    NSLog(@"result = %@",str);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
