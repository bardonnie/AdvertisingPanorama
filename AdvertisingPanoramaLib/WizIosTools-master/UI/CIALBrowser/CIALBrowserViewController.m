//
//  CIALBrowserViewController.m
//  CIALBrowser
//
//  Created by Sylver Bruneau on 01/09/10.
//  Copyright 2011 CodeIsALie. All rights reserved.
//
#import "WizNetworkEngine.h"
#import "CIALBrowser.h"
#import "CIALBrowserViewController.h"
#import "UIWebViewAdditions.h"
#import "UnpreventableUILongPressGestureRecognizer.h"
#import "UIWebView+WizWebViewAddition.h"

@interface CIALBrowserViewController ()

- (void)addBookmark;
- (void)updateLoadingStatus;
- (void)longPressRecognized:(UILongPressGestureRecognizer *)gestureRecognizer;

- (void)goBack:(id)sender;
- (void)goForward:(id)sender;
- (void)reloadOrStop:(id)sender;
- (void)loadURL:(NSURL *)url;

- (void)dismiss:(id)sender;
@end

@implementation CIALBrowserViewController
@synthesize navTitle;
@synthesize actionActionSheet = _actionActionSheet;
@synthesize modal = _modal;
@synthesize enabledSafari = _enabledSafari;
@synthesize isViewAttachment;

+ (CIALBrowserViewController *)modalBrowserViewControllerWithURL:(NSURL *)url
{
    CIALBrowserViewController *controller = [[self alloc] initWithURL:url];
    controller.modal = YES;
    return controller;
}
- (void) addBookmark
{
    
}
/* DELETEME: default is nil
- (id)init {
    self = [super init];
    if (self) {
        _urlToLoad = nil;
        req = nil;
    }
    return self;
}
*/

- (id)initWithURL:(NSURL *)url  {
    self = [super init];
    if (self) {
        [self setURL:url];
        self.isViewAttachment = NO;
    }
    return self;
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
        // titleView
            
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTitle:WizStrCancel target:self action:@selector(backToNote)];
    if ([WizGlobals WizDeviceIsPad]) {
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTitle:NSLocalizedString(@"Back", nil) target:self action:@selector(backToNote)];
    }
        
    if (!isViewAttachment) {
        locationField = [[UITextField alloc] initWithFrame:CGRectMake(37,7,246,31)];
        locationField.delegate = self;
        locationField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        locationField.textColor = [UIColor colorWithRed:102.0/255 green:102.0/255 blue:102.0/255 alpha:1.0];
        locationField.textAlignment = UITextAlignmentLeft;
        locationField.borderStyle = UITextBorderStyleRoundedRect;
        locationField.font = [UIFont fontWithName:@"Helvetica" size:15];
        locationField.autocorrectionType = UITextAutocorrectionTypeNo;
        locationField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        locationField.clearsOnBeginEditing = NO;
        
        locationField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        locationField.autocorrectionType = UITextAutocorrectionTypeNo;
        locationField.keyboardType = UIKeyboardTypeURL;
        locationField.returnKeyType = UIReturnKeyGo;
        
        locationField.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        // reloadButton
        stopReloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        stopReloadButton.bounds = CGRectMake(0, 0, 26, 30);
        [stopReloadButton setImage:[UIImage imageNamed:@"CIALBrowser.bundle/images/AddressViewReload.png"] forState:UIControlStateNormal];
        [stopReloadButton setImage:[UIImage imageNamed:@"CIALBrowser.bundle/images/AddressViewReload.png"] forState:UIControlStateHighlighted];
        stopReloadButton.showsTouchWhenHighlighted = NO;
        [stopReloadButton addTarget:self action:@selector(reloadOrStop:) forControlEvents:UIControlEventTouchUpInside];
        locationField.rightView = stopReloadButton;
        locationField.rightViewMode = UITextFieldViewModeUnlessEditing;
        
//        navigationItem.titleView = locationField;
    }else{
        navigationItem.title = navTitle;
    }
    
        if (self.isModal) {
            NSString *closeTitle = CIALBrowserLocalizedString(@"Close", nil);
            closeButtonItem = [[UIBarButtonItem alloc] initWithTitle:closeTitle style:UIBarButtonItemStyleBordered target:self action:@selector(dismiss:)];
            self.navigationItem.rightBarButtonItem = closeButtonItem;
        }
    
        // Toolbar
    if (!isViewAttachment) {
        NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:9];
        UIBarButtonItem *flexibleSpaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        backButtonItem = [UIBarButtonItem toolbarItemWithImage:WizImageByKind(ImageOfWebViewGoBackArrow) target:self action:@selector(goBack:)];
        forwardButtonItem =[UIBarButtonItem toolbarItemWithImage:WizImageByKind(ImageOfWebViewGoForwardArrow) target:self action:@selector(goForward:)];

        actionButtonItem = [UIBarButtonItem toolbarItemWithImage:WizImageByKind(BarIconShare) target:self action:@selector(actionButton:)];
        
        [buttons addObject:flexibleSpaceButtonItem];
        [buttons addObject:backButtonItem];
        [buttons addObject:flexibleSpaceButtonItem];
        [buttons addObject:forwardButtonItem];
        [buttons addObject:flexibleSpaceButtonItem];
        [buttons addObject:actionButtonItem];
        [buttons addObject:flexibleSpaceButtonItem];
        
        [self setToolbarItems:buttons animated:YES];
        [self.navigationController setToolbarHidden:NO animated:NO];    
    }
    
        // webView
        webView = [[UIWebView alloc] initWithFrame:CGRectSetOrigin(self.view.frame, CGPointZero)];
        webView.scalesPageToFit = YES;
        if ([[[WizNetworkEngine shareEngine]aboutWizNoteURL] isEqual:_urlToLoad]){
            webView.scalesPageToFit = NO;
        }
        webView.multipleTouchEnabled = YES;
        webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:webView];
