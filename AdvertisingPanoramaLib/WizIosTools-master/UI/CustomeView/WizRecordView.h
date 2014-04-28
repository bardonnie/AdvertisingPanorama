//
//  WizRecordView.h
//  WizNote
//
//  Created by dzpqzb on 13-4-24.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WizRecordViewActionDelegate <NSObject>

- (void) didStartRecord;
- (void) didCancelRecord;
- (void) didEndRecord:(NSString*)filePath;

@end

@interface WizRecordView : UIView
@property (nonatomic, weak) id<WizRecordViewActionDelegate> delegate;
- (void) startRecord;
@end
