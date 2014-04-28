//
//  WizWebView.m
//  WizNote
//
//  Created by dzpqzb on 13-3-29.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizWebView.h"
#import <objc/runtime.h>
#import "WizDragView.h"
#import "UIColor+SSToolkitAdditions.h"


@interface UIWebView (Share)
+ (UIWebView*) shareInstance;
+ (BOOL) webviewResponseToSEL:(SEL)sel;
@end

@implementation UIWebView (Share)

+ (UIWebView*) shareInstance
{
     static  UIWebView* web = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        web = [[UIWebView alloc] init];
    });
    return web;
}
+ (BOOL) webviewResponseToSEL:(SEL)sel
{
    return [[UIWebView shareInstance] respondsToSelector:sel];
}
@end

static float WizDragSpaceHeight = 70;
static float maxDragViewHeight = 50;

static char WizVertivalExpandedWillKey;
@implementation UIView (WizVerticalExpanded)

- (BOOL) willVerticalExpanded
{
    NSNumber* number = objc_getAssociatedObject(self, &WizVertivalExpandedWillKey);
    if (!number) {
        return YES;
    }
    return [number boolValue];
}

- (void) setWillVerticalExpanded:(BOOL)willVerticalExpanded
{
    objc_setAssociatedObject(self, &WizVertivalExpandedWillKey, @(willVerticalExpanded), OBJC_ASSOCIATION_RETAIN);
}

@end


static NSString* const KeyOfFrame = @"frame";


@interface WizWebMaskView : UIView

@end

@implementation WizWebMaskView



@end

@interface WizWebView ()<UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    CGPoint lastScrollContentOffset;
    WizDragView* topDragView;
    WizDragView* bottomDragView;
    BOOL isScrolling;
}
@property (nonatomic, strong) WizWebMaskView* webMaskView;

@end



@implementation WizWebView
@synthesize headerView = _headerView;
@synthesize headerOffSet= _headerOffSet;
@synthesize footerView = _footerView;
@synthesize gestrueDelegate = _gestrueDelegate;
@synthesize webMaskView = _webMaskView;
- (void) dealloc
{
    [_headerView removeObserver:self forKeyPath:KeyOfFrame];
    [_footerView removeObserver:self forKeyPath:KeyOfFrame];
}
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:KeyOfFrame]) {
        if ([object isEqual:_headerView]) {
            if (!isLayoutingHeaderView) {
                [self layoutHeaderView];
                
            }
        }
        else if ([object isEqual:_footerView])
        {
            if (!isLayoutingFooterView) {
                [self layoutFooterView];
            }
        }
        
    }
}
- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self hideGradientBackground:self];
    if (self) {
        self.scrollView.scrollsToTop = YES;
        topDragView = [WizDragView new];
        topDragView.enableImage = WizImageByKind(ImageOfReadViewPreviousEnable);
        topDragView.disableImage = WizImageByKind(ImageOfReadViewNextEnable);
        topDragView.dragDirection = WizDragDirectionUp;
        topDragView.backgroundColor = WizColorByKind(ColorOfDefaultBackgroud);
        
        bottomDragView = [WizDragView new];
        bottomDragView.enableImage = WizImageByKind(ImageOfReadViewNextEnable);
        bottomDragView.disableImage = WizImageByKind(ImageOfReadViewPreviousEnable);
        bottomDragView.dragDirection = WizDragDirectionDown;
        bottomDragView.backgroundColor = WizColorByKind(ColorOfDefaultBackgroud);
    }
    return self;
}


- (void) layoutAAAA
{
    
}

- (id) init
{
    self = [super init];
    if (self) {
        isScrolling = NO;
    }
    return self;
}
- (void) layoutHeaderView
{
    if (_headerView) {
        isLayoutingHeaderView = YES;
        self.scrollView.contentInset = UIEdgeInsetsMake(_headerOffSet + CGRectGetHeight(self.headerView.bounds), 0, self.scrollView.contentInset.bottom, 0);
        self.scrollView.scrollsToTop = YES;
        _headerView.frame = CGRectMake(self.scrollView.contentOffset.x, 0 - CGRectGetHeight(self.headerView.frame), CGRectGetWidth(self.bounds), CGRectGetHeight(_headerView.frame));
        [_headerView setNeedsLayout];
        isLayoutingHeaderView = NO;
    }
}

