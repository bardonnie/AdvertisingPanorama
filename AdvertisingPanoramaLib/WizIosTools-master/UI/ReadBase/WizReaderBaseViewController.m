//
//  WizReaderBaseViewController.m
//  WizNote
//
//  Created by dzpqzb on 13-4-15.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizWorkOperation.h"
#import "WizReaderBaseViewController.h"
#import "WizEnc.h"
#import "WizTokenManger.h"
#import "WizSyncKb.h"
#import "WizGlobalError.h"
#import "WizSelectGroupViewController.h"
#import "UIWebView+WizTool.h"
#import "WizCore.h"
#import "APLPrintPageRenderer.h"
#import "UIColor+SSToolkitAdditions.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSData+SSToolkitAdditions.h"
#import "UIViewController+WizPopoverController.h"
#import "WizFloatingLayer.h"
#import "WizAttachmentListViewController.h"
#import "WizProgressBar.h"
#import "WizNetworkEngine.h"
#import "SBJson.h"
#import "SVProgressHUD.h"

#define WizStrShareInnerLinkeToPasteboard  NSLocalizedString(@"Copy inner link to pasteboard", nil)

static int TagOfWizAlertViewShareWarning = 7834;
static NSInteger const TagOfWizEditingTapAttachment = 1457;

@interface WizReaderBaseViewController () < UIGestureRecognizerDelegate, WizSelectGroupDelegate,UIScrollViewDelegate , UIAlertViewDelegate,WizFloatingLayerDelegate,WizSyncDownloadDelegate>
{
    CGFloat titleHeight;
    WizProgressBar* progressBar;
    BOOL isLoading;
    BOOL isFirstLoad;
    NSString* readingDocumentTemperatoryPath;
    NSString* readingDocumentIndexFilePath;
    NSString* readingDocumentAdditonIndexFilesPath;
    
    BOOL isInUsing;
    
    UIToolbar* extraToolbar;
    WizFloatingLayer* itemsLayer;
    
    UIImageView* webViewShotView;
    CGPoint panGestureBeginPoint;
    WizAttachment* selectedAttachment;
}

@property (nonatomic, strong) NSMutableArray* photosArray;

@property (nonatomic, strong) NSURL *nowSelectAttachmentURL;
@property (nonatomic, strong) UIDatePicker* datePicker;
@property (nonatomic, strong) UIView* pickerToolBar;
@property (nonatomic, strong) UIView* pickerMaskView;
@property (nonatomic, strong) NSSet* shareGroups;

- (NSString*) kbGuid;
- (NSString*) accountUserId;
@end

@implementation WizReaderBaseViewController

@synthesize progressSlider, overlayView, currentTime, duration, pauseBtn, stopBtn, player;

@synthesize shareGroups;
@synthesize group = _group;
@synthesize  documentGuid = _documentGuid ;

@synthesize photosArray= _photosArray;
@synthesize doc;
@synthesize documentListDelegate = _documentListDelegate;

@synthesize nowSelectAttachmentURL;
- (void)dealloc
{
    readView.delegate = nil;
    readView.progressDelegate = nil;
    [readView stopLoading];
    [[WizNotificationCenter shareCenter] removeDownloadObserver:self];
}


- (BOOL) gestrueWebHasPreviousItem:(WizWebView *)webView
{
    if ([_documentListDelegate respondsToSelector:@selector(documentListHasPreviousItem)]) {
        return [_documentListDelegate documentListHasPreviousItem];
    }
    return NO;
}

- (BOOL) gestrueWebHasNextItem:(WizWebView *)webView
{
    if ([_documentListDelegate respondsToSelector:@selector(documentListHasNexItem)]) {
        return [_documentListDelegate documentListHasNexItem];
    }
    return NO;
}
- (void) checkGroup
{
    WizGroup* group = [self.documentListDelegate documentListWizGroup];
    if (![group isEqualToGroup:self.group])
    {
        self.group = group;
    }
}
- (void) gestrueWebCheckNextItem:(WizWebView *)webview
{
    if ([_documentListDelegate respondsToSelector:@selector(documentListNextItem)]) {
        NSString* documentguid = [_documentListDelegate documentListNextItem];
        if (documentguid) {
            [self checkGroup];
            WizDocument* document = self.doc;
            [self startLoadDocumentAnimation:NO];
            self.documentGuid = documentguid;
            [self checkDocument:document];
        }
    }
}

- (void) animationView:(UIView*)view isLeft:(BOOL)isLeft
{
    CGRect rect = view.frame;
    CGRect fromeRect = CGRectZero;
    CGRect aimRect = rect;
    if (isLeft) {
        fromeRect = CGRectOffset(rect, -CGRectGetWidth(rect), 0);
    }
    else
    {
        fromeRect = CGRectOffset(rect, CGRectGetWidth(rect), 0);
    }
    CFTimeInterval baseImte = CACurrentMediaTime();
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.beginTime = baseImte;
    [animation setRemovedOnCompletion:NO];
    [animation setDuration:WizAnimatedDuration];
    [animation setFillMode:kCAFillModeBackwards];
    [animation setDelegate:self];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    animation.fromValue = [NSValue valueWithCGPoint:CGCenterPoint(fromeRect)];
    animation.toValue = [NSValue valueWithCGPoint:CGCenterPoint(aimRect)];
    [view.layer addAnimation:animation forKey:@"title"];
}

- (void) startLoadDocumentAnimation:(BOOL)isUp
{
    readView.scrollView.showsHorizontalScrollIndicator = NO;
    readView.scrollView.showsVerticalScrollIndicator = NO;
    [self screenShot];
    [UIView beginAnimations:@"webViewAnimation" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.9];
    if (isUp) {
        webViewShotView.frame = CGRectSetY(webViewShotView.frame, 600);
    }else{
        webViewShotView.frame = CGRectSetY(webViewShotView.frame, - 600);
    }
    [UIView setAnimationDidStopSelector:@selector(releaseWebShotView)];
    [UIView commitAnimations];
    readView.scrollView.showsHorizontalScrollIndicator = YES;
    readView.scrollView.showsVerticalScrollIndicator = YES;
}

- (void)releaseWebShotView
{
    [webViewShotView removeFromSuperview];
    webViewShotView = nil;
}

- (void)getCommentCount
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL* url = [[WizNetworkEngine shareEngine] getCommentCountURLWith:self.doc.guid group:self.group];
        NSMutableURLRequest*  request = [NSMutableURLRequest new];
        [request setURL:url];
        [request setHTTPMethod:@"GET"];
        
        NSURLResponse* response ;
        NSData* data =  [NSURLConnection sendSynchronousRequest:request
                                              returningResponse:&response error:nil];
        SBJsonParser* parser = [[SBJsonParser alloc]init];
        NSDictionary* dictionary = [parser objectWithData:data];
        NSInteger returnCode = [[dictionary objectForKey:@"return_code"] integerValue];
        if (returnCode == 200) {
            NSInteger commentCount = [[dictionary objectForKey:@"comment_count"]integerValue];
            MULTIMAIN(^{
                [commentNoteItem setItemBadgeValue:commentCount ctrl:self action:@selector(commentNote)];
            });
        }
    });
}

