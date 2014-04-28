//
//  AD_RegisterViewController.h
//  AdvertisingPanorama
//
//  Created by mac on 14-2-19.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AD_RegisterViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *rEmailView;
@property (weak, nonatomic) IBOutlet UIView *rNameView;
@property (weak, nonatomic) IBOutlet UIView *rPasswordView;
@property (weak, nonatomic) IBOutlet UIView *rRepasswordView;
@property (weak, nonatomic) IBOutlet UIScrollView *rScrollView;

@property (weak, nonatomic) IBOutlet UITextField *rEmailTextField;
@property (weak, nonatomic) IBOutlet UITextField *rNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *rPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *rRePasswordTextField;

- (IBAction)registerActionClick:(UIButton *)sender;

@end
