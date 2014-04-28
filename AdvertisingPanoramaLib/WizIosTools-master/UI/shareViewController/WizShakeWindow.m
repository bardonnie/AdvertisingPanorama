//
//  WizShakeWindow.m
//  WizNote
//
//  Created by dzpqzb on 13-5-24.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizShakeWindow.h"

@implementation WizShakeWindow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeMotion && event.subtype == UIEventSubtypeMotionShake) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:WizNotificationMessageShake object:nil];
        NSLog(@"shake");
    }
}
@end
