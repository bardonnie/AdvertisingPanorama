//
//  WizSegmentedViewController.h
//  Wiz
//
//  Created by wiz on 12-8-13.
//
//

#import <UIKit/UIKit.h>
#import "WizSegmentOrientationDelegate.h"

@interface WizSegmentedViewController : UIViewController <WizSegmentOrientationDelegate>
- (id) initWithViewControllers:(NSArray*)viewControllers  titles:(NSArray*)titles;
@end
