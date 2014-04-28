//
//  WizSearchBar.m
//  NaviBarTest
//
//  Created by wzz on 13-10-30.
//  Copyright (c) 2013年 wzz. All rights reserved.
//

#import "WizSearchBar.h"

@interface WizSearchBar()
{
    CGRect defaultTextFieldRect;
    BOOL isShowCancleButton;
}
@property (nonatomic, strong)UIButton* cancelButton;
@property(nonatomic, strong) UIActivityIndicatorView* activityIndicatorView;
@end

@implementation WizSearchBar
@synthesize cancelButton = _cancelButton;
@synthesize activityIndicatorView = _activityIndicatorView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        isShowCancleButton = NO;
    }
    return self;
}

- (UIView*)findSubViewInView:(UIView*)myView ByClassName:(NSString*)string
{
    for (UIView* view in [myView subviews]) {
        if ([view isKindOfClass:NSClassFromString(string)]) {
            return view;
        }else if([[view subviews] count] > 0) {
            return [self findSubViewInView:view ByClassName:string];
        }
    }
    return nil;
}

- (void)setShowsCancelButton:(BOOL)showsCancelButton
{
    [self setShowsCancelButton:showsCancelButton animated:NO];
}

- (void)setShowsCancelButton:(BOOL)showsCancelButton animated:(BOOL)animated
{
    isShowCancleButton = showsCancelButton;
    if (DEVICE_VERSION_BELOW_7){
        [super setShowsCancelButton:showsCancelButton animated:animated];
    }else{
        UIView* textFieldView = [self findSubViewInView:self ByClassName:@"UISearchBarTextField"];
        if (showsCancelButton) {
            defaultTextFieldRect = textFieldView.frame;
        }
        if (textFieldView) {
            float animatedDuration = animated ? WizAnimatedDuration : 0.1;
            if (showsCancelButton) {
                [UIView animateWithDuration:animatedDuration animations:^{
                    if (_cancelButton == nil) {
                        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
                        [_cancelButton setTitle:WizStrCancel forState:UIControlStateNormal];
                        [_cancelButton addTarget:self action:@selector(clickedCancelButton) forControlEvents:UIControlEventTouchUpInside];
                        _cancelButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
                        float buttonWidth = [_cancelButton.titleLabel.text sizeWithFont:_cancelButton.titleLabel.font].width;
                        _cancelButton.frame = CGRectMake(CGRectGetWidth(defaultTextFieldRect), 0, buttonWidth, 0);
                    }
                    textFieldView.frame = CGRectSetWidth(defaultTextFieldRect, CGRectGetWidth(defaultTextFieldRect) - CGRectGetWidth(_cancelButton.frame) - 10);
                    _cancelButton.frame = CGRectMake(CGRectGetMaxX(textFieldView.frame) + 10, CGRectGetMinY(textFieldView.frame), _cancelButton.frame.size.width, CGRectGetHeight(textFieldView.frame));
                    if (_cancelButton.superview != textFieldView.superview) {
                        [textFieldView.superview addSubview:_cancelButton];
                    }
                }];
            }else{
                [UIView animateWithDuration:animatedDuration animations:^{
                    textFieldView.frame = defaultTextFieldRect;
                }];
                [_cancelButton removeFromSuperview];
            }
        }
    }
}

- (BOOL)showsCancelButton
{
    return isShowCancleButton;
}

- (void)clickedCancelButton
{
    [self.delegate searchBarCancelButtonClicked:self];
}

- (void)startActivity
{
    UIView* textFieldView = [self findSubViewInView:self ByClassName:@"UISearchBarTextField"];
    for (UIView* view in [textFieldView subviews]) {
        if ([view isKindOfClass:[UIImageView class]] && ![view isKindOfClass:NSClassFromString(@"_UISearchBarSearchFieldBackgroundView")]) {
            if (self.activityIndicatorView == nil) {
                UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                activityIndicator.hidesWhenStopped = YES;
                activityIndicator.backgroundColor = [UIColor whiteColor];
                activityIndicator.frame = view.bounds;
                [view addSubview:activityIndicator];
                self.activityIndicatorView = activityIndicator;
            }
            [self.activityIndicatorView startAnimating];
        }
    }
}

- (void)finishActivity
{
    [self.activityIndicatorView stopAnimating];
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
