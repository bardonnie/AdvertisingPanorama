//
//  WizAttachmentProtrol.h
//  WizIphone7
//
//  Created by wzz on 13-10-18.
//  Copyright (c) 2013年 dzpqzb inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WizAttachmentViewDelegate <NSObject>

- (void) didSelectAttachment:(WizAttachment*)attachment;

@end


@protocol WizAttachmentProtrol <NSObject>
@property (nonatomic, weak) id<WizAttachmentViewDelegate> attachmentsDelegate;
@optional
- (void) addAttachment:(WizAttachment*)attachment animated:(BOOL)animated;
- (void) removeAllAttachments;
- (void) removeAttachmentObjectAt:(NSInteger)index animation:(BOOL)animation;
- (void) setAttachments:(NSArray*)attachmetns;

@end
