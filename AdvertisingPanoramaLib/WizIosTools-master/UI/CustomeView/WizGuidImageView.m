//
//  WizGuidImageView.m
//  WizIphone7
//
//  Created by dzpqzb on 13-9-10.
//  Copyright (c) 2013年 dzpqzb inc. All rights reserved.
//

#import "WizGuidImageView.h"
@interface WizGuidImageView ()
{
    UIImageView* _imageView;
    UIView* _maskView;
    
    //
    UIButton* knewButton;
}
@property (nonatomic, strong) UIImageView* imageView;
@end

@implementation WizGuidImageView
@synthesize imageView = _imageView;
- (void) hiddenTaped:(id*)sender
{
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void) layoutSubviews
{
    _imageView.frame = self.bounds;
    _maskView.frame = self.bounds;
    
    knewButton.frame = CGRectSetY(CGRectSetCenter(self.bounds, CGSizeMake(80, 40)), CGRectGetHeight(self.bounds) - 80);
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenTaped:)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        _maskView = [UIView new];
        _maskView.backgroundColor = [UIColor blackColor];
        [self addSubview:_maskView];
        _maskView.alpha = 0.8;
        
        [self addGestureRecognizer:tapGesture];
        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
        self.backgroundColor = [UIColor clearColor];
        
        knewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [knewButton setTitle:NSLocalizedString(@"I know", nil) forState:UIControlStateNormal];
        knewButton.titleLabel.font = [UIFont systemFontOfSize:20];
        knewButton.titleLabel.textColor = [UIColor whiteColor];
        [knewButton addTarget:self action:@selector(hiddenTaped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:knewButton];
    }
    return self;
}

+ (WizGuidImageView*) showGuidWithImage:(UIImage*)image
{
    UIViewController* rootViewController = [[UIApplication sharedApplication] keyWindow].rootViewController;
    WizGuidImageView* imageView = [[WizGuidImageView alloc] initWithFrame:rootViewController.view.bounds];
    imageView.imageView.image = image;
    [rootViewController.view addSubview:imageView];
    return imageView;
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
