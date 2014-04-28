//
//  WizProgressBar.m
//  WizIphone7
//
//  Created by wzz on 13-11-21.
//  Copyright (c) 2013年 dzpqzb inc. All rights reserved.
//

#import "WizProgressBar.h"
@interface WizProgressBar()
{
    NSTimer *_animationTimer;
}
@property (nonatomic, assign)float process;
@end

@implementation WizProgressBar
@synthesize process = _process;
@synthesize processTintColor = _processTintColor;
@synthesize trackTintColor = _trackTintColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _processTintColor = [UIColor lightGrayColor];
        _trackTintColor = [UIColor whiteColor];
    }
    return self;
}


- (void) setProgress:(CGFloat)value animated:(BOOL)animated
{
    if (value > _process) {
        self.process = value;
        [self setNeedsDisplay];
    }
}


- (void) hideWithFadeOut {
    //initialize fade animation
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.5;
    [self.layer addAnimation:animation forKey:nil];
    
    //Do hide progress bar
    self.hidden = YES;
    
    if (_animationTimer != nil) {
        [_animationTimer invalidate];
        _animationTimer = nil;
    }
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect progressRect = rect;
    
    progressRect.size.width *= self.process;
    CGContextSetFillColorWithColor(ctx, [_trackTintColor CGColor]);
    CGContextFillRect(ctx, rect);
    
    CGContextSetFillColorWithColor(ctx, [_processTintColor CGColor]);
    CGContextFillRect(ctx, progressRect);
    
    //Hide progress with fade-out effect
    if (self.process == 1.0f &&
        _animationTimer == nil) {
        _animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(hideWithFadeOut) userInfo:nil repeats:YES];
    }
}


@end
