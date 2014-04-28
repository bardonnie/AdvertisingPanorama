//
//  WizReadTitleView.m
//  WizNote
//
//  Created by dzpqzb on 13-4-15.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizReadTitleView.h"
#import "UIViewController+WizHelp.h"
#import "WizExpandHeightLabel.h"
#import "WizWebView.h"
static NSString* const KeyOfFrame = @"frame";
static NSString* const KeyOfHidden = @"hidden";

@interface WizReadTitleView ()
{
    BOOL isLayoutingSubViews;
    UILongPressGestureRecognizer* longPressGestureRecognizer;
}
@end

@implementation WizReadTitleView
@synthesize textLabel = _textLabel;
@synthesize shrinkButton = _shrinkButton;
@synthesize delegate;

- (void) dealloc
{
    [_textLabel removeObserver:self forKeyPath:KeyOfFrame];
    [_shrinkButton removeObserver:self forKeyPath:KeyOfHidden];
}

- (void) resizeFrame
{
    float height = 0;
    NSArray* subViews = [self subviews];
    for (UIView* each in subViews) {
        if ([_shrinkButton isEqual:each]) {
           continue;
        }
        if (!each.willVerticalExpanded) {
            continue;
        }
        height += CGRectGetHeight(each.frame);
    }
    self.frame = CGRectSetHeight(self.frame, height);
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:KeyOfFrame]) {
        if ([object isEqual:_textLabel]) {
            if (!isLayoutingSubViews) {
                [self resizeFrame];
            }
        }
    }
    else if ([keyPath isEqualToString:KeyOfHidden])
    {
        [self setNeedsLayout];
    }
}
- (void) commitInit
{
    _shrinkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_shrinkButton addTarget:self action:@selector(didTapZoomButton) forControlEvents:UIControlEventTouchUpInside];
    
    _textLabel = [[WizExpandHeightLabel alloc] init];
    _textLabel.numberOfLines = 0;
    _textLabel.lineBreakMode = NSLineBreakByCharWrapping;
    _textLabel.font = [UIFont boldSystemFontOfSize:16];
    _textLabel.verticalTextAlignment = SSLabelVerticalTextAlignmentMiddle;
    _textLabel.enabled = YES;
    _textLabel.backgroundColor = [UIColor clearColor];
    [_textLabel addObserver:self forKeyPath:KeyOfFrame options:NSKeyValueObservingOptionNew context:nil];
    [_textLabel setUserInteractionEnabled:YES];
    
    
    [self addSubview:_shrinkButton];
    [self addSubview:_textLabel];
    _textLabel.backgroundColor = [UIColor clearColor];
    [_shrinkButton addObserver:self forKeyPath:KeyOfHidden options:NSKeyValueObservingOptionNew context:nil];
    self.backgroundColor = WizColorByKind(ColorOfReadViewTitleBackground);
    isLayoutingSubViews = NO;
    
    longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self addGestureRecognizer:longPressGestureRecognizer];

}

- (void) showZoomButton
{
    if (![self.delegate respondsToSelector:@selector(isViewZoomed)]) {
        return;
    }
    if ([self.delegate isViewZoomed]) {
        [_shrinkButton setImage:WizImageByKind(BtnImageLeaveFullScreen) forState:UIControlStateNormal];
    }
    else
    {
        [_shrinkButton setImage:WizImageByKind(BtnImageEnterFullScreen) forState:UIControlStateNormal];
    }
}
- (void) didTapZoomButton
{
    [self.delegate didTapZoomButton];
    [self showZoomButton];
}

- (id) init
{
    self = [super init];
    if (self) {
        [self commitInit];
    }
    return self;
}
- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commitInit];
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    if (_shrinkButton.hidden) {
        _shrinkButton.frame = CGRectMake(10, 10, 0, 0);
    }
    else
    {
        CGRect rect = CGRectSetCenterY(self.frame, 40);
        rect = CGRectSetX(rect, 5);
        rect = CGRectSetWidth(rect, 40);
        _shrinkButton.frame = rect;
    }
    CGRect labelFrme = CGRectSetOrigin(self.frame, CGPointMake(CGRectGetMaxX(_shrinkButton.frame), 0));
    _textLabel.frame = CGRectSetWidth(labelFrme, CGRectGetWidth(self.frame) - CGRectGetWidth(_shrinkButton.frame) - 20);
    [self showZoomButton];
}

#pragma mark - copy

- (void)longPressGestureRecognized:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == longPressGestureRecognizer)
    {
//        if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
//        {
//            NSAssert([self becomeFirstResponder], @"Sorry, UIMenuController will not work with %@ since it cannot become first responder", self);
        [self becomeFirstResponder];
        UIMenuController *copyMenu = [UIMenuController sharedMenuController];
        [copyMenu setTargetRect:self.textLabel.frame inView:self];
        copyMenu.arrowDirection = UIMenuControllerArrowDefault;
        [copyMenu setMenuVisible:YES animated:YES];
//        }
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(copy:)) {
        return YES;
    }
    return NO;
}

- (void)copy:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:_textLabel.text];
}


@end