- (void)screenShot
{
    if(UIGraphicsBeginImageContextWithOptions != NULL)
    {
        UIGraphicsBeginImageContextWithOptions(readView.frame.size, YES, 0.0);
    } else {
        UIGraphicsBeginImageContext(readView.frame.size);
    }
    
    [readView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    webViewShotView = [[UIImageView alloc]initWithFrame:readView.bounds];
    webViewShotView.backgroundColor = [UIColor clearColor];
    webViewShotView.image = image;
    [readView addSubview:webViewShotView];
}


- (void) gestrueWebCheckPreviousItem:(WizWebView *)webView
{
    if ([_documentListDelegate respondsToSelector:@selector(documentListPreviousItem)]) {
        NSString* documentguid = [_documentListDelegate documentListPreviousItem];
        if (documentguid) {
            [self checkGroup];
            WizDocument* document = self.doc;
            [self startLoadDocumentAnimation:YES];
            self.documentGuid = documentguid;
            [self checkDocument:document];
        }
    }
}

- (NSString *)gestrueWebNextNoteTitle:(WizWebView *)webView
{
    if ([_documentListDelegate respondsToSelector:@selector(documentListNextItemTitle)]) {
        return  [_documentListDelegate documentListNextItemTitle];
    }
    return nil;
}

- (NSString *)gestrueWebPreviousNoteTitle:(WizWebView *)webView
{
    if ([_documentListDelegate respondsToSelector:@selector(documentListPreviousItemTitle)]) {
        return [_documentListDelegate documentListPreviousItemTitle];
    }
    return nil;
}

//


- (id) initWithGroup:(WizGroup *)group documentGuid:(NSString *)documentGuid
{
    self = [super init];
    if (self) {
        _group = group;
        _documentGuid = documentGuid;
    }
    return self;
}
- (WizDocument*) doc
{
    id<WizInfoDatabaseDelegate> db = [WizDBManager getMetaDataBaseForKbguid:self.group.guid accountUserId:self.group.accountUserId];
    return [db documentFromGUID:self.documentGuid];
}

- (NSString*) kbGuid
{
    return self.group.guid;
}
- (NSString*) accountUserId
{
    return self.group.accountUserId;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        progressBar = [[WizProgressBar alloc] init];
        _photosArray = [NSMutableArray new];
    }
    return self;
}
- (BOOL) canLoadDocument:(NSString *)documentGuid
{
    if ([documentGuid isEqualToString:self.documentGuid]) {
        return YES;
    }
    else
    {
        return NO;
    }
}
- (void) loadView
{
    [super loadView];
    UIColor* backgroudColor = [UIColor whiteColor];
    self.view.backgroundColor = backgroudColor;
    readView = [[WizWebView alloc] initWithFrame:CGRectLoadViewFrame];
    readView.delegate = self;
    readView.scalesPageToFit = YES;
    readView.scrollView.scrollsToTop = YES;
    readView.scrollView.bounces = NO;
    readView.scrollView.directionalLockEnabled = YES;
    readView.scrollView.alwaysBounceVertical = YES;
    readView.scrollView.alwaysBounceHorizontal = NO;
    readView.progressDelegate = self;
    readView.scrollView.scrollEnabled = YES;
    [readView.scrollView setContentOffset:CGPointMake(0, -44)];
    readView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    titleView = [[WizReadTitleView alloc] initWithFrame:CGRectMake(0, 4, CGRectGetWidth(self.view.frame), 43)];
    [titleView setNeedsLayout];
    titleView.delegate = self;
    
    progressBar.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 4);
    progressBar.processTintColor = WizColorByKind(ColorForReadViewProcessView);
    progressBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    progressBar.willVerticalExpanded = NO;
    [titleView addSubview:progressBar];
    
    readHeadView = [[WizVerticalExpandView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(readView.frame), 44)];
    UIView* bottomLine = [self lineViewWithFrame:CGRectMake(0, CGRectGetHeight(readHeadView.frame) - 1, CGRectGetWidth(readHeadView.frame), 1)];
    
    titleView.backgroundColor = backgroudColor;
    readView.scrollView.backgroundColor = WizColorByKind(ColorOfDefaultBackgroud);
    [readHeadView addSubview:titleView];
    [readHeadView addSubview:bottomLine];
    readView.headerView = readHeadView;
    self.view = readView;
}


- (void)scrollToTopAuto
{
    [readView.scrollView setContentOffset:CGPointMake(0, -CGRectGetHeight(titleView.frame)) animated:YES];
}

- (void) webView:(IMTWebView *)webView didReceiveResourceNumber:(int)resourceNumber totalResources:(int)totalResources
{
    [progressBar setProgress:resourceNumber/(float)totalResources animated:YES];
}

- (NSString*)willLoadAttachment:(NSString*)guid
{
    WizFileManager* fm = [WizFileManager shareManager];
    if ([fm prepareReadingEnviroment:guid accountUserId:self.group.accountUserId]) {
        return [fm attachmentFilePath:guid accountUserId:self.group.accountUserId];
    }
    return nil;
}

- (void)checkAttachment:(WizAttachment*)attachement
{
    NSString* documentFileName = [self willLoadAttachment:attachement.guid];
    if (!documentFileName) {
        [WizGlobals reportErrorWithString:NSLocalizedString(@"Sorry!There is an error parsing this note, please try again.", nil)];
        return;
    }
    
    if (![[WizFileManager shareManager] fileExistsAtPath:documentFileName])
    {
        [WizGlobals reportErrorWithString:NSLocalizedString(@"Attachments without downloading, open it in a network environment.", nil)];
        return ;
    }
    
    NSURL* url = [[NSURL alloc] initFileURLWithPath:documentFileName];
//    if ([WizGlobals WizDeviceIsPad])
        [self showUrlFromInnerBrowser:url];
//    else{
//        self.nowSelectAttachmentURL=url;
//        [self showUrlFromInnerBrowser:self.nowSelectAttachmentURL];
//        UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:attachement.title
//                                                                 delegate:self
//                                                        cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
//                                                   destructiveButtonTitle:nil
//                                                        otherButtonTitles:NSLocalizedString(@"Open",nil),NSLocalizedString(@"Open as", nil),
//                                      nil];
//        actionSheet.destructiveButtonIndex=2;
//        actionSheet.tag=TagOfWizEditingTapAttachment;
//        [actionSheet showFromToolbar:self.navigationController.toolbar];
//    }
}


- (void) openWizInnerLinkDocumentGuid:(NSString*)documentGuid kbguid:(NSString*)kbguid
{
    NSLog(@"documentguid %@ kbguid %@", documentGuid, kbguid);
}

