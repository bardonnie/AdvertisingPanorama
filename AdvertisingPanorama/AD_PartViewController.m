//
//  AD_PartViewController.m
//  AdvertisingPanorama
//
//  Created by mac on 14-2-18.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//

#import "AD_PartViewController.h"

@interface AD_PartViewController ()< UITableViewDataSource, UITableViewDelegate, AD_NetWorkDelegate>

@end

@implementation AD_PartViewController
{
    NSArray *_numArray;
    UITableView *_partTableView;
    NSArray *_partDataArray;
}

- (id)initWithViewController:(ViewControllers)viewController VcTag:(int)tag
{
    self = [super init];
    if (self)
    {
        NSLog(@"vc - %d",viewController);
        NSLog(@"tag - %d",tag);
        _vc = viewController;
        _tag = tag;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = [[[AD_NetWork addProgramaArray] objectAtIndex:_tag] objectForKey:@"name"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"programaChange" object:[NSString stringWithFormat:@"%d",_tag]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backBarBtnItemClick:) name:@"homeClick" object:nil];
    
    self.navigationController.navigationBar.backgroundColor = UIColorFromRGB(0xb61527);
    self.navigationController.navigationBar.translucent = NO;
    
    UIBarButtonItem *programaButtonItem;
    if (_vc == 0)
        programaButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backBarBtnItemClick:)];
    else
        programaButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStylePlain target:self action:@selector(programaBtnClick:)];
    self.navigationItem.leftBarButtonItem = programaButtonItem;
    
    _partTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MAIN_WINDOW_WIDTH,NAV_VIEW_HEIGHT) style:UITableViewStylePlain];
    _partTableView.delegate = self;
    _partTableView.dataSource = self;
    _partTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_partTableView];
    
    NSMutableString *allGuid = [[NSMutableString alloc] init];
    
    for (WizDocument *wizDoc in [[AD_NetWork shareNetWork].wizDocArray objectAtIndex:_tag])
    {
        [allGuid appendFormat:@"%@,",wizDoc.guid];
    }

    AD_NetWork *network = [[AD_NetWork alloc] init];
    network.delegate = self;
    [network startDownloadWithURL:[NSString stringWithFormat:LOCALHOST_NEW,[NSString stringWithFormat:GET_COMM_NUM,[self removeLastOneChar:allGuid]]]];
    _numArray = [[NSMutableArray alloc] init];
    NSLog(@"url - %@",[NSString stringWithFormat:LOCALHOST_NEW,[NSString stringWithFormat:GET_COMM_NUM,[self removeLastOneChar:allGuid]]]);
    [SVProgressHUD showWithStatus:@"正在努力加载..."];
    
    _partDataArray = [NSArray arrayWithArray:[[AD_NetWork shareNetWork].wizDocArray objectAtIndex:_tag]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *titleStr = [[NSString alloc] init];
    NSArray *wizTitleArray = [[[_partDataArray objectAtIndex:indexPath.row] title] componentsSeparatedByString:@"@"];
    titleStr = [wizTitleArray objectAtIndex:0];
    
    AD_ArticleViewController *articleViewController = [[AD_ArticleViewController alloc] initWithGuid:[[_partDataArray objectAtIndex:indexPath.row] guid] WithTitle:titleStr];
    [self.navigationController pushViewController:articleViewController animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _partDataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 260;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = [NSString stringWithFormat:@"Cell%@",indexPath];
    AD_PartCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"AD_PartCell" owner:self options:nil] lastObject];
    }
    WizDocument *wizDoc = [_partDataArray objectAtIndex:indexPath.row];
    
    NSString *tmp = NSTemporaryDirectory();
    NSString *tmpPath = [tmp stringByAppendingPathComponent:wizDoc.guid];
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
    
    NSArray *wizTitleArray = [wizDoc.title componentsSeparatedByString:@"@"];
    cell.articleTitleLabel.text = [wizTitleArray objectAtIndex:0];
    if (wizTitleArray.count > 1)
    {
        cell.articleDetailLabel.text = [wizTitleArray objectAtIndex:1];
    }
    if (_numArray.count) {
        cell.reviewNumLabel.text = [NSString stringWithFormat:@"%@",[_numArray objectAtIndex:indexPath.row]];
    }
    NSArray *dateArray = [[NSString stringWithFormat:@"%@",wizDoc.dateCreated] componentsSeparatedByString:@" "];
    cell.dataLabel.text = [dateArray objectAtIndex:0];
    return cell;
}

- (void)downloadFinish:(NSData *)data
{
    _numArray = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] componentsSeparatedByString:@","];
    NSLog(@"num-%@",_numArray);
    [SVProgressHUD showSuccessWithStatus:@"加载完成"];
    [_partTableView reloadData];
}

- (void)downloadFaild
{
    [SVProgressHUD showErrorWithStatus:@"请连接网络" duration:1];
}

- (void)programaBtnClick:(UIBarButtonItem *)sender
{
    [self.mm_drawerController openDrawerSide:MMDrawerSideLeft animated:YES completion:^(BOOL finished) {
        
    }];
}

- (void)backBarBtnItemClick:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)removeLastOneChar:(NSString*)origin
{
    NSString* cutted;
    if([origin length] > 0){
        // 去掉最后一个","
        cutted = [origin substringToIndex:([origin length]-1)];
    }else{
        cutted = origin;
    }
    return cutted;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
