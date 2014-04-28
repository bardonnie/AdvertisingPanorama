//
//  WizAddressBook.h
//  WizIphone7
//
//  Created by zhao on 3/27/14.
//  Copyright (c) 2014 dzpqzb inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WizAddressBook : NSObject {
    NSInteger sectionNumber;
    NSInteger recordID;
    BOOL rowSelected;
    NSString *name;
    NSString *email;
    NSString *tel;
    UIImage *thumbnail;
}

@property NSInteger sectionNumber;
@property NSInteger recordID;
@property BOOL rowSelected;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *email;
@property (nonatomic) NSString *tel;
@property (nonatomic) UIImage *thumbnail;

@end
