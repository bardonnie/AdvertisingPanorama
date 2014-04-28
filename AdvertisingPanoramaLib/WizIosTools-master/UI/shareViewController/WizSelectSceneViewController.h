//
//  WizSelectSceneViewController.h
//  WizIphone7
//
//  Created by dzpqzb on 13-9-12.
//  Copyright (c) 2013年 dzpqzb inc. All rights reserved.
//

#import "WizTableViewController.h"

@protocol WizSelectSceneDelegate <NSObject>

- (void) didSelectSecneAccountUserId:(NSString*)accountUserId folders:(NSArray*)floders tags:(NSArray*)tags;

@end

@interface WizSelectSceneViewController : WizTableViewController
@property (nonatomic, weak) id<WizSelectSceneDelegate> delegate;
@end
