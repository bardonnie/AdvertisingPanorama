//
//  WizUIGlobals.m
//  WizNote
//
//  Created by wzz on 13-4-2.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizUIGlobals.h"
#import <QuartzCore/QuartzCore.h>
#import "SSLabel.h"

static NSString* const WizUIKeyOfCurrentState = @"WizUIKeyOfCurrentState";

static NSString* const WizIntroduceImagePath = @"WizIntroduceImagePath";
static NSString* const WizIntroduceDescripter = @"WizIntroduceDescripter";
static NSString* const WizIntroduceTitle = @"WizIntroduceTitle";

static NSString* const WizIntroduceNew = @"WizIntroduceNew";
static NSString* const WizIntroduceUpdate = @"WizIntroduceUpdate";
static NSString* const WizIntroduceIphone = @"WizIntroduceIphone";
static NSString* const WizIntroduceIpad = @"WizIntroduceIpad";

#define WizIntroduceSettingFileName  @"WizIntroduceData"

@interface WizNoDcoumentRemindView : UIView
@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) SSLabel* detailLabel;
@property (nonatomic, strong) NSString* titleText;
@property (nonatomic, strong) NSString* detailText;
@property (nonatomic, strong) UIImage* remindImage;
@end

@implementation WizNoDcoumentRemindView

@synthesize imageView = _imageView;
@synthesize titleLabel = _titleLabel;
@synthesize detailLabel = _detailLabel;
@synthesize detailText = _detailText;
@synthesize titleText = _titleText;
@synthesize remindImage = _remindImage;

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commitInit];
    }
    return self;
}
- (void) setRemindImage:(UIImage *)remindImage
{
    _remindImage = remindImage;
    _imageView.image = _remindImage;
    [self setNeedsLayout];
}

- (void) setDetailText:(NSString *)detailText
{
    _detailText = detailText;
    _detailLabel.text = _detailText;
    [self setNeedsLayout];
}

- (void) setTitleText:(NSString *)titleText
{
    _titleText = titleText;
    _titleLabel.text = _titleText;
    [self setNeedsLayout];
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    float minWidth = CGRectGetWidth(self.bounds)<CGRectGetHeight(self.bounds)?CGRectGetWidth(self.bounds):CGRectGetHeight(self.bounds);
    float imageHeight = minWidth*0.4;
    if (iPad) {
        imageHeight = minWidth*0.5;
    }
    
    CGRect imageFrame = CGRectSetCenter(self.bounds, CGSizeMake(_remindImage.size.width, _remindImage.size.height));
    imageFrame = CGRectSetY(imageFrame, imageHeight);
    _imageView.frame = imageFrame;
    
    CGSize titleTextSize = [_titleLabel.text sizeWithFont:_titleLabel.font];
    if (titleTextSize.width > minWidth || [_titleLabel.text firstLine].length < [_titleLabel.text length]) {
        _titleLabel.numberOfLines = 2;
    }
    CGRect titleRect = CGRectSetCenter(self.bounds, CGSizeMake(minWidth, titleTextSize.height * _titleLabel.numberOfLines));
    titleRect = CGRectSetY(titleRect, CGRectGetMaxY(imageFrame)+10);
    _titleLabel.frame = titleRect;
    
    CGSize detailTextSize = [_detailLabel.text sizeWithFont:_detailLabel.font];
    if (detailTextSize.width > minWidth || iPad) {
        _detailLabel.numberOfLines = 2;
    }
    CGRect detailRect = CGRectSetCenter(self.bounds, CGSizeMake(minWidth, detailTextSize.height * _detailLabel.numberOfLines));
    detailRect = CGRectSetY(detailRect, CGRectGetMaxY(titleRect)+5);
    _detailLabel.frame = detailRect;
    
}

NSString*(^WizUIKey)(NSString*) = ^(NSString*key) {
    return [NSString stringWithFormat:@"Wiz-ui-%@",key];
};
- (void) commitInit
{
    
    //
    self.backgroundColor = WizColorByKind(ColorOfDefaultBackgroud);
     _imageView= [[UIImageView alloc] init];
    _imageView.backgroundColor = [UIColor clearColor];
    
    
    [self addSubview:_imageView];
    
    UILabel* topLabel = [[UILabel alloc] init];
    topLabel.backgroundColor = [UIColor clearColor];
    topLabel.textAlignment = UITextAlignmentCenter;
    topLabel.font = [UIFont boldSystemFontOfSize:15];
    topLabel.textColor = [UIColor lightGrayColor];
    topLabel.lineBreakMode = NSLineBreakByTruncatingTail;
 
    _titleLabel = topLabel;
    [self addSubview:_titleLabel];
    //
    
    SSLabel* bottomLabel = [[SSLabel alloc] init];
    bottomLabel.backgroundColor = [UIColor clearColor];
    bottomLabel.textAlignment = UITextAlignmentCenter;
    bottomLabel.font = [UIFont systemFontOfSize:13];
    bottomLabel.textColor = [UIColor lightGrayColor];
    _detailLabel = bottomLabel;
    [self addSubview:bottomLabel];
}

@end

@interface WizUIGlobals ()
@property (nonatomic, strong) NSMutableDictionary* infoDictionary;
@end

