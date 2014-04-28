//
//  WizBizUserTokenierTextView.h
//  WizNote
//
//  Created by dzpqzb on 13-5-13.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WizBizUserTokenierTextView : UITextView
@property (nonatomic, strong) NSString* bizGuid;
- (id) initWithBizGuid:(NSString*)bizGuid;
@end