- (void) didSelectAttachment:(WizAttachment *)attachment
{
    [self checkAttachment:attachment];
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        BOOL(^ISWizInnerInlink)(NSString*) = ^(NSString* url) {
            if ([url hasPrefix:@"wiz:open_document?"]) {
                return YES;
            }
            return NO;
        };
        NSString* absluteUrl = request.URL.absoluteString;
        if (ISWizInnerInlink(absluteUrl))
        {
            NSString* documentGuid = nil;
            NSString* kbguid = nil;
            
            NSInteger indexOf = [absluteUrl indexOf:@"?"];
            if (indexOf != NSNotFound) {
                NSString* subContent = [absluteUrl substringFromIndex:indexOf+1];
                NSArray* contents = [subContent componentsSeparatedByString:@"&"];
                for (NSString* content in contents) {
                    NSArray* keys = [content componentsSeparatedByString:@"="];
                    if (keys.count) {
                        NSString* key = keys[0];
                        NSString* value = nil;
                        if (keys.count > 1) {
                            value = keys[1];
                            if ([value isEqualToString:@""]) {
                                value = nil;
                            }
                        }
                        
                        if ([key isEqualToString:@"guid"]) {
                            documentGuid = value;
                        }
                        else if ([key isEqualToString:@"kbguid"])
                        {
                            
                            kbguid = value;
                        }
                    }
                }
            }
            [self openWizInnerLinkDocumentGuid:documentGuid kbguid:kbguid];
        }else if ([absluteUrl hasPrefix:@"wiz:open_attachment?"]){
            NSInteger indexOf = [absluteUrl indexOf:@"guid="];
            if (indexOf != NSNotFound) {
                NSString* attachmentGuid = [absluteUrl substringFromIndex:indexOf+5];
                id<WizInfoDatabaseDelegate> db = [WizDBManager getMetaDataBaseForKbguid:self.group.guid accountUserId:self.group.accountUserId];
                WizAttachment* attachment = [db attachmentFromGUID:attachmentGuid];
                selectedAttachment = attachment;
                if (attachment.serverChanged) {
                    [[WizSyncCenter shareCenter]downloadAttachment:attachmentGuid kbguid:self.group.guid accountUserId:self.group.accountUserId];
                }else{
                    [self didSelectAttachment:attachment];
                }
            }
            return NO;
        }
        else if (![WizGlobals checkAttachmentTypeIsImage:[[[[request URL]absoluteString] componentsSeparatedByString:@"."] lastObject]]) {
            NSString* scheme = [[request URL] scheme];
            if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
                [self showUrlFromInnerBrowser:request.URL];
                return NO;
            }
        }
    }
    else{
        NSArray* cmds = [webView decodeJsCmd:[[request URL] absoluteString]];
        if (cmds && [cmds count] >=2) {
            NSString* identify = [cmds objectAtIndex:0];
            NSString* contentString = [cmds objectAtIndex:1];
            if ([identify isEqualToString:WizNotCmdChangedImage])
            {
                static NSString* fileBom =@"file://";
                NSInteger indexOfFileBom = [contentString indexOf:fileBom];
                if (indexOfFileBom != NSNotFound) {
                    contentString = [contentString substringFromIndex:indexOfFileBom+fileBom.length];
                }
                
                if ([[contentString fileName] hasPrefix:WizRecordAttachmentNamePrefix] || [[contentString fileName] hasPrefix:@"wiz:open_record_attachment:iphone:ipad__"]) {
                    return NO;
                }
                
                if ([contentString hasPrefix:@"http://"] || [contentString hasPrefix:@"webkit-fake-url://"] || [contentString hasPrefix:@"https://"]) {
                    [self browserBigImage:webView isHttp:YES currentImage:contentString];
                    return NO;
                }else{
                    [self browserBigImage:webView isHttp:NO  currentImage:contentString];
                    return NO;
                }
            }
            return NO;
        }
    }
    return YES;
}

- (void) browserBigImage:(UIWebView *)webView isHttp:(BOOL)isHttp  currentImage:(NSString *)contentString
{
    MWPhoto *photo;
    NSMutableArray* imageArrayOther = [[NSMutableArray alloc] init];
    NSMutableArray* imageArray = [NSMutableArray arrayWithArray:[webView readGetAllImages]];
    [self.photosArray removeAllObjects];
    
    if (isHttp) {
        for (NSString* each in imageArray) {
            if (![each hasPrefix:WizRecordAttachmentNamePrefix]) {
                [self.photosArray addObject:[MWPhoto photoWithURL:[NSURL URLWithString:each]]];
            }
        }
    }else{
        [imageArrayOther removeAllObjects];
        for (NSString* each in imageArray) {
            if (![each hasPrefix:WizRecordAttachmentNamePrefix]) {
                NSString* filePath = [readingDocumentAdditonIndexFilesPath stringByAppendingPathComponent:each];
                if ([WizGlobals checkAttachmentTypeIsImage:[each fileType]]) {
                    UIImage* image = [UIImage imageWithContentsOfFile:filePath];
                    photo = [MWPhoto photoWithImage:image];
                    [self.photosArray addObject:photo];
                    [imageArrayOther addObject:filePath];
                }
            }
        }
    }
    if (imageArrayOther.count) {
        [imageArray removeAllObjects];
        [imageArray addObjectsFromArray:imageArrayOther];
    }
    
    int index = [imageArray indexOfObject:contentString];
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = YES;
    [browser setInitialPageIndex:index];
    WizNavigationViewController* browserNavCon = [[WizNavigationViewController alloc]initWithRootViewController:browser];
    [self presentViewController:browserNavCon animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    }];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.photosArray.count;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.photosArray.count)
        return [self.photosArray objectAtIndex:index];
    return nil;
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (itemsLayer && itemsLayer.alpha != 0) {
        [itemsLayer dismissMenu:YES];
    }
    
    [self hiddenLoadingActivity];
    [self tapStopBtn];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"wizPlayVoiceFile" object:nil];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:YES animated:YES];
    [super viewDidDisappear:animated];
}

- (void)webViewDidFinishLoad:(UIWebView *)webview
{
    [webview loadReadJavaScript];
    [self setNavigationBarItemEnable:YES];
    if (self.doc.bProtected) {
        [editNoteItem setEnabled:NO];
    }
    if (iPad) {
        [webview stringByEvaluatingJavaScriptFromString:@"document.body.style.fontSize=22.0;"];
    }else{
        [webview stringByEvaluatingJavaScriptFromString:@"document.body.style.fontSize=18.0;"];
    }
    
//    NSString* str1 =[NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%f%%'",300.0];
//    [webview stringByEvaluatingJavaScriptFromString:str1];
    if ([self.doc.title hasSuffix:@".md"] || [self.doc.title indexOf:@".md "] != NSNotFound) {
        [webview markDownRendering];
    }
    else if ([self.doc.title hasSuffix:@".mj"] || [self.doc.title indexOf:@".mj "] != NSNotFound)
    {
        [webview markJexRendering];
    }
    if (![[[[webview request] URL] absoluteString]  isEqual: @"about:blank"]) {
        [self hiddenLoadingActivity];
    }
}

- (void) showLoadingActivity
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading note...", nil)];
}