- (void) hideGradientBackground:(UIView*)theView
{
    for (UIView * subview in theView.subviews)
    {
        if ([subview isKindOfClass:[UIImageView class]])
            subview.hidden = YES;
        [self hideGradientBackground:subview];
    }
}

- (void) layoutFooterView
{
    if (_footerView) {
        isLayoutingFooterView = YES;
        self.scrollView.contentInset = UIEdgeInsetsMake(_headerOffSet + CGRectGetHeight(self.headerView.bounds), 0, CGRectGetHeight(_footerView.bounds), 0);
        self.scrollView.scrollsToTop = YES;
        _footerView.frame = CGRectMake(self.scrollView.contentOffset.x, self.scrollView.contentSize.height, CGRectGetWidth(self.bounds), CGRectGetHeight(_footerView.frame));
        _footerView.backgroundColor = [UIColor whiteColor];
        isLayoutingFooterView = NO;
    }
}
- (void) setHeaderView:(UIView *)headerView
{
    if (_headerView) {
        [_headerView removeObserver:self forKeyPath:KeyOfFrame];
        [_headerView removeFromSuperview];
    }
    if (headerView) {
        [headerView addObserver:self forKeyPath:KeyOfFrame options:NSKeyValueObservingOptionNew context:nil];
        headerView.autoresizingMask = headerView.autoresizingMask | UIViewAutoresizingFlexibleWidth;
        [self.scrollView addSubview:headerView];
    }
    _headerView = headerView;
    [self layoutHeaderView];
}

- (void) setFooterView:(UIView *)footerView
{
    if (_footerView) {
        [_footerView removeObserver:self forKeyPath:KeyOfFrame];
        [_footerView removeFromSuperview];
    }
    if (footerView) {
        [footerView addObserver:self forKeyPath:KeyOfFrame options:NSKeyValueObservingOptionNew context:nil];
        self.autoresizingMask = footerView.autoresizingMask | UIViewAutoresizingFlexibleWidth;
        [self.scrollView addSubview:footerView];
    }
    _footerView = footerView;
    [self layoutFooterView];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    isScrolling = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    isScrolling = NO;
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    if ([UIWebView webviewResponseToSEL:@selector(scrollViewWillBeginDragging:)]) {
//        [super scrollViewWillBeginDragging:scrollView];
//    }
    lastScrollContentOffset = scrollView.contentOffset;
    if (scrollView.contentSize.height == CGRectGetHeight(self.bounds)) {
        scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, CGRectGetHeight(self.bounds) + 2);
        topDragView.checkEnable = NO;
        bottomDragView.checkEnable = NO;
    }
}

- (void) layoutTopDragView
{
    BOOL canShowPreDrag = [_gestrueDelegate respondsToSelector:@selector(gestrueWebHasPreviousItem:)];
    float currentX = self.scrollView.contentOffset.x;
    if (canShowPreDrag) {
        float startY = CGRectGetMinY(_headerView.frame);
        topDragView.frame = CGRectMake(currentX, - maxDragViewHeight + startY, CGRectGetWidth(self.scrollView.frame), maxDragViewHeight);
        [self.scrollView addSubview:topDragView];
        [self.scrollView bringSubviewToFront:topDragView];
    }

    else
    {
        [topDragView removeFromSuperview];
    }

    if (canShowPreDrag) {
        BOOL hasPre = [_gestrueDelegate gestrueWebHasPreviousItem:self];
        
        if (hasPre) {
            if (ABS(lastScrollContentOffset.y - self.scrollView.contentOffset.y) > WizDragSpaceHeight) {
                topDragView.checkEnable = YES;
                topDragView.prompt = WizStrReleaseToPreviousNote;
            }
            else
            {
                topDragView.checkEnable = NO;
                topDragView.prompt = WizStrDragDownPreviousNote;
            }
            topDragView.title = [_gestrueDelegate gestrueWebPreviousNoteTitle:self];
        }else{
            topDragView.checkEnable = NO;
            topDragView.prompt = WizStrNonePreviousNote;
            topDragView.title = nil;
            [topDragView setNeedsLayout];
        }
    }
 
}

