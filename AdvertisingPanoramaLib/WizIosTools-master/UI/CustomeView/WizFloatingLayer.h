//
//  WizFloatingLayer.h
//  FloatLayer
//
//  Created by wzz on 13-9-2.
//  Copyright (c) 2013年 wzz. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WizArrowSize    9.0f


@class WizFloatingLayer;
@protocol WizFloatingLayerDelegate <NSObject>
@optional
- (void) willFloatingLayerAppear;
- (void) didFloatingLayerAppear;
- (void) willFloatingLayerDismiss;
- (void) didFloatingLayerDismiss;
@end

@interface WizFloatingLayer : UIView
@property (nonatomic, weak)id<WizFloatingLayerDelegate> delegate;
- (id)initWithContentView:(UIView*)contentView;

- (void) showMenuInView:(UIView *)view
              fromPoint:(CGPoint)point;

- (void) dismissMenu:(BOOL)animated;

- (void) setTintColor: (UIColor *) tintColor;
@end
