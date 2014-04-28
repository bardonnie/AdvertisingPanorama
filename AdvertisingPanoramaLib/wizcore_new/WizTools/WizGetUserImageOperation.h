//
//  WizGetUserImageOperation.h
//  WizNote
//
//  Created by dzpqzb on 13-7-12.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WizGetUserImageOperation : NSOperation
@property (nonatomic, strong) NSString* userGuid;
- (id) initWithUserGuid:(NSString*)userGuid;
@end