- (void) layoutBottomDragView
{
    BOOL canShowNextDrag = [_gestrueDelegate respondsToSelector:@selector(gestrueWebHasNextItem:)];
    float currentX = self.scrollView.contentOffset.x;
    if (canShowNextDrag) {
        [self.scrollView addSubview:bottomDragView];
        [self.scrollView bringSubviewToFront:bottomDragView];
        float bottomStartY = self.scrollView.contentSize.height;
        bottomDragView.frame = CGRectMake(currentX, bottomStartY, CGRectGetWidth(self.scrollView.frame), maxDragViewHeight);
    }
    else
    {
        [bottomDragView removeFromSuperview];
    }

    if (canShowNextDrag) {
        BOOL hasNext = [_gestrueDelegate gestrueWebHasNextItem:self];
        if (hasNext) {
            if (ABS(lastScrollContentOffset.y - self.scrollView.contentOffset.y) > WizDragSpaceHeight) {
                bottomDragView.checkEnable = YES;
                bottomDragView.prompt = WizStrReleaseToNextNote;
            }
            else
            {
                bottomDragView.checkEnable = NO;
                bottomDragView.prompt = WizStrDragUpToNextNote;
            }
            bottomDragView.title = [_gestrueDelegate gestrueWebNextNoteTitle:self];
        }else{
            bottomDragView.checkEnable = NO;
            bottomDragView.prompt = WizStrNoneNextNote;
            bottomDragView.title = nil;
            [bottomDragView setNeedsLayout];
        }
    }
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([UIWebView webviewResponseToSEL:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }

    float maxHeight = scrollView.contentOffset.y + CGRectGetHeight(scrollView.frame) - scrollView.contentSize.height;
    if (ABS(maxHeight) > WizDragSpaceHeight) {
        if (topDragView.checkEnable) {
            if ([_gestrueDelegate respondsToSelector:@selector(gestrueWebCheckPreviousItem:)]) {
                [topDragView removeFromSuperview];
                [_gestrueDelegate gestrueWebCheckPreviousItem:self];
            }
        }
        if (bottomDragView.checkEnable)
        {
            if ([_gestrueDelegate respondsToSelector:@selector(gestrueWebCheckNextItem:)]) {
                [bottomDragView removeFromSuperview];
                [_gestrueDelegate gestrueWebCheckNextItem:self];
            }
        }
    }
}

- (void) disableAllNextPreCheck
{
    topDragView.checkEnable = NO;
    bottomDragView.checkEnable = NO;
    [topDragView removeFromSuperview];
    [bottomDragView removeFromSuperview];
}

- (void) scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    if ([UIWebView webviewResponseToSEL:@selector(scrollViewWillBeginZooming:withView:)])
    {
       [super scrollViewWillBeginZooming:scrollView withView:view];
    }
    [self disableAllNextPreCheck];
}

- (void) scrollViewDidZoom:(UIScrollView *)scrollView
{
    if ([UIWebView webviewResponseToSEL:@selector(scrollViewDidZoom:)]) {
       [super scrollViewDidZoom:scrollView]; 
    }
    [self disableAllNextPreCheck];
}
- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([UIWebView webviewResponseToSEL:@selector(scrollViewDidScroll:)])
    {
        [super scrollViewDidScroll:scrollView];
    }
    [self layoutHeaderView];
    [self layoutFooterView];
    
        
    if (lastScrollContentOffset.y  <  scrollView.contentOffset.y) {
        
        if (lastScrollContentOffset.y + CGRectGetHeight(scrollView.frame) < scrollView.contentSize.height ) {
                lastScrollContentOffset = scrollView.contentOffset;
            [bottomDragView removeFromSuperview];
        }
        else
        {
            [self layoutBottomDragView];
        }
    }
    else
    {
        if (lastScrollContentOffset.y > 0) {
            lastScrollContentOffset = scrollView.contentOffset;
            [topDragView removeFromSuperview];
        }
        else
        {
            [self layoutTopDragView];
        }
        
    }
}



- (void) layoutSubviews
{
    [super layoutSubviews];
    [self layoutHeaderView];
    [self layoutFooterView];
}

@end
@interface WizVerticalExpandView ()
{
    BOOL isLayoutingSubViews;
}
@end


@implementation WizVerticalExpandView


