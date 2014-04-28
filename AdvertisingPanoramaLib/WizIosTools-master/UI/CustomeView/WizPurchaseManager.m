//
//  WizPurchaseManager.m
//  WizNote
//
//  Created by dzpqzb on 13-5-22.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizPurchaseManager.h"
#import <StoreKit/StoreKit.h>
#import "MKNetworkKit.h"
#import "SBJson.h"

#define WizPurchaseVerifierHost @"pay.wiz.cn"

@implementation WizNoteProduct
@synthesize identifier = _identifier;
@synthesize localizedDescript = _localizedDescript;
@synthesize pricer = _pricer;
@synthesize timeType = _timeType;
-(id) initWithIdentifer:(NSString*)identifier  pricer:(NSString*)pricer timeType:(NSString*) timeType
{
    self = [super init];
    if(self)
    {
        _identifier = identifier;
        _pricer = pricer;
        _timeType = [NSString stringWithFormat:@"/%@",NSLocalizedString(timeType, nil)] ;
    }
    return self;
}

+ (WizNoteProduct*) iphoneMonthlyProduct
{
    WizNoteProduct* a = [[WizNoteProduct alloc] initWithIdentifer:@"cn.wiz.wiznote.iphone.pro.monthly" pricer:@"¥12" timeType:@"Month"];
    return a;
}


+ (WizNoteProduct*) iphoneYearlyProduct
{
    WizNoteProduct* a = [[WizNoteProduct alloc] initWithIdentifer:@"cn.wiz.wiznote.iphone.pro.yearly" pricer:@"¥98" timeType:@"Year"];
    return a;
}

+ (WizNoteProduct*) ipadMonthlyProduct
{
    WizNoteProduct* a = [[WizNoteProduct alloc] initWithIdentifer:@"cn.wiz.wiznote.ipad.pro.monthly" pricer:@"¥12" timeType:@"Month"];
    return a;
}


+ (WizNoteProduct*) ipadYearlyProduct
{
    WizNoteProduct* a = [[WizNoteProduct alloc] initWithIdentifer:@"cn.wiz.wiznote.ipad.pro.yearly" pricer:@"¥98" timeType:@"Year"];
    return a;
}

@end

typedef enum {
   WizPurchaseServerResponseAlreadyPurchase = 345,
    WizPurchaseServerResponseNetworkError = 346,
    WizPurchaseServerResponseInvailed = 347,
    WizPurchaseServerResponseSucceedButNotSave = 348,
    WizPurchaseServerResponseSucceed = 200
}WizPurchaseServerResponseStatus;

@interface WizPurchaseManager() <SKPaymentTransactionObserver, SKProductsRequestDelegate, WizVerifyAccountDelegate>

@end

@implementation WizPurchaseManager
@synthesize paySucceed;
- (void) dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}
- (void) paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction* transaction in transactions) {
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}
- (id)init
{
    self = [super init];
    if (self) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}
+ (id) shareInstance
{
    static WizPurchaseManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [WizPurchaseManager new];
    });
    return manager;
}
+ (NSArray*) wiznoteProProductKey
{
    return  @[@"cn.wiz.wiznote.ipad.pro.monthly", @"cn.wiz.wiznote.ipad.pro.yearly"];
}

- (void) requestAllProduct
{

    
    if ([SKPaymentQueue canMakePayments]) {
        SKProductsRequest* request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:[WizPurchaseManager wiznoteProProductKey]]];
        request.delegate = self;
        [request start];
    }
    else
    {
        [WizGlobals reportErrorWithString:NSLocalizedString(@"Can't purchase!", nil)];
    }
}

- (void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    
}

- (void) purchaseProductByKey:(NSString*)key
{
    self.paySucceed = YES;
    SKMutablePayment* payment = [[SKMutablePayment alloc] init];
    payment.productIdentifier = key;
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

- (void) didVerifyAccountFailed:(NSError *)error
{
    
}

- (void) didVerifyAccountSucceed:(NSString *)userId password:(NSString *)password kbguid:(NSString *)kbguid userGuid:(NSString *)userGuid
{
    
}
- (void) didPurchaseScceed
{
    NSString* accountUserId = [[WizAccountManager defaultManager] activeAccountUserId];
    NSString* accountPassword = [[WizAccountManager defaultManager] activeAccountPassword];
    [[WizSettings defaultSettings] setAccountType:WizProTypeLevel1 accountUserId:accountUserId];
    WizVerifyAccountOperation* verify = [[WizVerifyAccountOperation alloc] initWithAccount:accountUserId password:accountPassword];
    verify.delegate = self;
    [[NSOperationQueue backGroupQueue] addOperation:verify];
    [WizGlobals reportMessage:NSLocalizedString(@"Congratulations， you are vip now.", nil) withTitle:NSLocalizedString(@"", nil)];
}


- (void) purchaseEnd:(NSDictionary*)dictionary
{
    int code = [dictionary[@"return_code"] integerValue];
    NSString* message = dictionary[@"return_message"];
    if (code == WizPurchaseServerResponseSucceed) {
        [self didPurchaseScceed];
    }
    else
    {
        [WizGlobals reportWarningWithString:message];
    }
    self.paySucceed = NO;
}

- (void) postRecipt:(SKPaymentTransaction*)transaction
{

    NSData* data = transaction.transactionReceipt;
    NSString* accountUserId = [[WizAccountManager defaultManager] activeAccountUserId];
    NSString* accountPassword = [[WizAccountManager defaultManager] activeAccountPassword];
    [[WizSettings defaultSettings] setAccountType:WizProTypeLevel1 accountUserId:accountUserId];
    WizVerifyAccountOperation* verify = [[WizVerifyAccountOperation alloc] initWithAccount:accountUserId password:accountPassword];
    verify.delegate = self;
    [[NSOperationQueue backGroupQueue] addOperation:verify];
    
    //
    MKNetworkEngine* engine = [[MKNetworkEngine alloc] initWithHostName:WizPurchaseVerifierHost];
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    params[@"receipt"] = [data base64EncodedString];
    NSString* userId = [[WizAccountManager defaultManager] activeAccountUserId];
    
    NSDictionary* attribute = [[WizSettings defaultSettings] accountAttributes:userId];
    
    NSString* userGuid = [attribute userGuid];
    userGuid = userGuid?userGuid:@"";
    params[@"user_guid"] = userGuid;
    params[@"client_type"] = @"ios";
    params[@"user_id"] = userId;
    MKNetworkOperation* op = [engine operationWithPath:@"/in_app_purchase" params:params httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        [self purchaseEnd:completedOperation.responseJSON];
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
    }];
    [engine enqueueOperation:op];
   [[SKPaymentQueue defaultQueue] finishTransaction:transaction]; 
}
- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}
- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled) {
        // Optionally, display an error here.
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    NSError* error = (NSError*) transaction.error;
    if ([error.domain isEqualToString:@"SKErrorDomain"] && error.code == 2) {
    }
    else
    {
        [WizGlobals reportError:error];
    }
    self.paySucceed = NO;
}
- (void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction* transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStateFailed:
            {
                [self failedTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStatePurchased:
                [self postRecipt:transaction];
                break;
            case SKPaymentTransactionStatePurchasing:
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

@end
