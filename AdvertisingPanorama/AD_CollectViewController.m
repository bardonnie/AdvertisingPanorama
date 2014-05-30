//
//  AD_CollectViewController.m
//  AdvertisingPanorama
//
//  Created by mac on 14-2-20.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//

#import "AD_CollectViewController.h"

@interface AD_CollectViewController ()< UITableViewDataSource, UITableViewDelegate, AD_NetWorkDelegate>

@end

@implementation AD_CollectViewController
{
    NSArray *_articleArray;
    UITableView *_collectTableView;
    NSMutableArray *_wizDocArray;
    UIButton *_compileBtn;
    AD_NetWork *_network;
    
    BOOL cancelBtnIsHide;
    CGFloat cellHeight;
    NSString *_guidStr;
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationController.navigationBar.translucent = NO;
    self.title = @"我的收藏";
    
    UIBarButtonItem *backBarBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backBarBtnItemClick:)];
    self.navigationItem.leftBarButtonItem = backBarBtnItem;
    
    _compileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _compileBtn.frame = CGRectMake(0, 0, 44, 30);
    [_compileBtn addTarget:self action:@selector(compileBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_compileBtn setTitle:@"编辑" forState:UIControlStateNormal];
    
    UIBarButtonItem *compileBarItem = [[UIBarButtonItem alloc] initWithCustomView:_compileBtn];
    self.navigationItem.rightBarButtonItem = compileBarItem;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"programaChange" object:nil];
    
    _articleArray = [[NSArray alloc] init];
    
    _collectTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MAIN_WINDOW_WIDTH, NAV_VIEW_HEIGHT) style:UITableViewStylePlain];
    _collectTableView.delegate = self;
    _collectTableView.dataSource = self;
    [self.view addSubview:_collectTableView];
    
    _network = [[AD_NetWork alloc] init];
    _network.delegate = self;
    [_network startDownloadWithURL:[NSString stringWithFormat:LOCALHOST_NEW,[NSString stringWithFormat:GET_COLL,[[NSUserDefaults standardUserDefaults] valueForKey:@"userID"]]]];
    
    FMResultSet *resultSet = [[DataBase shareDataBase] select];;
    _wizDocArray = [[NSMutableArray alloc] init];
    while ([resultSet next])
    {
        WizDocument *doc = [[WizDocument alloc] init];
        doc.title = [resultSet stringForColumn:@"DOCUMENT_TITLE"];
        doc.guid = [resultSet stringForColumn:@"DOCUMENT_GUID"];
        [_wizDocArray addObject:doc];
    }
    
    cancelBtnIsHide = YES;
    cellHeight = 260;
    _guidStr = [[NSString alloc] init];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _articleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId;
    AD_PartCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"AD_PartCell" owner:self options:nil] lastObject];
    }
    
    for (WizDocument *doc in _wizDocArray) {
        if ([[[_articleArray objectAtIndex:indexPath.row] objectForKey:@"ArticleID"] isEqual:doc.guid])
        {
            NSString *tmp = NSTemporaryDirectory();
            NSString *tmpPath = [tmp stringByAppendingPathComponent:doc.guid];
            NSString *tmpPathIndex = [tmpPath stringByAppendingPathComponent:@"index_files"];
            NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tmpPathIndex error:nil];
            for (NSString *fileName in files) {
                NSRange jpgRange = [fileName rangeOfString:@".jpg"];
                NSRange pngRange = [fileName rangeOfString:@".png"];
                if (jpgRange.length > 0 || pngRange.length > 0) {
                    NSString *imagePath = [tmpPathIndex stringByAppendingPathComponent:fileName];
                    cell.thumbnailImageView.image = [UIImage imageWithContentsOfFile:imagePath];
                    cell.thumbnailImageView.clipsToBounds = YES;
                }
            }
            NSArray *wizTitleArray = [doc.title componentsSeparatedByString:@"@"];
            cell.articleTitleLabel.text = [wizTitleArray objectAtIndex:0];
            cell.articleDetailLabel.text = [wizTitleArray objectAtIndex:1];            
            NSArray *dateArray = [[[_articleArray objectAtIndex:indexPath.row] objectForKey:@"DateString"] componentsSeparatedByString:@" "];
            cell.dataLabel.text = [dateArray objectAtIndex:0];
            cell.reviewNumLabel.hidden = YES;
            cell.reviewImageView.hidden = YES;
        }
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (cancelBtnIsHide)
        {
            cancelBtn.frame = CGRectMake(9, 221, 302, 38);
        }
        else
        {
            cancelBtn.frame = CGRectMake(9, 260, 302, 38);
        }
        cancelBtn.hidden = cancelBtnIsHide;
        cancelBtn.tag = indexPath.row;
        [cancelBtn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [cancelBtn setImage:[UIImage imageNamed:@"cancel_coll"] forState:UIControlStateNormal];
        [cell.contentView addSubview:cancelBtn];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *titleStr = [[NSString alloc] init];
    NSString *shareUrl;
    for (WizDocument *doc in _wizDocArray) {
        if ([[[_articleArray objectAtIndex:indexPath.row] objectForKey:@"ArticleID"] isEqual:doc.guid])
        {
            NSArray *wizTitleArray = [doc.title componentsSeparatedByString:@"@"];
            titleStr = [wizTitleArray objectAtIndex:0];
            if (wizTitleArray.count >= 3) {
                shareUrl = [wizTitleArray objectAtIndex:2];
            }
        }
    }

    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AD_ArticleViewController *articleViewController = [[AD_ArticleViewController alloc] initWithGuid:[[_articleArray objectAtIndex:indexPath.row] objectForKey:@"ArticleID"] WithTitle:titleStr AndShareUrl:shareUrl];
    [self.navigationController pushViewController:articleViewController animated:YES];
}

- (void)cancelBtnClick:(UIButton *)sender
{
    [_network startDownloadWithURL:[NSString stringWithFormat:LOCALHOST_NEW,[NSString stringWithFormat:CANCEL_COLL, [[_articleArray objectAtIndex:sender.tag] objectForKey:@"ArticleID"],[[NSUserDefaults standardUserDefaults] valueForKey:@"userID"]]]];
    _guidStr = [[_articleArray objectAtIndex:sender.tag] objectForKey:@"ArticleID"];
}

- (void)downloadFinish:(NSData *)data
{
    NSLog(@"data");
    if ([[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil] count]) {
        _articleArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    }
    else if ([[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] isEqual:@"取消收藏成功"])
    {
        NSMutableArray *docArray = [[NSMutableArray alloc] init];
        for (NSDictionary *docDic in _articleArray)
        {
            if (![[docDic objectForKey:@"ArticleID"] isEqual:_guidStr])
            {
                [docArray addObject:docDic];
            }
        }
        _articleArray = docArray;
    }
    else
    {
        
    }
    [_collectTableView reloadData];
}

- (void)downloadFaild
{
    [SVProgressHUD showErrorWithStatus:@"请连接网络" duration:1];
}

- (void)backBarBtnItemClick:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)compileBtnClick:(UIButton *)sender
{
    if (cancelBtnIsHide)
    {
        cellHeight = 298;
        [sender setTitle:@"完成" forState:UIControlStateNormal];
    }
    else
    {
        cellHeight = 260;
        [sender setTitle:@"编辑" forState:UIControlStateNormal];
    }
    cancelBtnIsHide = !cancelBtnIsHide;
    [_collectTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
