//
//  WizShareToMailCtrl.m
//  WizIphone7
//
//  Created by zhao on 3/26/14.
//  Copyright (c) 2014 dzpqzb inc. All rights reserved.
//

#import "WizShareToEmailCtrl.h"

#define cellHight 46
#define OFFSET (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)?120:220)

@interface WizShareToEmailCtrl (){
}

@end

@implementation WizShareToEmailCtrl

@synthesize group,documentGuid;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        isBoxOpen = NO;
        isSendMe = NO;
        isKeyboardDidShow = NO;
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(keyboardDidHide:)  name:UIKeyboardDidHideNotification object:nil];
        [center addObserver:self selector:@selector(keyboardDidShow:)  name:UIKeyboardDidShowNotification object:nil];
        [center addObserver:self selector:@selector(keyboardWillHide:)  name:UIKeyboardWillHideNotification object:nil];
        [center addObserver:self selector:@selector(keyboardWillShow:)  name:UIKeyboardWillShowNotification object:nil];
    }
    return self;
}

- (void)keyboardWillHide:(NSNotification *) notification
{
    isKeyboardDidShow = NO;
}

- (void)keyboardWillShow:(NSNotification *) notification
{
    isKeyboardDidShow = YES;
}

- (void)keyboardDidHide:(NSNotification *) notification
{
    keyboardHeight = 0;
    [self resetBgScrollViewContentSize];
}

- (void)keyboardDidShow:(NSNotification *) notification
{
    NSDictionary *info = [notification userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    keyboardHeight = keyboardSize.height;
    [self resetBgScrollViewContentSize];
}

- (void) resetBgScrollViewContentSize{
    if(!iPad){
        if (keyboardHeight > 252) {
            keyboardHeight = 310;
        }
    }
    float hight = textViewHight + cellHight*5 + keyboardHeight;
    if(iPad){
        if (hight < 1024) {
            hight = 1025;
        }
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && !isKeyboardDidShow) {
            [bgScrollView setContentSize:CGSizeMake(768, hight + 10 + keyboardHeight + 300)];
        } else if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation) &&isKeyboardDidShow){
            [bgScrollView setContentSize:CGSizeMake(768, hight - 200)];
        }else{
            [bgScrollView setContentSize:CGSizeMake(768, hight + 20)];
        }
    }else{
        if (hight < self.view.bounds.size.height) {
            hight = self.view.bounds.size.height + 1;
        }
        
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && !isKeyboardDidShow) {
            [bgScrollView setContentSize:CGSizeMake(320, hight + 110)];
        }else{
            [bgScrollView setContentSize:CGSizeMake(320, hight)];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    [self initNavigationView];
    [self initMainView];
    if (!DEVICE_VERSION_BELOW_7) {
        [self.navigationController.navigationBar setBarTintColor:WizColorByKind(ColorOfDefaultTintColor)];
    }
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
    {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationBarBackgound"] forBarMetrics:UIBarMetricsDefault];
    }
}

