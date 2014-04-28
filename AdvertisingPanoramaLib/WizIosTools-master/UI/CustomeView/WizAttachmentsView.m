//
//  WizAttachmentsView.m
//  WizNote
//
//  Created by dzpqzb on 13-4-4.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizAttachmentsView.h"
#import "GMGridView.h"
#import "GMGridViewLayoutStrategies.h"
#import "WizInterfaceEngine.h"
#import "UIViewController+WizHelp.h"

static NSString* const IndentifierOfAttachCellVertical = @"IndentifierOfAttachCellVertical";
static NSString* const IndentifierOfAttachCellHorizontal = @"IndentifierOfAttachCellHorizontal";

@interface WizGridAttachmentCell : GMGridViewCell
{
    UIImageView* backgroundView;
}
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) UIActivityIndicatorView* downloadIndicatorView;
@property (nonatomic, strong) UIImage* backgroundImage;
@property (nonatomic, strong) UIImageView* arrowView;
@end

@implementation WizGridAttachmentCell
@synthesize titleLabel = _titleLabel;
@synthesize imageView = _imageView;
@synthesize downloadIndicatorView;
@synthesize backgroundImage = _backgroundImage;
@synthesize arrowView = _arrowView;
- (void) commitInit
{
    backgroundView = [[UIImageView alloc]init];
    backgroundView.userInteractionEnabled = YES;
    [self addSubview:backgroundView];

    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [backgroundView addSubview:_titleLabel];
    _titleLabel.numberOfLines = 1;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [backgroundView addSubview:_imageView];

    
    _arrowView = [[UIImageView alloc]init];
    _arrowView.contentMode = UIViewContentModeCenter;
    [backgroundView addSubview:_arrowView];
    
    downloadIndicatorView = [[UIActivityIndicatorView alloc]
                             initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [backgroundView addSubview:downloadIndicatorView];
    
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    if (!_backgroundImage) {
    }
    [self setNeedsLayout];
}

-(void) makeDeleteButtonToFront{
    [self sendSubviewToBack:_imageView];
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    backgroundView.image = _backgroundImage;
    backgroundView.frame = self.bounds;

    if ([self.reuseIdentifier isEqualToString:IndentifierOfAttachCellHorizontal]) {
        _imageView.frame = CGRectSetWidth(CGRectSetCenterY(self.bounds, 33), 33 + 10);
        if (_backgroundImage) {
            _arrowView.image = [UIImage imageNamed:@"rightArrow"];
            _arrowView.frame =  CGRectSetX(_imageView.frame, CGRectGetWidth(self.bounds) - 43);
        }else{
            _arrowView.image = nil;
            _arrowView.frame = CGRectZero;
        }
        downloadIndicatorView.frame = CGRectMake(0,0, 10, 10);
        downloadIndicatorView.center = CGPointMake(CGRectGetMidX(_arrowView.frame), CGRectGetMidY(_arrowView.frame));
        
        _titleLabel.frame = CGRectSetWidth( CGRectSetX(CGRectSetCenterY(self.bounds, 20),
                                                       CGRectGetMaxX(_imageView.frame)),
                                           CGRectGetWidth(self.bounds) - CGRectGetWidth(_imageView.frame)-CGRectGetWidth(_arrowView.frame)) ;
        _titleLabel.numberOfLines = 1;
        [backgroundView bringSubviewToFront:_titleLabel];
        [self sendSubviewToBack:backgroundView];
    }else if ([self.reuseIdentifier isEqualToString:IndentifierOfAttachCellVertical]){
        backgroundView.backgroundColor = [UIColor clearColor];
        CGSize imageSize = _imageView.image.size;
        _imageView.frame = CGRectSetCenterX(self.bounds, imageSize.width);
        _imageView.frame = CGRectSetSize(CGRectSetY(_imageView.frame, 8), imageSize);
        _titleLabel.frame = CGRectMake(0, CGRectGetMaxY(_imageView.frame), CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - CGRectGetMaxY(_imageView.frame));
        _titleLabel.font = [UIFont systemFontOfSize:10];
        _titleLabel.textAlignment = UITextAlignmentCenter;
        _titleLabel.numberOfLines = 2;
        downloadIndicatorView.frame = CGRectMake(0,0, 10, 10);
        downloadIndicatorView.center = _titleLabel.center;
    }
}

- (id) init
{
    self = [super init];
    if (self) {
        [self commitInit];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commitInit];
    }
    return self;
}

@end

@interface WizAttachmentsView () <WizSyncDownloadDelegate>
@property (nonatomic, strong) WizAttachment* lastSelectedAttachment;
@end

