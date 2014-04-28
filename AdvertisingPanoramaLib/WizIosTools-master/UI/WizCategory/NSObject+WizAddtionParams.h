//
//  NSObject+WizAddtionParams.h
//  WizNote
//
//  Created by dzpqzb on 13-4-16.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (WizAddtionParams)
@property (nonatomic, strong) WizGroup* wizGroup;
- (id) initWithGroup:(WizGroup*)group;
@end
