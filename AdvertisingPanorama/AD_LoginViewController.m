//
//  AD_LoginViewController.m
//  AdvertisingPanorama
//
//  Created by mac on 14-2-19.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//

#import "AD_LoginViewController.h"

@interface AD_LoginViewController ()< AD_NetWorkDelegate, UIAlertViewDelegate>

@end

@implementation AD_LoginViewController

@synthesize emailView, emailTextField, passwordView, passwordTextField, loginScrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"登录/注册";
    
    UIBarButtonItem *backBarBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backBarBtnItemClick:)];
    self.navigationItem.leftBarButtonItem = backBarBtnItem;
    
    self.emailView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wire-frame"]];
    self.passwordView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wire-frame"]];
    
    emailTextField.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"email"];
    passwordTextField.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"password"];
    
    // 系统通知（键盘出现消失）
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:Nil];
}

- (void)keyboardWillShow:(NSNotification *)sender
{
    // 获取系统键盘高
    NSDictionary *dict = [sender userInfo];
    NSValue *value = [dict objectForKey:@"UIKeyboardBoundsUserInfoKey"];
    CGSize keyboardSize = [value CGRectValue].size;
    
    self.loginScrollView.contentSize = CGSizeMake(MAIN_WINDOW_WIDTH, 340);
    self.loginScrollView.frame = CGRectMake(0, 0, MAIN_WINDOW_HEIGHT, self.view.frame.size.height-keyboardSize.height);
}

- (void)keyboardWillHide:(NSNotification *)sender
{
    self.loginScrollView.frame = CGRectMake(0, 0, MAIN_WINDOW_HEIGHT, NAV_VIEW_HEIGHT);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backBarBtnItemClick:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)loginBtnClick:(UIButton *)sender
{
    NSLog(@"login");
    [emailTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    
    [[NSUserDefaults standardUserDefaults] setValue:emailTextField.text forKey:@"email"];
    [[NSUserDefaults standardUserDefaults] setValue:passwordTextField.text forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([emailTextField.text isEqual:@""])
    {
        [SVProgressHUD showErrorWithStatus:@"登录邮箱不能为空!" duration:1];
    }
    else if ([passwordTextField.text isEqual:@""])
    {
        [SVProgressHUD showErrorWithStatus:@"密码不能为空！" duration:1];
    }
    else
    {
        AD_NetWork *network = [[AD_NetWork alloc] init];
        network.delegate = self;
        [network startDownloadWithURL:[NSString stringWithFormat:LOCALHOST,[NSString stringWithFormat:VERIFY_USER,emailTextField.text,passwordTextField.text]]];
        [SVProgressHUD showWithStatus:@"登录中" maskType:SVProgressHUDMaskTypeGradient];
    }
}

- (void)downloadFinish:data
{
    NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    if ([[resultDic objectForKey:@"Data"] intValue] > 0)
    {
        [SVProgressHUD showSuccessWithStatus:@"登陆成功" duration:1];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccess" object:[resultDic objectForKey:@"Data"] userInfo:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:@"用户名或密码错误" duration:1];
    }
}

- (void)downloadFaild
{
    [SVProgressHUD showErrorWithStatus:@"请连接网络" duration:1];
}

- (IBAction)registerBtnClick:(UIButton *)sender
{
    AD_RegisterViewController *registerViewController = [[AD_RegisterViewController alloc] init];
    [self.navigationController pushViewController:registerViewController animated:YES];
}

- (IBAction)sinaWeiboLogin:(UIButton *)sender
{
    NSLog(@"sina");
}

- (IBAction)tencentWeiboLogin:(UIButton *)sender
{
    NSLog(@"tengxun");
}

- (IBAction)forgetPassword:(UIButton *)sender
{
    NSLog(@"忘记密码");
    AD_RePwdViewController *rePwdViewController = [[AD_RePwdViewController alloc] init];
    [self.navigationController pushViewController:rePwdViewController animated:YES];
}

@end
