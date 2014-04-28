//
//  AD_RegisterViewController.m
//  AdvertisingPanorama
//
//  Created by mac on 14-2-19.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//

#import "AD_RegisterViewController.h"

@interface AD_RegisterViewController ()< AD_NetWorkDelegate>

@end

@implementation AD_RegisterViewController

@synthesize rEmailTextField, rNameTextField, rPasswordTextField, rRePasswordTextField;
@synthesize rEmailView, rNameView, rPasswordView, rRepasswordView, rScrollView;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.translucent = NO;
    self.title = @"注册";
    
    UIBarButtonItem *backBarBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backBarBtnItemClick:)];
    self.navigationItem.leftBarButtonItem = backBarBtnItem;
    
    self.rEmailView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wire-frame"]];
    self.rNameView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wire-frame"]];
    self.rPasswordView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wire-frame"]];
    self.rRepasswordView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wire-frame"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)sender
{
    // 获取系统键盘高
    NSDictionary *dict = [sender userInfo];
    NSValue *value = [dict objectForKey:@"UIKeyboardBoundsUserInfoKey"];
    CGSize keyboardSize = [value CGRectValue].size;
    
    self.rScrollView.contentSize = CGSizeMake(MAIN_WINDOW_WIDTH, 340);
    self.rScrollView.frame = CGRectMake(0, 0, MAIN_WINDOW_HEIGHT, self.view.frame.size.height-keyboardSize.height);
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

- (IBAction)registerActionClick:(UIButton *)sender
{
    NSLog(@"注册中...");
    if ([rEmailTextField.text isEqual:@""])
    {
        [SVProgressHUD showErrorWithStatus:@"请填写登陆邮箱"];
    }
    else if ([rNameTextField.text isEqual:@""])
    {
        [SVProgressHUD showErrorWithStatus:@"请填写用户名"];
    }
    else if (![rPasswordTextField.text isEqual:rRePasswordTextField.text])
    {
        [SVProgressHUD showErrorWithStatus:@"两次密码不一致"];
    }
    else if ([rNameTextField.text isEqual:@""])
    {
        [SVProgressHUD showErrorWithStatus:@"请填写用户名"];
    }
    else if (rPasswordTextField.text.length < 5)
    {
        [SVProgressHUD showErrorWithStatus:@"密码不能少于6位" duration:1];
    }
    else if (![self isValidateEmail:rEmailTextField.text])
    {
        [SVProgressHUD showErrorWithStatus:@"邮箱格式不正确" duration:1];
    }
    else
    {
        AD_NetWork *network = [[AD_NetWork alloc] init];
        network.delegate = self;
        [network startDownloadWithURL:[NSString stringWithFormat:LOCALHOST,[NSString stringWithFormat:ADD_USER,5,rEmailTextField.text,rPasswordTextField.text,rNameTextField.text]]];
        [SVProgressHUD showWithStatus:@"注册中" maskType:SVProgressHUDMaskTypeGradient];
    }
}

// 判断邮箱
- (BOOL)isValidateEmail:(NSString *)Email
{
    NSString *emailCheck = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailCheck];
    return [emailTest evaluateWithObject:Email];
}

- (void)downloadFinish:(NSData *)data
{
    NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    if ([[resultDic objectForKey:@"Data"] isEqual:@"0"])
    {
        [SVProgressHUD showErrorWithStatus:@"该用户已存在"];
    }
    else if (![[resultDic objectForKey:@"Data"] intValue] > 1000)
    {
        [SVProgressHUD showErrorWithStatus:@"请填写真确的邮箱格式" duration:1];
    }
    else
    {
        [SVProgressHUD showSuccessWithStatus:@"注册成功" duration:1];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)downloadFaild
{
    [SVProgressHUD showErrorWithStatus:@"请连接网络" duration:1];
}

@end