@implementation WizAttachmentsView
@synthesize attachmentsArray;
@synthesize attachmetnsView;
@synthesize attachmentsDelegate;
@synthesize wizGroup;
@synthesize lastSelectedAttachment;
@synthesize layoutStrategy;
@synthesize cellBackgroundImage;
@synthesize flexibleSpacing;
@synthesize minEdgeInsets;
@synthesize direction;
- (void) dealloc
{
    [[WizNotificationCenter shareCenter] removeObserver:self];
}
- (void)GMGridView:(GMGridView *)gridView moveItemAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex
{
    
}
- (void)GMGridView:(GMGridView *)gridView exchangeItemAtIndex:(NSInteger)index1 withItemAtIndex:(NSInteger)index2{
}
- (CGSize)GMGridView:(GMGridView *)gridView sizeInFullSizeForCell:(GMGridViewCell *)cell atIndex:(NSInteger)index inInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return CGSizeMake(100, 100);
}
- (UIView *)GMGridView:(GMGridView *)gridView fullSizeViewForCell:(GMGridViewCell *)cell atIndex:(NSInteger)index{
    return [UIView new];
}

- (void) commitInit
{
    self.direction = WizAttachmentCellLayoutDirectionHorizontal;
    attachmentsArray = [NSMutableArray array];
    attachmetnsView = [[GMGridView alloc] initWithFrame:self.bounds];
    attachmetnsView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutHorizontal];
    [self addSubview:attachmetnsView];
    attachmetnsView.centerGrid = NO;
    attachmetnsView.scrollEnabled = YES;
    attachmetnsView.scrollsToTop = YES;
    attachmetnsView.style = GMGridViewStyleSwap;
    attachmetnsView.actionDelegate = self;
    attachmetnsView.dataSource = self;
    attachmetnsView.sortingDelegate = self;
    attachmetnsView.transformDelegate = self;
    attachmetnsView.itemSpacing = 10;
    attachmetnsView.minEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    attachmetnsView.enableEditOnLongPress = YES;
//    attachmetnsView.itemFlexibleSpace = 0.0;
    [[WizNotificationCenter shareCenter] addDownloadDelegate:self];
}


- (void)setLayoutStrategy:(id<GMGridViewLayoutStrategy>)layoutStrategy_
{
    attachmetnsView.layoutStrategy = layoutStrategy_;
}

- (void)setCellBackgroundImage:(UIImage *)cellBackgroundImage_
{
    cellBackgroundImage = cellBackgroundImage_;
}

- (void)setFlexibleSpacing:(CGFloat)_flexibleSpacing
{
//    attachmetnsView.itemFlexibleSpace = _flexibleSpacing;
}

- (void)setMinEdgeInsets:(UIEdgeInsets)minEdgeInsets_
{
    attachmetnsView.minEdgeInsets = minEdgeInsets_;
}



- (void) didDownloadEnd:(NSString *)guid
{
    NSArray* attachmetns = [self.attachmentsArray copy];
    for (int index = 0; index < attachmetns.count; index++) {
        WizAttachment* attach = [attachmetns objectAtIndex:index];
        if ([attach.guid isEqualToString:guid]) {
            WizGridAttachmentCell* cell = (WizGridAttachmentCell*)[attachmetnsView cellForItemAtIndex:index];
            [cell.downloadIndicatorView stopAnimating];
            cell.arrowView.hidden = NO;
        }
    }
    
    if ([self.lastSelectedAttachment.guid isEqualToString:guid]) {
        [self.attachmentsDelegate didSelectAttachment:self.lastSelectedAttachment];
    }
}

- (BOOL) GMGridView:(GMGridView *)gridView shouldAllowShakingBehaviorWhenMovingCell:(GMGridViewCell *)view atIndex:(NSInteger)index
{
    return YES;
}
- (void) GMGridView:(GMGridView *)gridView processDeleteActionForItemAtIndex:(NSInteger)index
{
    [attachmentsArray removeObjectAtIndex:index];
    [attachmetnsView removeObjectAtIndex:index animated:YES];
}

- (void) reloadAllData
{
    [attachmetnsView reloadData];
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commitInit];
    }
    return self;
}

- (void) GMGridViewDidTapOnEmptySpace:(GMGridView *)gridView
{
    gridView.editing = NO;
}
- (id) init
{
    self = [super init];
    if (self) {
        [self commitInit];
    }
    return self;
}

- (void) addAttachment:(WizAttachment*)attachment animated:(BOOL)animated
{
    NSInteger index = [self.attachmentsArray count];
    [attachmentsArray insertObject:attachment atIndex:index];
    [attachmetnsView insertObjectAtIndex:index animated:animated];
}
- (void) setAttachments:(NSArray *)attachmetns
{
    [attachmentsArray removeAllObjects];
    [attachmentsArray addObjectsFromArray:attachmetns];
    [attachmetnsView reloadData];
}

