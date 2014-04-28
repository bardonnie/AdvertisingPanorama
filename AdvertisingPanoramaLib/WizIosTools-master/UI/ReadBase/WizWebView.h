//
//  WizWebView.h
//  WizNote
//
//  Created by dzpqzb on 13-3-29.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMTWebView.h"
@class WizWebView;
@protocol WizGestrueWebDelegate <NSObject>

- (BOOL) gestrueWebHasPreviousItem:(WizWebView*)webView;
- (BOOL) gestrueWebHasNextItem:(WizWebView*)webView;

- (void) gestrueWebCheckPreviousItem:(WizWebView*)webView;
- (void) gestrueWebCheckNextItem:(WizWebView*)webview;

- (NSString*) gestrueWebPreviousNoteTitle:(WizWebView*)webView;
- (NSString*) gestrueWebNextNoteTitle:(WizWebView*)webView;

@end

@interface UIView (WizVerticalExpanded)
@property (nonatomic, assign) BOOL willVerticalExpanded;
@end

@interface WizWebView : IMTWebView
{
    BOOL isLayoutingHeaderView;
    BOOL isLayoutingFooterView;
}
@property (nonatomic, strong) UIView* headerView;
@property (nonatomic, strong) UIView* footerView;
@property (nonatomic, assign) CGFloat headerOffSet;
@property (nonatomic, weak) id<WizGestrueWebDelegate> gestrueDelegate;
@end
@class WizWebHeadview;
@protocol WizWebHeadViewSourceDelegate <NSObject>
- (UIView*) viewForWizWebHeaderView:(WizWebHeadview*)header index:(NSInteger)index;
- (CGFloat) heightFroWizWebHeaderView:(WizWebHeadview*)header index:(NSInteger)index;
- (NSInteger) numberOfItemInWizWebHeaderView:(WizWebHeadview*)header;


@end

@interface WizVerticalExpandView : UIView

@end


@interface WizWebHeadview : UIView
@property (nonatomic, weak) id<WizWebHeadViewSourceDelegate> delegate;
- (id) initWithDelegate:(id<WizWebHeadViewSourceDelegate>)delegate;
@end

