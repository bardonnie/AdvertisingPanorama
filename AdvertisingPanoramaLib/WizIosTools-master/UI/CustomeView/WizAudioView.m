//
//  WizAudioView.m
//  WizNote
//
//  Created by dzpqzb on 13-2-27.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizAudioView.h"
#define WizDefaultAudioViewProcess  100


@implementation WizAudioView

@synthesize currentProcess;
@synthesize maxProcess;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        maxProcess = WizDefaultAudioViewProcess;
        currentProcess = 0.0;
        self.backgroundColor = [UIColor clearColor];

    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
}


- (void) setCurrentProcess:(NSInteger)currentProcess_
{
    currentProcess = currentProcess_;
    [self setNeedsDisplay];
}

- (void) drawRectangle:(CGRect)rect color:(CGColorRef)color context:(CGContextRef)content
{
    CGContextSetLineWidth(content, 0.1);
    CGContextSetFillColorWithColor(content, color);
    CGContextFillRect(content, rect);
    CGContextStrokePath(content);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    static float processLineWidth = 2;
    NSInteger countOfLines = CGRectGetWidth(rect)/processLineWidth;
    NSInteger currentLineIndex = ceil((float)self.currentProcess / (float)self.maxProcess * countOfLines);
    UIColor* blueImageColor = [UIColor colorWithPatternImage:WizImageByKind(ImageOfRecordActiveState)];
    UIColor* grayImageColor = [UIColor colorWithPatternImage:WizImageByKind(ImageOfRecordInactiveState)];
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (int i = 0; i < countOfLines; ++i) {
        CGRect lineRect = CGRectMake(CGRectGetMinX(rect)+ processLineWidth*2*i, 0.0, processLineWidth, CGRectGetHeight(rect));
        if (i < currentLineIndex) {
            [self drawRectangle:lineRect color:blueImageColor.CGColor context:context];
        }
        else
        {
            [self drawRectangle:lineRect color:grayImageColor.CGColor context:context];
        }
    }
}


@end
