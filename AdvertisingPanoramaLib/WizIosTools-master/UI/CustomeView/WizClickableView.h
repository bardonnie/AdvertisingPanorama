//
//  WizClickableView.h
//  WizNote
//
//  Created by wzz on 13-7-31.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WizClickableView : UIButton
@property (nonatomic, setter = setButtonTitle:) NSString* text;
@property (nonatomic, setter = setTextColor:) UIColor* textColor;
@property (nonatomic, setter = setButtonImage:) UIImage* stateImage;
@property (nonatomic, getter = viewWidth)CGFloat viewWidth;
@property (nonatomic, strong) UIImageView* stateImageView;
@property (nonatomic, assign)float imageWidth;
@end
