//
//  AD_RePwdViewController.m
//  AdvertisingPanorama
//
//  Created by mac on 14-3-11.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//

#import "AD_RePwdViewController.h"

@interface AD_RePwdViewController ()< AD_NetWorkDelegate>

@end

@implementation AD_RePwdViewController

@synthesize rPEmailTextField,rPNameTextField,rPEmailView,rPNameView;

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
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.translucent = NO;
    self.title = @"找回密码";
    
    UIBarButtonItem *backBarBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backBarBtnItemClick:)];
    self.navigationItem.leftBarButtonItem = backBarBtnItem;
    
    self.rPNameView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wire-frame"]];
    self.rPEmailView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wire-frame"]];
}

- (void)backBarBtnItemClick:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)rePwdBtnClick:(UIButton *)sender
{
    if ([rPEmailTextField.text isEqual:@""])
    {
        [SVProgressHUD showErrorWithStatus:@"邮箱不能为空" duration:1];
    }
    else if ([rPNameTextField.text isEqual:@""])
    {
        [SVProgressHUD showErrorWithStatus:@"昵称不能为空" duration:1];
    }
    else if (![self isValidateEmail:rPEmailTextField.text])
    {
        [SVProgressHUD showErrorWithStatus:@"邮箱格式不正确" duration:1];
    }
    else
    {
        AD_NetWork *network = [[AD_NetWork alloc] init];
        network.delegate = self;
        [network startDownloadWithURL:[NSString stringWithFormat:LOCALHOST,[NSString stringWithFormat:RETRIEVE_PWD,rPNameTextField.text,rPEmailTextField.text]]];
    }
}

- (void)downloadFinish:(NSData *)data
{
    NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    if (![[resultDic objectForKey:@"Success"] objectForKey:@"Data"])
    {
        [SVProgressHUD showErrorWithStatus:@"用户名与找回密码的邮箱不符" duration:1];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:@"您的密码已发送至注册邮箱，请注意查收。" duration:2];
    }
}

- (void)downloadFaild
{
    [SVProgressHUD showErrorWithStatus:@"请连接网络" duration:1];
}

// 判断邮箱
- (BOOL)isValidateEmail:(NSString *)Email
{
    NSString *emailCheck = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailCheck];
    return [emailTest evaluateWithObject:Email];
}

@end
