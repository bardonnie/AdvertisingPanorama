//
//  WizFloatingLayer.m
//  FloatLayer
//
//  Created by wzz on 13-9-2.
//  Copyright (c) 2013年 wzz. All rights reserved.
//

#import "WizFloatingLayer.h"
#import <QuartzCore/QuartzCore.h>


@interface WizMenuViewOverlay : UIView
@end

@implementation WizMenuViewOverlay

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIView *touched = [[touches anyObject] view];
    if (touched == self) {
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[WizFloatingLayer class]]){
                WizFloatingLayer* layer = (WizFloatingLayer*)view;
                if ([layer respondsToSelector:@selector(dismissMenu:)]) {
                    [layer performSelector:@selector(dismissMenu:) withObject:@(YES)];
                }
            }
        }
    }
}

@end


typedef enum {
    
    WizMenuViewArrowDirectionNone,
    WizMenuViewArrowDirectionUp,
    WizMenuViewArrowDirectionDown,
    WizMenuViewArrowDirectionLeft,
    WizMenuViewArrowDirectionRight,
    
} WizMenuViewArrowDirection;

@interface WizFloatingLayer()
{
    WizMenuViewArrowDirection    _arrowDirection;
    CGFloat                     _arrowPosition;
}
@property (nonatomic, strong)UIView* contentView;
@property (nonatomic, strong)UIColor* tintColor;
@end

@implementation WizFloatingLayer
@synthesize delegate;
@synthesize contentView = _contentView;
@synthesize tintColor  =_tintColor;

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectZero];
    if(self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = YES;
        self.alpha = 0;
        self.layer.shadowRadius = 1;
    }
    
    return self;
}

- (id)initWithContentView:(UIView *)contentView
{
    self = [super init];
    if (self) {
        _contentView = contentView;
        [self addSubview:_contentView];
    }
    return self;
}

- (void) setupFrameInView:(UIView *)view
                 fromRect:(CGRect)fromRect
{
    const CGSize contentSize = _contentView.frame.size;
    
    const CGFloat outerWidth = view.bounds.size.width;
    const CGFloat outerHeight = view.bounds.size.height;
    
    const CGFloat rectX0 = fromRect.origin.x;
    const CGFloat rectX1 = fromRect.origin.x + fromRect.size.width;
    const CGFloat rectXM = fromRect.origin.x + fromRect.size.width * 0.5f;
    const CGFloat rectY0 = fromRect.origin.y;
    const CGFloat rectY1 = fromRect.origin.y + fromRect.size.height;
    const CGFloat rectYM = fromRect.origin.y + fromRect.size.height * 0.5f;;
    
    const CGFloat widthPlusArrow = contentSize.width + WizArrowSize;
    const CGFloat heightPlusArrow = contentSize.height + WizArrowSize;
    const CGFloat widthHalf = contentSize.width * 0.5f;
    const CGFloat heightHalf = contentSize.height * 0.5f;
    
    const CGFloat kMargin = 0.0f;
    
    if (heightPlusArrow < (outerHeight - rectY1)) {
        
        _arrowDirection = WizMenuViewArrowDirectionUp;
        CGPoint point = (CGPoint){
            rectXM - widthHalf,
            rectY1
        };
        
        if (point.x < kMargin)
            point.x = kMargin;
        
        if ((point.x + contentSize.width + kMargin) > outerWidth)
            point.x = outerWidth - contentSize.width - kMargin;
        
        _arrowPosition = rectXM - point.x;
        _contentView.frame = (CGRect){0, WizArrowSize, contentSize};
        
        self.frame = (CGRect) {
            
            point,
            contentSize.width,
            contentSize.height + WizArrowSize
        };
        
    } else if (heightPlusArrow < rectY0) {
        
        _arrowDirection = WizMenuViewArrowDirectionDown;
        CGPoint point = (CGPoint){
            rectXM - widthHalf,
            rectY0 - heightPlusArrow
        };
        
        if (point.x < kMargin)
            point.x = kMargin;
        
        if ((point.x + contentSize.width + kMargin) > outerWidth)
            point.x = outerWidth - contentSize.width - kMargin;
        
        _arrowPosition = rectXM - point.x;
        _contentView.frame = (CGRect){CGPointZero, contentSize};
        
        self.frame = (CGRect) {
            
            point,
            contentSize.width,
            contentSize.height + WizArrowSize
        };
        
    } else if (widthPlusArrow < (outerWidth - rectX1)) {
        
        _arrowDirection = WizMenuViewArrowDirectionLeft;
        CGPoint point = (CGPoint){
            rectX1,
            rectYM - heightHalf
        };
        
        if (point.y < kMargin)
            point.y = kMargin;
        
        if ((point.y + contentSize.height + kMargin) > outerHeight)
            point.y = outerHeight - contentSize.height - kMargin;
        
        _arrowPosition = rectYM - point.y;
        _contentView.frame = (CGRect){WizArrowSize, 0, contentSize};
        
        self.frame = (CGRect) {
            
            point,
            contentSize.width + WizArrowSize,
            contentSize.height
        };
        
    } else if (widthPlusArrow < rectX0) {
        
        _arrowDirection = WizMenuViewArrowDirectionRight;
        CGPoint point = (CGPoint){
            rectX0 - widthPlusArrow,
            rectYM - heightHalf
        };
        
        if (point.y < kMargin)
            point.y = kMargin;
        
        if ((point.y + contentSize.height + 5) > outerHeight)
            point.y = outerHeight - contentSize.height - kMargin;
        
        _arrowPosition = rectYM - point.y;
        _contentView.frame = (CGRect){CGPointZero, contentSize};
        
        self.frame = (CGRect) {
            
            point,
            contentSize.width  + WizArrowSize,
            contentSize.height
        };
        
    } else {
        
        _arrowDirection = WizMenuViewArrowDirectionNone;
        
        self.frame = (CGRect) {
            
            (outerWidth - contentSize.width)   * 0.5f,
            (outerHeight - contentSize.height) * 0.5f,
            contentSize,
        };
    }
}

