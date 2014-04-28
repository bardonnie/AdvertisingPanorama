//
//  AD_CommentViewController.m
//  AdvertisingPanorama
//
//  Created by mac on 14-2-19.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//

#import "AD_CommentViewController.h"

@interface AD_CommentViewController ()< UITableViewDataSource, UITableViewDelegate, AD_NetWorkDelegate>

@end

@implementation AD_CommentViewController
{
    NSString *_guid;
    NSArray *_commArray;
    UITableView *_commentTableView;
    UIImageView *_commImageBackImageView;
    UIControl *_reviewView;
    UITextView *_reviewTextView;
    
    NSMutableArray *_cellHeightArray;
    AD_NetWork *_network;
}

- (id)initWithGuid:(NSString *)guid
{
    self = [super init];
    if (self) {
        _guid = [NSString stringWithString:guid];
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
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    _commentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MAIN_WINDOW_WIDTH, NAV_VIEW_HEIGHT-NAV_BAR_HEIGHT) style:UITableViewStylePlain];
    _commentTableView.delegate = self;
    _commentTableView.dataSource = self;
    [self.view addSubview:_commentTableView];
    
    _commImageBackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, NAV_VIEW_HEIGHT-NAV_BAR_HEIGHT, MAIN_WINDOW_WIDTH, NAV_BAR_HEIGHT)];
    [_commImageBackImageView setImage:[UIImage imageNamed:@"background"]];
    _commImageBackImageView.userInteractionEnabled = YES;
    [self.view addSubview:_commImageBackImageView];
    
    UIImageView *commImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 8, 296, 28)];
    [commImageView setImage:[UIImage imageNamed:@"write-frame-1"]];
    commImageView.userInteractionEnabled = YES;
    [_commImageBackImageView addSubview:commImageView];
    
    UITextField *commTextField = [[UITextField alloc] initWithFrame:CGRectMake( 28, 4, 252, 20)];
    commTextField.borderStyle = UITextBorderStyleNone;
    commTextField.placeholder = @"写评论";
    commTextField.font = [UIFont systemFontOfSize:16];
    [commImageView addSubview:commTextField];
    
    // 弹出的评论框
    _reviewView = [[UIControl alloc] initWithFrame:CGRectMake(0, 100, MAIN_WINDOW_WIDTH, 145)];
    _reviewView.backgroundColor = [UIColor whiteColor];
    _reviewView.alpha = .9;
    _reviewView.hidden = YES;
    [self.view addSubview:_reviewView];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(10, 10, 35, 28);
    [cancelBtn setImage:[UIImage imageNamed:@"no"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_reviewView addSubview:cancelBtn];
    
    UIImageView *writeReview = [[UIImageView alloc] initWithFrame:CGRectMake(133, 15, 53, 18)];
    [writeReview setImage:[UIImage imageNamed:@"write"]];
    [_reviewView addSubview:writeReview];
    
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    submitBtn.frame = CGRectMake(270, 10, 35, 28);
    [submitBtn setImage:[UIImage imageNamed:@"yes"] forState:UIControlStateNormal];
    [submitBtn addTarget:self action:@selector(submitBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_reviewView addSubview:submitBtn];
    
    _reviewTextView = [[UITextView alloc] initWithFrame:CGRectMake(15, 44, 291, 80)];
    _reviewTextView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"box"]];
    _reviewTextView.font = [UIFont systemFontOfSize:16];
    [_reviewView addSubview:_reviewTextView];
    
    _network = [[AD_NetWork alloc] init];
    _network.delegate = self;
    [_network startDownloadWithURL:[NSString stringWithFormat:LOCALHOST_NEW,[NSString stringWithFormat:GET_ALL_COMM,_guid]]];
    
    _commArray = [[NSArray alloc] init];
    _cellHeightArray = [[NSMutableArray alloc] init];
    
    // 系统通知（键盘出现消失）
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardwillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)keyboardWillShow:(NSNotification *)sender
{
    _reviewView.hidden = NO;
    // 获取系统键盘高
    NSDictionary *dict = [sender userInfo];
    NSValue *value = [dict objectForKey:@"UIKeyboardBoundsUserInfoKey"];
    CGSize keyboardSize = [value CGRectValue].size;
    // 移动工具条上移
    [UIView animateWithDuration:.3 animations:^{
        _reviewView.frame = CGRectMake(0, NAV_VIEW_HEIGHT-145-keyboardSize.height, MAIN_WINDOW_WIDTH, 145);
    }];
    
    [_reviewTextView becomeFirstResponder];
}