- (void) hiddenLoadingActivity
{
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (DocumentInfoViewController*) documentInfoViewController
{
    DocumentInfoViewController* infoView = [[DocumentInfoViewController alloc] initWithStyle:UITableViewStyleGrouped];
    infoView.group = self.group;
    infoView.doc = self.doc;
    return infoView;
}

- (void) showDetail
{
    [self showDocumentInfoViewController:[self documentInfoViewController]];
}

- (void) showDocumentInfoViewController:(DocumentInfoViewController *)infoVC
{
    
}

- (void) didDeletedCurrentDocument
{
    
}

- (void) deleteCurrentDocument
{
    [self tapStopBtn];
    
    if (![WizUserPrivilige canEditNote:self.doc  privilige:self.group.userGroup accountUserId:self.group.accountUserId]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:WizStrWarning message:NSLocalizedString(@"You do not have permission to delete others’note", nil) delegate:nil cancelButtonTitle:WizStrOK otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    WizDocument* document = self.doc;
    if (document.isInDeletedBox) {
        [WizCore deleteDocumentForever:document.guid group:self.group];
    }
    else
    {
        [WizCore deleteDocument:document.guid group:self.group];
    }
    [self didDeletedCurrentDocument];
}


- (void) doShareToGroups
{
    id<WizInfoDatabaseDelegate> db = [WizDBManager getMetaDataBaseForKbguid:self.group.guid accountUserId:self.group.accountUserId];
    NSArray* attachments = [db attachmentsByDocumentGUID:self.documentGuid];
    
    NSString* ziwFilePath = [[WizFileManager shareManager] wizObjectFilePath:self.documentGuid accountUserId:self.group.accountUserId];
    
    for (NSDictionary* eachDic in self.shareGroups) {
        NSString* key = [[eachDic allKeys]lastObject];
        WizGroup* eachGroup = [[WizAccountManager defaultManager]groupFroKbguid:key accountUserId:self.accountUserId];
        NSString* docguid = nil;
        if ([key isEqualToString:WizGlobalPersonalKbguid]) {
            docguid =[WizCore addDocumentFromZiw:ziwFilePath toAccountUserId:eachGroup.accountUserId kbguid:eachGroup.guid  withDocumentAttribute:@{DataTypeUpdateDocumentTitle:self.doc.title,DataTypeUpdateDocumentAttachmentCount:@(self.doc.attachmentCount),DataTypeUpdateDocumentOwner:self.doc.ownerName,DataTypeUpdateDocumentLocation:[eachDic objectForKey:key]}];
        }else{
            docguid =[WizCore addDocumentFromZiw:ziwFilePath toAccountUserId:eachGroup.accountUserId kbguid:eachGroup.guid  withDocumentAttribute:@{DataTypeUpdateDocumentTitle:self.doc.title,DataTypeUpdateDocumentAttachmentCount:@(self.doc.attachmentCount),DataTypeUpdateDocumentOwner:self.doc.ownerName,DataTypeUpdateDocumentTagGuids:[eachDic objectForKey:key]}];
        }
        
        NSInteger attachCount = 0;
        if ([attachments count]) {
            for (WizAttachment* each  in attachments) {
                NSString* filePath = [[WizFileManager shareManager] wizObjectFilePath:each.guid accountUserId:self.group.accountUserId];
                if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                    NSMutableDictionary* dic = [[each toWizServerObject] mutableCopy];
                    [dic setObject:docguid forKey:DataTypeUpdateAttachmentDocumentGuid];
                    if([WizCore addAttachmentFromZiw:filePath toAccountUserId:eachGroup.accountUserId kbguid:eachGroup.guid withAttachmentAttribute:dic])
                    {
                        attachCount += 1;
                    }
                    
                }
            }
        }
        
        id<WizInfoDatabaseDelegate> shareToDb = [WizDBManager getMetaDataBaseForKbguid:eachGroup.guid accountUserId:eachGroup.accountUserId];
        WizDocument* shareDoc = [shareToDb documentFromGUID:docguid];
        if (shareDoc) {
            shareDoc.attachmentCount = attachCount;
            [shareToDb updateDocument:shareDoc];
        }
        [[WizSyncCenter shareCenter] autoSyncKbguid:eachGroup.guid accountUserId:eachGroup.accountUserId];
    }
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString* title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:WizStrContinue]) {
        [self doShareToGroups];
    }
    else if ([title isEqualToString:WizStrCancel])
    {
        return;
    }
    else
    {
        return;
    }
}

- (void) showShareWarning:(NSSet*)groups
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:WizStrWarning message:NSLocalizedString(@"Some attachments are not downloaded, clike continue to share the content only.", nil) delegate:self cancelButtonTitle:WizStrCancel otherButtonTitles:WizStrContinue, nil];
    [alertView show];
    alertView.tag = TagOfWizAlertViewShareWarning;
}

- (void) didSelectedGroups:(NSSet *)groups
{
    [self.navigationController popViewControllerAnimated:YES];
    if ([groups count] == 0) {
        return;
    }
    self.shareGroups = groups;
    id<WizInfoDatabaseDelegate> db = [WizDBManager getMetaDataBaseForKbguid:self.group.guid accountUserId:self.group.accountUserId];
    NSArray* attachments = [db attachmentsByDocumentGUID:self.documentGuid];
    for (WizAttachment* attach in attachments) {
        NSString* filePath = [[WizFileManager shareManager] wizObjectFilePath:attach.guid accountUserId:self.group.accountUserId];
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [self showShareWarning:groups];
            return;
        }
    }
    [self doShareToGroups];
    
}

- (void)didDownloadEnd:(NSString *)guid
{
    if ([selectedAttachment.guid isEqualToString:guid]) {
        [SVProgressHUD dismiss];
        [self didSelectAttachment:selectedAttachment];
    }
}

- (void)didDownloadStart:(NSString *)guid
{
    if ([selectedAttachment.guid isEqualToString:guid]) {
        [SVProgressHUD show];
    }
}

- (void)didDownloadFaild:(NSString *)guid error:(NSError *)error
{
    if ([selectedAttachment.guid isEqualToString:guid]) {
        [SVProgressHUD dismiss];
        [WizGlobals reportErrorWithString:error.localizedDescription];
    }
}

- (NSString*) selectGroupExpectKbguid
{
    return self.group.guid;
}
- (void) showSelectGroupViewController:(WizSelectGroupViewController*)vc
{
    
}

- (void) shareByWiznote
{
    WizSelectGroupViewController* selectVC = [[WizSelectGroupViewController alloc] initWithRootKey:@"ROOT/"];
    selectVC.accountUserId = self.group.accountUserId;
    selectVC.delegate = self;
    selectVC.minPrivilige = WizUserPriviligeTypeEditor;
    [self showSelectGroupViewController:selectVC];
}

-(void)dismissPopoverController:(NSString*)sharePath{
    [self dismissCurrentPopoverController];
    if ([sharePath hasPrefix:@"/ROOT/"]) {
        sharePath = [sharePath substringFromIndex:5];
    }
    [SVProgressHUD showImage:[UIImage imageNamed:@"success"] status:[NSString stringWithFormat:@"%@：%@ %@!",NSLocalizedString(@"Shared to",nil),sharePath,NSLocalizedString(@"Sucessfully",nil)]];
}

- (void)deleteNote
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    if ([self.doc.location hasPrefix:WizDeletedItemsKey]) {
        [actionSheet addButtonWithTitle:WizStrDeleteForever];
    }
    else
    {
        [actionSheet addButtonWithTitle:WizStrDelete];
    }
    [actionSheet addButtonWithTitle:WizStrCancel];
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons -1;
    if (itemsLayer.alpha != 0) {
        [self showActionSheetFromItem:moreOptionItem action:actionSheet];
    }else{
        [self showActionSheetFromItem:deleteNoteItem action:actionSheet];
    }
}

