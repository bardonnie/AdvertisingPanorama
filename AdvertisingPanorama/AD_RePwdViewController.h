//
//  AD_RePwdViewController.h
//  AdvertisingPanorama
//
//  Created by mac on 14-3-11.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AD_RePwdViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *rPNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *rPEmailTextField;
@property (weak, nonatomic) IBOutlet UIView *rPNameView;
@property (weak, nonatomic) IBOutlet UIView *rPEmailView;
- (IBAction)rePwdBtnClick:(UIButton *)sender;

@end
