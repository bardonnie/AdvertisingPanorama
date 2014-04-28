//
//  WizUnreadClickableView.m
//  WizNote
//
//  Created by wzz on 13-8-2.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizUnreadClickableView.h"
#import "SSLabel.h"
@interface WizUnreadClickableView()
@property (nonatomic, strong) SSLabel* unreadLabel;
@end


@implementation WizUnreadClickableView
@synthesize unreadCount = _unreadCount;
@synthesize unreadLabel = _unreadLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _unreadLabel = [[SSLabel alloc]init];
        _unreadLabel.backgroundColor = [UIColor clearColor];
        _unreadLabel.textAlignment = UITextAlignmentCenter;
        _unreadLabel.font = [UIFont boldSystemFontOfSize:13];
        _unreadLabel.textColor = [UIColor whiteColor];
        _unreadLabel.verticalTextAlignment = SSLabelVerticalTextAlignmentMiddle;
        [self.stateImageView addSubview:_unreadLabel];
    }
    return self;
}

- (void)setUnreadMessageNumber:(NSInteger)unreadCount
{
    if (unreadCount > 0) {
        if (unreadCount > 99) {
            _unreadLabel.text = @"99+";
        }else{
            _unreadLabel.text = [NSString stringWithFormat:@"%d",unreadCount];
        }
    }else{
        _unreadLabel.text = @"";
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize size = self.stateImageView.image.size;
    _unreadLabel.frame = CGRectIntegral(CGRectOffset(CGRectSetCenter(self.stateImageView.frame, size), 2, 0));
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