- (void) shareFromEmail{
    WizShareToEmailCtrl *mailCtrl = [[WizShareToEmailCtrl alloc] init];
    mailCtrl.group = self.group;
    mailCtrl.documentGuid = self.documentGuid;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mailCtrl];
    navController.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:navController animated:YES completion:nil];
}

//- (void) shareFromEmail
//{
//    if ([MFMailComposeViewController canSendMail]) {
//        MFMailComposeViewController* emailController = [[MFMailComposeViewController alloc] init];
//        NSString* bodyString = [NSString stringWithContentsOfFile:readingDocumentIndexFilePath usedEncoding:nil error:nil];
//        emailController.mailComposeDelegate = self;
//        NSString* title = [NSString stringWithFormat:@"%@ %@",self.doc.title,WizStrShareByWiz];
//        [emailController setSubject:title];
//        if ([readView containImages]) {
//            NSArray* contents = [[WizFileManager shareManager]contentsOfDirectoryAtPath:readingDocumentAdditonIndexFilesPath error:nil];
//            for (NSString* each in contents) {
//                NSString* filePath = [readingDocumentAdditonIndexFilesPath stringByAppendingPathComponent:each];
//                if ([WizGlobals checkAttachmentTypeIsImage:[each fileType]]) {
//                    NSData* data = [NSData dataWithContentsOfFile:filePath];
//                    if (nil != data) {
//                        [emailController addAttachmentData:data mimeType:@"image" fileName:each];
//                    }
//                }
//            }
//        }
//        [emailController setMessageBody:bodyString isHTML:YES];
//        if (iPad) {
//            emailController.modalPresentationStyle = UIModalPresentationFormSheet;
//            [self.navigationController presentViewController:emailController animated:YES completion:^{
//                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//            }];
//        }else{
////            [self presentModalViewController:emailController animated:YES];
//            [self presentViewController:emailController animated:YES completion:^{
//                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
//            }];
//        }
//    }else{
//        NSString *recipients = @"mailto:first@example.com&subject=my email!";
//        NSString *body = @"&body=email body!";
//        NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
//        email = [email stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
//        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:email]]) {
//            [[UIApplication sharedApplication] openURL: [NSURL URLWithString:email]];
//        }else{
//            NSLog(@"邮件应用打不开！");
//        }
//    }
//}
//
//#pragma mark MFMailComposeViewControllerDelegate
//- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
//{
//    NSString *msg;
//    switch (result)
//    {
//        case MFMailComposeResultCancelled:
//            msg = @"邮件发送取消";
//            break;
//        case MFMailComposeResultSaved:
//            msg = @"邮件保存成功";
//            break;
//        case MFMailComposeResultSent:
//            msg = @"邮件发送成功";
//            break;
//        case MFMailComposeResultFailed:
//            msg = @"邮件发送失败";
//            break;
//        default:
//            break;
//    }
//    [self dismissModalViewControllerAnimated:YES];
//}

- (void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissModalViewControllerAnimated:YES];
}
- (NSString*)webViewSelection
{
    return [readView stringByEvaluatingJavaScriptFromString:@"document.getSelection().toLocaleString()"];
}
- (void) shareFromEms
{
    MFMessageComposeViewController* messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    NSString* title = [NSString stringWithFormat:@"%@....%@",self.doc.title,WizStrShareByWiz];
    [messageController setTitle:title];
    NSString* bodyString = [self webViewSelection];
    if (!bodyString || [bodyString isEqualToString:@""]) {
        bodyString = [readView bodyText];
        if (bodyString.length >= 72) {
            bodyString = [bodyString substringToIndex:72];
        }
    }
    NSString* shareBodyText = [NSString stringWithFormat:@"%@",bodyString];
    [messageController setBody:shareBodyText];
//    [self presentModalViewController:messageController animated:YES];
    [self presentViewController:messageController animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    }];
}


- (void) printDocument
{
    UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
    if(!controller){
        NSLog(@"Couldn't get shared UIPrintInteractionController!");
        return;
    }
    
    UIPrintInteractionCompletionHandler completionHandler =
    ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        if(!completed && error){
            NSLog(@"FAILED! due to error in domain %@ with error code %u", error.domain, error.code);
        }
    };
    
    
    // Obtain a printInfo so that we can set our printing defaults.
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    // This application produces General content that contains color.
    printInfo.outputType = UIPrintInfoOutputGeneral;
    // We'll use the URL as the job name.
    printInfo.jobName = [titleView.textLabel text];
    // Set duplex so that it is available if the printer supports it. We are
    // performing portrait printing so we want to duplex along the long edge.
    printInfo.duplex = UIPrintInfoDuplexLongEdge;
    // Use this printInfo for this print job.
    controller.printInfo = printInfo;
    
    // Be sure the page range controls are present for documents of > 1 page.
    controller.showsPageRange = YES;
    APLPrintPageRenderer *myRenderer = [[APLPrintPageRenderer alloc] init];
    // The APLPrintPageRenderer class provides a jobtitle that it will label each page with.
    myRenderer.jobTitle = printInfo.jobName;
    // To draw the content of each page, a UIViewPrintFormatter is used.
    UIPrintPageRenderer* pageRender = [[UIPrintPageRenderer alloc] init];
    controller.printPageRenderer = pageRender;
    // This code uses a custom UIPrintPageRenderer so that it can draw a header and footer.
    // To draw the content of each page, a UIViewPrintFormatter is used.
    UIViewPrintFormatter *viewFormatter = [readView viewPrintFormatter];
    [myRenderer addPrintFormatter:viewFormatter startingAtPageAtIndex:0];
    // Set our custom renderer as the printPageRenderer for the print job.
    controller.printPageRenderer = myRenderer;
    if ([WizGlobals WizDeviceIsPad]) {
        [controller presentFromBarButtonItem:shareNoteItem animated:YES completionHandler:completionHandler];
    }else{
        [controller presentAnimated:YES completionHandler:completionHandler];  // iPhone
    }
}


static NSString* const kWebArchiveTemlateReplace = @"REPLACE_WITH_ENCODED_DATA";

static NSString* const kWebArchiveTemplate = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?> \
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\"> \
<plist version=\"1.0\"> \
<dict>\
<key>WebMainResource</key>\
<dict>\
<key>WebResourceData</key>\
<data>\
REPLACE_WITH_ENCODED_DATA\
</data>\
<key>WebResourceFrameName</key>\
<string></string>\
<key>WebResourceMIMEType</key>\
<string>text/html</string>\
<key>WebResourceTextEncodingName</key>\
<string>UTF-8</string>\
<key>WebResourceURL</key>\
<string>about:blank</string>\
</dict>\
</dict>\
</plist>";

