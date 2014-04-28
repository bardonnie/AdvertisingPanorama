//
//  WizPlayProgressView.m
//  WizNote
//
//  Created by dzpqzb on 13-6-24.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizPlayProgressView.h"

float CGAngleFromRand(float rand)
{
    return rand * (M_PI/180);
}

@interface WizPlayProgressViewInner : UIView
{
    UILabel* currentTimeLabel;
}
@property (nonatomic, assign) float maxProgress;
@property (nonatomic, assign) float currentProgress;
//
@property (nonatomic, strong) UIColor* progressColor;
@property (nonatomic, strong) UIColor* progressLineColor;
@property (nonatomic, strong) UIColor* progressBackgroudColor;
@end


@implementation WizPlayProgressViewInner
@synthesize maxProgress = _maxProgress;
@synthesize currentProgress = _currentProgress;
@synthesize progressColor = _progressColor;
@synthesize progressBackgroudColor = _progressBackgroudColor;
@synthesize progressLineColor = _progressLineColor;
- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    [self commitInit];
    return self;
}
- (void) commitInit
{
    _maxProgress = INTMAX_MAX;
    self.backgroundColor= [UIColor clearColor];
    _progressColor = [UIColor blueColor];
    
    currentTimeLabel = [UILabel new];
    currentTimeLabel.textColor = WizColorByKind(ColorOfPlayProgressLabelText);
    currentTimeLabel.backgroundColor = [UIColor clearColor];
    currentTimeLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:currentTimeLabel];
}

- (void) setMaxProgress:(float)maxProgress
{
    _maxProgress = maxProgress;
    [self setNeedsDisplay];
}

- (void) setCurrentProgress:(float)currentProgress
{
    _currentProgress = currentProgress;
    currentTimeLabel.text  = [NSString stringMSFromTimeInterval:currentProgress];
       [self setNeedsLayout];
    [self setNeedsDisplay];
    
}
- (void) layoutSubviews
{
    CGRect rect = self.bounds;
    
    float textWidth = 0;
    NSString* timeText = currentTimeLabel.text;
    if (timeText) {
        textWidth = [timeText sizeWithFont:currentTimeLabel.font forWidth:1000 lineBreakMode:NSLineBreakByCharWrapping].width;
    }
    float radius = CGRectGetHeight(rect) / 2;
    float endPointX = CGRectGetWidth(rect) - radius*2;
//    float currentPointX = radius;
    if (_maxProgress != 0) {
        radius =  endPointX * _currentProgress / _maxProgress;
    }
    else
    {
        radius = 0;
    }
    
    float timeLabelWidth = textWidth;
    if (radius < timeLabelWidth) {
        timeLabelWidth = 0;
    }
    float timeLabelHeigth = CGRectGetHeight(self.bounds) * 0.682;
    currentTimeLabel.frame = CGRectMake(radius - timeLabelWidth, (CGRectGetHeight(self.bounds) - timeLabelHeigth )/2,  timeLabelWidth,timeLabelHeigth);
}

- (void) drawCornRectInRect:(CGRect)rect lineColor:(UIColor*)lineColor lineWidth:(float)lineWidth fillColor:(UIColor*)fillColor
{
    if (lineColor) {
        [lineColor setStroke];
    }
    if (fillColor) {
        [fillColor setFill];
    }
    
    float radius = CGRectGetHeight(rect) / 2;
    float endPointX = CGRectGetMinX(rect) + CGRectGetWidth(rect) - radius;

    //
    UIBezierPath* path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointAddX(rect.origin, radius)];
    //
    static float angle = 89;
    [path addArcWithCenter:CGPointMake(endPointX, CGRectGetMinY(rect) + radius) radius:radius startAngle:CGAngleFromRand(-angle) endAngle:CGAngleFromRand(angle) clockwise:YES];
    //
    [path addArcWithCenter:CGPointMake(CGRectGetMinX(rect) + radius, CGRectGetMinY(rect) + radius) radius:radius startAngle:CGAngleFromRand(angle) endAngle:CGAngleFromRand(-angle) clockwise:YES];
    [path closePath];
    path.lineWidth = lineWidth;
    [path fill];
    [path stroke];
}

