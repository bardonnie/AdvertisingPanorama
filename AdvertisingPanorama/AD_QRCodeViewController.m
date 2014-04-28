//
//  AD_QRCodeViewController.m
//  AdvertisingPanorama
//
//  Created by mac on 14-4-11.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//

#import "AD_QRCodeViewController.h"

@interface AD_QRCodeViewController ()

@end

@implementation AD_QRCodeViewController

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
    self.title = @"扫我下载";
    
    
   // https://itunes.apple.com/app/id837986227?ls=1&mt=8
    
    
    UILabel *downloadLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 40)];
    downloadLabel.backgroundColor = [UIColor clearColor];
    downloadLabel.text = @"扫描二维码 下载iOS版广告大观";
    downloadLabel.textAlignment = NSTextAlignmentCenter;
    downloadLabel.font = [UIFont systemFontOfSize:20];
    [self.view addSubview:downloadLabel];
    
    UIBarButtonItem *backBarBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backBarBtnItemClick:)];
    self.navigationItem.leftBarButtonItem = backBarBtnItem;
    
    UIImageView *qrCodeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 50, 280, 280)];
    [qrCodeImageView setImage:[UIImage imageNamed:@"downLoadCode"]];
    [self.view addSubview:qrCodeImageView];
    
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 330, 300, 80)];
    infoLabel.backgroundColor = [UIColor clearColor];
    infoLabel.lineBreakMode = UILineBreakModeCharacterWrap;
    infoLabel.numberOfLines = 0;
    infoLabel.textAlignment = UITextAlignmentCenter;
    infoLabel.font = [UIFont systemFontOfSize:18];
    infoLabel.text = @"其他下载方式：\n在App Store搜索“广告大观”下载。";
    [self.view addSubview:infoLabel];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
