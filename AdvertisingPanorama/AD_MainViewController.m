//
//  AD_MainViewController.m
//  AdvertisingPanorama
//
//  Created by mac on 14-2-18.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//


#import "AD_MainViewController.h"

@interface AD_MainViewController ()< UITableViewDelegate, UITableViewDataSource>

@end

@implementation AD_MainViewController
{
    UIPageControl *_pageControl;
    UITableView *_mainTableView;
    NSArray *_mainArray;
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
	// Do any additional setup after loading the view.
    self.title = @"广告大观";
    
    // 订阅wiz下载完成系统通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wizDownloadFinish:) name:@"WizDownloadFinish" object:nil];
    self.navigationController.navigationBar.backgroundColor = UIColorFromRGB(0xb61527);
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.translucent = NO;
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor whiteColor], NSForegroundColorAttributeName,
                                                          nil, NSShadowAttributeName,
                                                          nil, NSFontAttributeName, nil]];
    
    UIBarButtonItem *programaButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStylePlain target:self action:@selector(programaBtnClick:)];
    self.navigationItem.leftBarButtonItem = programaButtonItem;
    
    UIBarButtonItem *userCenterButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"user"] style:UIBarButtonItemStyleBordered target:self action:@selector(userCenterBtnClick:)];
    self.navigationItem.rightBarButtonItem = userCenterButtonItem;
    
    _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MAIN_WINDOW_WIDTH, NAV_VIEW_HEIGHT) style:UITableViewStylePlain];
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    [self.view addSubview:_mainTableView];
    
    _mainArray = [[NSArray alloc] init];
    // wiz
    [[AD_NetWork shareNetWork] updateAccount];
}