//    }

    // Create a long press recognizer for handling links long press
    UnpreventableUILongPressGestureRecognizer *longPressRecognizer = [[UnpreventableUILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognized:)];
    longPressRecognizer.allowableMovement = 20;
    longPressRecognizer.minimumPressDuration = 1.0f;
    [webView addGestureRecognizer:longPressRecognizer];
}

- (void)backToNote
{
    if (iPad) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)dealloc {
    // Stop the spinner
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


#pragma mark -

- (void) viewDidLoad {
    [super viewDidLoad];
    
    webView.delegate = self;
    
    [self updateLoadingStatus];
    
    if (_urlToLoad) {
        [self loadURL:_urlToLoad];
    } else {
        [locationField becomeFirstResponder];
    }
}

#pragma mark -

- (void)loadURL:(NSURL *)url {
    if (!webView) {
        [self setURL:url];
        return;
    }
    if (!url) return;
    locationField.text = url.absoluteString;
    if ([url.absoluteString hasSuffix:@".avi"] ||
        [url.absoluteString hasSuffix:@".rm"] ||
        [url.absoluteString hasSuffix:@".rmvb"] ||
        [url.absoluteString hasSuffix:@".MP4"] ||
        [url.absoluteString hasSuffix:@".amr"]) {
        [self reportErrorWithString:NSLocalizedString(@"Does not support this format attachment.", nil)];
        return ;
    } else {
        if (!isViewAttachment) {
            [webView noNetworkConnection];
        }
        
        if([url.absoluteString hasPrefix:@"https://"] || [url.absoluteString hasPrefix:@"http://"]){
            [webView loadRequest:[NSURLRequest requestWithURL:url]];
            return;
        }
        
        NSData *data=[NSData dataWithContentsOfURL:url];
        if (data.length > 30 * 1024 * 1024) {
            [self reportErrorWithString:NSLocalizedString(@"暂不支持较大附件的打开！", nil)];
            return;
        }
        NSString *path = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentFilePath"];
        if (![self fileMIMEType:path]
            || [[path pathExtension] isEqualToString:@"zip"]
            || [[path pathExtension] isEqualToString:@"ziw"]
            || [[path pathExtension] isEqualToString:@"dmg"]) {
            [self reportErrorWithString:NSLocalizedString(@"Does not support this format attachment.", nil)];
            return ;
        }
        [webView loadData:data MIMEType:[self fileMIMEType:path] textEncodingName:@"UTF-8" baseURL:url];
        return ;
    }
}

- (void) reportErrorWithString:(NSString*)error
{
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:WizStrError message:error delegate:nil cancelButtonTitle:WizStrOK otherButtonTitles:nil];
    alert.delegate = self;
	[alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self backToNote];
}

