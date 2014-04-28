//
//  WizBizUserTokenierTextView.m
//  WizNote
//
//  Created by dzpqzb on 13-5-13.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizBizUserTokenierTextView.h"
@interface WizBizUserTokenierTextView () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>
{
    UITableView* userTableView;
}
@property (nonatomic, strong) NSArray* bizUserArray;
@property (nonatomic, weak) id<UITextViewDelegate> oldDelegate;
@end

@implementation WizBizUserTokenierTextView
@synthesize bizGuid = _bizGuid;
@synthesize bizUserArray = _bizUserArray;
@synthesize oldDelegate = _oldDelegate;



- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_bizUserArray count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellIndentifier = @"Cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    }
    WizBizUser* bizUser = [_bizUserArray objectAtIndex:indexPath.row];
    cell.textLabel.text = bizUser.userId;
    return cell;
}
- (id) initWithBizGuid:(NSString*)bizGuid
{
    self = [super init];
    if (self) {
        _bizGuid = bizGuid;
        _bizUserArray = [[WizDBManager temporaryDataBase] bizUsersByBizGuid:bizGuid];
        userTableView = [[UITableView alloc] init];
        userTableView.delegate = self;
        userTableView.dataSource = self;
        self.delegate = self;
        [self addSubview:userTableView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void) textViewDidChange:(UITextView *)textView
{
    if ([textView.text hasSuffix:@"@"]) {

            userTableView.frame = CGRectMake(0, 0, 100, 300);
            [userTableView reloadData];
        
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
