//
//  WizNavigationViewController.m
//  WizNote
//
//  Created by dzpqzb on 13-8-2.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizNavigationViewController.h"
#import <objc/runtime.h>
#import "CRNavigationBar.h"
static void* kWizViewControllerVisiling = &kWizViewControllerVisiling;
@interface WizNavigationViewController ()
{
    BOOL _isVisible;
}
@end


@implementation WizNavigationViewController
- (void) dealloc
{
    [self removeTriggerSyncGroupStatus];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    _isVisible = NO;
    self = [super initWithNavigationBarClass:nil toolbarClass:nil];
    if (self) {
        self.viewControllers = @[rootViewController];
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController reciveMessage:(BOOL)messageIsVisible
{
    _isVisible = messageIsVisible;
    self = [super initWithNavigationBarClass:nil toolbarClass:nil];
    if (self) {
        self.viewControllers = @[rootViewController];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    if (_isVisible) {
        [self triggerSyncGroupStatus];
    }
	// Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setISVisulabling:(BOOL)v
{
    objc_setAssociatedObject(self, kWizViewControllerVisiling, @(v), OBJC_ASSOCIATION_RETAIN);
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setISVisulabling:_isVisible];
}

- (BOOL) isVisibling
{
    return [objc_getAssociatedObject(self, kWizViewControllerVisiling) boolValue];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self setISVisulabling:NO];
}

@end
