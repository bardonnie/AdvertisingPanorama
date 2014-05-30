//
//  AD_UserCenterViewController.m
//  AdvertisingPanorama
//
//  Created by mac on 14-2-18.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//

#import "AD_UserCenterViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "AD_QRCodeViewController.h"

@interface AD_UserCenterViewController ()< UITableViewDataSource, UITableViewDelegate, AD_NetWorkDelegate, UIActionSheetDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate>
{
    NSArray *_userCenterArray;
    NSArray *_userCenterImageArray;
    AD_AppDelegate *_delegate;
    UILabel *_loginLabel;
    UIButton *_loginBtn;
}

@end

@implementation AD_UserCenterViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    [self getUserInfo:[[NSUserDefaults standardUserDefaults] valueForKey:@"userID"]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBarHidden = YES;
    
    // 订阅登录完成系统通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFinish:) name:@"LoginSuccess" object:nil];
    
    UITableView *userCenterTableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, WINDOW_WIDTH, MAIN_WINDOW_HEIGHT) style:UITableViewStylePlain];
    userCenterTableView.delegate = self;
    userCenterTableView.dataSource = self;
    userCenterTableView.scrollEnabled = NO;
    userCenterTableView.backgroundColor = UIColorFromRGB(0x1d1d1d);
    userCenterTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:userCenterTableView];
    
    _userCenterArray = [[NSArray alloc] initWithObjects:@"我的收藏", @"关于我们", @"在线投稿", @"扫我下载", @"常用设置",@"应用推荐",nil];
    _delegate = [UIApplication sharedApplication].delegate;
    
    _userCenterImageArray = [[NSArray alloc] initWithObjects:@"collect_white", @"about", @"投稿", @"二维码", @"set-up", @"推荐", nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _userCenterArray.count-1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WINDOW_WIDTH, 150)];
    [headerImageView setImage:[UIImage imageNamed:@"right-background"]];
    headerImageView.userInteractionEnabled = YES;
    
    _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _loginBtn.frame = CGRectMake(97, 47, 53, 53);
    [_loginBtn setImage:[UIImage imageNamed:@"Head"] forState:UIControlStateNormal];
    [_loginBtn addTarget:self action:@selector(loginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [headerImageView addSubview:_loginBtn];
    
    _loginLabel = [[UILabel alloc] init];
    _loginLabel.frame = CGRectMake(0, 106, WINDOW_WIDTH, 28);
    _loginLabel.backgroundColor = [UIColor clearColor];
    _loginLabel.textColor = [UIColor whiteColor];
    _loginLabel.font = [UIFont boldSystemFontOfSize:16];
    _loginLabel.textAlignment = NSTextAlignmentCenter;
    _loginLabel.text = @"登录/注册";
    [headerImageView addSubview:_loginLabel];
    
    return headerImageView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 150;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    cell.textLabel.text = [_userCenterArray objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.imageView.image = [UIImage imageNamed:[_userCenterImageArray objectAtIndex:indexPath.row]];
    cell.contentView.backgroundColor = UIColorFromRGB(0x1d1d1d);
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = UIColorFromRGB(0x181718);
    
    UIImageView *lineImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_black"]];
    lineImageView.frame = CGRectMake(30, 43, WINDOW_WIDTH-30, 1);
    [cell.contentView addSubview:lineImageView];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row)
    {
        case 0:
        {
            AD_CollectViewController *collectViewController = [[AD_CollectViewController alloc] init];
            [_delegate.rootNav pushViewController:collectViewController animated:YES];
        }
            break;
        case 1:
        {
            AD_AboutViewController *aboutViewController = [[AD_AboutViewController alloc] init];
            [_delegate.rootNav pushViewController:aboutViewController animated:YES];
        }
            break;
        case 2:
        {
            Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
            if (mailClass != nil)
            {
                if ([mailClass canSendMail])
                {
                    [self displayMailViewController];
                }
                else
                {
                    [SVProgressHUD showErrorWithStatus:@"请设置邮箱或直接投稿至adp@vip.163.com" duration:3];
                }
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:@"请设置邮箱或直接投稿至adp@vip.163.com" duration:3];
            }
        }
            break;
        case 3:
        {
            AD_QRCodeViewController *qRCodeViewController = [[AD_QRCodeViewController alloc] init];
            [_delegate.rootNav pushViewController:qRCodeViewController animated:YES];
        }
            break;
        case 4:
        {
            AD_SettingViewController *settingViewController = [[AD_SettingViewController alloc] init];
            [_delegate.rootNav pushViewController:settingViewController animated:YES];
        }
            break;
//        case 5:
//        {
//            AD_AppViewController *appViewController = [[AD_AppViewController alloc] init];
//            [_delegate.rootNav pushViewController:appViewController animated:YES];
//        }
            break;
        default:
            break;
    }
}

- (void)displayMailViewController
{
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:@"在线投稿"];
    [mc setToRecipients:[NSArray arrayWithObjects:@"adp@vip.163.com", nil]];
     [self presentModalViewController:mc animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSLog(@"error - %@",error);
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"cancel");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"save");
            break;
        case MFMailComposeResultSent:
        {
            [SVProgressHUD showSuccessWithStatus:@"投稿已发送"];
            NSLog(@"sent");
        }
            break;
        case MFMailComposeResultFailed:
            NSLog(@"failed");
            break;
        default:
            break;
    }
    [controller dismissModalViewControllerAnimated:YES];
}

- (void)loginFinish:(NSNotification *)sender
{
    NSLog(@"id - %@",[sender object]);
    [[NSUserDefaults standardUserDefaults] setValue:[sender object] forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self getUserInfo:[sender object]];
}

- (void)getUserInfo:(NSString *)uid
{
    if ([uid intValue] > 1000) {
        AD_NetWork *network = [[AD_NetWork alloc] init];
        network.delegate = self;
        [network startDownloadWithURL:[NSString stringWithFormat:LOCALHOST,[NSString stringWithFormat:GET_USER,uid]]];
    }
    else
    {
        _loginLabel.text = @"登录/注册";
        [_loginBtn setImage:[UIImage imageNamed:@"Head"] forState:UIControlStateNormal];
        [_loginBtn removeTarget:self action:@selector(chooseHeaderImage:) forControlEvents:UIControlEventTouchUpInside];
        [_loginBtn addTarget:self action:@selector(loginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)downloadFinish:(NSData *)data
{
    NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    _loginLabel.text = [[resultDic objectForKey:@"Data"] objectForKey:@"RealName"];
    [_loginBtn setImage:[UIImage imageNamed:@"Head_red"] forState:UIControlStateNormal];
    [_loginBtn removeTarget:self action:@selector(loginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_loginBtn addTarget:self action:@selector(chooseHeaderImage:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)downloadFaild
{
    
}

- (void)chooseHeaderImage:(UIButton *)sender
{
    UIActionSheet *chooseImageSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                                  delegate:self
                                                         cancelButtonTitle:@"取消"
                                                    destructiveButtonTitle:nil
                                                         otherButtonTitles:@"退出登录", nil];
    chooseImageSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [chooseImageSheet showInView:_delegate.rootNav.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccess" object:@"1000" userInfo:nil];
        [SVProgressHUD showSuccessWithStatus:@"退出成功" duration:1];
    }
    else
    {
        
    }
}

- (void)loginBtnClick:(UIButton *)sender
{
    AD_LoginViewController *loginViewController = [[AD_LoginViewController alloc] init];
    [_delegate.rootNav pushViewController:loginViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
