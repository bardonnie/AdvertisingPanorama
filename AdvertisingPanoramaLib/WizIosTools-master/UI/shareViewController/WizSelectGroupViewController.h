//
//  WizSelectGroupViewController.h
//  WizNote
//
//  Created by dzpqzb on 13-5-20.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WizTreeViewController.h"

@protocol WizSelectGroupDelegate <NSObject>
- (void) didSelectedGroups:(NSSet*)groups;
- (NSString*) selectGroupExpectKbguid;
-(void)dismissPopoverController:(NSString*)sharePath;
@end  


@interface WizSelectGroupViewController : WizTreeViewController
@property (nonatomic, weak) id<WizSelectGroupDelegate> delegate;
@property (nonatomic, strong) NSString* accountUserId;
@property (nonatomic, assign) WizUserPriviligeType minPrivilige;
@end