- (void)keyboardwillHide:(NSNotification *)sender
{
    _reviewView.hidden = YES;
}

- (void)cancelBtnClick
{
    [_reviewTextView resignFirstResponder];
    _reviewTextView.text = @"";
}

- (void)submitBtnClick
{
    if ([_reviewTextView.text isEqual:@""])
    {
        [SVProgressHUD showErrorWithStatus:@"请输入评论内容" duration:1];
    }
    else
    {
        [_reviewTextView resignFirstResponder];
        [_network startDownloadWithURL:[NSString stringWithFormat:LOCALHOST,[NSString stringWithFormat:POST_COMM,[[NSUserDefaults standardUserDefaults] valueForKey:@"userID"], _guid, _reviewTextView.text]]];
    }
}

- (void)downloadFinish:(NSData *)data
{
    if ([[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil] isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        if ([dic objectForKey:@"Status"])
        {
            [_network startDownloadWithURL:[NSString stringWithFormat:LOCALHOST_NEW,[NSString stringWithFormat:GET_ALL_COMM,_guid]]];
        }
    }
    else
    {
        _commArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        for (NSDictionary *dic in _commArray)
        {
            NSString *s = [dic objectForKey:@"Content"];
            UIFont *font = [UIFont fontWithName:@"Arial" size:14];
            CGSize size = CGSizeMake(300,2000);
            CGSize labelsize = [s sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
            [_cellHeightArray addObject:[NSString stringWithFormat:@"%f",labelsize.height]];
        }
    }
    [_commentTableView reloadData];
}

- (void)downloadFaild
{
    [SVProgressHUD showErrorWithStatus:@"请连接网络" duration:1];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _commArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_cellHeightArray.count)
    {
        return 44;
    }
    else
    {
        return 32+[[_cellHeightArray objectAtIndex:indexPath.row] floatValue];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = [NSString stringWithFormat:@"cellID%@",indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 25)];
    nameLabel.backgroundColor = [UIColor whiteColor];
    nameLabel.font = [UIFont systemFontOfSize:16];
    nameLabel.text = [[_commArray objectAtIndex:indexPath.row] objectForKey:@"RealName"];
    [cell.contentView addSubview:nameLabel];
    
    UILabel *label = [[UILabel alloc] init];
    [label setNumberOfLines:0];
    label.backgroundColor = [UIColor whiteColor];
    
    NSString *s =[[_commArray objectAtIndex:indexPath.row] objectForKey:@"Content"];
    UIFont *font = [UIFont fontWithName:@"Arial" size:14];
    CGSize size = CGSizeMake(300,2000);
    CGSize labelsize = [s sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
    
    label.text = s;
    label.font = [UIFont systemFontOfSize:13];
    label.lineBreakMode = NSLineBreakByCharWrapping;
    label.frame = CGRectMake(10, 25, labelsize.width, labelsize.height);
    [cell.contentView addSubview:label];
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 100, 20)];
    dateLabel.textAlignment = NSTextAlignmentRight;
    dateLabel.backgroundColor = [UIColor whiteColor];
    dateLabel.text = [[_commArray objectAtIndex:indexPath.row] objectForKey:@"DateString"];
    dateLabel.font = [UIFont systemFontOfSize:14];
    [cell.contentView addSubview:dateLabel];
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
