//
//  WizMenuView.h
//  WizNote
//
//  Created by wzz on 13-5-17.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#define messageGroupCellHeight   35.0
#define WizStrAllMessages       NSLocalizedString(@"All Messages", nil)

@class WizMenuView;
@protocol WizMenuViewDelegate <NSObject>
- (void)menuView:(WizMenuView*)menuView_ didSelectedRowAtIndexPath:(NSIndexPath*)indexPath;
@end

@interface WizMenuView : UIImageView<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, setter = setDataArray:) NSMutableArray* dataArray;
@property (nonatomic, assign) id<WizMenuViewDelegate> menuDelegate;
@property (nonatomic, getter = dataCount) NSInteger dataCount;
- (void)reloadMenuData;
- (void)autoScrollToLastSelectedPosition;
- (void)showMenuWithAnimate:(BOOL)animated;
- (void)hideMenuWithAnimate:(BOOL)animated;
@end
