//
//  AD_PartCell.h
//  AdvertisingPanorama
//
//  Created by mac on 14-2-28.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AD_PartCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *articleTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *articleDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *dataLabel;
@property (weak, nonatomic) IBOutlet UILabel *reviewNumLabel;
@property (weak, nonatomic) IBOutlet UIImageView *reviewImageView;

@end
