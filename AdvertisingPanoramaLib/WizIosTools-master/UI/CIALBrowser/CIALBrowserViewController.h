//
//  CIALBrowserViewController.h
//  CIALBrowser
//
//  Created by Sylver Bruneau on 01/09/10.
//  Copyright 2011 CodeIsALie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface CIALBrowserViewController : UIViewController <UIWebViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UIPrintInteractionControllerDelegate, UIAlertViewDelegate> {
    UIToolbar *toolBar;
    UIBarButtonItem *backButtonItem;
    UIBarButtonItem *forwardButtonItem;
    UIBarButtonItem *actionButtonItem;
    UIButton *stopReloadButton;
    UIButton *bookmarkButton;
    UINavigationItem *navigationItem;
    UIBarButtonItem *closeButtonItem;
    UIBarButtonItem *doneButtonItem;
    UITextField *locationField;
    UIWebView *webView;
    UINavigationBar *navigationBar;
    NSURL *_urlToLoad;
    NSURL *_urlToHandle;
    
    UIPopoverController *_bookmarkPopoverController;
    UIPopoverController *_addBookmarkPopoverController;
    UIActionSheet *_actionActionSheet;
    UIActionSheet *_longPressActionSheet;
    
    // Buttons Indexes for UIActionSheet (long tap)
    NSInteger copyButtonIndex;
    NSInteger openLinkButtonIndex;
    
    // Buttons Indexes for UIActionSheet (action button)
    NSInteger addBookmarkButtonIndex;
    NSInteger sendUrlButtonIndex;
    NSInteger printButtonIndex;
    NSInteger openWithSafariButtonIndex;
    
    UIPrintInteractionController *printInteraction;
    
    NSMutableURLRequest* req;
}

+ (CIALBrowserViewController *)modalBrowserViewControllerWithURL:(NSURL *)url;

@property (nonatomic, strong, setter=loadURL:) NSURL *url;
@property (nonatomic, strong) UIActionSheet *actionActionSheet;
@property (nonatomic, strong) NSString* navTitle;
@property (getter = isModal) BOOL modal;
@property BOOL enabledSafari;
@property BOOL isViewAttachment;

- (id)initWithURL:(NSURL *)url;


@end