- (void) dealloc
{

}

- (void) layoutSubviewsByView:(UIView*)view
{
    NSInteger indexOfView = NSNotFound;
    NSArray* subViews = [self.subviews copy];
    for (int i = 0; i < [subViews count]; ++i){
        if ([[subViews objectAtIndex:i] isEqual:view]) {
            indexOfView = i;
            break;
        }
    }
    if(indexOfView != NSNotFound && indexOfView + 1 < [subViews count])
    {
        UIView* nextView = [subViews objectAtIndex:indexOfView + 1];
        if (nextView.willVerticalExpanded) {
           nextView.frame = CGRectSetY(nextView.frame, CGRectGetMaxY(view.frame));
        }
    }
    self.frame = CGRectSetHeight(self.frame,[self subviewsHeight]);
}
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([KeyOfFrame isEqualToString:keyPath]) {
        if ([object isKindOfClass:[UIView class]]) {
            if (!isLayoutingSubViews) {
                [self layoutSubviewsByView:object];
            }
        }
    }
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        isLayoutingSubViews = NO;
    }
    return self;
    
}
- (float) subviewsHeight
{
    float sumY = 0;
    
    NSArray* subs = [self.subviews copy];
    for (UIView* each in subs) {
        if (each.willVerticalExpanded) {
            sumY += each.frame.size.height; 
        }
    }
    return sumY;
}

- (void) addViewWithExpand:(UIView*)view
{
    view.autoresizingMask =view.autoresizingMask | UIViewAutoresizingFlexibleWidth;
    [self layoutSubviewsHeight];
    [view addObserver:self forKeyPath:KeyOfFrame options:NSKeyValueObservingOptionNew context:nil];
}

- (void) layoutSubviewsHeight
{
    NSArray* subViews = [self.subviews copy];
    float sumY = 0;
    for (UIView* eachView in subViews) {
        if (eachView.willVerticalExpanded) {
            isLayoutingSubViews = YES;
            eachView.frame = CGRectSetY(eachView.frame, sumY);
            isLayoutingSubViews = NO;
            sumY += CGRectGetHeight(eachView.frame);
        }
    }
    self.frame = CGRectSetHeight(self.frame, sumY);
}

- (void) addSubview:(UIView *)view
{
    [super addSubview:view];
    if (view.willVerticalExpanded) {
       [self addViewWithExpand:view]; 
    }
}

- (void) insertSubview:(UIView *)view atIndex:(NSInteger)index
{
    [super insertSubview:view atIndex:index];
    if (view.willVerticalExpanded) {
       [self addViewWithExpand:view]; 
    }
    
}

- (void) insertSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview
{
    [super insertSubview:view aboveSubview:siblingSubview];
    if (view.willVerticalExpanded) {
       [self addViewWithExpand:view];
    }
}

- (void) insertSubview:(UIView *)view belowSubview:(UIView *)siblingSubview
{
    [super insertSubview:view belowSubview:siblingSubview];
    if (view.willVerticalExpanded) {
        [self addViewWithExpand:view]; 
    }
   
}
- (void) willRemoveSubview:(UIView *)subview
{
    [super willRemoveSubview:subview];
    if (subview.willVerticalExpanded) {
        [subview removeObserver:self forKeyPath:KeyOfFrame];
        subview.frame = CGRectSetHeight(subview.frame, 0);
    }
    [self layoutSubviewsHeight];
}


@end


@interface WizWebHeadview ()
{
    
}
@end

@implementation WizWebHeadview
@synthesize delegate=_delegate;

- (id) initWithDelegate:(id<WizWebHeadViewSourceDelegate>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    return self;
}

- (void) commitInit
{
    
}

- (void) layoutSubviews
{
    NSInteger numberOfItem = [self.delegate numberOfItemInWizWebHeaderView:self];
    float currentY = 0;
    for (int i = 0; i < numberOfItem; ++i) {
        UIView* view = [self.delegate viewForWizWebHeaderView:self index:i];
        float height = [self.delegate heightFroWizWebHeaderView:self index:i];
        view.frame = CGRectMake(0, currentY, CGRectGetWidth(self.bounds), height);
        currentY += height;
        [self addSubview:view];
    }
    self.frame = CGRectSetHeight(self.frame, currentY);
}


@end



