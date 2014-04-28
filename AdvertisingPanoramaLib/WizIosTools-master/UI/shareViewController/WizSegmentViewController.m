//
//  WizSegmentViewController.m
//  WizSegmentViewController
//
//  Created by dzpqzb on 13-3-18.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizSegmentViewController.h"

#define WizViewControllerTransitionDuration 0.35

@interface WizSegmentViewController ()
@property (nonatomic, strong) UISegmentedControl* segmentControl;
@property (nonatomic, assign) NSInteger seletedIndex;
@property (nonatomic, strong) UIViewController* selectedViewController;
@property (nonatomic, strong) NSArray* titles;
@end

@implementation WizSegmentViewController
@synthesize segmentControl;
@synthesize seletedIndex = _seletedIndex;
@synthesize titles= _titles;
@synthesize selectedViewController = _selectedViewController;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _seletedIndex = -1;
        // Custom initialization
    }
    return self;
}
- (void) setViewControllers:(NSArray*)vcs titles:(NSArray*)titles
{
    NSAssert([vcs count] == [titles count], @"vc count not equal title's");
    [self setViewControllers:vcs];
    self.titles = titles;
}
- (void) setViewControllers:(NSArray*)vcs
{
    for (UIViewController* vc in self.childViewControllers) {
        [self willMoveToParentViewController:nil];
        [vc removeFromParentViewController];
    }
    NSAssert([vcs count], @"subviewcontroller is nil");
    for(UIViewController* vc in vcs)
    {
        [self addChildViewController:vc];
        [vc didMoveToParentViewController:self];
    }
    if ([self isViewLoaded]) {
        
    }
}

- (void) setSegmentControlSelectedIndex:(NSInteger)seletedIndex
{
    [self.segmentControl setSelectedSegmentIndex:seletedIndex];
}
- (void) setSeletedIndex:(NSInteger)seletedIndex
{
    if (self.seletedIndex != seletedIndex) {
         
        if ([self isViewLoaded]) {
            UIViewController* toViewController = [self.childViewControllers objectAtIndex:seletedIndex];
            if (self.selectedViewController) {
                [self transitionFromViewController:self.selectedViewController toViewController:toViewController duration:WizViewControllerTransitionDuration options:UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionCurveEaseOut animations:^{
                    toViewController.view.frame = self.view.bounds;
                } completion:^(BOOL finished) {
                    self.selectedViewController = toViewController;
                    _seletedIndex = seletedIndex;
                    [toViewController didMoveToParentViewController:self];
                }];
            }
            else
            {
                toViewController.view.frame = self.view.bounds;
                [self.view addSubview:toViewController.view];
                self.selectedViewController = toViewController;
                _seletedIndex = seletedIndex;
                [toViewController didMoveToParentViewController:self];
            }
        }
        else
        {
            _seletedIndex = seletedIndex;
            
        }
    }
    if (self.segmentControl.selectedSegmentIndex != seletedIndex) {
        [self.segmentControl setSelectedSegmentIndex:seletedIndex];
    }
}
- (id) initWithChildViewController:(NSArray*)viewControllers titles:(NSArray *)titles
{
    self = [super init];
    if (self) {
        _seletedIndex = -1;
        [self setViewControllers:viewControllers titles:titles];
    }
    return self;
}

- (void) segmentControlValueChanged:(id)sender
{
    if ([sender isKindOfClass:[UISegmentedControl class]]) {
        UISegmentedControl* segc = (UISegmentedControl*)sender;
        NSInteger seletedIndex = [segc selectedSegmentIndex];
        [self setSeletedIndex:seletedIndex];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!self.segmentControl) {
        self.segmentControl = [[UISegmentedControl alloc] initWithItems:self.titles];
        self.segmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
        [self.segmentControl addTarget:self action:@selector(segmentControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        self.navigationItem.titleView = self.segmentControl;
//        [self.segmentControl setContentOffset:CGSizeMake(40, 0) forSegmentAtIndex:0];
//        [self.segmentControl setContentOffset:CGSizeMake(-5, 0) forSegmentAtIndex:[self.titles count]-1];
    }
    [self setSeletedIndex:0];
	// Do any additional setup after loading the view.
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Only rotate if all child view controllers agree on the new orientation.
	for (UIViewController *viewController in self.childViewControllers)
	{
		if (![viewController shouldAutorotateToInterfaceOrientation:interfaceOrientation])
			return NO;
	}
	return YES;
}
- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

@end
