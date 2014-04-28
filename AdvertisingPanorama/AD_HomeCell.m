//
//  AD_HomeCell.m
//  AdvertisingPanorama
//
//  Created by mac on 14-2-27.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//

#import "AD_HomeCell.h"

@implementation AD_HomeCell

@synthesize homeCellTitle, homeCellDetail, homeCellDetailImage;

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