- (void)initNavigationView{
    UILabel *customLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [customLab setTextColor:[UIColor whiteColor]];
    [customLab setText:NSLocalizedString(@"Share by email", nil)];
    [customLab setFont:[UIFont systemFontOfSize:18]];
    customLab.backgroundColor = [UIColor clearColor];
    customLab.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = customLab;
    
    UIButton *leftBarBtnItem = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [leftBarBtnItem addTarget:self action:@selector(cancelMail) forControlEvents:UIControlEventTouchUpInside];
    [leftBarBtnItem setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [leftBarBtnItem setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc ]initWithCustomView:leftBarBtnItem]];
    
    UIButton *rightBarBtnItem = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    [rightBarBtnItem addTarget:self action:@selector(sendMail) forControlEvents:UIControlEventTouchUpInside];
    [rightBarBtnItem setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    [rightBarBtnItem setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc ]initWithCustomView:rightBarBtnItem]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.group = [[WizAccountManager defaultManager] groupFroKbguid:self.group.guid accountUserId:self.group.accountUserId];
    if (!self.group.mywizEmail) {
        NSString *defaultMywizEmail =[[WizSettings defaultSettings] mywizEmailForAccount:self.group.accountUserId];
        [expandBtn setTitle:defaultMywizEmail forState:UIControlStateNormal];
    }else{
        [expandBtn setTitle:self.group.mywizEmail forState:UIControlStateNormal];
    }
    textField3.text = self.group.accountUserId;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [center removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [center removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [center removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void) initMainView{
    bgScrollView = [[WizScrollView alloc] initWithFrame:self.view.bounds];
    bgScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    bgScrollView.alwaysBounceHorizontal = NO;
    bgScrollView.delegate = self;
    [bgScrollView setContentSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height + 1)];
    [self.view addSubview:bgScrollView];
    [self initLine1View];
    [self initLine2View];
    [self initLine3View];
    [self initLine4View];
    [self initExpandBtn];
    
    textview = [[UITextView alloc] initWithFrame:CGRectMake(20.0f, CGRectGetMaxY(bgLine4View.frame)+2, self.view.bounds.size.width - 40, 300)];
    textview.delegate = self;
    textview.text = NSLocalizedString(@"Content", nil);
    textview.textColor = [UIColor grayColor];
    textview.font = [UIFont systemFontOfSize:18.0f];
    textview.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleBottomMargin;
    [bgScrollView addSubview:textview];
}

- (void) initLine1View{
    bgLine1View = [[UIView alloc] initWithFrame:CGRectMake(20.0, 0.0f, self.view.bounds.size.width - 20 - 20, cellHight)];
    bgLine1View.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    label.textColor = [UIColor colorWithHexHex:0x8e8d93];
    label.text = NSLocalizedString(@"To:", nil);
    
    CGRect textFieldRect = CGRectMake(CGRectGetMaxX(label.frame), 0.0f, self.view.bounds.size.width - 80 - 85, cellHight);
    textField1 = [[UITextField alloc] initWithFrame:textFieldRect];
    textField1.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    textField1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField1.returnKeyType = UIReturnKeyDone;
    textField1.clearButtonMode = YES;
    textField1.delegate = self;
    
    btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    btn1.frame = CGRectMake(CGRectGetMaxX(textField1.frame), 5, 60, 40);
    [btn1 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [btn1 setImage:[UIImage imageNamed:@"addpeople"] forState:UIControlStateNormal];
    [btn1 setImage:[UIImage imageNamed:@"addpeople_selected"] forState:UIControlStateHighlighted];
    btn1.tag = 1000;
    
    [bgLine1View addSubview:label];
    [bgLine1View addSubview:textField1];
    [bgLine1View addSubview:btn1];
    
    [bgScrollView addSubview:bgLine1View];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(textField1.frame), self.view.bounds.size.width - 20, 1.0)];
    line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    line.backgroundColor = [UIColor colorWithHexHex:0xc7c7c7];
    [bgLine1View addSubview:line];
}

- (void) initLine2View{
    bgLine2View = [[UIView alloc] initWithFrame:CGRectMake(20.0, CGRectGetMaxY(bgLine1View.frame), self.view.bounds.size.width - 20 - 20, cellHight)];
    bgLine2View.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 80, 40)];
    label.textColor = [UIColor colorWithHexHex:0x8e8d93];
    label.text = NSLocalizedString(@"Send copy to me", nil);
    
    CGRect textFieldRect = CGRectMake(CGRectGetMaxX(label.frame), 0.0f, self.view.bounds.size.width - 80 - 85, cellHight);
    textField2 = [[UITextField alloc] initWithFrame:textFieldRect];
    textField2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField2.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    textField2.returnKeyType = UIReturnKeyDone;
    textField2.clearButtonMode = YES;
    textField2.delegate = self;
    textField2.userInteractionEnabled = NO;
    
    btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(CGRectGetMaxX(textField2.frame), 5, 60, 40);
    btn2.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [btn2 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [btn2 setImage:[UIImage imageNamed:@"sendme"] forState:UIControlStateNormal];
    btn2.tag = 1001;
    
    [bgLine2View addSubview:label];
    [bgLine2View addSubview:textField2];
    [bgLine2View addSubview:btn2];
    
    [bgScrollView addSubview:bgLine2View];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(textField2.frame) + 1, self.view.bounds.size.width - 20, 1.0)];
    line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    line.backgroundColor = [UIColor colorWithHexHex:0xc7c7c7];
    [bgLine2View addSubview:line];
}

