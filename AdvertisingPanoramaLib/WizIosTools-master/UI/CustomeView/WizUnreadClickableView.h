//
//  WizUnreadClickableView.h
//  WizNote
//
//  Created by wzz on 13-8-2.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizClickableView.h"

@interface WizUnreadClickableView : WizClickableView
@property (nonatomic, setter = setUnreadMessageNumber:) NSInteger unreadCount;
@end
