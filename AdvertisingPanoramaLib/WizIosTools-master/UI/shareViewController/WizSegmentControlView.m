//
//  WizSegmentControlView.m
//  WizNote
//
//  Created by wzz on 13-8-7.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizSegmentControlView.h"
#import "UIImage+WizTintColor.h"

@interface WizSegmentControlCell : UIView
{
    UILabel* titleLabel;
    UIImageView* imageView;
    
    float imageWidth;
    float titleLableWidth;
}
@property(nonatomic, strong)NSString* itemTitle;
@property (nonatomic, assign)BOOL selected;
- (id)initWithTitle:(NSString*)title image:(UIImage *)image tag:(NSInteger)tag;
- (void)setCellSelected:(BOOL)selected;

@end

@implementation WizSegmentControlCell
@synthesize itemTitle;
@synthesize selected = _selected;
- (id)initWithTitle:(NSString *)title image:(UIImage *)image tag:(NSInteger)tag
{
    self = [super init];
    if (self) {
        titleLabel = [[UILabel alloc]init];
        titleLabel.text = title;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = WizColorByKind(ColorOfDefaultGrayText);
        titleLabel.highlightedTextColor = WizColorByKind(ColorOfWizSegementControlHilight);
        imageView = [[UIImageView alloc]initWithImage:[image imageWithTintColor:WizColorByKind(ColorOfDefaultGrayText)]];
        imageView.highlightedImage = [image imageWithTintColor:WizColorByKind(ColorOfWizSegementControlHilight)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:titleLabel];
        [self addSubview:imageView];
        imageWidth = image.size.width;
        titleLableWidth = [title sizeWithFont:titleLabel.font].width;
        self.tag = tag;
        self.itemTitle = title;
        _selected = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

- (void)setCellSelected:(BOOL)selected
{
    if (_selected != selected) {
        _selected = selected;
        imageView.highlighted = _selected;
        titleLabel.highlighted = _selected;
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    titleLabel.font = [UIFont systemFontOfSize:13.0];
    titleLableWidth = [titleLabel.text sizeWithFont:titleLabel.font].width;
    float space = 5.0;
    float margin = (CGRectGetWidth(self.bounds) - titleLableWidth - imageWidth - space) / 2;
    if (margin < 5) {
        margin = 5;
    }

    imageView.frame = CGRectMake(margin, 0, imageWidth, CGRectGetHeight(self.bounds));
    if (imageWidth) {
        titleLabel.frame = CGRectIntegral(CGRectMake(CGRectGetMaxX(imageView.frame) + space, 0, CGRectGetWidth(self.bounds) - CGRectGetMaxX(imageView.frame) - space - margin, CGRectGetHeight(self.bounds)));
    }else{
        titleLabel.frame = CGRectIntegral(CGRectMake(space, 0, CGRectGetWidth(self.bounds) - 2 * space, CGRectGetHeight(self.bounds)));
    }
    if( _selected){
    }else{
        self.backgroundColor = [UIColor clearColor];
    }
}

@end

@interface WizSegmentControlView()
{
    NSInteger itemCount;
    NSInteger selectIndex;
    NSInteger itemWidth;
}
@property (nonatomic, strong) NSArray* itemTitles;
@property (nonatomic, strong) NSArray* itemImages;
@property (nonatomic, strong) NSMutableArray* itemsArray;
@end

@implementation WizSegmentControlView
@synthesize delegate;
@synthesize separatorImage;
@synthesize itemTitles = _itemTitles;
@synthesize itemImages = _itemImages;
@synthesize itemsArray = _itemsArray;
@synthesize defaultSelectedIndex;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

- (id)initWithTitles:(NSArray *)titles images:(NSArray *)images
{
    self = [super init];
    if (self) {
        _itemImages = images;
        _itemTitles = titles;
        itemCount = MAX([images count], [titles count]);
        _itemsArray = [NSMutableArray array];
        for (int i = 0; i < itemCount; i++) {
            NSString* title = nil;
            UIImage* image = nil;
            if ([_itemTitles count] > i) {
                title = [_itemTitles objectAtIndex:i];
            }else{
                title = nil;
            }
            if ([_itemImages count] > i) {
                image = [_itemImages objectAtIndex:i];
            }else{
                image = nil;
            }
            WizSegmentControlCell* cell = [[WizSegmentControlCell alloc]initWithTitle:title image:image tag:i];
            [_itemsArray addObject:cell];
            [self addSubview:cell];
            self.backgroundColor = [UIColor clearColor];
            selectIndex = -1;
        }
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    if (CGRectContainsPoint(self.bounds, touchLocation)) {
        NSInteger segment = touchLocation.x / itemWidth;
        if (segment != selectIndex) {
            if (selectIndex >= 0) {
                WizSegmentControlCell* oldSelectedCell = [_itemsArray objectAtIndex:selectIndex];
                [oldSelectedCell setCellSelected:!oldSelectedCell.selected];
            }
            WizSegmentControlCell* newSelectedCell = [_itemsArray objectAtIndex:segment];
            [newSelectedCell setCellSelected:!newSelectedCell.selected];
            [self.delegate didSelectedItemWithIndex:segment itemTitle:newSelectedCell.itemTitle];
            selectIndex = segment;
        }
    }
}

- (void)setDefaultSelected:(NSInteger)defaultSelectedIndex_
{
    WizSegmentControlCell* selectedCell = [_itemsArray objectAtIndex:defaultSelectedIndex_];
    [selectedCell setCellSelected:YES];
    [self.delegate didSelectedItemWithIndex:defaultSelectedIndex_ itemTitle:selectedCell.itemTitle];
    selectIndex = defaultSelectedIndex_;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
//    self.layer.shadowColor = [UIColor colorWithHexHex:0x8d8d8d].CGColor;
//    self.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
//    self.layer.shadowRadius = 1.0;
//    self.layer.shadowOpacity = 0.5;
    float space = 1.0;
    float cellWidth = (CGRectGetWidth(self.bounds) - (itemCount + 1)* space)/itemCount ;
    itemWidth = cellWidth;
    for (WizSegmentControlCell* cell in _itemsArray) {
        cell.frame = CGRectMake(cellWidth * cell.tag + space * (cell.tag + 1), 1, cellWidth, CGRectGetHeight(self.bounds) - 2);
        [cell setNeedsLayout];
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
