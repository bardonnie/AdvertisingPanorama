//
//  WizDragView.h
//  WizNote
//
//  Created by dzpqzb on 13-6-17.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    WizDragDirectionLeft,
    WizDragDirectionRight,
    WizDragDirectionUp,
    WizDragDirectionDown
}WizDragDirection;

@interface WizDragView : UIView
@property (nonatomic, strong) UIImage* enableImage;
@property (nonatomic, strong) UIImage* disableImage;
@property (nonatomic, strong) UIImageView* dragImageView;
@property (nonatomic, setter = setLableTitle:) NSString* title;
@property (nonatomic, setter = setLablePrompt:) NSString* prompt;
@property (nonatomic, assign) BOOL checkEnable;
@property (nonatomic, assign) WizDragDirection dragDirection;
@end