- (void)showMenuInView:(UIView *)view fromPoint:(CGPoint)point
{
    CGRect rect = CGRectMake(point.x, point.y, 0, 0);
    [self setupFrameInView:view fromRect:rect];
    
    WizMenuViewOverlay *overlay = [[WizMenuViewOverlay alloc] initWithFrame:view.bounds];
    [overlay addSubview:self];
    [view addSubview:overlay];
    
    _contentView.hidden = YES;
    const CGRect toFrame = self.frame;
    self.frame = (CGRect){self.arrowPoint, 1, 1};
    
    [UIView animateWithDuration:0.2
                     animations:^(void) {
                         
                         self.alpha = 1.0f;
                         self.frame = toFrame;
                         [self setNeedsDisplay];
                         if ([self.delegate respondsToSelector:@selector(willFloatingLayerAppear)]) {
                             [self.delegate willFloatingLayerAppear];
                         }
                     } completion:^(BOOL completed) {
                         _contentView.hidden = NO;
                     }];
    if ([self.delegate respondsToSelector:@selector(didFloatingLayerAppear)]) {
        [self.delegate didFloatingLayerAppear];
    }
}

- (void)dismissMenu:(BOOL) animated
{
    if (self.superview) {
        
        if (animated) {
            
            _contentView.hidden = YES;
            const CGRect toFrame = (CGRect){self.arrowPoint, 1, 1};
            
            [UIView animateWithDuration:0.2
                             animations:^(void) {
                                 
                                 self.alpha = 0;
                                 self.frame = toFrame;
                                 if ([self.delegate respondsToSelector:@selector(willFloatingLayerDismiss)]) {
                                     [self.delegate willFloatingLayerDismiss];
                                 }
                             } completion:^(BOOL finished) {
                                 
                                 if ([self.superview isKindOfClass:[WizMenuViewOverlay class]])
                                     [self.superview removeFromSuperview];
                                 [self removeFromSuperview];
                             }];
            
        } else {
            
            if ([self.superview isKindOfClass:[WizMenuViewOverlay class]])
                [self.superview removeFromSuperview];
            [self removeFromSuperview];
        }
        if ([self.delegate respondsToSelector:@selector(didFloatingLayerDismiss)]) {
            [self.delegate didFloatingLayerDismiss];
        }
    }
}

