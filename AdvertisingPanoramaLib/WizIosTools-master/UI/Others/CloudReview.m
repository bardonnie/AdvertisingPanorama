//
//  CloudReview.m
//  Wiz
//
//  Created by wiz on 12-2-21.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "CloudReview.h"

@implementation CloudReview  
static CloudReview* _sharedReview = nil;  
+(CloudReview*)sharedReview  
{  
    @synchronized([CloudReview class])  
    {  
        if (!_sharedReview)  
            _sharedReview = [[CloudReview alloc] init];
        
        return _sharedReview;  
    }  
}
- (id) init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
+(id)alloc
{  
    @synchronized([CloudReview class])
    {  
        NSAssert(_sharedReview == nil, @"Attempted to allocate a second instance of a singleton.");
        _sharedReview = [super alloc];  
        return _sharedReview;  
    }  
    
    return nil;  
}  
-(void)reviewFor:(int)appleID  
{  
    m_appleID = appleID;  
    BOOL neverRate = NO;
    if(neverRate != YES) {  
        //Show alert here  
        UIAlertView *alert;  
       
        alert = [[UIAlertView alloc] initWithTitle:WizStrRateWizNote 
                                           message:NSLocalizedString(@"Please rate WizNote",nil)  
                                          delegate: self  
                                 cancelButtonTitle:WizStrCancel  
                                 otherButtonTitles: NSLocalizedString(@"Rate now",nil),  nil];  
        [alert show];  
    }  
}  
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex  
{  
    if (buttonIndex == 1)  
    {  
        [self doReviewFor:m_appleID];
    }  
}

- (void) doReviewFor:(int) appleID
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"neverRate"];
    NSString *str = [NSString stringWithFormat:
                     @"itms-apps://itunes.apple.com/app/id%d",
                     appleID];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}
@end