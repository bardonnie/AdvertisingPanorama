//
//  WizMenuView.m
//  WizNote
//
//  Created by wzz on 13-5-17.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizMenuView.h"
#import <QuartzCore/QuartzCore.h>


@interface WizMenuViewCell : UITableViewCell

@end

@implementation WizMenuViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectedBackgroundView = [self msgGroupCellSelectedView];
        if ([reuseIdentifier isEqualToString:@"WizBizNameCell"]) {
            UIView* view = [[UIView alloc]init];
            view.backgroundColor = [UIColor colorWithHexHex:0x3c4651];
            self.backgroundView = view;
        }
    }
    return self;
}

- (UIView*)msgGroupCellSelectedView
{
    UIView* view = [[UIView alloc]init];
    view.backgroundColor = [UIColor colorWithHexHex:0x56677b];
    return view;
}


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if ([self.reuseIdentifier isEqualToString:@"WizMessageGroupCell"]) {
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.highlightedTextColor = [UIColor colorWithHexHex:0x7ac2ff];
        self.textLabel.font = [UIFont boldSystemFontOfSize:18];
    }else if ([self.reuseIdentifier isEqualToString:@"WizBizNameCell"]){
        self.textLabel.textColor = [UIColor colorWithHexHex:0x898d93];
        self.textLabel.font = [UIFont boldSystemFontOfSize:15];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

@end


@interface WizMenuView()
{
    NSIndexPath* lastSelectedIndexPath;
}
@end

@implementation WizMenuView
@synthesize tableView = _tableView;
@synthesize dataArray = _dataArray;
@synthesize menuDelegate = _menuDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 20, 20) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self addSubview:_tableView];
        _dataArray = [NSMutableArray array];
        lastSelectedIndexPath = nil;
    }
    return self;
}

- (NSInteger)dataCount
{
    NSInteger count = 0;
    for (NSArray* each in _dataArray) {
        count += [each count];
    }
    return count;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    float letfMargin = 2;
    float topMargin = 13;
    _tableView.frame = CGRectMake(letfMargin, topMargin, CGRectGetWidth(self.bounds) - 2*letfMargin, CGRectGetHeight(self.bounds) - 20);
}

- (void)setDataArray:(NSMutableArray *)dataArray
{
    _dataArray = dataArray;
}

- (void)reloadMenuData
{    
    [self.tableView reloadData];
    lastSelectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:lastSelectedIndexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
}

- (void)autoScrollToLastSelectedPosition
{
    if (lastSelectedIndexPath) {
        [self.tableView scrollToRowAtIndexPath:lastSelectedIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
}

- (void)showMenuWithAnimate:(BOOL)animated
{
    [UIView beginAnimations:@"showMenu" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.25];
    self.alpha = 1.0;
    [UIView commitAnimations];
}

- (void)hideMenuWithAnimate:(BOOL)animated
{
    if (animated != -1) {
        animated = YES;
    }
    if (animated) {
        [UIView beginAnimations:@"hideMenu" context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.25];
        self.alpha = 0.0;
        [UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
        [UIView commitAnimations];
    }else{
        [self removeFromSuperview];
    }
}

#pragma -
#pragma tableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_dataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_dataArray objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = nil;
    WizGroup* object = [[self.dataArray objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
    if ([object isKindOfClass:[NSString class]] && ![object isEqual:WizStrAllMessages]) {
        CellIdentifier = @"WizBizNameCell";
    }else{
        CellIdentifier = @"WizMessageGroupCell";
    }
    WizMenuViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[WizMenuViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if ([object isKindOfClass:[NSString class]]) {
        if ( [object isEqual:WizStrAllMessages]) {
            cell.textLabel.text = WizStrAllMessages;
        }else{
            NSString* bizName = (NSString*)object;
            cell.textLabel.text = bizName;
        }
    }else{
        cell.textLabel.text = object.title;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WizGroup* object = [[self.dataArray objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
    if ([object isKindOfClass:[NSString class]] && ![object isEqual:WizStrAllMessages]) {
        return 20;
    }else{
        return messageGroupCellHeight;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    lastSelectedIndexPath = indexPath;
    [self.menuDelegate menuView:self didSelectedRowAtIndexPath:indexPath];
}


@end
