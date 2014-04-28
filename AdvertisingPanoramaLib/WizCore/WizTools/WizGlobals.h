//
//  WizGlobals.h
//  Wiz
//
//  Created by Wei Shijun on 3/4/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WizDBManager.h"
#import "WizSyncCenter.h"
#import "WizGlobalCache.h"
#import "WizNotificationCenter.h"
#import "WizFileManager.h"
#import "WizObject.h"
#import "NSString+WizString.h"
#import "NSDate+WizTools.h"
#import "CommonString.h"
#import "WizAccountManager.h"
#import "WizSettings.h"
#import "UIImage+WizTools.h"
#import "UIWebView+WizTools.h"
#import "WizAccountManager.h"
//#define _DEBUG
#ifdef _DEBUG
#define NSLog(s,...) ;
#else
#endif

void PRINT_CGRECT(CGRect rect);

static NSString* const  WizGlobalPersonalKbguid = @"WizGlobalPersonalKbguidKKKKKKKKKKKLLLLLL";

#define MaxDownloadProcessCount 10
// wiz-dzpqzb test
#define TestFlightToken             @"5bfb46cb74291758452c20108e140b4e_NjY0MzAyMDEyLTAyLTI5IDA0OjIwOjI3LjkzNDUxOQ"
#define WIZTESTFLIGHTDEBUG
#define WizBackgroundColor [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:240.0/255.0 alpha:1.0]
//
#define WizDocumentKeyString        @"document"
#define WizAttachmentKeyString      @"attachment"
#define WizTagKeyString             @"tag"
//
#define WizUpdateError              @"UpdateError"


//
//CGFloat WizStatusBarHeight(void) {
//    if ([[UIApplication sharedApplication] isStatusBarHidden]) return 0.0;
//    if (UIInterfaceOrientationIsLandscape(PPInterfaceOrientation()))
//        return [[UIApplication sharedApplication] statusBarFrame].size.width;
//    else
//        return [[UIApplication sharedApplication] statusBarFrame].size.height;
//}

//UIInterfaceOrientation WizInterfaceOrientation(void) {
//	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
//	return orientation;
//}
//
//CGRect WizScreenBounds(void) {
//	CGRect bounds = [UIScreen mainScreen].bounds;
//	if (UIInterfaceOrientationIsLandscape(WizInterfaceOrientation())) {
//		CGFloat width = bounds.size.width;
//		bounds.size.width = bounds.size.height;
//		bounds.size.height = width;
//	}
//	return bounds;
//}

//debug
#define WGDetailCellBackgroudColor  [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0]
//
#define MULTIBACK(block) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
#define MULTIMAIN(block) dispatch_async(dispatch_get_main_queue(),block)

#define WizLog(s,...) logTofile(__FILE__,(char *)__FUNCTION__ ,__LINE__,s,##__VA_ARGS__)


extern NSString* const WizCrashHanppend;

void logTofile(char*sourceFile, char*functionName ,int lineNumber,NSString* format,...);
@interface WizGlobals : NSObject {
    
}

+ (BOOL) isChineseEnviroment;
//
+(float) heightForWizTableFooter:(int)exisitCellCount orientation:(UIInterfaceOrientation)orientation;
+ (NSString*) folderStringToLocal:(NSString*) str;
+(int) currentTimeZone;


+(NSNumber*) wizNoteAppleID;
+(void) showAlertView:(NSString*)title message:(NSString*)message delegate: (id)callback retView:(UIAlertView**) pAlertView;
+(void) reportErrorWithString:(NSString*)error;
+(void) reportError:(NSError*)error;
+ (BOOL) checkObjectIsDocument:(NSString*)type;
+ (BOOL) checkObjectIsAttachment:(NSString*)type;
+(NSString*) genGUID;
+(BOOL) WizDeviceIsPad;

+(NSString*)fileMD5:(NSString*)path;
+ (NSURL*) wizServerUrl;
+ (const char*) wizServerUrlStdString;
+ (void) reportMemory;
+ (BOOL) checkAttachmentTypeIsAudio:(NSString*) attachmentType;
+ (BOOL) checkAttachmentTypeIsImage:(NSString *)attachmentType;
+(float) WizDeviceVersion;
+ (NSString*) documentKeyString;
+ (NSString*) attachmentKeyString;
//2012-2-22
+ (BOOL) checkAttachmentTypeIsPPT:(NSString*)type;
+ (BOOL) checkAttachmentTypeIsWord:(NSString*)type;
+ (BOOL) checkAttachmentTypeIsExcel:(NSString*)type;
+ (BOOL)checkAttachmentTypeIsPdf:(NSString*)attachmentType;
//2012-2-25
+ (BOOL) checkFileIsEncry:(NSString*)filePath;
+(void) reportWarningWithString:(NSString*)error;
+ (void) reportWarning:(NSError*)error;
//2012-3-9
//2012-3-16
//+ (NSString*) tagsDisplayStrFromGUIDS:(NSArray*)tags;
//2012-3-19
+ (BOOL) checkAttachmentTypeIsTxt:(NSString*)attachmentType;
+ (NSString*) wizNoteVersion;
+ (NSString*) localLanguageKey;
//
+ (NSString*) md5:(NSData *)input;
+ (NSString*) encryptPassword:(NSString*)password;
+ (BOOL) checkPasswordIsEncrypt:(NSString*)password;
+ (NSString*) ensurePasswordIsEncrypt:(NSString*)password;
//
+ (UIView*) noNotesRemind;
+ (UIView*) noNotesRemindFor:(NSString*)string;
//
+ (NSInteger)fileLength:(NSString*)path;
+ (BOOL) checkAttachmentTypeIsHtml:(NSString *)attachmentType;
+ (UIImage*) attachmentNotationImage:(NSString*)type;
//
+ (void) decorateViewWithShadowAndBorder:(UIView*)view;

+ (NSString*) AccountLoginInfo;
+ (void) setAccountInfo:(NSString*)info;
+ (NSString*) timerStringFromTimerInver:(NSTimeInterval) ftime;
+(BOOL) wizDeviceIsPhone5;

+ (void) setNavigationItemTitle:(NSString*)title;
+ (NSString*)getNavigationItemTitle;
+ (UILabel*)navigationTitleView:(NSString*)title prompt:(NSString*)prompt;

@end

extern BOOL WizDeviceIsPad(void);
//
@interface UIViewController (WizScreenBounds)
- (CGSize) contentViewSize;
@end


@interface WizTestSpendTime : NSObject
@end

@interface UIColor (Wiz)
+ (UIColor *) colorWithHexHex:(int)hex;

@end


@interface  NSBundle(Wiz)
+ (NSBundle*) WizBundle;
@end

@interface UIImage (WizBundleImage)
+ (UIImage*) imageWithNameFromWizBundle:(NSString*)name;
@end
