//
//  WizBadgeValeButton.m
//  WizIphone7
//
//  Created by wzz on 13-9-4.
//  Copyright (c) 2013年 dzpqzb inc. All rights reserved.
//

#import "WizBadgeValeButton.h"

@interface WizBadgeValeButton()
@property (nonatomic,strong)UIImageView* badgeView;
@property (nonatomic,strong)UILabel* valueLabel;
@end

@implementation WizBadgeValeButton
@synthesize badgeView = _badgeView;
@synthesize valueLabel = _valueLabel;
@synthesize badgeValue = _badgeValue;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _badgeView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        _badgeView.backgroundColor = [UIColor clearColor];
        _valueLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        _valueLabel.textColor = [UIColor whiteColor];
        _valueLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_valueLabel];
        [self addSubview:_badgeView];
        _badgeView.hidden = YES;
    }
    return self;
}

- (void)setBadgeValue:(NSInteger)badgeValue
{
    _badgeValue = badgeValue;
    if (_badgeValue == 0) {
        _badgeView.hidden = YES;
        _valueLabel.text = @"";
    }else{
        _badgeView.hidden = NO;
        _valueLabel.text = [NSString stringWithFormat:@"%d",_badgeValue];
        [self layoutSubviews];
    }
}

-(void)setBadgeRoundImage:(UIImage *)badgeRoundImage_
{
    _badgeView.image = [badgeRoundImage_ resizableImageWithCapInsets:UIEdgeInsetsMake(0, 11, 0, 11)];
}

- (NSInteger)badgeValue
{
    return _badgeValue;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    float margin = 5.0;
    CGSize labelSize = [_valueLabel.text sizeWithFont:_valueLabel.font];
    float badgeViewWidth = labelSize.width + margin * 2;
    if (badgeViewWidth < 23) {
        badgeViewWidth = 23;
    }
    _badgeView.frame = CGRectMake(CGRectGetWidth(self.bounds) - 18, 0 , badgeViewWidth, 22);
    _valueLabel.frame = CGRectMake(0, 0, labelSize.width, labelSize.height);
    _valueLabel.center = _badgeView.center;
    [self bringSubviewToFront:_valueLabel];
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
