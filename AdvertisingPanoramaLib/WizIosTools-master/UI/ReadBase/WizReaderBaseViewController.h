//
//  WizReaderBaseViewController.h
//  WizNote
//
//  Created by dzpqzb on 13-4-15.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WizSelectGroupViewController.h"
#import "WizReadTitleView.h"
#import "DocumentInfoViewController.h"
#import "WizWebView.h"
#import "WizReadTitleView.h"
#import "WizWebView.h"
#import "WizAttachmentsView.h"
#import "UIViewController+WizHelp.h"
#import "CIALBrowserViewController.h"
#import "UIWebView+WizTool.h"
#import "DocumentInfoViewController.h"
#import "WizFileManager.h"
#import  "MBProgressHUD.h"
#import "WizEnc.h"
#import "WizWorkOperation.h"
#import "WizReadDocumentOperation.h"
#import "MWPhotoBrowser.h"
#import <AVFoundation/AVFoundation.h>
#import "WizShareToEmailCtrl.h"

@protocol WizDocumentListDelegate <NSObject>

- (BOOL) documentListHasNexItem;
- (BOOL) documentListHasPreviousItem;
- (NSString*) documentListNextItem;
- (NSString*) documentListPreviousItem;
- (NSString*) documentListCurrentItem;
- (NSString*) documentListPreviousItemTitle;
- (NSString*) documentListNextItemTitle;
- (WizGroup*) documentListWizGroup;
@end

@protocol WizReadProtocol <NSObject>
@optional
- (void) editNote;
- (void) didDeletedCurrentDocument;
- (void) showDocumentInfoViewController:(DocumentInfoViewController*)infoVC;

@end

@interface WizReaderBaseViewController : UIViewController <
        WizSyncDownloadDelegate,
        UIWebViewDelegate,
        IMTWebViewProgressDelegate,
        UIActionSheetDelegate,
        MFMessageComposeViewControllerDelegate,
        WizAttachmentViewDelegate,
        WizReadTitleViewDelegate,
        UIPopoverControllerDelegate,
        WizReadProtocol,
        WizWorkDelegate,
        MWPhotoBrowserDelegate,
        WizLoadDocumentOperationDelegate,
        AVAudioPlayerDelegate>
{
@public
    UIBarButtonItem* editNoteItem;
    UIBarButtonItem* shareNoteItem;
    UIBarButtonItem* deleteNoteItem;
    UIBarButtonItem* detailNoteItem;
    UIBarButtonItem* commentNoteItem;
    UIBarButtonItem* faveriteItem;
    UIBarButtonItem* moreOptionItem;
    UIBarButtonItem* showAttachItem;
    WizReadTitleView* titleView;
    WizWebView* readView;
    
    WizVerticalExpandView* readHeadView;
    UIView *overlayView;
    UISlider *progressSlider;
    UILabel	*currentTime;
	UILabel	*duration;
    UIButton *pauseBtn, *stopBtn;
    NSTimer	*updateTimer;
}
@property (nonatomic, strong) NSString* documentGuid;
@property (nonatomic, strong) WizGroup* group;
@property (nonatomic, readonly) WizDocument* doc;
@property (nonatomic, weak) id<WizDocumentListDelegate> documentListDelegate;


@property (nonatomic, retain) AVAudioPlayer *player;
@property (nonatomic, retain) UISlider *progressSlider;
@property (nonatomic, retain) UIView *overlayView;
@property (nonatomic, retain) UILabel	*currentTime;
@property (nonatomic, retain) UILabel	*duration;
@property (nonatomic, retain) UIButton *pauseBtn, *stopBtn;

- (BOOL) canShowFaildMessage;
- (id) initWithGroup:(WizGroup*)group documentGuid:(NSString*)documentGuid;
- (void)checkDocument:(WizDocument*)document;
- (void) loadDocument;
- (void) showSelectGroupViewController:(WizSelectGroupViewController*)vc;
- (void) openWizInnerLinkDocumentGuid:(NSString*)documentGuid kbguid:(NSString*)kbguid;
- (void) commentNote;
- (void) resetPlayViewFrame;
- (void) showOverlayView:(NSURL *)url;
@end
