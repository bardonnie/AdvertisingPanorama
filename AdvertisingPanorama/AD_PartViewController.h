//
//  AD_PartViewController.h
//  AdvertisingPanorama
//
//  Created by mac on 14-2-18.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AD_PartViewController : UIViewController
{
    ViewControllers _vc;
    int _tag;
}

- (id)initWithViewController:(ViewControllers)viewController VcTag:(int)tag;

@end
