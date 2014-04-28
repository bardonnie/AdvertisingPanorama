//
//  WizScrollView.m
//  WizIphone7
//
//  Created by zhao on 3/28/14.
//  Copyright (c) 2014 dzpqzb inc. All rights reserved.
//

#import "WizScrollView.h"

@implementation WizScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    if ([view isKindOfClass:[UIButton class]])
    {
        return YES;
    }else{
        return [super touchesShouldBegin:touches withEvent:event inContentView:view];
    }
}

@end
