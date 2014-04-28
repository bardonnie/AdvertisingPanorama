//
//  WizSegmentControlView.h
//  WizNote
//
//  Created by wzz on 13-8-7.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WizSegmentControlView;
@protocol WizSegmentControlViewDelegate<NSObject>
- (void)didSelectedItemWithIndex:(NSInteger)index itemTitle:(NSString*)itemTitle;
@end

@interface WizSegmentControlView : UIView
@property (nonatomic, assign)id<WizSegmentControlViewDelegate> delegate;
@property (nonatomic, strong) UIImage* separatorImage;
@property (nonatomic, setter = setDefaultSelected:) NSInteger defaultSelectedIndex;
- (id)initWithTitles:(NSArray*)titles images:(NSArray*)images;
@end