- (void) shareInnerLinkToPasteBoard
{
    NSString* kbguid = self.group.guid? self.group.guid : @"";
    NSString* innerLinker = [NSString stringWithFormat:@"</DIV><A href='wiz:open_document?guid=%@&kbguid=%@'>%@</A><DIV>",self.doc.guid, kbguid, self.doc.title];
    
    
    NSString* (^GetPasteWebString)(NSString*) = ^(NSString*html) {
        NSString* template = [kWebArchiveTemplate copy];
        NSData* data = [html dataUsingEncoding:NSUTF8StringEncoding];
        NSString* base64 = [data base64EncodedString];
        template = [template stringByReplacingOccurrencesOfString:kWebArchiveTemlateReplace withString:base64];
        return template;
    };
    
    NSString* archiveData = GetPasteWebString(innerLinker);;
    //
    NSDictionary* item = @{kWizNoteWebArchive:archiveData};
    [[UIPasteboard generalPasteboard] setItems:@[item]];
}

- (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex > 10 || buttonIndex <0) {
        return;
    }
    
    NSString* title = [actionSheet buttonTitleAtIndex:buttonIndex];
//    if (actionSheet.tag==TagOfWizEditingTapAttachment){
//        if ([title isEqualToString:NSLocalizedString(@"Open",nil)]) {
//            [self showUrlFromInnerBrowser:self.nowSelectAttachmentURL];
//        }
//        else if ([title isEqualToString:NSLocalizedString(@"Open as", nil)]){
//            [self openFileViewController:self.nowSelectAttachmentURL];
//        }
//        return;
//    }
    if ([title isEqualToString:WizStrCancel]) {
        return;
    }
    else if ([title isEqualToString:WizStrDelete])
    {
        [self deleteCurrentDocument];
    }
    else if ([title isEqualToString:WizStrDeleteForever])
    {
        [self deleteCurrentDocument];
    }
    if ([title isEqualToString:WizStrShareByEmail]) {
        [self shareFromEmail];
    }
    
    else if ([title isEqualToString:WizStrShareByEms])
    {
        [self shareFromEms];
    }
    else if ([title isEqualToString:WizStrShareInnerLinkeToPasteboard])
    {
        [self shareInnerLinkToPasteBoard];
    }
    else if([title isEqualToString:NSLocalizedString(@"Share To Group", nil)]) {
        [self shareByWiznote];
    }
    else if ([title isEqualToString:WizStrPrint])
    {
        [self printDocument];
    }
    else
    {
    }
    if (itemsLayer.alpha != 0) {
        [itemsLayer dismissMenu:YES];
    }
}
- (void)shareNote
{
    UIActionSheet* shareSheet = [[UIActionSheet alloc]
                                 initWithTitle:NSLocalizedString(@"Share", nil)
                                 delegate:self
                                 cancelButtonTitle:nil
                                 destructiveButtonTitle:nil
                                 otherButtonTitles:nil];;
    [shareSheet addButtonWithTitle:WizStrShareByEmail];
    [shareSheet addButtonWithTitle:WizStrShareByEms];
    
    [shareSheet addButtonWithTitle:NSLocalizedString(@"Share To Group", nil)];
    [shareSheet addButtonWithTitle:WizStrShareInnerLinkeToPasteboard];
    if ([UIPrintInteractionController isPrintingAvailable]) {
        [shareSheet addButtonWithTitle:WizStrPrint];
    }
    [shareSheet addButtonWithTitle:WizStrCancel];
    shareSheet.cancelButtonIndex = shareSheet.numberOfButtons-1;
    
    if (itemsLayer.alpha != 0) {
        [self showActionSheetFromItem:moreOptionItem action:shareSheet];
    }else{
        [self showActionSheetFromItem:shareNoteItem action:shareSheet];
    }
}

- (NSArray*) readFunctionItems
{
    NSMutableArray* array = [NSMutableArray new];
    if (editNoteItem) {
        [array addObject:editNoteItem];
    }
    if (deleteNoteItem) {
        [array addObject:deleteNoteItem];
    }
    if (shareNoteItem) {
        [array addObject:shareNoteItem];
    }
    return array;
}

- (void) removeAllDatePickView
{
    [self.datePicker removeFromSuperview];
    [self.pickerMaskView removeFromSuperview];
    [self.pickerToolBar removeFromSuperview];
}
- (void) addUserTask
{
    id<WizTemporaryDataBaseDelegate> db = [WizDBManager temporaryDataBase];
    WizUserTask* task = [db userTaskFromDocumentGuid:self.documentGuid];
    if (!task) {
        task = [[WizUserTask alloc] init];
        task.guid = [WizGlobals genGUID];
        task.kbguid = self.group.guid;
        task.accountUserId = self.group.accountUserId;
        task.documentGuid = self.documentGuid;
        task.dtCreated = [NSDate date];
        task.dtDeadline = self.datePicker.date;
        task.title = self.doc.title;
        task.body = @"";
        task.bizGuid = self.group.bizName;
    }
    else
    {
        task.dtDeadline = self.datePicker.date;
    }
    [db updateWizUserTask:task];
    
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    if (localNotification) {
        
        NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
        userInfo[WizNotificationUserInfoAccountUserId]= self.accountUserId;
        userInfo[WizNotificationUserInfoKbguid] = self.group.guid?self.group.guid:WizGlobalPersonalKbguid;
        userInfo[WizNotificationUserInfoDocumentGuid] = self.documentGuid;
        localNotification.userInfo = userInfo;
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
    [self removeAllDatePickView];
    
}
- (void) addDatePickerView
{
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 200, CGRectGetWidth(self.view.frame), 200)];
    self.pickerMaskView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.pickerMaskView.backgroundColor = [UIColor grayColor];
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    self.pickerMaskView.alpha = 0.5;
    self.pickerToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(self.datePicker.frame) - 44, CGRectGetWidth(self.datePicker.frame),44 )];
    self.pickerToolBar.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.pickerMaskView];
    [self.view addSubview:self.datePicker];
    [self.view addSubview:self.pickerToolBar];
    
    UITapGestureRecognizer* tapCancelGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeAllDatePickView)];
    [self.pickerMaskView addGestureRecognizer:tapCancelGesture];
    
    UIButton* saveButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [saveButton addTarget:self action:@selector(addUserTask) forControlEvents:UIControlEventTouchUpInside];
    saveButton.frame = CGRectMake(0, 0, 40, 40);
    [self.pickerToolBar addSubview:saveButton];
}

