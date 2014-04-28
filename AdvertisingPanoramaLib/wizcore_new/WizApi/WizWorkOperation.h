//
//  WizWorkOperation.h
//  WizNote
//
//  Created by dzpqzb on 13-4-17.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizObject.h"
@protocol WizWorkDelegate <NSObject>
@optional
- (void) onStart;
- (void) onEnd;
- (void) onError:(NSError*)error;
- (NSError*) onWork;
- (void) onProcessWithMessage:(NSDictionary*)userInfo;
@end
@interface WizWorkOperation : NSOperation
@property (nonatomic, weak) id<WizWorkDelegate> delegate;
- (id) initWithDelegate:(id<WizWorkDelegate>)delegate;
- (void) sendMessageToDelegate:(NSDictionary*)dictionay;
@end

@protocol WizSearchActionDelegate <NSObject>
@optional
- (void) didSearchLocalSucceed:(NSArray*)array;
- (void) didSearchOnServerSucceed:(NSArray*)array;

@end

@interface WizSearchAction : NSObject
@property (nonatomic, weak) id<WizSearchActionDelegate> delegate;
@property (nonatomic, strong) WizGroup* group;
@property (nonatomic, assign) enum WizSearchType type;
- (id) initWithGroup:(WizGroup*)group delegate:(id<WizSearchActionDelegate>)delegate;
- (void) startSearch:(NSString*)keywords;
@end
