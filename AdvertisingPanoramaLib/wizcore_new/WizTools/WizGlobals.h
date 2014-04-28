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
#import "WizAccountManager.h"
#import "WizLogger.h"
#import "DDLog.h"
#import "UIViewController+WizAppStatus.h"
#import "WizNavigationViewController.h"
#import "NSObject+WizObject.h"

#ifdef __cplusplus

extern "C"
{
#endif
    void PRINT_CGRECT(CGRect rect);
    void PRINT_CGPOINT(CGPoint point);
    void PRINT_CGSIZE(CGSize size);
    void PRINT_UIEGDE(UIEdgeInsets ed);
    NSUInteger DeviceSystemMajorVersion();
#ifdef __cplusplus
}
#endif

#define DEVICE_VERSION_BELOW_7 (DeviceSystemMajorVersion() < 7)
#define DEVICE_VERSION_ABOVE_5 (DeviceSystemMajorVersion() > 5)
#define DEVICE_VERSION_BELOW_6 (DeviceSystemMajorVersion() < 6)

#define CGRectLoadViewFrame (DEVICE_VERSION_BELOW_7?[[UIScreen mainScreen] applicationFrame]:[UIScreen mainScreen].bounds)

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPad [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad
#define iPhone [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone


#if WIZ_DEBUG==1
    static const int ddLogLevel = LOG_LEVEL_VERBOSE;
//    #define NSLog(fmt,...) DDLogInfo(fmt, ##__VA_ARGS__)
#else
    static const int ddLogLevel = LOG_LEVEL_ERROR;
#endif

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

//Animation define
static NSString* const WizDeletedItemsKey = @"/Deleted Items/";


#define WizAnimationDuration  0.25

//#define _DEBUG
#ifdef _DEBUG
#define NSLog(s,...) ;
#else
#endif
extern void addArgumentToArray(NSMutableArray* array, id param);
extern void (^SendSelectorToObjectInMainThread)(SEL selector, id observer, id params);
extern void (^SendSelectorToObjectInMainThreadWith2Params)(SEL selector, id observer, id params, id);
extern void (^SendSelectorToObjectInMainThreadWith3Params)(SEL selector, id observer , id param1, id param2, id param3) ;
extern void (^SendSelectorToObjectInMainThreadWithoutParams)(SEL selecrot, id object);




static NSString* const  WizGlobalPersonalKbguid = @"WizGlobalPersonalKbguidKKKKKKKKKKKLLLLLL";
static NSString* const WizGlobalUserGuid = @"WizGlobalUserGuid";

#define MaxDownloadProcessCount 10
// wiz-dzpqzb test
#define TestFlightToken             @"5bfb46cb74291758452c20108e140b4e_NjY0MzAyMDEyLTAyLTI5IDA0OjIwOjI3LjkzNDUxOQ"
#define WIZTESTFLIGHTDEBUG
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
#define WGDetailCellBackgroudColor  WizColorByKind(ColorForNoBackgroundView)//[UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0]
//
#define MULTIBACK(block) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), block)
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

+(BOOL)deviceIsRetina;
+(NSNumber*) wizNoteAppleID;
+(void) showAlertView:(NSString*)title message:(NSString*)message delegate: (id)callback retView:(UIAlertView**) pAlertView;
+(void) reportErrorWithString:(NSString*)error;
+(void) reportError:(NSError*)error;
+ (BOOL) checkObjectIsDocument:(NSString*)type;
+ (BOOL) checkObjectIsAttachment:(NSString*)type;
+(NSString*) genGUID;
+(BOOL) WizDeviceIsPad;
+ (NSString*) wizSoftName;
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

+ (BOOL) isPasscodeViewControllingShowing;
+ (void) setPasscodeViewControlleringShowing:(BOOL)showing;
//md5
+ (NSString*) md5String:(NSString*)string;
+ (NSString*) md5CString:(const char*)string;

+ (NSString*) wizDeviceName;
+ (void) reportMessage:(NSString*)string withTitle:(NSString*)title;
//
+ (NSString*) appIdentifier;
//
+ (CGSize)labelSizeFromTextSize:(CGSize)textSize maxLength:(float)maxLength;
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