- (void) commentNote
{
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = NSLocalizedString(@"View Note", nil);
    editNoteItem = [UIBarButtonItem toolbarItemWithImage:WizImageByKind(BarIconEdit) target:self action:@selector(editNote)];
    shareNoteItem = [UIBarButtonItem toolbarItemWithImage:WizImageByKind(BarIconShare) target:self action:@selector(shareNote)];
    deleteNoteItem = [UIBarButtonItem toolbarItemWithImage:WizImageByKind(BarIconDelete) target:self action:@selector(deleteNote)];
    detailNoteItem = [UIBarButtonItem toolbarItemWithImage:WizImageByKind(BarIconInfo) target:self action:@selector(showDetail)];
    commentNoteItem = [UIBarButtonItem toolbarItemWithImage:WizImageByKind(ImageOfBarIconComment) target:self action:@selector(commentNote)];
    showAttachItem = [UIBarButtonItem toolbarItemWithImage:WizImageByKind(BarIconAttachment) target:self action:@selector(showAttachmentList)];
    moreOptionItem = [UIBarButtonItem toolbarItemWithImage:WizImageByKind(BarIconMore) target:self action:@selector(showMoreOptions)];
    [self loadDocument];
    
//    UISwipeGestureRecognizer* swipUpGes = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipGestrue:)];
//    swipUpGes.numberOfTouchesRequired = 2;
//    swipUpGes.direction = UISwipeGestureRecognizerDirectionUp;
//    [readView addGestureRecognizer:swipUpGes];
//    swipUpGes.delegate = self;
//    
//    UISwipeGestureRecognizer* swipDownGes = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipGestrue:)];
//    swipDownGes.numberOfTouchesRequired = 2;
//    swipDownGes.direction =  UISwipeGestureRecognizerDirectionDown;
//    [readView addGestureRecognizer:swipDownGes];
//    swipDownGes.delegate = self;
    [[WizNotificationCenter shareCenter]addDownloadDelegate:self];
}

- (void) showMoreOptions
{
    [[UIToolbar appearance]setBackgroundImage:WizImageByKind(ImageOfNoBackgroundBarButtonBG) forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    
    if (extraToolbar == nil) {
        NSArray* itemsArray = nil;
        UIBarButtonItem* felxItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        if (self.group.guid ) {
            if ([WizUserPrivilige canEditNote:self.doc privilige:self.group.userGroup accountUserId:self.group.accountUserId]) {
                itemsArray = @[shareNoteItem,felxItem,deleteNoteItem,felxItem,detailNoteItem];
            }
        }else{
            itemsArray = @[deleteNoteItem,felxItem,detailNoteItem];
        }
        extraToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, [itemsArray count] * 35, 50)];
        extraToolbar.items = itemsArray;
    }
    if (itemsLayer == nil) {
        itemsLayer = [[WizFloatingLayer alloc]initWithContentView:extraToolbar];
        itemsLayer.delegate = self;
        [itemsLayer setTintColor:[UIColor colorWithWhite:1.0 alpha:0.9]];
    }
    
    CGPoint arrowPoint = CGPointMake(CGRectGetWidth(self.view.frame) - 20, CGRectGetMinY(self.navigationController.toolbar.frame) + WizArrowSize);
    [itemsLayer showMenuInView:self.navigationController.view fromPoint:arrowPoint];
}