- (void) removeAllAttachments
{
    [attachmentsArray removeAllObjects];
    [attachmetnsView reloadData];
}

- (void) removeAttachmentObjectAt:(NSInteger)index animation:(BOOL)animation
{
    [attachmentsArray removeObjectAtIndex:index];
    [attachmetnsView removeObjectAtIndex:index animated:animation];
}


- (NSInteger) numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [attachmentsArray count];
}
- (GMGridViewCell*) GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    static NSString* identifier = nil;
    if (direction == WizAttachmentCellLayoutDirectionVertical) {
        identifier = IndentifierOfAttachCellVertical;
    }else if (direction == WizAttachmentCellLayoutDirectionHorizontal) {
        identifier = IndentifierOfAttachCellHorizontal;
    }
    WizGridAttachmentCell* cell = (WizGridAttachmentCell*)[gridView dequeueReusableCellWithIdentifier:identifier];
    if(!cell)
    {
        cell = [[WizGridAttachmentCell alloc] init];
        cell.reuseIdentifier = identifier;
        cell.deleteButtonIcon = WizImageByKind(ImageOfAttachmentDeleteIcon);
        cell.deleteButtonOffset = CGPointMake(-2, 0);
        [cell makeDeleteButtonToFront];
        cell.backgroundImage = cellBackgroundImage;
    }
    WizAttachment* attchment = [self.attachmentsArray objectAtIndex:index];
    cell.titleLabel.text = attchment.title;
    cell.imageView.image = WizImageAttachmentByKind(attchment.type);
    return cell;
}
- (void) GMGridView:(GMGridView *)gridView changedEdit:(BOOL)edit
{
    
}

- (CGSize) GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return CGSizeMake(67.5, 70);

    if (self.direction == WizAttachmentCellLayoutDirectionVertical) {
    }
    if (cellBackgroundImage) {
        return CGSizeMake(320, 44);
    }
    return CGSizeMake(150, 20);
}

- (void) GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    WizAttachment* attachment = [self.attachmentsArray objectAtIndex:position];
    if (attachment) {
        self.lastSelectedAttachment = attachment;
        if (attachment.serverChanged) {
            [[WizSyncCenter shareCenter] downloadAttachment:attachment.guid kbguid:self.wizGroup.guid accountUserId:self.wizGroup.accountUserId];
            WizGridAttachmentCell* cell = (WizGridAttachmentCell*)[gridView cellForItemAtIndex:position];
            [cell.downloadIndicatorView startAnimating];
            cell.downloadIndicatorView.hidden = NO;
            cell.arrowView.hidden = YES;
        }
        else
        {
           [self.attachmentsDelegate didSelectAttachment:attachment];
        }
    }
}

- (BOOL) GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index
{
    return YES;
}



@end

static float const WizAttachmentsCellHeight = 44;

@interface UITableViewCell (WizAttachment)
- (void) startActivity;
- (void) stopActivity;
@end


@implementation UITableViewCell (WizAttachment)

- (void) startActivity
{
    UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.accessoryView = activityView;
    [activityView startAnimating];
    self.userInteractionEnabled = NO;
}

- (void) stopActivity
{
    self.accessoryView= nil;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.userInteractionEnabled = YES;
}

@end


@interface WizAttachmentListCell : UITableViewCell

@end
@implementation WizAttachmentListCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        UISwipeGestureRecognizer* swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:nil];
//        swipe.direction = UISwipeGestureRecognizerDirectionLeft & UISwipeGestureRecognizerDirectionRight;
//        [self.contentView addGestureRecognizer:swipe];
    }
    return self;
}


- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
}

@end
@interface WizAttachmentListView () <UITableViewDataSource, UITableViewDelegate, WizSyncDownloadDelegate>
{
    NSMutableArray* attachmentsArray;
}
@property (nonatomic, strong) WizAttachment* lastSelectedAttachment;
@end

@implementation WizAttachmentListView
@synthesize attachmentsDelegate;
- (void) commitInit
{
   attachmentsArray = [NSMutableArray array];
    self.dataSource = self;
    self.delegate = self;
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView = nil;
    self.scrollEnabled = NO;
    [[WizNotificationCenter shareCenter] addDownloadDelegate:self];
}
- (void) dealloc
{
    [[WizNotificationCenter shareCenter] removeObserver:self];
}
- (id) init
{
    self = [super init];
    if (self) {
        [self commitInit];

    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commitInit];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commitInit];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self commitInit];
    }
    return self;
}

- (void) addAttachment:(WizAttachment *)attachment animated:(BOOL)animated
{
    [attachmentsArray insertObject:attachment atIndex:0];
    [self beginUpdates];
    [self insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self endUpdates];
}