- (void) initLine3View{
    bgLine3View = [[UIView alloc] initWithFrame:CGRectMake(20.0, CGRectGetMaxY(bgLine2View.frame), self.view.bounds.size.width - 20 - 20, cellHight)];
    bgLine3View.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 80, 40)];
    label.textColor = [UIColor colorWithHexHex:0x8e8d93];
    label.text = NSLocalizedString(@"Sender", nil);
    
    CGRect textFieldRect = CGRectMake(CGRectGetMaxX(label.frame), 0.0f, self.view.bounds.size.width - 80 - 85, cellHight);
    textField3 = [[UITextField alloc] initWithFrame:textFieldRect];
    textField3.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField3.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    textField3.returnKeyType = UIReturnKeyDone;
    textField3.clearButtonMode = YES;
    textField3.delegate = self;
    textField3.userInteractionEnabled = NO;
    
    btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn3.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    btn3.frame = CGRectMake(CGRectGetMaxX(textField3.frame), 5, 60, 40);
    [btn3 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [btn3 setImage:[UIImage imageNamed:@"tagBoxOpen"] forState:UIControlStateNormal];
    btn3.tag = 1002;
    
    [bgLine3View addSubview:label];
    [bgLine3View addSubview:textField3];
    [bgLine3View addSubview:btn3];
    
    [bgScrollView addSubview:bgLine3View];
    
    bline = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(textField3.frame) + 1, self.view.bounds.size.width - 20, 1.0)];
    bline.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    bline.backgroundColor = [UIColor colorWithHexHex:0xc7c7c7];
    [bgLine3View addSubview:bline];
}

- (void)initExpandBtn{
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(60, CGRectGetMaxY(textField3.frame) + 1, self.view.bounds.size.width - 80, 1.0)];
    line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    line.backgroundColor = [UIColor colorWithHexHex:0xc7c7c7];
    [bgLine3View addSubview:line];
    
    expandBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    expandBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    expandBtn.frame = CGRectMake(100, CGRectGetMaxY(bgLine3View.frame), self.view.bounds.size.width - 100 - 20, 94/2);
    [expandBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [expandBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    expandBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    expandBtn.tag = 1003;
    expandBtn.hidden = YES;
    [bgScrollView addSubview:expandBtn];
}

- (void) initLine4View{
    bgLine4View = [[UIView alloc] initWithFrame:CGRectMake(20.0, CGRectGetMaxY(bgLine3View.frame), self.view.bounds.size.width - 20 - 20, cellHight)];
    bgLine4View.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 80, 40)];
    label.textColor = [UIColor colorWithHexHex:0x8e8d93];
    label.text = NSLocalizedString(@"Subject:", nil);
    
    CGRect textFieldRect = CGRectMake(CGRectGetMaxX(label.frame), 0.0f, self.view.bounds.size.width - 115, cellHight);
    textField4 = [[UITextField alloc] initWithFrame:textFieldRect];
    textField4.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField4.returnKeyType = UIReturnKeyDone;
    textField4.clearButtonMode = YES;
    textField4.delegate = self;
    
    [bgLine4View addSubview:label];
    [bgLine4View addSubview:textField4];
    [bgScrollView addSubview:bgLine4View];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(textField4.frame) + 1, self.view.bounds.size.width - 20, 1.0)];
    line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    line.backgroundColor = [UIColor colorWithHexHex:0xc7c7c7];
    [bgLine4View addSubview:line];
}

- (void)feedback:(NSString *)message{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:WizStrOK otherButtonTitles:nil];
    [alert show];
}

