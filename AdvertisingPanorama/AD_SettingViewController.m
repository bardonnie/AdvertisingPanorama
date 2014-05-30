//
//  AD_SettingViewController.m
//  AdvertisingPanorama
//
//  Created by mac on 14-2-19.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//


#define GUANG_GAO_DA_GUAN_URL   @"http://itunes.apple.com/app/guang-gao-da-guan/id837986227?mt=8"

#import "AD_SettingViewController.h"

@interface AD_SettingViewController ()

@end

@implementation AD_SettingViewController
{
    BOOL _isOn;
    NSString *_tmpDirectory;
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
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.title = @"常用设置";
    
    UIBarButtonItem *backBarBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backBarBtnItemClick:)];
    self.navigationItem.leftBarButtonItem = backBarBtnItem;
    
    NSString *homeDirectory = NSHomeDirectory();
    _tmpDirectory = [homeDirectory stringByAppendingPathComponent:@"tmp"];
    
    NSArray *optionNameArray = [[NSArray alloc] initWithObjects:@"离线下载", @"清空缓存", @"版本更新", @"意见反馈", nil];
    
    for (int i = 0; i<4; i++)
    {
        UIButton *optionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        optionBtn.frame = CGRectMake( 10, 13+54*i, 300, 44);
        [optionBtn setImage:[UIImage imageNamed:@"wire-frame"] forState:UIControlStateNormal];
        [optionBtn addTarget:self action:@selector(optionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        optionBtn.tag = 100+i;
        optionBtn.adjustsImageWhenHighlighted = NO;
        [self.view addSubview:optionBtn];
        
        UILabel *optionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 7, 126, 30)];
        optionLabel.backgroundColor = [UIColor clearColor];
        optionLabel.text = [optionNameArray objectAtIndex:i];
        optionLabel.textAlignment = NSTextAlignmentCenter;
        optionLabel.font = [UIFont systemFontOfSize:18];
        [optionBtn addSubview:optionLabel];
        
        if (i == 0)
        {
            UIButton *switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            switchBtn.frame = CGRectMake(224, 7, 66, 30);
            _isOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"OffLine"];
            if (_isOn == YES)
                [switchBtn setImage:[UIImage imageNamed:@"on"] forState:UIControlStateNormal];
            else
                [switchBtn setImage:[UIImage imageNamed:@"off"] forState:UIControlStateNormal];
            [switchBtn addTarget:self action:@selector(switchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [optionBtn addSubview:switchBtn];
        }
        else if (i == 3)
        {
            UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake( 276, 15, 8, 14)];
            [arrowImageView setImage:[UIImage imageNamed:@"right-go"]];
            [optionBtn addSubview:arrowImageView];
        }
        else
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(200, 7, 90, 30)];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentRight;
            if (i == 1)
                label.text = [NSString stringWithFormat:@"%@",[FileSize stringFromFileSize:[FileSize sizeOfFolder:_tmpDirectory]]];
            else
                label.text = [NSString stringWithFormat:@"%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
            [optionBtn addSubview:label];
        }
    }

    UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    logoutBtn.frame = CGRectMake(10, 232, 300, 44);
    [logoutBtn setImage:[UIImage imageNamed:@"quit"] forState:UIControlStateNormal];
    [logoutBtn addTarget:self action:@selector(logoutBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logoutBtn];
    
    [self switchBtnClick:nil];
}

- (void)logoutBtnClick:(UIButton *)sender
{
    NSLog(@"logoutBtnClick");
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"userID"] intValue] > 1000)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccess" object:@"1000" userInfo:nil];
        [SVProgressHUD showSuccessWithStatus:@"退出成功" duration:1];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:@"尚未登录" duration:1];
    }
}

- (void)optionBtnClick:(UIButton *)sender
{
    NSLog(@"tag - %d",sender.tag);
    if (sender.tag == 103)
    {
        AD_FeedbackViewController *feedbackViewController = [[AD_FeedbackViewController alloc] init];
        [self.navigationController pushViewController:feedbackViewController animated:YES];
    }
    if (sender.tag == 101)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        NSArray *fileList = [[NSArray alloc] init];
        //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
        fileList = [fileManager contentsOfDirectoryAtPath:_tmpDirectory error:&error];
        for (NSString *path in fileList)
        {
            [fileManager removeItemAtPath:[_tmpDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",path]] error:nil];
        }
        [SVProgressHUD showSuccessWithStatus:@"清除成功" duration:1];
    }
    if (sender.tag == 102)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:GUANG_GAO_DA_GUAN_URL]];
    }
}

- (void)switchBtnClick:(UIButton *)sender
{
    NSLog(@"isOn - %d",_isOn);
    if (_isOn)
    {
        [[AD_NetWork shareNetWork] offLineDownload];
        [sender setImage:[UIImage imageNamed:@"on"] forState:UIControlStateNormal];
    }
    else
    {
        [sender setImage:[UIImage imageNamed:@"off"] forState:UIControlStateNormal];
    }
    [[NSUserDefaults standardUserDefaults] setBool:_isOn forKey:@"OffLine"];
    _isOn = !_isOn;
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

@end