- (CGPoint) arrowPoint
{
    CGPoint point;
    
    if (_arrowDirection == WizMenuViewArrowDirectionUp) {
        
        point = (CGPoint){ CGRectGetMinX(self.frame) + _arrowPosition, CGRectGetMinY(self.frame) };
        
    } else if (_arrowDirection == WizMenuViewArrowDirectionDown) {
        
        point = (CGPoint){ CGRectGetMinX(self.frame) + _arrowPosition, CGRectGetMaxY(self.frame) };
        
    } else if (_arrowDirection == WizMenuViewArrowDirectionLeft) {
        
        point = (CGPoint){ CGRectGetMinX(self.frame), CGRectGetMinY(self.frame) + _arrowPosition  };
        
    } else if (_arrowDirection == WizMenuViewArrowDirectionRight) {
        
        point = (CGPoint){ CGRectGetMaxX(self.frame), CGRectGetMinY(self.frame) + _arrowPosition  };
        
    } else {
        
        point = self.center;
    }
    
    return point;
}

- (void) drawRect:(CGRect)rect
{
    [self drawBackground:self.bounds
               inContext:UIGraphicsGetCurrentContext()];
}

- (void)drawBackground:(CGRect)frame
             inContext:(CGContextRef) context
{
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat alpha = 0.0;

    const CGFloat* components = CGColorGetComponents([_tintColor CGColor]);
    if (CGColorGetNumberOfComponents([_tintColor CGColor]) == 2) {
        red = components[0];
        green = components[0];
        blue = components[0];
        alpha = components[1];
    }else if(CGColorGetNumberOfComponents([_tintColor CGColor]) == 4){
        red = components[0];
        green = components[1];
        blue = components[2];
        alpha = components[3];
    }

    CGFloat X0 = frame.origin.x;
    CGFloat X1 = frame.origin.x + frame.size.width;
    CGFloat Y0 = frame.origin.y;
    CGFloat Y1 = frame.origin.y + frame.size.height;
    
    // render arrow
    
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    
    // fix the issue with gap of arrow's base if on the edge
    const CGFloat kEmbedFix = 0.f;
    
    if (_arrowDirection == WizMenuViewArrowDirectionUp) {
        
        const CGFloat arrowXM = _arrowPosition;
        const CGFloat arrowX0 = arrowXM - WizArrowSize;
        const CGFloat arrowX1 = arrowXM + WizArrowSize;
        const CGFloat arrowY0 = Y0;
        const CGFloat arrowY1 = Y0 + WizArrowSize + kEmbedFix;
        
        [arrowPath moveToPoint:    (CGPoint){arrowXM, arrowY0}];
        [arrowPath addLineToPoint: (CGPoint){arrowX1, arrowY1}];
        [arrowPath addLineToPoint: (CGPoint){arrowX0, arrowY1}];
        [arrowPath addLineToPoint: (CGPoint){arrowXM, arrowY0}];
        
        [[UIColor colorWithRed:red green:green blue:blue alpha:alpha] set];
        
        Y0 += WizArrowSize;
        
    } else if (_arrowDirection == WizMenuViewArrowDirectionDown) {
        
        const CGFloat arrowXM = _arrowPosition;
        const CGFloat arrowX0 = arrowXM - WizArrowSize;
        const CGFloat arrowX1 = arrowXM + WizArrowSize;
        const CGFloat arrowY0 = Y1 - WizArrowSize - kEmbedFix;
        const CGFloat arrowY1 = Y1;
        
        [arrowPath moveToPoint:    (CGPoint){arrowXM, arrowY1}];
        [arrowPath addLineToPoint: (CGPoint){arrowX1, arrowY0}];
        [arrowPath addLineToPoint: (CGPoint){arrowX0, arrowY0}];
        [arrowPath addLineToPoint: (CGPoint){arrowXM, arrowY1}];
        
        [[UIColor colorWithRed:red green:green blue:blue alpha:alpha] set];
        
        Y1 -= WizArrowSize;
        
    } else if (_arrowDirection == WizMenuViewArrowDirectionLeft) {
        
        const CGFloat arrowYM = _arrowPosition;
        const CGFloat arrowX0 = X0;
        const CGFloat arrowX1 = X0 + WizArrowSize + kEmbedFix;
        const CGFloat arrowY0 = arrowYM - WizArrowSize;;
        const CGFloat arrowY1 = arrowYM + WizArrowSize;
        
        [arrowPath moveToPoint:    (CGPoint){arrowX0, arrowYM}];
        [arrowPath addLineToPoint: (CGPoint){arrowX1, arrowY0}];
        [arrowPath addLineToPoint: (CGPoint){arrowX1, arrowY1}];
        [arrowPath addLineToPoint: (CGPoint){arrowX0, arrowYM}];
        
        [[UIColor colorWithRed:red green:green blue:blue alpha:alpha] set];
        
        X0 += WizArrowSize;
        
    } else if (_arrowDirection == WizMenuViewArrowDirectionRight) {
        
        const CGFloat arrowYM = _arrowPosition;
        const CGFloat arrowX0 = X1;
        const CGFloat arrowX1 = X1 - WizArrowSize - kEmbedFix;
        const CGFloat arrowY0 = arrowYM - WizArrowSize;;
        const CGFloat arrowY1 = arrowYM + WizArrowSize;
        
        [arrowPath moveToPoint:    (CGPoint){arrowX0, arrowYM}];
        [arrowPath addLineToPoint: (CGPoint){arrowX1, arrowY0}];
        [arrowPath addLineToPoint: (CGPoint){arrowX1, arrowY1}];
        [arrowPath addLineToPoint: (CGPoint){arrowX0, arrowYM}];
        
        [[UIColor colorWithRed:red green:green blue:blue alpha:alpha] set];
        
        X1 -= WizArrowSize;
    }
    
    [arrowPath fill];
    
    // render body
    
    const CGRect bodyFrame = {X0, Y0, X1 - X0, Y1 - Y0};
    
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:bodyFrame
                                                          cornerRadius:1];
    [borderPath fill];
    
    if (_arrowDirection == WizMenuViewArrowDirectionUp) {
        [[UIColor colorWithHexHex:0xa4a4a4] setStroke];
        UIBezierPath* path = [UIBezierPath bezierPath];
        [path setLineWidth:0.5];
        [path moveToPoint:CGPointMake(_arrowPosition, 0)];
        [path addLineToPoint:CGPointMake(_arrowPosition - WizArrowSize, Y0)];
        [path addLineToPoint:CGPointMake(0, WizArrowSize)];
        [path addLineToPoint:CGPointMake(0, CGRectGetHeight(self.frame))];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), WizArrowSize)];
        [path addLineToPoint:CGPointMake(_arrowPosition + WizArrowSize, Y0)];
        [path closePath];
        [path stroke];
    }else if (_arrowDirection == WizMenuViewArrowDirectionDown) {
        [[UIColor colorWithHexHex:0xa4a4a4] setStroke];
        UIBezierPath* path = [UIBezierPath bezierPath];
        [path setLineWidth:1.0];

        [path moveToPoint:CGPointMake(_arrowPosition, CGRectGetHeight(self.frame))];
        [path addLineToPoint:CGPointMake(_arrowPosition + WizArrowSize, CGRectGetHeight(self.frame) - WizArrowSize)];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - WizArrowSize)];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), 0)];
        [path addLineToPoint:CGPointMake(0, 0)];
        [path addLineToPoint:CGPointMake(0, CGRectGetHeight(self.frame) - WizArrowSize)];
        [path addLineToPoint:CGPointMake(_arrowPosition - WizArrowSize, CGRectGetHeight(self.frame) - WizArrowSize)];
        [path closePath];
        [path stroke];
    }
}
@end