- (void)cancelMail{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)sendMail{
    if (![Reachability reachabilityForInternetConnection].isReachable) {
        [self feedback:NSLocalizedString(@"The internet is unavailable ,check it!",nil)];
        return;
    }
    if ([textField1.text.trim isBlock]) {
        [self feedback:NSLocalizedString(@"Recipients can not be empty!",nil)];
        return;
    }
    if (![self validateEmailString]) {
        [self feedback:NSLocalizedString(@"The format of email is illegal!",nil)];
        return;
    }
    [self sendEmailUrl];
}

- (void) buttonClick:(id)sender{
    UIButton *btn = (UIButton* )sender;
    switch (btn.tag) {
        case 1000:{
            WizContactsMultiPickerCtrl *controller = [[WizContactsMultiPickerCtrl alloc]init];
            controller.delegate = self;
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
            navController.modalPresentationStyle = UIModalPresentationPageSheet;
            [self presentModalViewController:navController animated:YES];
        }
            break;
        case 1001:
            if (!isSendMe) {
                [btn setImage:[UIImage imageNamed:@"sendme_selected"] forState:UIControlStateNormal];
                isSendMe = YES;
            }else{
                [btn setImage:[UIImage imageNamed:@"sendme"] forState:UIControlStateNormal];
                isSendMe = NO;
            }
            break;
        case 1002:
            if (!isBoxOpen) {
                [btn setImage:[UIImage imageNamed:@"tagBoxOff"] forState:UIControlStateNormal];
                bgLine4View.frame = CGRectSetY(bgLine4View.frame, CGRectGetMaxY(expandBtn.frame));
                textview.frame = CGRectSetY(textview.frame, CGRectGetMaxY(bgLine4View.frame) + 2);
                bline.frame = CGRectSetY(bline.frame, CGRectGetMaxY(bline.frame) + cellHight);
                isBoxOpen = YES;
                expandBtn.hidden = NO;
            }else{
                isBoxOpen = NO;
                bgLine4View.frame = CGRectSetY(bgLine4View.frame, CGRectGetMaxY(bgLine3View.frame));
                textview.frame = CGRectSetY(textview.frame, CGRectGetMaxY(bgLine4View.frame) + 2);
                bline.frame = CGRectMake(0, CGRectGetMaxY(textField3.frame) + 1, self.view.bounds.size.width - 20, 1.0);
                [btn setImage:[UIImage imageNamed:@"tagBoxOpen"] forState:UIControlStateNormal];
                expandBtn.hidden = YES;
            }
            break;
        case 1003:
        {
            NSString *temp = expandBtn.titleLabel.text;
            [expandBtn setTitle:textField3.text forState:UIControlStateNormal];
            textField3.text = temp;
        }
            break;
        default:
            break;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (bgScrollView.contentOffset.y < (-100)) {
        [selectedTextField resignFirstResponder];
        [subjectTextView resignFirstResponder];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    lastContentOffset = scrollView.contentOffset.y;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    if (lastContentOffset < scrollView.contentOffset.y && isKeyboardDidShow) {
        [self resetBgScrollViewContentSize];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    selectedTextField = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [selectedTextField resignFirstResponder];
    return NO;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [textView flashScrollIndicators];
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(frame.size.width, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraintSize];
    textView.scrollEnabled = NO;
    textViewHight = size.height;
    textView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, textViewHight);
    CGRect caretRect = [textView caretRectForPosition:textView.selectedTextRange.end];
    if (!iPad) {
        [bgScrollView setContentOffset:CGPointMake(0, frame.origin.y + CGRectGetMaxY(caretRect) - OFFSET + 64) animated:YES];
    }else{
        [bgScrollView setContentOffset:CGPointMake(0, frame.origin.y + CGRectGetMaxY(caretRect) - OFFSET - 100) animated:YES];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textview.text isEqualToString:NSLocalizedString(@"Content", nil)]) {
        textview.text = @"";
    }
    
    subjectTextView = textView;
    subjectTextView.textColor = [UIColor blackColor];
    CGRect frame = textView.frame;
    CGRect caretRect = [textView caretRectForPosition:textView.selectedTextRange.end];
    [bgScrollView setContentOffset:CGPointMake(0, frame.origin.y + CGRectGetMaxY(caretRect) - OFFSET) animated:YES];
}

#pragma mark - WizContactsMultiPickerCtrlDelegate
- (void)contactsMultiPickerController:(WizContactsMultiPickerCtrl*)picker didFinishPickingDataWithInfo:(NSArray*)data
{
    if(![textField1.text.trim isBlock]){
        textField1.text = [textField1.text.trim stringByAppendingString:[NSString stringWithFormat:@",%@",[data componentsJoinedByString:@","]]];
    }else{
        textField1.text = [data componentsJoinedByString:@","];
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void)contactsMultiPickerControllerDidCancel:(WizContactsMultiPickerCtrl*)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (BOOL) validateEmailString{
    NSString *emailStr = textField1.text.trim;
    NSArray *arr = [emailStr componentsSeparatedByString:@","];
    for (NSString *email in arr) {
        if (![self isValidateEmail:email]) {
            return NO;
        }
    }
    return YES;
}

- (void)sendEmailUrl{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlStr = [self getSendEmailUrl];
        if (!self.group.guid) {
            self.group.guid = [[WizSettings defaultSettings]personalKbGuid:self.group.accountUserId];
        }
        
        NSString *cc_to_self;
        NSString *subject;
        NSString *note;
        if (isSendMe) {
            cc_to_self = @"true";
        }else{
            cc_to_self = @"false";
        }
        
        if (![textField4.text.trim isBlock]) {
            subject = textField4.text;
        }else{
            subject = @"";
        }
        
        if (![textview.text.trim isBlock]) {
            note = textview.text;
        }else{
            note = @"";
        }

        WizTokenAndKapiurl* token = [[WizTokenManger shareInstance] tokenUrlForAccountUserId:self.group.accountUserId kbguid:self.group.guid error:nil];
        NSString *post = [NSString stringWithFormat:@"kb_guid=%@&document_guid=%@&token=%@&mail_to=%@&subject=%@&cc_to_self=%@&reply_to=%@&note=%@&api_version=%d&client_type=ios",self.group.guid,self.documentGuid,token.token,textField1.text,textField4.text,cc_to_self,textField3.text,note, 4];
        
        NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:urlStr]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        NSURLResponse* response = [[NSURLResponse alloc] init];
        NSError* error = nil;
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        SBJsonParser* parser = [[SBJsonParser alloc]init];
        NSDictionary* dictionary = [parser objectWithData:returnData];
        NSInteger returnCode = [[dictionary objectForKey:@"return_code"] integerValue];
        NSString *return_message = [dictionary objectForKey:@"return_message"];
        [self sendStatusCode:returnCode message:return_message];
    });
}

- (void) sendStatusCode:(NSInteger)returnCode message:(NSString *)message{
    MULTIMAIN(^{
        if (returnCode == 200) {
            [SVProgressHUD showImage:[UIImage imageNamed:@"success.png"] status:NSLocalizedString(@"发送成功！", nil)];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [SVProgressHUD showErrorWithStatus:message];
        }
    });
}

- (NSString *)getSendEmailUrl{
    NSURL *url = [[WizNetworkEngine shareEngine] wizEmailUrl];
    NSURLRequest*  request = [NSURLRequest requestWithURL:url];
    NSURLResponse* response = [[NSURLResponse alloc] init];
    NSData* data =  [NSURLConnection sendSynchronousRequest:request
                                          returningResponse:&response error:nil];
    NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString* groupKapiUrl = self.group.kApiurl;
    if (!groupKapiUrl) {
        groupKapiUrl = [[[WizSettings defaultSettings] accountAttributes:self.group.accountUserId] objectForKey:@"kapi_url"];
    }
    str = [str stringByReplacingOccurrencesOfString:@"{ks_host}" withString:((NSURL*)[NSURL URLWithString:groupKapiUrl]).host];
    return str;
}

@end
