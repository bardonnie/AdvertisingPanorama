//
//  WizBadgeView.m
//  WizIphone7
//
//  Created by dzpqzb on 13-9-12.
//  Copyright (c) 2013年 dzpqzb inc. All rights reserved.
//

#import "WizBadgeView.h"
@interface WizBadgeView ()
{
    NSString* countStr;
}
@end

@implementation WizBadgeView

@synthesize count = _count;
- (id)initWithFrame:(CGRect)frame
{
    CGRect newRect = CGRectSetWidth(frame, CGRectGetWidth(frame)*2.0);
    self = [super initWithFrame:newRect];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
    }
    return self;
}

- (void) setCount:(NSInteger)count
{
    _count = count;
    if (count > 99) {
        countStr = @"99+";
    }
    else
    {
        countStr = [@(count) stringValue];
    }
    if (count == 0) {
        self.hidden = YES;
    }
    else
    {
        self.hidden = NO;
        [self setNeedsDisplay];
    }
}
- (void) drawRect:(CGRect)rect
{
    if (countStr) {
        UIFont* font = [UIFont systemFontOfSize:15];
        CGSize size = [countStr sizeWithFont:font forWidth:1000 lineBreakMode:NSLineBreakByCharWrapping];
        CGPoint point = CGPointZero;
        CGRect needDrawRect = CGRectSetWidth(CGRectSetX(rect, CGRectGetWidth(rect) - size.width - 20), size.width + 20);
        
        UIBezierPath* badge = nil;
        if (_count < 10) {
            badge = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(CGRectGetWidth(rect) - CGRectGetHeight(rect), 0, CGRectGetHeight(rect), CGRectGetHeight(rect))];
            point = CGPointAddX(CGCenterPoint(rect), (CGRectGetWidth(rect) - CGRectGetHeight(rect))/2);

        }else{
            badge = [UIBezierPath bezierPathWithRoundedRect:needDrawRect cornerRadius:CGRectGetHeight(rect)/2];
            point = CGPointAddX(CGCenterPoint(rect), (CGRectGetWidth(rect) - size.width - 20)/2);
        }
        [[UIColor colorWithHexHex:0xe54734] setFill];
        [badge fill];
        
        [[UIColor whiteColor] setFill];
        [[UIColor whiteColor] setStroke];

        point = CGPointMake(point.x - size.width/2, point.y - size.height/2);
        [countStr drawAtPoint:point  forWidth:size.width withFont:font fontSize:15 lineBreakMode:NSLineBreakByCharWrapping baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
    }
}

@end