- (NSString*) fileMIMEType:(NSString *) file{
    @try {
        NSString * lowercase = [[file pathExtension] lowercaseString];
        if ([ lowercase isEqualToString:@"java"]
            ||[lowercase isEqualToString:@"cpp"]
            ||[lowercase isEqualToString:@"mm"]
            ||[lowercase isEqualToString:@"m"]
            ||[lowercase isEqualToString:@"h"]
            ||[lowercase isEqualToString:@"c"]
            ||[lowercase isEqualToString:@"xml"]
            ||[lowercase isEqualToString:@"properties"]
            ||[lowercase isEqualToString:@"css"]
            ||[lowercase isEqualToString:@"html"]
            ||[lowercase isEqualToString:@"txt"]
            ||[lowercase isEqualToString:@"log"]
            ||[lowercase isEqualToString:@"crash"]
            ||[lowercase isEqualToString:@"eml"]
            ||[lowercase isEqualToString:@"plist"]
            ||[lowercase isEqualToString:@"p12"]
            ) {
            
            return @"text/plain";
        }
        if([file pathExtension]){ //当为rar时，返回nil
            CFStringRef ref = (__bridge CFStringRef)[file pathExtension];
            CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ref, NULL);
            CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
            NSString* str = (__bridge NSString *)MIMEType;
            CFRelease(UTI);
//        CFRelease(MIMEType);  // 有crash 如：为.dmg等格式时
//            NSLog(@"mimeType = %@",str);
            return str;
        }else{
            return nil;
        }
    }
    @catch (NSException *exception) {
        return nil;
    }
    @finally {
        
    }
}

- (void)goBack:(id) sender {
    [webView goBack];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateLocationField) object:nil];
    [self performSelector:@selector(updateLocationField) withObject:nil afterDelay:1.];
}

- (void)goForward:(id) sender {
    [webView goForward];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateLocationField) object:nil];
    [self performSelector:@selector(updateLocationField) withObject:nil afterDelay:1.];
}

- (void)reloadOrStop:(id) sender {
    if (webView.loading)
        [webView stopLoading];
    else [webView reload];
}

- (NSURL *)url {
    NSURL *url = [NSURL URLWithString:locationField.text];
    if (!url.scheme.length && locationField.text.length) url = [NSURL URLWithString:[@"http://" stringByAppendingString:locationField.text]];
    return url;
}

#pragma mark -
#pragma mark UITextField delegate

