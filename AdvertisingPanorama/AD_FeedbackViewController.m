//
//  AD_FeedbackViewController.m
//  AdvertisingPanorama
//
//  Created by mac on 14-2-20.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//

#import "AD_FeedbackViewController.h"

@interface AD_FeedbackViewController ()

@end

@implementation AD_FeedbackViewController
{
    CBTextView *_feedbackTextView;
    UITextField *_number;
    UIScrollView *_feedbackScrollView;
}

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
    
    _feedbackScrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_feedbackScrollView];
    
    _feedbackTextView = [[CBTextView alloc] init];
    _feedbackTextView.frame = CGRectMake(10, 10, 300, 145);
    _feedbackTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _feedbackTextView.layer.borderWidth = 1.0;
    _feedbackTextView.layer.cornerRadius = 2.0;
    _feedbackTextView.backgroundColor = [UIColor whiteColor];
    _feedbackTextView.textView.font = [UIFont systemFontOfSize:16];
    _feedbackTextView.placeHolder = @"请输入您的宝贵意见";
    [_feedbackScrollView addSubview:_feedbackTextView];
    
    _number = [[UITextField alloc] init];
    _number.frame = CGRectMake(10, 160, 300, 30);
    _number.backgroundColor = [UIColor clearColor];
    _number.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _number.layer.borderWidth = 1.0;
    _number.layer.cornerRadius = 2.0;
    _number.borderStyle = UITextBorderStyleLine;
    _number.keyboardType = UIKeyboardTypeNumberPad;
    _number.font = [UIFont systemFontOfSize:16];
    _number.placeholder = @"请输入您的QQ、邮箱或手机号";
    [_number setBackground:[UIImage imageNamed:@"联系电话"]];
    [_feedbackScrollView addSubview:_number];
    
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    submitBtn.frame = CGRectMake(10, 200, 300, 45);
    [submitBtn setImage:[UIImage imageNamed:@"submit"] forState:UIControlStateNormal];
    [submitBtn addTarget:self action:@selector(submitBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_feedbackScrollView addSubview:submitBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)sender
{
    // 获取系统键盘高
    NSDictionary *dict = [sender userInfo];
    NSValue *value = [dict objectForKey:@"UIKeyboardBoundsUserInfoKey"];
    CGSize keyboardSize = [value CGRectValue].size;
    
    _feedbackScrollView.contentSize = CGSizeMake(MAIN_WINDOW_WIDTH, 340);
    _feedbackScrollView.frame = CGRectMake(0, 0, MAIN_WINDOW_HEIGHT, self.view.frame.size.height-keyboardSize.height);
}

- (void)submitBtnClick:(UIButton *)sender
{
    NSLog(@"提交");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
