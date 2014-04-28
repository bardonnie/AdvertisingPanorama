//
//  AD_LoginViewController.h
//  AdvertisingPanorama
//
//  Created by mac on 14-2-19.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AD_LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *emailView;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *loginScrollView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;


- (IBAction)loginBtnClick:(UIButton *)sender;
- (IBAction)registerBtnClick:(UIButton *)sender;
- (IBAction)sinaWeiboLogin:(UIButton *)sender;
- (IBAction)tencentWeiboLogin:(UIButton *)sender;
- (IBAction)forgetPassword:(UIButton *)sender;

@end
