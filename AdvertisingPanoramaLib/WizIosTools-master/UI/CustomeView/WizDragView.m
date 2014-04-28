//
//  WizDragView.m
//  WizNote
//
//  Created by dzpqzb on 13-6-17.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizDragView.h"
#import "UIViewController+WizHelp.h"
#import <QuartzCore/QuartzCore.h>
@interface WizDragView ()
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UILabel* promptLable;
@end

@implementation WizDragView
@synthesize dragImageView = _dragImageView;
@synthesize checkEnable = _checkEnable;
@synthesize enableImage = _enableImage;
@synthesize disableImage = _disableImage;
@synthesize titleLabel = _titleLabel;
@synthesize dragDirection = _dragDirection;
@synthesize title = _title;
@synthesize promptLable = _promtpLable;
@synthesize prompt = _prompt;
- (void) commitInit
{
    _dragDirection = WizDragDirectionLeft;
    _dragImageView = [UIImageView new];
    [self addSubview:_dragImageView];
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.font = [UIFont systemFontOfSize:15];
    _titleLabel.textColor = [UIColor colorWithHexHex:0x929292];
    _titleLabel.textAlignment = UITextAlignmentLeft;
    
    _promtpLable = [[UILabel alloc] init];
    _promtpLable.backgroundColor = [UIColor clearColor];
    _promtpLable.font = [UIFont systemFontOfSize:13];
    _promtpLable.textColor = [UIColor colorWithHexHex:0xb6b6b6];
    _promtpLable.textAlignment = UITextAlignmentLeft;

    [self addSubview:_titleLabel];
    [self addSubview:_promtpLable];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commitInit];
    }
    return self;
}

- (void)setLableTitle:(NSString *)title
{
    _titleLabel.text = title;
}

- (void)setLablePrompt:(NSString *)prompt_
{
    _promtpLable.text = prompt_;
}

- (void)setEnableImage:(UIImage *)enableImage
{
    self.dragImageView.image = enableImage;
}

- (void) layoutSubviews
{
    CGSize imageSize = self.dragImageView.image.size;
    self.dragImageView.frame = CGRectSetX(CGRectSetCenter(self.bounds, imageSize), 5);
    
    float startX = CGRectGetMaxX(self.dragImageView.frame);
    if (_titleLabel.text && ![_titleLabel.text isEqualToString:@""])
    {
        _titleLabel.hidden = NO;
        _promtpLable.frame = CGRectMake(startX, 5, CGRectGetWidth(self.bounds) - startX, 15);
        _titleLabel.frame  = CGRectMake(startX, CGRectGetMaxY(_promtpLable.frame), CGRectGetWidth(_promtpLable.frame), 20);
    }
    else
    {
        _titleLabel.hidden= YES;
        _promtpLable.frame = CGRectMake(startX, 5, CGRectGetWidth(self.bounds) - startX, 30);
    }

}

- (void) setCheckEnable:(BOOL)checkEnable
{
    if (checkEnable == _checkEnable) {
        return ;
    }
    _checkEnable = checkEnable;
    if (_checkEnable) {
        [UIView animateWithDuration:WizAnimatedDuration animations:^{
            self.dragImageView.transform = CGAffineTransformMakeRotation(M_PI);
        }];
    }
    else
    {
        self.dragImageView.transform = CGAffineTransformMakeRotation(0);
    }
    [self setNeedsLayout];
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