- (void)wizDownloadFinish:(NSNotification *)notification
{
    //    NSLog(@"wiz - %@",[notification object]);
    _mainArray = [notification object];
    [_mainTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 1;
    else
        return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _mainArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 0;
    else
        return 22;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
        return 144;
    else
        return 74;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = [NSString stringWithFormat:@"homeCell%@",indexPath];
    if (indexPath.section == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        }
        
        UIScrollView *homeScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 10, 300, 124)];
        homeScrollView.backgroundColor = [UIColor clearColor];
        homeScrollView.pagingEnabled = YES;
        homeScrollView.contentSize = CGSizeMake(1200, 124);
        homeScrollView.showsVerticalScrollIndicator = NO;
        homeScrollView.delegate = self;
        [cell.contentView addSubview:homeScrollView];
        
        int i = 0;
        for (WizDocument *wizDoc in [_mainArray objectAtIndex:indexPath.section])
        {
            UIButton *bannerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            bannerBtn.frame = CGRectMake(i*300, 0, 300, 124);
            bannerBtn.contentMode = UIViewContentModeScaleAspectFill;
            bannerBtn.tag = 1000+i;
            [bannerBtn addTarget:self action:@selector(bannerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [homeScrollView addSubview:bannerBtn];
            
            UIImageView *bannerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 124)];
            [bannerImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:IMAGE_URL,wizDoc.guid,KBGUID,[[NSUserDefaults standardUserDefaults] valueForKey:@"token"]]]
                            placeholderImage:[UIImage imageNamed:@"banner"]];
            bannerImageView.contentMode = UIViewContentModeScaleAspectFill;
            [bannerBtn addSubview:bannerImageView];
            i++;
        }
        
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.frame = CGRectMake( 10, 114, 300, 10);
        _pageControl.pageIndicatorTintColor = [UIColor darkGrayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor colorWithWhite:.8 alpha:1];
        _pageControl.numberOfPages = 4;
        _pageControl.currentPage = 0;
        [_pageControl addTarget:self action:@selector(changePage:)forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:_pageControl];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        AD_HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell)
        {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"AD_HomeCell" owner:self options:nil] lastObject];
        }
        
        if ([[_mainArray objectAtIndex:indexPath.section] count] > 0) {
            WizDocument *wizDoc;
            if (indexPath.row == 0) {
                wizDoc = [[_mainArray objectAtIndex:indexPath.section] objectAtIndex:0];
            }
            
            if ([[_mainArray objectAtIndex:indexPath.section] count] > 1) {
                if (indexPath.row == 1)
                {
                    wizDoc = [[_mainArray objectAtIndex:indexPath.section] objectAtIndex:1];
                }
            }
            
            [cell.homeCellDetailImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:IMAGE_URL,wizDoc.guid,KBGUID,[[NSUserDefaults standardUserDefaults] valueForKey:@"token"]]]
                                     placeholderImage:[UIImage imageNamed:@"image"]];
            
            NSArray *wizTitleArray = [wizDoc.title componentsSeparatedByString:@"@"];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.homeCellTitle.text = [wizTitleArray objectAtIndex:0];
            if (wizTitleArray.count > 1) {
                cell.homeCellDetail.text = [wizTitleArray objectAtIndex:1];
            }
            
        }
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    
    UIView *headerBackView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, 22)];
    headerBackView.backgroundColor = UIColorFromRGB(0xb61527);
    [headerView addSubview:headerBackView];
    
    UILabel *programaNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 55, 22)];
    programaNameLabel.backgroundColor = [UIColor blackColor];
    programaNameLabel.text = [[[AD_NetWork addProgramaArray] objectAtIndex:section] objectForKey:@"name"];
    programaNameLabel.textAlignment = NSTextAlignmentCenter;
    programaNameLabel.font = [UIFont boldSystemFontOfSize:14];
    programaNameLabel.textColor = [UIColor whiteColor];
    [headerBackView addSubview:programaNameLabel];
    
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    moreBtn.frame = CGRectMake(240, 0, 60, 22);
    [moreBtn setTitle:@"more" forState:UIControlStateNormal];
    [moreBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    moreBtn.titleLabel.textColor = [UIColor whiteColor];
    moreBtn.backgroundColor = [UIColor clearColor];
    moreBtn.tag = section;
    [moreBtn addTarget:self action:@selector(moreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [headerBackView addSubview:moreBtn];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *titleStr = [[NSString alloc] init];
    if ([[_mainArray objectAtIndex:indexPath.section] count] > 0) {
        if (indexPath.row == 0) {
            NSArray *wizTitleArray = [[[[_mainArray objectAtIndex:indexPath.section] objectAtIndex:0] title] componentsSeparatedByString:@"@"];
            titleStr = [wizTitleArray objectAtIndex:0];
            
            AD_ArticleViewController *articleViewController = [[AD_ArticleViewController alloc] initWithGuid:[[[_mainArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] guid] WithTitle:titleStr];
            [self.navigationController pushViewController:articleViewController animated:YES];
        }
        if ([[_mainArray objectAtIndex:indexPath.section] count] > 1) {
            if (indexPath.row == 1) {
                NSArray *wizTitleArray = [[[[_mainArray objectAtIndex:indexPath.section] objectAtIndex:0] title] componentsSeparatedByString:@"@"];
                titleStr = [wizTitleArray objectAtIndex:0];
                
                AD_ArticleViewController *articleViewController = [[AD_ArticleViewController alloc] initWithGuid:[[[_mainArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] guid] WithTitle:titleStr];
                [self.navigationController pushViewController:articleViewController animated:YES];
            }
        }
    }
}

- (void)bannerBtnClick:(UIButton *)sender
{
    //    NSLog(@"tag - %d",sender.tag);
    NSString *titleStr = [[NSString alloc] init];
    NSArray *wizTitleArray = [[[[_mainArray objectAtIndex:0] objectAtIndex:sender.tag-1000] title] componentsSeparatedByString:@"@"];
    titleStr = [wizTitleArray objectAtIndex:0];
    
    AD_ArticleViewController *articleViewController = [[AD_ArticleViewController alloc] initWithGuid:[[[_mainArray objectAtIndex:0] objectAtIndex:sender.tag-1000] guid] WithTitle:titleStr];
    [self.navigationController pushViewController:articleViewController animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _pageControl.currentPage = scrollView.contentOffset.x/300;
}

- (void)moreBtnClick:(UIButton *)sender
{
    AD_AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    AD_PartViewController *partViewController = [[AD_PartViewController alloc] initWithViewController:Home VcTag:sender.tag];
    [delegate.mainNav pushViewController:partViewController animated:YES];
}

- (void)programaBtnClick:(UIBarButtonItem *)sender
{
    [self.mm_drawerController openDrawerSide:MMDrawerSideLeft animated:YES completion:^(BOOL finished) {
        
    }];
}

- (void)changePage:(UIPageControl *)sender
{
    NSLog(@"change");
}

- (void)userCenterBtnClick:(UIButton *)sender
{
    [self.mm_drawerController openDrawerSide:MMDrawerSideRight animated:YES completion:^(BOOL finished) {
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