- (void)setURL:(NSURL *)url
{
    NSString *urlString = url.absoluteString;
    if ([urlString length]) {
        if (!url.scheme.length) {
            url = [NSURL URLWithString:[@"http://" stringByAppendingString:urlString]];
        }

        _urlToLoad = url;
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *) textField {
    NSURL *url = [NSURL URLWithString:locationField.text];
    
    // if user didn't enter "http", add it the the url
    if (!url.scheme.length) {
        url = [NSURL URLWithString:[@"http://" stringByAppendingString:locationField.text]];
    }
    
    [self loadURL:url];
    
    [locationField resignFirstResponder];
    
    return YES;
}

#pragma mark -

- (void) updateLocationField {
    NSString *location = webView.request.URL.absoluteString;
    if (location.length)
        locationField.text = webView.request.URL.absoluteString;
}

- (void) updateLoadingStatus {
    UIImage *image = nil;
    if (webView.loading) {
        image = [UIImage imageNamed:@"CIALBrowser.bundle/images/AddressViewStop.png"];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    } else {
        image = [UIImage imageNamed:@"CIALBrowser.bundle/images/AddressViewReload.png"];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    
    [stopReloadButton setImage:image forState:UIControlStateNormal];
    
    // update status of back/forward buttons
    backButtonItem.enabled = [webView canGoBack];
    forwardButtonItem.enabled = [webView canGoForward];
}

#pragma mark -
#pragma mark UIWebView delegate

- (BOOL)webView:(UIWebView *) sender shouldStartLoadWithRequest:(NSURLRequest *) request navigationType:(UIWebViewNavigationType) navigationType {
    if (isViewAttachment){
        return YES;
    }

    if ([request.URL.absoluteString isEqual:@"about:blank"])
        return NO;
    req = (NSMutableURLRequest *)request;
    return YES;
}

- (void) webViewDidStartLoad:(UIWebView *) sender {
    [self updateLoadingStatus];
}

- (void) webViewDidFinishLoad:(UIWebView *) sender {
    // Disable the defaut actionSheet when doing a long press

    [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitTouchCallout='none';"];
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateLocationField) object:nil];
    [self performSelector:@selector(updateLocationField) withObject:nil afterDelay:1.];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateLoadingStatus) object:nil];
    [self performSelector:@selector(updateLoadingStatus) withObject:nil afterDelay:1.];
}

- (void) webView:(UIWebView *)sender didFailLoadWithError:(NSError *) error {
    switch ([error code]) {
        case kCFURLErrorCancelled :
        {
            // Do nothing in this case
            break;
        }
        default:
        {
            [self reportErrorWithString:[error localizedDescription]];
            break;
        }
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateLocationField) object:nil];
    [self performSelector:@selector(updateLocationField) withObject:nil afterDelay:1.];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateLoadingStatus) object:nil];
    [self performSelector:@selector(updateLoadingStatus) withObject:nil afterDelay:1.];
}

#pragma mark actions -

- (void)dismiss:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark UIBarButtonItem functions

- (void)actionButton:(UIBarButtonItem *)button {
    if (printInteraction != nil) {
        [printInteraction dismissAnimated:YES];
        printInteraction = nil;
        // printInteraction is created by this actionSheet
        // if this button is tapped, make it disappear and don't create the actionSheet
        return;
    }
    
    // Create the actionSheet or make it disappear if needed
    if (!self.actionActionSheet) {
        self.actionActionSheet = [[UIActionSheet alloc] initWithTitle:[_urlToHandle.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                                         delegate:self
                                                cancelButtonTitle:nil
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:nil];
        self.actionActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        
        if (self.enabledSafari) {
            openWithSafariButtonIndex = [self.actionActionSheet addButtonWithTitle:NSLocalizedString(@"Open with Safari",@"")];
        } else {
            openWithSafariButtonIndex = -1;
        }
        
        self.actionActionSheet.cancelButtonIndex = [_actionActionSheet addButtonWithTitle:NSLocalizedString(@"Cancel",@"")];

    }
    if ([WizGlobals WizDeviceIsPad]) {
        [_actionActionSheet showFromBarButtonItem:actionButtonItem animated:YES];
    }else{
        [_actionActionSheet showInView:self.view];
    }
}

#pragma mark -
#pragma mark UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (openWithSafariButtonIndex == buttonIndex) {
        [[UIApplication sharedApplication] openURL:self.url];
    } 
    
    if (req != nil) {
        req = nil;
    }    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet == _longPressActionSheet)
    {
        _longPressActionSheet = nil;
    }
}


