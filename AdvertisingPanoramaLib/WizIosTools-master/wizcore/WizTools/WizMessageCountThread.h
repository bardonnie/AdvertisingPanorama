//
//  WizMessageCountThread.h
//  WizNote
//
//  Created by dzpqzb on 13-7-12.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WizMessageCountThread : NSThread
- (void) addCommand:(NSString*)accountUserId;
- (NSString*) anyCommand;
- (void) removeCommand:(NSString*)accountUserId;
@end
