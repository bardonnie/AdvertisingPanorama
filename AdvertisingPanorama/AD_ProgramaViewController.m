//
//  AD_ProgramaViewController.m
//  AdvertisingPanorama
//
//  Created by mac on 14-2-18.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//

#import "AD_ProgramaViewController.h"

@interface AD_ProgramaViewController ()< UITableViewDataSource, UITableViewDelegate>

@end

@implementation AD_ProgramaViewController
{
    NSArray *_programaImageArray;
    UIView *_selectView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorFromRGB(0x1d1d1d);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectViewChange:) name:@"programaChange" object:nil];
    
    UITableView *programaTabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MAIN_WINDOW_WIDTH, MAIN_WINDOW_HEIGHT) style:UITableViewStylePlain];
    programaTabelView.delegate = self;
    programaTabelView.dataSource = self;
    programaTabelView.scrollEnabled = NO;
    programaTabelView.backgroundColor = UIColorFromRGB(0x1d1d1d);
    programaTabelView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:programaTabelView];
    
    _programaImageArray = [[NSArray alloc] initWithObjects:@"home", @"editorial", @"subject", @"Focus", @"Trend", @"person",@"Case" ,@"media",@"tiger", @"observe", nil];
    
    _selectView = [[UIView alloc] initWithFrame:CGRectMake(0, 74, 5, 37.5)];
    _selectView.backgroundColor = UIColorFromRGB(0xb61527);
    [programaTabelView addSubview:_selectView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [AD_NetWork addProgramaArray].count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 74;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 37.5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AD_AppDelegate *delegate = [[UIApplication sharedApplication] delegate];

    [UIView animateWithDuration:.1 animations:^{
        _selectView.frame = CGRectMake(0, 74+indexPath.row*37.5, 5, 37.5);
    }];
    
    AD_PartViewController *partViewController;
    switch (indexPath.row) {
        case Home:
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"homeClick" object:nil];
            [self.mm_drawerController setCenterViewController:delegate.mainNav withFullCloseAnimation:YES completion:nil];
        }
            break;
        case Editorial:
        {
            partViewController = [[AD_PartViewController alloc] initWithViewController:Editorial VcTag:Editorial];
            UINavigationController *partNav = [[UINavigationController alloc] initWithRootViewController:partViewController];
            [self.mm_drawerController setCenterViewController:partNav withFullCloseAnimation:YES completion:nil];
        }
            break;
        case Subject:
        {
            partViewController = [[AD_PartViewController alloc] initWithViewController:Subject VcTag:Subject];
            UINavigationController *partNav = [[UINavigationController alloc] initWithRootViewController:partViewController];
            [self.mm_drawerController setCenterViewController:partNav withFullCloseAnimation:YES completion:nil];
        }
            break;
        case Focus:
        {
            partViewController = [[AD_PartViewController alloc] initWithViewController:Focus VcTag:Focus];
            UINavigationController *partNav = [[UINavigationController alloc] initWithRootViewController:partViewController];
            [self.mm_drawerController setCenterViewController:partNav withFullCloseAnimation:YES completion:nil];
        }
            break;
        case Trend:
        {
            partViewController = [[AD_PartViewController alloc] initWithViewController:Trend VcTag:Trend];
            UINavigationController *partNav = [[UINavigationController alloc] initWithRootViewController:partViewController];
            [self.mm_drawerController setCenterViewController:partNav withFullCloseAnimation:YES completion:nil];
        }
            break;
        case Tiger:
        {
            partViewController = [[AD_PartViewController alloc] initWithViewController:Tiger VcTag:Tiger];
            UINavigationController *partNav = [[UINavigationController alloc] initWithRootViewController:partViewController];
            [self.mm_drawerController setCenterViewController:partNav withFullCloseAnimation:YES completion:nil];
        }
            break;
        case Observer:
        {
            partViewController = [[AD_PartViewController alloc] initWithViewController:Observer VcTag:Observer];
            UINavigationController *partNav = [[UINavigationController alloc] initWithRootViewController:partViewController];
            [self.mm_drawerController setCenterViewController:partNav withFullCloseAnimation:YES completion:nil];
        }
            break;
        case Cases:
        {
            partViewController = [[AD_PartViewController alloc] initWithViewController:Cases VcTag:Cases];
            UINavigationController *partNav = [[UINavigationController alloc] initWithRootViewController:partViewController];
            [self.mm_drawerController setCenterViewController:partNav withFullCloseAnimation:YES completion:nil];
        }
            break;
        case Media:
        {
            partViewController = [[AD_PartViewController alloc] initWithViewController:Media VcTag:Media];
            UINavigationController *partNav = [[UINavigationController alloc] initWithRootViewController:partViewController];
            [self.mm_drawerController setCenterViewController:partNav withFullCloseAnimation:YES completion:nil];
        }
            break;
        case Person:
        {
            partViewController = [[AD_PartViewController alloc] initWithViewController:Person VcTag:Person];
            UINavigationController *partNav = [[UINavigationController alloc] initWithRootViewController:partViewController];
            [self.mm_drawerController setCenterViewController:partNav withFullCloseAnimation:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAIN_WINDOW_WIDTH, NAV_BAR_HEIGHT)];
    
    UIImageView *programaImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"left_background"]];
    programaImageView.frame = CGRectMake(0, 0, WINDOW_WIDTH, 74);
    [headerView addSubview:programaImageView];
    
    UIImageView *sloganImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Slogan"]];
    sloganImageView.frame = CGRectMake( 28, 36, 190, 19);
    [programaImageView addSubview:sloganImageView];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    cell.textLabel.text = [[[AD_NetWork addProgramaArray] objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.imageView.image = [UIImage imageNamed:[_programaImageArray objectAtIndex:indexPath.row]];
    cell.contentView.backgroundColor = UIColorFromRGB(0x1d1d1d);
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = UIColorFromRGB(0x181718);
    
    UIImageView *lineImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_black"]];
    lineImageView.frame = CGRectMake(30, 36.5, WINDOW_WIDTH-30, 1);
    [cell.contentView addSubview:lineImageView];
    return cell;
}

- (void)selectViewChange:(NSNotification *)sender
{
    [UIView animateWithDuration:.1 animations:^{
        _selectView.frame = CGRectMake(0, 74+[[sender object] intValue]*37.5, 5, 37.5);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