- (void) removeAllAttachments
{
    [attachmentsArray removeAllObjects];
    [self reloadData];
    [self fixFrame];
}
- (void) removeAttachmentObjectAt:(NSInteger)index animation:(BOOL)animation
{
    if (index >= [attachmentsArray count]) {
        return;
    }
    [attachmentsArray removeObjectAtIndex:index];
    [self deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self fixFrame];
}
- (void) setAttachments:(NSArray *)attachmetns
{
    [attachmentsArray removeAllObjects];
    [attachmentsArray addObjectsFromArray:attachmetns];
    [self reloadData];
    [self fixFrame];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [attachmentsArray count];
}
- (NSInteger) numberOfSections
{
    return 1;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellIdentifier = @"attachmentsCell";
    WizAttachmentListCell* cell = (WizAttachmentListCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[WizAttachmentListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];

    }
    WizAttachment* attachment = [attachmentsArray objectAtIndex:indexPath.row];
    cell.imageView.image = WizImageAttachmentByKind(attachment.type);
    cell.textLabel.text = attachment.title;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.detailTextLabel.text = attachment.type;
    [cell stopActivity];
    return cell;
}

- (NSString*)attachmentType:(WizAttachment*)attachment
{
    NSArray* contents = [attachment.title componentsSeparatedByString:@"."];
    NSString* type = [contents lastObject];
    
    if ([WizGlobals checkAttachmentTypeIsAudio:type]) {
        return @"wav";
    }else if([WizGlobals checkAttachmentTypeIsTxt:type]){
        return @"txt";
    }else if([WizGlobals checkAttachmentTypeIsWord:type]){
        return @"word";
    }else if([WizGlobals checkAttachmentTypeIsPPT:type]){
        return @"ppt";
    }else if([WizGlobals checkAttachmentTypeIsExcel:type]){
        return @"excel";
    }else if([WizGlobals checkAttachmentTypeIsHtml:type]){
        return @"html";
    }else if ([WizGlobals checkAttachmentTypeIsPdf:type]){
        return @"pdf";
    }else if ([WizGlobals checkAttachmentTypeIsImage:type]){
        return @"img";
    }else{
        return @"Others";
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WizAttachment* attachment = [attachmentsArray objectAtIndex:indexPath.row];
    
    if (attachment.serverChanged) {
        [[WizSyncCenter shareCenter] downloadAttachment:attachment.guid kbguid:self.group.guid accountUserId:self.group.accountUserId];
        self.lastSelectedAttachment = attachment;
    }
    else
    {
        [self.attachmentsDelegate didSelectAttachment:attachment];
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return WizAttachmentsCellHeight;
}
- (void) fixFrame
{
    NSInteger rows = [attachmentsArray count];
    float height = rows * WizAttachmentsCellHeight;
    if (self.style == UITableViewStyleGrouped && height > 2) {
        height += 40;
    }
    [UIView animateWithDuration:0.25 animations:^{
       self.frame = CGRectSetHeight(self.frame, height);
    }];
}

- (NSIndexPath*) indexPathForAttachment:(NSString*)guid
{
    for (int i = 0 ; i < [attachmentsArray count]; ++i) {
        WizAttachment* attachment = [attachmentsArray objectAtIndex:i];
        if ([attachment.guid isEqualToString:guid]) {
            return [NSIndexPath indexPathForRow:i inSection:0];
        }
    }
    return nil;
}

- (void) didDownloadStart:(NSString *)guid
{
    NSIndexPath* indexPath = [self indexPathForAttachment:guid];
    if (indexPath) {
        UITableViewCell* cell = [self cellForRowAtIndexPath:indexPath];
        [cell startActivity];
    }
}
- (void) didDownloadFaild:(NSString *)guid error:(NSError *)error
{
    NSIndexPath* indexPath = [self indexPathForAttachment:guid];
    if (indexPath) {
        UITableViewCell* cell = [self cellForRowAtIndexPath:indexPath];
        [cell stopActivity];
    }
}
- (void) didDownloadEnd:(NSString *)guid
{
    NSIndexPath* indexPath = [self indexPathForAttachment:guid];
    if (indexPath) {
        UITableViewCell* cell = [self cellForRowAtIndexPath:indexPath];
        [cell stopActivity];
        id<WizInfoDatabaseDelegate> db = [WizDBManager getMetaDataBaseForKbguid:self.group.guid accountUserId:self.group.accountUserId];
        WizAttachment* attachment = [db attachmentFromGUID:guid];
        [attachmentsArray replaceObjectAtIndex:indexPath.row withObject:attachment];
        [self.attachmentsDelegate didSelectAttachment:attachment];
    }
}
@end