- (void)didFloatingLayerDismiss
{
    [[UIToolbar appearance]setBackgroundImage:WizImageByKind(ToolBarBackgroundImage) forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
}

- (void)showAttachmentList
{
    
}

- (void) changeFavirateStatue
{
    WizShotCut* shot = [WizShotCut new];
    shot.document = self.doc;
    shot.group = self.group;
    [[WizShotCutCache shareInstance] addShotCut:shot];
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void) swipGestrue:(id)sender
{
    if ([sender isKindOfClass:[UISwipeGestureRecognizer class]]) {
        UISwipeGestureRecognizer* swip = (UISwipeGestureRecognizer*)sender;
        if (swip.direction == UISwipeGestureRecognizerDirectionUp) {
            if ([self gestrueWebHasNextItem:readView]) {
                [self gestrueWebCheckNextItem:readView];
            }
        }else if (swip.direction == UISwipeGestureRecognizerDirectionDown){
            if ([self gestrueWebHasPreviousItem:readView]) {
                [self gestrueWebCheckPreviousItem:readView];
            }
        }
    }
}

- (void) didLoadDocumentUserCancel:(NSString *)documentGuid
{
    if ([documentGuid isEqualToString:self.documentGuid]) {
        if (iPad) {
            [self dismissCurrentViewController];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void) dismissCurrentViewController{
    
}

- (void) didLoadDocumentStart:(WizDocument *)document
{
    if ([document.guid isEqualToString:self.documentGuid]) {
        [readView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
        titleView.textLabel.text = document.title;
        [readView.scrollView setContentOffset:CGPointMake(0, -readView.scrollView.contentInset.top)];
        [progressBar setProgress:0.1 animated:YES];
        [[readView scrollView] setScrollsToTop:YES];
        [self setNavigationBarItemEnable:NO];
        [self showLoadingActivity];
    }
}

- (BOOL) canShowFaildMessage
{
    return YES;
}

- (void) didLoadDocumentFaild:(NSString *)documentGuid_ error:(NSError *)error
{
    if ([documentGuid_ isEqualToString:self.documentGuid]) {
        if ([self canShowFaildMessage]) {
            if (error == nil) {
                [readView showErrorMessage:NSLocalizedString(@"Note failed to load content", nil)];
            }else{
                [readView showErrorMessage:error.localizedDescription];
                [self hiddenLoadingActivity];
            }
            readView.scrollView.scrollEnabled = NO;
        }
    }
}

- (void) didLoadDocumentSucceed:(NSString *)documentGuid path:(NSString *)documentFilePath
{
    if (documentFilePath && [documentGuid isEqualToString:self.documentGuid]) {
        readingDocumentTemperatoryPath = [documentFilePath stringByDeletingLastPathComponent];
        readingDocumentIndexFilePath = documentFilePath;
        readingDocumentAdditonIndexFilesPath = [readingDocumentTemperatoryPath stringByAppendingPathComponent:@"index_files"];
        NSURL* url = [NSURL fileURLWithPath:documentFilePath];
        [readView loadRequest:[NSURLRequest requestWithURL:url]];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getCommentCount];
    if (iPad) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(overlayView:) name:@"wizPlayVoiceFile" object:nil];
    }
}

- (void)overlayView:(NSNotification *)notification{
    
    NSURL *url = (NSURL *)notification.object;
    [self showOverlayView:url];
    [self dismissCurrentPopoverController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) setNavigationBarItemEnable:(BOOL)enable
{
    if (self.doc.bProtected) {
        [editNoteItem setEnabled:NO];
    }
    else
    {
        [editNoteItem setEnabled:enable];
    }
    [shareNoteItem setEnabled:enable];
    [deleteNoteItem setEnabled:enable];
    [detailNoteItem setEnabled:enable];
    [showAttachItem setEnabled:enable];
}

- (void)loadDocument
{
    WizReadDocumentOperation* readOperation = [[WizReadDocumentOperation alloc] initWithDocumentGuid:self.documentGuid accountUserId:self.group.accountUserId kbguid:self.group.guid];
    readOperation.delegate = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        [readOperation start];
    });
}
- (void) checkDocument:(WizDocument *)document
{
    [readView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    titleView.textLabel.text = document.title;
    [readView.scrollView setContentOffset:CGPointMake(0, -readView.scrollView.contentInset.top)];
    [progressBar setProgress:0.1 animated:YES];
    [[readView scrollView] setScrollsToTop:YES];
    [self setNavigationBarItemEnable:NO];
    [self showLoadingActivity];
    [self loadDocument];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (itemsLayer.alpha != 0) {
        [itemsLayer dismissMenu:NO];
        [self showMoreOptions];
    }
    [self resetPlayViewFrame];
}

- (void) resetPlayViewFrame{
    float with = self.view.bounds.size.width - 24*2 - 32 - 30*2 - 48 - 24*2 - 5*2 - 60;
    self.progressSlider.frame = CGRectSetWidth(self.progressSlider.frame
                                               , with);
    self.duration.frame = CGRectMake(CGRectGetMaxX(progressSlider.frame) + 10, (44 - 24)/2, 48, 24);
    stopBtn.frame = CGRectMake(self.view.bounds.size.width - 24 - 60, (44 - 40)/2, 60, 40);
}

- (void)showOverlayView:(NSURL *)url
{
    if (DEVICE_VERSION_BELOW_6) {
        if (player && player.playing) {
            return;
        }
    }
    
    if (self.overlayView) {
        if (player && player.playing) {
            [player stop];
        }
        [self.overlayView removeFromSuperview];
    }
    
    self.overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    overlayView.backgroundColor = [UIColor colorWithHexHex:0xF2F2F2];
    overlayView.opaque = NO;
    
    self.pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [pauseBtn setImage:WizImageByKind(ImageOfPlayIpadIconPause) forState:UIControlStateNormal];
    [pauseBtn addTarget:self action:@selector(tapPauseBtn) forControlEvents:UIControlEventTouchUpInside];
    pauseBtn.frame = CGRectMake(24, (44 - 32)/2, 32, 32);
    [overlayView addSubview:pauseBtn];
    
    self.currentTime = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(pauseBtn.frame) + 30, (44 - 24)/2, 48, 24)];
    currentTime.font = [UIFont boldSystemFontOfSize:16];
    currentTime.backgroundColor = [UIColor clearColor];
    currentTime.textColor = [UIColor colorWithHexHex:0xB8B9B7];
    currentTime.textAlignment = UITextAlignmentRight;
    [overlayView addSubview:currentTime];
    
    float with = self.view.bounds.size.width - 24*2 - 32 - 30*2 - 48 - 24*2 - 5*2 - 60;
    self.progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(currentTime.frame) + 10, (44 - 24)/2, with, 24)];
    [progressSlider setThumbImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerScrubberKnob" ofType:@"png"]] forState:UIControlStateNormal];
    [progressSlider setMinimumTrackImage:[[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerScrubberLeft" ofType:@"png"]] stretchableImageWithLeftCapWidth:5 topCapHeight:3] forState:UIControlStateNormal];
    [progressSlider setMaximumTrackImage:[[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerScrubberRight" ofType:@"png"]] stretchableImageWithLeftCapWidth:5 topCapHeight:3] forState:UIControlStateNormal];
    [progressSlider addTarget:self action:@selector(progressSliderMoved:) forControlEvents:UIControlEventValueChanged];
    progressSlider.maximumValue = player.duration;
    progressSlider.minimumValue = 0.0;
    [overlayView addSubview:progressSlider];
    
    self.duration = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(progressSlider.frame) + 10, (44 - 24)/2, 48, 24)];
    duration.font = [UIFont boldSystemFontOfSize:16];
    duration.backgroundColor = [UIColor clearColor];
    duration.textColor = [UIColor colorWithHexHex:0xB8B9B7];
    [overlayView addSubview:duration];
    
    duration.adjustsFontSizeToFitWidth = YES;
    currentTime.adjustsFontSizeToFitWidth = YES;
    
    self.stopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [stopBtn setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    stopBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [stopBtn setTitleColor:[UIColor colorWithHexHex:0x359BDD] forState:UIControlStateNormal];
    [stopBtn addTarget:self action:@selector(tapStopBtn) forControlEvents:UIControlEventTouchUpInside];
    stopBtn.frame = CGRectMake(self.view.bounds.size.width - 24 - 60, (44 - 40)/2, 60, 40);
    [overlayView addSubview:stopBtn];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.4];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [self.view addSubview:overlayView];
	[UIView commitAnimations];
    
    if (!iPad) {
        overlayView.frame = CGRectMake(0, 64, self.view.bounds.size.width, 44);
        pauseBtn.frame = CGRectMake(5, 6, 32, 32);
        currentTime.frame = CGRectMake(CGRectGetMaxX(pauseBtn.frame)-7, 10, 48, 24);
        progressSlider.frame = CGRectMake(CGRectGetMaxX(currentTime.frame) + 10, 10, 130, 24);
        duration.frame = CGRectMake(CGRectGetMaxX(progressSlider.frame) + 10, 10, 48, 24);
        stopBtn.frame = CGRectMake(CGRectGetMaxX(duration.frame), (44 - 40)/2, 40, 40);
    }
    
    [self play:url];
}

- (void)play:(NSURL *)url{
    NSError *error = nil;
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [player setNumberOfLoops:0];
    player.delegate = self;
    [player play];
    
    [self updateViewForPlayerInfo:player];
    [self updateViewForPlayerState:player];
    if (error)
        DDLogCError(@"play error:%@", error.description);
}

- (void)progressSliderMoved:(UISlider *)sender
{
	player.currentTime = sender.value;
	[self updateCurrentTimeForPlayer:player];
}

-(void)updateViewForPlayerInfo:(AVAudioPlayer*)p
{
	duration.text = [NSString stringWithFormat:@"%d:%02d", (int)p.duration / 60, (int)p.duration % 60, nil];
	progressSlider.maximumValue = p.duration;
}

- (void)updateViewForPlayerState:(AVAudioPlayer *)p
{
	[self updateCurrentTimeForPlayer:p];
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(updateCurrentTime) userInfo:nil repeats:YES];
}

- (void)updateCurrentTime
{
	[self updateCurrentTimeForPlayer:player];
}

-(void)updateCurrentTimeForPlayer:(AVAudioPlayer *)p
{
	NSString *current = [NSString stringWithFormat:@"%d:%02d", (int)p.currentTime / 60, (int)p.currentTime % 60, nil];
	NSString *dur = [NSString stringWithFormat:@"-%d:%02d", (int)((int)(p.duration - p.currentTime)) / 60, (int)((int)(p.duration - p.currentTime)) % 60, nil];
	duration.text = dur;
	currentTime.text = current;
	progressSlider.value = p.currentTime;
}

-(void)tapPauseBtn
{
	if (player.playing) {
        [pauseBtn setImage:WizImageByKind(ImageOfPlayIpadIconContinue) forState:UIControlStateNormal];
		[player pause];
	} else {
        [pauseBtn setImage:WizImageByKind(ImageOfPlayIpadIconPause) forState:UIControlStateNormal];
		if (![player play]) {
			NSLog(@"Could not play %@\n", player.url);
		}
	}
}

- (void) tapStopBtn
{
    [player stop];
    [overlayView removeFromSuperview];
}

#pragma mark AVAudioPlayer delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)p successfully:(BOOL)flag
{
	if (!flag)
		NSLog(@"the system could not decode the audio data.");
    [self tapStopBtn];
}

- (void)playerDecodeErrorDidOccur:(AVAudioPlayer *)p error:(NSError *)error
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Decode Error"
														message:[NSString stringWithFormat:@"Unable to decode audio file with error: %@", [error localizedDescription]]
													   delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	[alertView show];
}

@end
