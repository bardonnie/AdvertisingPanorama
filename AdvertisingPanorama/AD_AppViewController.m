//
//  AD_AppViewController.m
//  AdvertisingPanorama
//
//  Created by mac on 14-5-12.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//


#define MBA_URL     @"https://itunes.apple.com/app/kong-zhongmba/id662790168?mt=8"
#define WIZ_URL     @"https://itunes.apple.com/app/wei-zhi-bi-ji-iphone-ban/id599493807?mt=8"

#import "AD_AppViewController.h"

@interface AD_AppViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation AD_AppViewController
{
    NSMutableArray *appInfoArray;
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
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.title = @"应用推荐";
    
    UIBarButtonItem *backBarBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backBarBtnItemClick:)];
    self.navigationItem.leftBarButtonItem = backBarBtnItem;
    
    UITableView *appTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MAIN_WINDOW_WIDTH, NAV_VIEW_HEIGHT) style:UITableViewStylePlain];
    appTableView.delegate = self;
    appTableView.dataSource = self;
    [self.view addSubview:appTableView];
    
    appInfoArray = [[NSMutableArray alloc] init];
    NSDictionary *mbaDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"空中MBA",@"name",@"轻型mba学习应用，利用您的零散时间实现碎片化的深度阅读。",@"detail",@"mba",@"icon", nil];
    NSDictionary *wizDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"为知笔记",@"name",@"一款云服务的笔记软件，你可以随时随地记录喝查看有价值的信息。",@"detail",@"wiz",@"icon", nil];
    [appInfoArray addObject:mbaDic];
    [appInfoArray addObject:wizDic];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return appInfoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 14, 60, 60)];
    iconImageView.backgroundColor = [UIColor clearColor];
    [iconImageView setImage:[UIImage imageNamed:[[appInfoArray objectAtIndex:indexPath.row] objectForKey:@"icon"]]];
    [cell.contentView addSubview:iconImageView];
    
    UILabel *appNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(84, 14, 190, 22)];
    appNameLabel.backgroundColor = [UIColor clearColor];
    appNameLabel.text = [[appInfoArray objectAtIndex:indexPath.row] objectForKey:@"name"];
    appNameLabel.font = [UIFont boldSystemFontOfSize:16];
    [cell.contentView addSubview:appNameLabel];
    
    UILabel *appDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(84, 36, 190, 38)];
    appDetailLabel.backgroundColor = [UIColor clearColor];
    appDetailLabel.text = [[appInfoArray objectAtIndex:indexPath.row] objectForKey:@"detail"];
    appDetailLabel.font = [UIFont systemFontOfSize:12];
    appDetailLabel.lineBreakMode = UILineBreakModeCharacterWrap;
    appDetailLabel.numberOfLines = 0;
    [cell.contentView addSubview:appDetailLabel];
    
    UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(280, 30, 26, 26)];
    [downImageView setImage:[UIImage imageNamed:@"下载"]];
    [cell.contentView addSubview:downImageView];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:MBA_URL]];
    }
    else if (indexPath.row == 1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:WIZ_URL]];
    }
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
