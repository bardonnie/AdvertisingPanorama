//
//  WizTableViewController.h
//  WizIphone7
//
//  Created by dzpqzb on 13-9-4.
//  Copyright (c) 2013年 dzpqzb inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WizTableViewController : UITableViewController
{
@public
    NSString* _accountUserId;
}
@property (nonatomic, readonly) NSString* accountUserId;
- (id) initWithAccountUserId:(NSString*)accountUserId;
@end
