//
//  WizSelectSceneViewController.m
//  WizIphone7
//
//  Created by dzpqzb on 13-9-12.
//  Copyright (c) 2013年 dzpqzb inc. All rights reserved.
//

#import "WizSelectSceneViewController.h"
#import "WizCore.h"


@interface WizSelectSceneCell : UITableViewCell
{
    
}
@end
@implementation WizSelectSceneCell

- (void) layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(20, 5, CGRectGetWidth(self.frame)-40, 20);
    self.detailTextLabel.frame = CGRectMake(30, CGRectGetMaxY(self.textLabel.frame) + 5, CGRectGetWidth(self.textLabel.frame)-10, 90);
    self.backgroundView.frame = CGRectMake(10, 0, CGRectGetWidth(self.frame) - 20, CGRectGetHeight(self.frame));
}

@end

@interface WizSelectSceneViewController ()
{
    NSArray* sceneData;
}
@end
static NSString* const kSenceDataKey = @"kSenceDataKey";
static NSString* const kSceneDataTitle = @"kSceneDataTitle";
static NSString* const kSceneDataDescripter = @"kSceneDataDescripter";
static NSString* const kSceneDataFolders = @"kSceneDataFolders";
static NSString* const kSceneDataTags = @"kSceneDataTags";

@implementation WizSelectSceneViewController

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
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    NSString* path = [[NSBundle mainBundle] pathForResource:@"UserGuideFolderAndTags" ofType:@"plist"];
    sceneData = [NSArray arrayWithContentsOfFile:path];
    
    UIView* view = [UIView new];
    view.backgroundColor =[UIColor colorWithPatternImage:[UIImage imageNamed:@"select_scene_backgroud"]];
    self.tableView.backgroundView = view;
	// Do any additional setup after loading the view.
    
    
    UIView* headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 80)];
    UILabel* selectTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, 22, (CGRectGetWidth(self.view.frame)- 22), 20)];
    selectTextLabel.textColor = [UIColor whiteColor];
    selectTextLabel.font = [UIFont systemFontOfSize:18];
    selectTextLabel.text =  NSLocalizedString(@"Choose one scene that suits you", nil);
    selectTextLabel.backgroundColor = [UIColor clearColor];
    UILabel* desTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(22, 22 + 25, (CGRectGetWidth(self.view.frame)- 32), 40)];
    desTextLabel.text = NSLocalizedString(@"We create a number of folders and tags for you to use WizNote conveniently.", nil);
    desTextLabel.textColor = [UIColor lightTextColor];
    desTextLabel.numberOfLines = 0;
    desTextLabel.font = [UIFont systemFontOfSize:13];
    desTextLabel.backgroundColor = [UIColor clearColor];
    [headView addSubview:selectTextLabel];
    [headView addSubview:desTextLabel];
    self.tableView.tableHeaderView = headView;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate didSelectSecneAccountUserId:_accountUserId folders:sceneData[indexPath.section][kSceneDataFolders] tags:sceneData[indexPath.section][kSceneDataTags]];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return [sceneData count];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell* ) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* const cellIdentify = @"cellForRowAtIndexPath";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (!cell) {
        cell = [[WizSelectSceneCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentify];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.textColor = [UIColor lightTextColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kuang"]];
    }
    NSString* title = NSLocalizedString(sceneData[indexPath.section][kSceneDataTitle], nil);
    NSString* descrpiter = NSLocalizedString(sceneData[indexPath.section][kSceneDataDescripter], nil);
    cell.textLabel.text = title;
    cell.detailTextLabel.text = descrpiter;
    return cell;
}
- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    return view;
}
- (float) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
