//
//  WizShareToMailCtrl.h
//  WizIphone7
//
//  Created by zhao on 3/26/14.
//  Copyright (c) 2014 dzpqzb inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "WizTreeViewController.h"
#import "WizScrollView.h"
#import "WizContactsMultiPickerCtrl.h"
#import "SBJsonParser.h"
#import "WizTokenManger.h"
#import "SVProgressHUD.h"

@interface WizShareToEmailCtrl : UIViewController <UITextFieldDelegate,UITextViewDelegate,WizContactsMultiPickerCtrlDelegate>{
    UITextField *selectedTextField;
    UITextView *textview , *subjectTextView;
    WizScrollView *bgScrollView;
    BOOL isBoxOpen;
    BOOL isSendMe, isKeyboardDidShow;
    float textViewHight;
    
    UIView *bgLine1View, *bgLine2View, *bgLine3View ,*bgLine4View;
    UITextField *textField1,*textField2,*textField3,*textField4;
    UIButton *btn1,*btn2,*btn3,*expandBtn;
    UILabel *bline;
    float lastContentOffset,keyboardHeight;
}

@property (nonatomic, strong) WizGroup* group;
@property (nonatomic, strong) NSString* documentGuid;

@end
