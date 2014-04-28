//
//  WizUIGlobals.h
//  WizNote
//
//  Created by wzz on 13-4-2.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MYIntroductionView.h"

#define WizIntroduceNewCount 4
#define WizIntroduceUpdateCount 3

typedef enum {
    WizUIstatueNormal = 0,
    WizUIStatueEditing,
    WizUIStatueRecording,
    WizUIStatuePhoto
}WizUIStatue;

@interface WizUIGlobals : NSObject
+ (UIView*)WizSelectCellBackgroundView;
+ (UIView*)WizUnreadDocumentCountViewByCount:(NSString*)count;
+ (UIView*)WizNoContentPromptView:(CGRect)rect image:(UIImage*)image_ text:(NSString*)text detailText:(NSString*)detailText;
+ (MYIntroductionView*) wizAppNewIntroduceView;
+ (MYIntroductionView*) wizAppUpdateIntroduceView;
+ (WizUIStatue) currentUIStatue;
+ (void) setCurrentUIStatue:(WizUIStatue)statue;
@end