#pragma mark -
#pragma mark UILongPressGestureRecognizer handling

- (void)longPressRecognized:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gestureRecognizer locationInView:webView];
        
        // convert point from view to HTML coordinate system
        CGSize viewSize = [webView frame].size;
        CGSize windowSize = [webView windowSize];
        
        CGFloat f = windowSize.width / viewSize.width;
        if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.) {
            point.x = point.x * f;
            point.y = point.y * f;
        } else {
            // On iOS 4 and previous, document.elementFromPoint is not taking
            // offset into account, we have to handle it
            CGPoint offset = [webView scrollOffset];
            point.x = point.x * f + offset.x;
            point.y = point.y * f + offset.y;
        }
              
        // Load the JavaScript code from the Resources and inject it into the web page
        NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"CIALBrowser" ofType:@"bundle"]];

        NSString *path = [bundle pathForResource:@"JSTools" ofType:@"js"];
        NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        [webView stringByEvaluatingJavaScriptFromString: jsCode];
        
        // get the Tags at the touch location
        NSString *tags = [webView stringByEvaluatingJavaScriptFromString:
                          [NSString stringWithFormat:@"MyAppGetHTMLElementsAtPoint(%i,%i);",(NSInteger)point.x,(NSInteger)point.y]];
        
        NSString *tagsHREF = [webView stringByEvaluatingJavaScriptFromString:
                              [NSString stringWithFormat:@"MyAppGetLinkHREFAtPoint(%i,%i);",(NSInteger)point.x,(NSInteger)point.y]];
        
        NSString *tagsSRC = [webView stringByEvaluatingJavaScriptFromString:
                             [NSString stringWithFormat:@"MyAppGetLinkSRCAtPoint(%i,%i);",(NSInteger)point.x,(NSInteger)point.y]];
        NSLog(@"tags : %@",tags);
        NSLog(@"href : %@",tagsHREF);
        NSLog(@"src : %@",tagsSRC);
        
        NSString *url = nil;
        if ([tags rangeOfString:@",IMG,"].location != NSNotFound) {
            url = tagsSRC;
        }
        if ([tags rangeOfString:@",A,"].location != NSNotFound) {
            url = tagsHREF;
        }
        NSLog(@"url : %@",url);
        
//        NSArray *urlArray = [[url lowercaseString] componentsSeparatedByString:@"/"];
//        NSString *urlBase = nil;
//        if ([urlArray count] > 2) {
//            urlBase = [urlArray objectAtIndex:2];
//        }
        
        if ((url != nil) &&
            ([url length] != 0)) {
            // Release any previous request
            req = nil;
            // Save URL for the request
            _urlToHandle = [[NSURL alloc] initWithString:url];
            
            // ask user what to do
            _longPressActionSheet = [[UIActionSheet alloc] initWithTitle:[_urlToHandle.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                                                delegate:self
                                                       cancelButtonTitle:nil
                                                  destructiveButtonTitle:nil
                                                       otherButtonTitles:nil];
            _longPressActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
            
            openLinkButtonIndex = [_longPressActionSheet addButtonWithTitle:CIALBrowserLocalizedString(@"Open",@"")];
            copyButtonIndex = [_longPressActionSheet addButtonWithTitle:CIALBrowserLocalizedString(@"Copy",@"")];
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                CGPoint touchPosition = [gestureRecognizer locationInView:webView];
                [_longPressActionSheet showFromRect:CGRectMake(touchPosition.x, touchPosition.y, 1, 1)
                                             inView:webView
                                           animated:YES];
            } else {
                _longPressActionSheet.cancelButtonIndex = [_longPressActionSheet addButtonWithTitle:CIALBrowserLocalizedString(@"Cancel",@"")];
                [_longPressActionSheet showInView:self.view];
            }
        }        
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}


@end
