//
//  WizClickableView.m
//  WizNote
//
//  Created by wzz on 13-7-31.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizClickableView.h"

#define leftSpace 8.0
#define rightSpace 8.0
#define middleSpace 8.0

@interface WizClickableView()
{
    
}
@property (nonatomic, strong) UILabel* textLabel;
//@property (nonatomic, strong) UIImageView* stateImageView;
@property (nonatomic, assign) CGFloat textLabelWidth;
@property (nonatomic, assign) CGFloat viewHeight;
@end

@implementation WizClickableView
@synthesize textLabel = _textLabel;
@synthesize text = _text;
@synthesize stateImage = _stateImage;
@synthesize viewWidth;
@synthesize textLabelWidth;
@synthesize imageWidth;
@synthesize viewHeight;
@synthesize stateImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        textLabelWidth = 0.0;
        imageWidth = 0.0;
        
        _textLabel = [[UILabel alloc]init];
        stateImageView = [[UIImageView alloc]init];
        stateImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.font = [UIFont systemFontOfSize:[WizStringByKind(StringOfNavigationBarTitleFont) integerValue]];
        _textLabel.textColor = WizColorByKind(ColorOfNavigationBarTitle);
        _textLabel.textAlignment = UITextAlignmentCenter;
        
        [self addSubview:_textLabel];
        [self addSubview:stateImageView];
    }
    return self;
}

- (CGFloat)viewHeight
{
    if (self.viewWidth == 0) {
        return 0;
    }
    if (CGRectGetHeight(self.bounds) == 0) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (![WizGlobals WizDeviceIsPad] && UIInterfaceOrientationIsLandscape(orientation)) {
            return 32.0;
        }else{
            return 44.0;
        }
    }else{
        return CGRectGetHeight(self.bounds);
    }
}

- (void)setButtonTitle:(NSString *)text
{
    _textLabel.text = text;
    textLabelWidth = [text sizeWithFont:_textLabel.font].width;
    self.frame = CGRectSetSize(self.frame, CGSizeMake(self.viewWidth, self.viewHeight));
    [self setNeedsLayout];
}

- (void)setTextColor:(UIColor *)textColor
{
    _textLabel.textColor = textColor;
}

- (void)setButtonImage:(UIImage *)stateImage
{
    stateImageView.image = stateImage;
    if (imageWidth == 0) {
        imageWidth = stateImage.size.width;
    }
    self.frame = CGRectSetSize(self.frame, CGSizeMake(self.viewWidth, self.viewHeight));
    [self setNeedsLayout];
}


- (CGFloat)viewWidth
{
    return textLabelWidth + imageWidth;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _textLabel.frame = CGRectMake(leftSpace, 0, textLabelWidth, CGRectGetHeight(self.bounds));
    stateImageView.frame = CGRectMake(CGRectGetMaxX(_textLabel.frame) + middleSpace, 0, imageWidth, CGRectGetHeight(self.bounds));
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
