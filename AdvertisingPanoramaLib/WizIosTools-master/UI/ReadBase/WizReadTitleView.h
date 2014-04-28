//
//  WizReadTitleView.h
//  WizNote
//
//  Created by dzpqzb on 13-4-15.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WizExpandHeightLabel.h"

@protocol WizReadTitleViewDelegate <NSObject>
@optional
- (BOOL) isViewZoomed;
- (void) didTapZoomButton;
@end

@interface WizReadTitleView :UIView
@property (nonatomic, strong) WizExpandHeightLabel* textLabel;
@property (nonatomic, strong) UIButton* shrinkButton;
@property (nonatomic, weak) id<WizReadTitleViewDelegate> delegate;
@end