//
//  AD_AboutViewController.m
//  AdvertisingPanorama
//
//  Created by mac on 14-2-19.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//

#import "AD_AboutViewController.h"

@interface AD_AboutViewController ()

@end

@implementation AD_AboutViewController

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
    self.title = @"关于我们";
    
    UIBarButtonItem *backBarBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backBarBtnItemClick:)];
    self.navigationItem.leftBarButtonItem = backBarBtnItem;
    
    UIScrollView *aboutScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, MAIN_WINDOW_WIDTH, NAV_VIEW_HEIGHT)];
    aboutScrollView.contentSize = CGSizeMake(MAIN_WINDOW_WIDTH, 840);
    aboutScrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:aboutScrollView];
    
    UILabel *aboutLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 500)];
    aboutLabel.backgroundColor = [UIColor clearColor];
    aboutLabel.lineBreakMode = NSLineBreakByWordWrapping;
    aboutLabel.numberOfLines = 0;
    aboutLabel.text = @"《广告大观》杂志是经国家新闻出版部署批准面向国内外公开发行的广告营销传播类专业期刊。办刊宗旨：新锐观、洞察力、责任感内容定位：洞察全程创意行销，专注传播价值提升杂志关注品牌传播领域重大事件及热点新闻，对热点问题及事件给予深度评说；从不同视角分析品牌的媒介传播方略；把脉市场趋势、洞察消费行为，全方位演绎品牌营销传播案例的实战过程，强调沟通与互动的现代办刊方式。杂志读者群为企业品牌战略管理者、品牌传播管理者、品牌运营高管、市场及营销核心人士、广告营销传播机构高管、媒体广告经营管理人员及相关专业大专院校的专家学者等。最高期发行量5万份左右，每月1日出版。杂志社还创办有业界著名的行业活动——中国广告趋势论坛（一年一届，迄今已成功举办七届），及商业传播领域享有盛名的奖项——中国经典传播虎啸大奖（虎啸奖每年一届，已成功举办五届）。";
    [aboutScrollView addSubview:aboutLabel];
    
    UIImageView *qrImageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 510, 220, 220)];
    [qrImageView setImage:[UIImage imageNamed:@"qr"]];
    [aboutScrollView addSubview:qrImageView];
    
    UILabel *promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 730, 300, 60)];
    promptLabel.backgroundColor = [UIColor clearColor];
    promptLabel.text = @"扫描二维码或在微信搜索jsggdg关注广告大观官方微信";
    promptLabel.textAlignment = NSTextAlignmentCenter;
    promptLabel.lineBreakMode = NSLineBreakByCharWrapping;
    promptLabel.numberOfLines = 0;
    promptLabel.font = [UIFont systemFontOfSize:16];
    [aboutScrollView addSubview:promptLabel];
    
    UILabel *powerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 800, 300, 30)];
    powerLabel.backgroundColor = [UIColor whiteColor];
    powerLabel.text = @"Powered by 八豆科技";
    powerLabel.textAlignment = NSTextAlignmentCenter;
    powerLabel.font = [UIFont boldSystemFontOfSize:16];
    [aboutScrollView addSubview:powerLabel];
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