@implementation WizUIGlobals
@synthesize infoDictionary;
- (id) init
{
    self = [super init];
    if (self) {
        infoDictionary = [NSMutableDictionary new];
        [infoDictionary setObject:@(WizUIstatueNormal) forKey:WizUIKey(WizUIKeyOfCurrentState)];
    }
    return self;
}
+ (WizUIGlobals*) shareInstance
{
    static WizUIGlobals* shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[WizUIGlobals alloc] init];
    });
    return shareInstance;
}
+ (UIView*)WizSelectCellBackgroundView
{
    UIView* view = [[UIView alloc]init];
    view.layer.shadowColor = (__bridge CGColorRef)(WizColorByKind(ColorOfDefaultBackgroud));
    view.layer.shadowOffset = CGSizeMake(0, 1);
    view.backgroundColor = WizColorByKind(ColorForDocCellSelectedView);
    return view;
}

+ (UIView *)WizUnreadDocumentCountViewByCount:(NSString *)count
{
    if (count == nil || [count isEqualToString:@""] || [count isEqualToString:@"0"] || [count integerValue]<0) {
        return nil;
    }else if([count integerValue]>99){
        count = @"99+";
    }
    float topMargin = 3.5;
    float leftMargin = 5.0;
    CGSize countStringSize = [count sizeWithFont:[UIFont boldSystemFontOfSize:12]];
    float labelWith = 12.0;
    if (countStringSize.width > labelWith) {
        labelWith = countStringSize.width;
    }
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(leftMargin, topMargin, labelWith, countStringSize.height)];
    label.text = count;
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:12];
    UIImageView* imageView = [[UIImageView alloc]initWithImage:[WizImageByKind(ImageOfUnreadDocumentCount) resizableImageWithCapInsets:UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)]];
    imageView.frame = CGRectMake(0, 0, labelWith + 2 * leftMargin, countStringSize.height + 2 * topMargin);
    [imageView addSubview:label];
    return imageView;
}

+ (UIView*)WizNoContentPromptView:(CGRect)rect image:(UIImage*)image_ text:(NSString*)text detailText:(NSString*)detailText
{
    if (!image_) {
        return nil;
    }
    WizNoDcoumentRemindView* reminderView = [[WizNoDcoumentRemindView alloc] initWithFrame:rect];
    reminderView.remindImage = image_;
    reminderView.titleText = text;
    reminderView.detailText = detailText;
    return reminderView;
}
// introduce

+ (NSArray*) getIntroduceDataWithNeedNew:(BOOL)isNew
{
    NSString* filePath = [[NSBundle mainBundle] pathForResource:WizIntroduceSettingFileName ofType:@"plist"];
    NSDictionary* dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
    //
    NSDictionary* plistDic = nil;
    if (![WizGlobals WizDeviceIsPad]) {
        plistDic = [dic objectForKey:WizIntroduceIphone];
    }
    else
    {
        plistDic = [dic objectForKey:WizIntroduceIpad];
    }
    if (isNew) {
        return [plistDic objectForKey:WizIntroduceNew];
    }
    else
    {
        return [plistDic objectForKey:WizIntroduceUpdate];
    }
}

+ (MYIntroductionView*) introduceViewWithData:(NSArray*)datas
{
    NSMutableArray* panels = [NSMutableArray new];
    for (NSDictionary* each in datas) {
        NSString* imageName = each[WizIntroduceImagePath];
        NSString* title = each[WizIntroduceTitle];
        NSString* descripter = each[WizIntroduceDescripter];
       
        NSString* filePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"jpg"];
        
        UIImage* image = [UIImage imageWithContentsOfFile:filePath];
        MYIntroductionPanel* panel = [[MYIntroductionPanel alloc] initWithimage:image title:NSLocalizedString(title, nil) description:NSLocalizedString(descripter, nil)];
        [panels addObject:panel];
        
        
    }
    
    CGRect rect = CGRectGetMainScreen((UIInterfaceOrientation)[[UIDevice currentDevice] orientation]);
    //
    MYIntroductionView* view = [[MYIntroductionView alloc] initWithFrame:rect headerText:WizStrWizNote panels:panels languageDirection:MYLanguageDirectionLeftToRight];
    view.backgroundColor = [UIColor colorWithHexHex:0xeef3f9];
    view.alpha = 1.0;
    return view;
}

+ (MYIntroductionView*) wizAppNewIntroduceView
{
    NSArray* datas = [WizUIGlobals getIntroduceDataWithNeedNew:YES];
    return [WizUIGlobals introduceViewWithData:datas];
}

+ (MYIntroductionView*) wizAppUpdateIntroduceView
{
    NSArray* datas = [WizUIGlobals getIntroduceDataWithNeedNew:NO];
    return [WizUIGlobals introduceViewWithData:datas];
}

+ (WizUIStatue) currentUIStatue
{
    return [[[WizUIGlobals shareInstance].infoDictionary objectForKey:WizUIKey(WizUIKeyOfCurrentState)] integerValue];
}
+ (void) setCurrentUIStatue:(WizUIStatue)statue
{
    [[WizUIGlobals shareInstance].infoDictionary setObject:@(statue) forKey:WizUIKey(WizUIKeyOfCurrentState)];
}
@end
