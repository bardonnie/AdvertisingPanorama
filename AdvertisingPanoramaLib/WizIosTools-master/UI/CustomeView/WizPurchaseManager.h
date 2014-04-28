//
//  WizPurchaseManager.h
//  WizNote
//
//  Created by dzpqzb on 13-5-22.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface WizNoteProduct : NSObject
@property (nonatomic, strong) NSString* identifier;
@property (nonatomic, strong) NSString* pricer;
@property (nonatomic, strong) NSString* localizedDescript;
@property (nonatomic, strong) NSString* timeType;
+ (WizNoteProduct*) iphoneMonthlyProduct;
+ (WizNoteProduct*) iphoneYearlyProduct;
+ (WizNoteProduct*) ipadMonthlyProduct;
+ (WizNoteProduct*) ipadYearlyProduct;
@end

@interface WizPurchaseManager : NSObject{
    BOOL paySucceed;
}
@property BOOL paySucceed;

+ (id) shareInstance;
+ (NSArray*) wiznoteProProductKey;
- (void) requestAllProduct;
- (void) purchaseProductByKey:(NSString*)key;

@end
