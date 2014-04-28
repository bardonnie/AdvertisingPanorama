//
//  AD_PartCell.m
//  AdvertisingPanorama
//
//  Created by mac on 14-2-28.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//

#import "AD_PartCell.h"

@implementation AD_PartCell

@synthesize thumbnailImageView, articleTitleLabel, articleDetailLabel, reviewNumLabel, reviewImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
