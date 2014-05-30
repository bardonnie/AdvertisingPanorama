//
//  AD_RootViewController.m
//  AdvertisingPanorama
//
//  Created by mac on 14-2-19.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//



#import "AD_RootViewController.h"

@interface AD_RootViewController ()< WizSyncDownloadDelegate>

@end

@implementation AD_RootViewController
{
    UIImageView *_advertisementBackImageView;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[WizNotificationCenter shareCenter] addDownloadDelegate:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hiddenAdvertisementImageView) userInfo:nil repeats:NO];
    
    _advertisementBackImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    _advertisementBackImageView.backgroundColor = [UIColor redColor];
    if (MAIN_WINDOW_HEIGHT == 480) {
        [_advertisementBackImageView setImage:[UIImage imageNamed:@"Advertisement_480"]];
    }
    else
    {
        [_advertisementBackImageView setImage:[UIImage imageNamed:@"Advertisement_568"]];
    }
    [self.view addSubview:_advertisementBackImageView];
    
    CGFloat advertisementImageViewHeight;
    if (MAIN_WINDOW_HEIGHT == 480)
    {
        advertisementImageViewHeight = 380;
    }
    else
    {
        advertisementImageViewHeight = 460;
    }
    
    UIImageView *advertisementImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, MAIN_WINDOW_WIDTH, advertisementImageViewHeight)];
    advertisementImageView.backgroundColor = [UIColor clearColor];
    advertisementImageView.contentMode = UIViewContentModeScaleToFill;
    [_advertisementBackImageView addSubview:advertisementImageView];
    
    NSString *tmp = NSTemporaryDirectory();
    NSString *tmpPath = [tmp stringByAppendingPathComponent:ADVERTISEMENT_GUID];
    NSString *tmpPathIndex = [tmpPath stringByAppendingPathComponent:@"index_files"];
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tmpPathIndex error:nil];
    for (NSString *fileName in files) {
        NSRange jpgRange = [fileName rangeOfString:@".jpg"];
        NSRange pngRange = [fileName rangeOfString:@".png"];
        if (jpgRange.length > 0 || pngRange.length > 0) {
            NSString *imagePath = [tmpPathIndex stringByAppendingPathComponent:fileName];
            [advertisementImageView setImage:[UIImage imageWithContentsOfFile:imagePath]];
        }
    }

}

- (void)hiddenAdvertisementImageView
{
    _advertisementBackImageView.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
