//
//  WizViewController.m
//  WizIphone7
//
//  Created by dzpqzb on 13-9-4.
//  Copyright (c) 2013年 dzpqzb inc. All rights reserved.
//

#import "WizViewController.h"

@interface WizViewController ()

@end

@implementation WizViewController
@synthesize accountUserId = _accountUserId;

- (id) initWithAccountUserId:(NSString *)accountUserId
{
    self = [super init];
    if (!self) {
        return nil;
    }
    _accountUserId = accountUserId;
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