- (void)drawRect:(CGRect)rect
{
    self.backgroundColor = [UIColor clearColor];
    [self drawCornRectInRect:rect lineColor:nil lineWidth:0  fillColor:_progressLineColor];
    
    CGRect(^ShinkRectBySpace)(CGRect, float) = ^(CGRect parentRect,  float space) {
        return CGRectMake(space, space, CGRectGetWidth(parentRect) - 2*space, CGRectGetHeight(parentRect) - 2*space);
    };
    
    [self drawCornRectInRect:ShinkRectBySpace(rect,1) lineColor:nil lineWidth:0 fillColor:_progressBackgroudColor];
    [self drawCornRectInRect:ShinkRectBySpace(rect, 2) lineColor:nil lineWidth:0 fillColor:_progressLineColor];
    [self drawCornRectInRect:ShinkRectBySpace(rect, 3) lineColor:nil lineWidth:0 fillColor:_progressBackgroudColor];
    float radius = CGRectGetHeight(rect) / 2;
    float contentWidth =CGRectGetWidth(rect) - radius*2;
    float currentPointX = contentWidth * _currentProgress / _maxProgress + radius + 10;
//    contentWidth -= 10;
    [self drawCornRectInRect:CGRectMake(2, 2, currentPointX -4 , CGRectGetHeight(rect)-4) lineColor:nil lineWidth:0 fillColor:_progressColor];

}

@end

@interface WizPlayProgressView ()
{
    UIImageView* backgroudImageView;
    UIImageView* progressImageView;
    WizPlayProgressViewInner* innerProgressView;
    
    UIButton* playPauseButton;
    UIButton* closeButton;
    UILabel* totalTimeLabel;
    
}
@end


@implementation WizPlayProgressView
@synthesize maxProgress = _maxProgress;
@synthesize currentProgress = _currentProgress;
@synthesize backgroudImage = _backgroudImage;
@synthesize progressColor = _progressColor;
@synthesize progressBackgroudImage = _progressBackgroudImage;
@synthesize progressLineColor = _progressLineColor;
@synthesize progressBackgroudColor = _progressBackgroudColor;
@synthesize delegate = _delegate;

- (void) setProgressBackgroudColor:(UIColor *)progressBackgroudColor
{
    innerProgressView.progressBackgroudColor = progressBackgroudColor;
}

- (void) setProgressLineColor:(UIColor *)progressLineColor
{
    innerProgressView.progressLineColor = progressLineColor;
}

- (UIColor*) progressLineColor
{
    return innerProgressView.progressLineColor;
}

- (UIColor*) progressBackgroudColor
{
    return innerProgressView.progressBackgroudColor;
}

- (void) setBackgroudImage:(UIImage *)backgroudImage
{
    _backgroudImage = backgroudImage;
    backgroudImageView.image = _backgroudImage;
}


- (void) pausePlay
{
    if ([_delegate respondsToSelector:@selector(playProgressViewDidTapPauseButton:)]) {
        [_delegate playProgressViewDidTapPauseButton:self];
    }
    [playPauseButton removeTarget:self action:@selector(pausePlay) forControlEvents:UIControlEventTouchUpInside];
    UIImage* image = WizImageByKind(ImageOfPlayIconPlay);
    [playPauseButton setImage:image forState:UIControlStateNormal];
    [playPauseButton addTarget:self action:@selector(startPlay) forControlEvents:UIControlEventTouchUpInside];
}

- (void) startPlay
{
    
    if ([_delegate respondsToSelector:@selector(playProgressViewDidTapPlayButton:)]) {
        [_delegate playProgressViewDidTapPlayButton:self];
    }
    
    [playPauseButton removeTarget:self action:@selector(startPlay) forControlEvents:UIControlEventTouchUpInside];
    [playPauseButton setImage:WizImageByKind(ImageOfPlayIconPause) forState:UIControlStateNormal];
    [playPauseButton addTarget:self action:@selector(pausePlay) forControlEvents:UIControlEventTouchUpInside];
}

