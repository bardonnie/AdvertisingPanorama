//
//  WizAttachmentsView.h
//  WizNote
//
//  Created by dzpqzb on 13-4-4.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizWebView.h"
#import "GMGridView.h"
#import "GMGridViewLayoutStrategies.h"
#import "WizAttachmentProtrol.h"

typedef enum{
    WizAttachmentCellLayoutDirectionVertical,
    WizAttachmentCellLayoutDirectionHorizontal,
}WizAttachmentCellLayoutDirection;

@interface WizAttachmentsView : WizVerticalExpandView <GMGridViewDataSource, GMGridViewActionDelegate, GMGridViewSortingDelegate, GMGridViewTransformationDelegate, WizAttachmentProtrol>
{
    
}
@property (nonatomic, strong)GMGridView* attachmetnsView;
@property (nonatomic, strong, readonly) NSMutableArray* attachmentsArray;
@property (nonatomic, strong) WizGroup* wizGroup;
@property (nonatomic, strong) id<GMGridViewLayoutStrategy> layoutStrategy;
@property (nonatomic, strong) UIImage* cellBackgroundImage;
@property (nonatomic, assign) CGFloat flexibleSpacing;
@property (nonatomic, assign) UIEdgeInsets minEdgeInsets;
@property (nonatomic, assign) WizAttachmentCellLayoutDirection direction;
@end

@interface WizAttachmentListView : UITableView <WizAttachmentProtrol>
@property (nonatomic, strong) WizGroup* group;
@end
