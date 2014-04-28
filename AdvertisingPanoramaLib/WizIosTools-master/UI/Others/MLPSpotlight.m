/*
//  MLPSpotlight.m
//  
//
//  Created by Eddy Borja on 1/26/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "MLPSpotlight.h"

#define kDEFAULT_DURATION 0.3

@interface MLPSpotlight ()
{
    UILabel* _indicatoryTextLabel;
    UIImageView*  _indicatoryImageView;
    
    UIButton* _hiddentButton;
}
@end

@implementation MLPSpotlight

#pragma mark - Static Methods

+ (instancetype)spotlightWithFrame:(CGRect)frame withSpotlightAtPoint:(CGPoint)centerPoint
{
    MLPSpotlight *newSpotlight = [[MLPSpotlight alloc] initWithFrame:frame
                                                withSpotlightAtPoint:centerPoint];
    return newSpotlight;
}

+ (instancetype)spotlightWithFrame:(CGRect)frame withSpotlightAtPoint:(CGPoint)centerPoint  title:(NSString*)title image:(UIImage*)image
{
    MLPSpotlight* newSpot = [[MLPSpotlight alloc] initWithFrame:frame withSpotlightAtPoint:centerPoint title:title image:image];
    return newSpot;
}

+ (instancetype)addSpotlightInView:(UIView *)view atPoint:(CGPoint)centerPoint
{
    return [[self class] addSpotlightInView:view atPoint:centerPoint withDuration:kDEFAULT_DURATION];
}
+ (instancetype)addSpotlightInView:(UIView *)view atPoint:(CGPoint)centerPoint withDuration:(NSTimeInterval)duration title:(NSString*)title image:(UIImage*)image
{
    MLPSpotlight *newSpotlight = [[self class] spotlightWithFrame:view.bounds
                                             withSpotlightAtPoint:centerPoint title:title image:image];
    [newSpotlight setAnimationDuration:duration];
    [view addSubview:newSpotlight];
    [newSpotlight setAlpha:0];
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationCurveEaseOut|
     UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [newSpotlight setAlpha:1];
                     }
                     completion:nil];
    
    return newSpotlight;
}
+ (instancetype)addSpotlightInView:(UIView *)view atPoint:(CGPoint)centerPoint withDuration:(NSTimeInterval)duration
{
    MLPSpotlight *newSpotlight = [[self class] spotlightWithFrame:view.bounds
                                             withSpotlightAtPoint:centerPoint];
    [newSpotlight setAnimationDuration:duration];
    [view addSubview:newSpotlight];
    [newSpotlight setAlpha:0];
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationCurveEaseOut|
                            UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [newSpotlight setAlpha:1];
                     }
                     completion:nil];
    
    return newSpotlight;
}


+ (NSArray *)spotlightsInView:(UIView *)view
{
    NSMutableArray *spotlights = [NSMutableArray array];
    for(UIView *subview in view.subviews){
        if([subview isKindOfClass:[self class]]){
            [spotlights addObject:subview];
        }
    }
    
    return [NSArray arrayWithArray:spotlights];
}

+ (void)removeSpotlightsInView:(UIView *)view
{
    NSArray *spotlightsInView = [[self class] spotlightsInView:view];
    for(MLPSpotlight *spotlight in spotlightsInView){
        if([spotlight isKindOfClass:[self class]]){
            [UIView animateWithDuration:spotlight.animationDuration
                                  delay:0
                                options:UIViewAnimationCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 [spotlight setAlpha:0];
                             }
                             completion:^(BOOL finished){
                                 [spotlight removeFromSuperview];
                             }];
        }
    }
}

- (void)setSpotlightGradientRef:(CGGradientRef)newSpotlightGradientRef
{
    CGGradientRelease(_spotlightGradientRef);
    _spotlightGradientRef = nil;
    
    _spotlightGradientRef = newSpotlightGradientRef;
    CGGradientRetain(_spotlightGradientRef);
    
    [self setNeedsDisplay];
}

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame withSpotlightAtPoint:(CGPoint)centerPoint title:(NSString*)title image:(UIImage*)image
{
    self = [self initWithFrame:frame withSpotlightAtPoint:centerPoint];
    if (!self) {
        return nil;
    }
    _indicatoryImageView = [[UIImageView alloc] init];
    _indicatoryTextLabel = [[UILabel alloc] init];
    _indicatoryTextLabel.textAlignment = NSTextAlignmentCenter;
    _indicatoryTextLabel.textColor = [UIColor whiteColor];
    [self addSubview:_indicatoryTextLabel];
    [self addSubview:_indicatoryImageView];
    
    _indicatoryImageView.image = image;
    _indicatoryTextLabel.text  = title;
    //
    _hiddentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_hiddentButton setTitle:NSLocalizedString(@"I know", nil) forState:UIControlStateNormal];
    [_hiddentButton addTarget:self action:@selector(hiddenSpotlightView) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_hiddentButton];
    return self;
}

- (id)initWithFrame:(CGRect)frame withSpotlightAtPoint:(CGPoint)centerPoint
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth |
                                  UIViewAutoresizingFlexibleHeight];
        
        [self setContentMode:UIViewContentModeRedraw];
        [self setUserInteractionEnabled:YES];
        [self setSpotlightCenter:centerPoint];
        [self setAnimationDuration:kDEFAULT_DURATION];
        [self setBackgroundColor:[UIColor clearColor]];
        
        CGGradientRef defaultGradientRef = [[self class] newSpotlightGradient];
        [self setSpotlightGradientRef:defaultGradientRef];
        CGGradientRelease(defaultGradientRef);
        
        [self setSpotlightStartRadius:0];
        [self setSpotlightEndRadius:350];
        

    }
    return self;
}



- (void) hiddenSpotlightView
{
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void) layoutSubviews
{
    _indicatoryImageView.frame = CGRectMake(self.spotlightCenter.x - 30, self.spotlightCenter.y - 30, 60, 60);
    _indicatoryTextLabel.frame = CGRectMake(0, CGRectGetMaxY(_indicatoryImageView.frame) + 10, CGRectGetWidth(self.frame), 30);
    _hiddentButton.frame = CGRectMake((CGRectGetWidth(self.frame)- 250)/2, CGRectGetHeight(self.frame) - 60, 250, 40);
}

#pragma mark - Drawing Override
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGGradientRef gradient = self.spotlightGradientRef;
    
    float radius = self.spotlightEndRadius;
    float startRadius = self.spotlightStartRadius;
    CGContextDrawRadialGradient (context, gradient, self.spotlightCenter, startRadius, self.spotlightCenter, radius, kCGGradientDrawsAfterEndLocation);
}

#pragma mark - Factory Method

+ (CGGradientRef)newSpotlightGradient
{
    size_t locationsCount = 2;
    CGFloat locations[2] = {0.0f, 1.0f,};
    CGFloat colors[12] = {0.1f,0.1f,0.1f,0.1f,
                            0.1f,0.10f,0.1f,1.0f};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
    CGColorSpaceRelease(colorSpace);
    return gradient;
}

#pragma mark - Deallocation

- (void)dealloc
{
    [self setSpotlightGradientRef:nil];
}

@end