- (void) resetToPlay
{
    [playPauseButton removeTarget:self action:@selector(startPlay) forControlEvents:UIControlEventTouchUpInside];
    [playPauseButton setImage:WizImageByKind(ImageOfPlayIconPause) forState:UIControlStateNormal];
    [playPauseButton addTarget:self action:@selector(pausePlay) forControlEvents:UIControlEventTouchUpInside];
    [self setMaxProgress:INTMAX_MAX];
    [self setCurrentProgress:0];
}

- (void) tapStopBtn
{
    if ([_delegate respondsToSelector:@selector(playProgressViewDidTapStopButton:)]) {
        [_delegate playProgressViewDidTapStopButton:self];
    }
}

- (void) commitInit
{
    self.backgroundColor = [UIColor clearColor];
    backgroudImageView = [UIImageView new];
    [self addSubview:backgroudImageView];
    backgroudImageView.backgroundColor = [UIColor clearColor];
    
    progressImageView = [UIImageView new];
    [self addSubview:progressImageView];
    
    innerProgressView = [[WizPlayProgressViewInner alloc] init];
    [self addSubview:innerProgressView];
    
    closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton addTarget:self action:@selector(tapStopBtn) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setImage:WizImageByKind(ImageOfPlayIconClose) forState:UIControlStateNormal];
    [self addSubview:closeButton];
    
    playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:playPauseButton];
    
    totalTimeLabel = [UILabel new];
    totalTimeLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:totalTimeLabel];
    totalTimeLabel.textColor = WizColorByKind(ColorOfPlayTimeLabelText);
    totalTimeLabel.textAlignment = NSTextAlignmentCenter;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commitInit];
    }
    return self;
}

- (void) setProgressColor:(UIColor *)progressColor
{
    _progressColor = progressColor;
    innerProgressView.progressColor = _progressColor;
}

- (void) setCurrentProgress:(float)currentProgress
{
    _currentProgress = currentProgress;
    innerProgressView.currentProgress = _currentProgress;
   totalTimeLabel.text = [NSString stringMSFromTimeInterval:_maxProgress - _currentProgress];
}

- (void) setMaxProgress:(float)maxProgress
{
    _maxProgress = maxProgress;
    innerProgressView.maxProgress = maxProgress;
    totalTimeLabel.text = [NSString stringMSFromTimeInterval:_maxProgress - _currentProgress];
}

- (void) setProgressBackgroudImage:(UIImage *)progressBackgroudImage
{
    _progressBackgroudImage = progressBackgroudImage;
    progressImageView.image = progressBackgroudImage;
}
- (void) layoutSubviews
{    
    float playBtnWidhth = 40;
    
    
    float width = CGRectGetWidth(self.bounds);
    float height = CGRectGetHeight(self.bounds);
    float playBtnHeight = height * 0.618;
    float minY = (height - playBtnHeight) /2;
    backgroudImageView.frame = self.bounds;
    
    float totalTimeWidth = 40;
    if (totalTimeLabel.text) {
        totalTimeWidth = [totalTimeLabel.text sizeWithFont:totalTimeLabel.font forWidth:1000 lineBreakMode:NSLineBreakByCharWrapping].width;
    }
    float itemSpace = 5;
    
    float progressWidth = width - totalTimeWidth - playBtnWidhth*2 - itemSpace * 5;
    
    playPauseButton.frame = CGRectMake(itemSpace, minY, playBtnWidhth, playBtnHeight);
    
    progressImageView.frame = CGRectMake(CGRectGetMaxX(playPauseButton.frame) + itemSpace, minY, progressWidth, playBtnHeight);
    float innerProgressViewY = minY + 2;
    if (playBtnHeight < 1) {
        innerProgressViewY = 0;
    }
    innerProgressView.frame = CGRectMake(CGRectGetMinX(progressImageView.frame) + 2, innerProgressViewY, progressWidth - 4, playBtnHeight -4);
    
    
    totalTimeLabel.frame = CGRectMake(CGRectGetMaxX(innerProgressView.frame)+5, minY, totalTimeWidth, playBtnHeight);
    closeButton.frame = CGRectMake(CGRectGetMaxX(totalTimeLabel.frame), minY  , playBtnWidhth  , playBtnHeight);
    [innerProgressView setNeedsDisplay];
}

@end
