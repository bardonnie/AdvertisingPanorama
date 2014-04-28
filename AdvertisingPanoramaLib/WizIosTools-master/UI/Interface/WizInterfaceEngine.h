//
//  WizInterfaceEngine.h
//  WizNote
//
//  Created by wzz on 13-4-3.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    WizThemeTypeBlue = 1,
}WizThemeType;

extern NSString* (^WizThemTypeKey)(WizThemeType);
extern UIImage* (^WizImageByTheme)(WizThemeType , NSString* kind);
extern UIImage* (^WizImageByKind)(NSString*kind);
extern UIColor* (^WizColorByKind)(NSString*kind);
extern NSArray* (^WizArrayByKind)(NSString*kind);
extern UIImage* (^WizImageAttachmentByKind)(NSString*kind);
extern UIColor* (^WizColorPatternByKind)(NSString* kind);
extern NSArray* (^WizImagesArrayByKind)(NSString*kind);
extern NSString* (^WizStringByKind)(NSString* kind);

static NSString* const ImageOfPlayBackgroud = @"ImageOfPlayBackgroud";
static NSString* const ImageOfPlayIconClose = @"ImageOfPlayIconClose";
static NSString* const ImageOfPlayIconStop = @"ImageOfPlayIconStop";
static NSString* const ImageOfPlayIconPlay = @"ImageOfPlayIconPlay";
static NSString* const ImageOfPlayIconPause = @"ImageOfPlayIconPause";
static NSString* const ColorOfPlayProgress  = @"ColorOfPlayProgress";
static NSString* const ColorOfPlayProgressBackground = @"ColorOfPlayProgressBackground";
static NSString* const ColorOfPlayProgressLine = @"ColorOfPlayProgressLine";
static NSString* const ColorOfPlayTimeLabelText = @"ColorOfPlayTimeLabelText";
static NSString* const ColorOfPlayProgressLabelText = @"ColorOfPlayProgressLabelText";

static NSString* const ImageOfPlayIpadIconPause = @"ImageOfPlayIpadIconPause";
static NSString* const ImageOfPlayIpadIconContinue = @"ImageOfPlayIpadIconContinue";

static NSString* const ImageOfIphoneLoginButtonNormal = @"ImageOfIphoneLoginButtonNormal";
static NSString* const ImageOfIphoneLoginButtonHighLight = @"ImageOfIphoneLoginButtonHighLight";
static NSString* const ImageOfIphoneRegisterButtonNormal = @"ImageOfIphoneRegisterButtonNormal";
static NSString* const ImageOfIphoneRegisterButtonHighLight = @"ImageOfIphoneRegisterButtonHighLight";
static NSString* const ImageIphoneLoginIconWeibo = @"ImageIphoneLoginIconWeibo";
static NSString* const ImageIpadLoginButtonNormal = @"ImageLoginButtonNormal";
static NSString* const ImageIpadLoginButtonLarge = @"ImageLoginButtonLarge";
static NSString* const ImageIpadLoginIconWeibo = @"ImageLoginWeibo";
static NSString* const ImageIpadLoginLandscapeBackground = @"ImageIpadLoginLandscapeBackground";
static NSString* const ImageIpadLoginPortraitBackground = @"ImageIpadLoginPortraitBackground";
static NSString* const ImageIpadLoginLogo = @"ImageIpadLoginLogo";
static NSString* const ImageIphoneLoginIconBack = @"ImageIphoneLoginIconBack";
static NSString* const ImageIphoneLoginIconFresh = @"ImageIphoneLoginIconFresh";

static NSString* const ImageAttachmentMark = @"ImageAttachmentMark";
static NSString* const WizThemeName = @"WizThemeName";
static NSString* const KeyOfWizThemeBlue = @"KeyOfWizThemeBlue";
static NSString* const ColorForNoBackgroundView = @"ColorForNoBackgroundView";
static NSString* const ColorForDocCellSelectedView = @"ColorForDocCellSelectedView";
static NSString* const NavigationBackgroudImage = @"NavigationBackgroudImage";
static NSString* const ToolBarBackgroundImage = @"ToolBarBackgroundImage";
static NSString* const GroupViewBackgroundImage = @"GroupViewBackgroundImage";
static NSString* const NavBarButtonBackgroundImage = @"NavBarButtonBackgroundImage";
static NSString* const ToolBarButtonBackgroundImage = @"ToolBarButtonBackgroundImage";
static NSString* const BackBarButtonBackgroundImage = @"BackBarButtonBackgroundImage";
static NSString* const DocListItemBackgroundImage = @"DocListItemBackgroundImage";
static NSString* const SegmentControlBackgroundImage = @"SegmentControlBackgroundImage";
static NSString* const ImageOfSegmentControlDividerLine = @"ImageOfSegmentControlDividerLine";
static NSString* const SegmentControlSelectedBackgroundImage = @"SegmentControlSelectedBackgroundImage";
static NSString* const BtnBackgroudAccountRegisterAndLogin = @"BtnBackgroudAccountRegisterAndLogin";
static NSString* const BtnBackgroudWelcomeRegisterAndLogin = @"BtnBackgroudWelcomeRegisterAndLogin";
static NSString* const BtnBackgroundAccountLogout = @"BtnBackgroundAccountLogout";
static NSString* const RecordBackgroundImage = @"RecordBackgroundImage";
static NSString* const BarIconSetting = @"BarIconSetting";
static NSString* const BarIconRefresh = @"BarIconRefresh";
static NSString* const BarIconHome = @"BarIconHome";
static NSString* const BarIconSearch = @"BarIconSearch";
static NSString* const BarIconAddNewNote = @"BarIconAddNewNote";
static NSString* const BarIconBack = @"BarIconBack";
static NSString* const BarIconEdit = @"BarIconEdit";
static NSString* const BarIconShare = @"BarIconShare";
static NSString* const BarIconDelete = @"BarIconDelete";
static NSString* const BarIconInfo = @"BarIconInfo";
static NSString* const ipad_barIcon_add = @"ipad_barIcon_add";
static NSString* const BarIconPhoto = @"BarIconPhoto";
static NSString* const BarIconCamera = @"BarIconCamera";
static NSString* const BarIconRecord = @"BarIconRecord";
static NSString* const BarIconStopRecord = @"BarIconStopRecord";
static NSString* const BarIconMore = @"BarIconMore";
static NSString* const BarIconRecentNote = @"BarIconRecentNote";
static NSString* const BarIconAttribute = @"BarIconAttribute";
static NSString* const BarIconCategory = @"BarIconCategory";
static NSString* const BarIconTag = @"BarIconTag";
static NSString* const BarIconDone = @"BarIconDone";
static NSString* const BarIconCancel = @"BarIconCancel";
static NSString* const BarIconPersonImage = @"BarIconPersonImage";
static NSString* const ImageKbListSectionBackgroud = @"ImageKbListSectionBackgroud";
static NSString* const ImageKbListPersonalNotesBG = @"ImageKbListPersonalNotesBG";
static NSString* const ImageKbListPersonalGroupsBG = @"ImageKbListPersonalGroupsBG";
static NSString* const ipad_barIcon_detail = @"ipad_barIcon_detail";

static NSString* const ImageGroupListPersonalIcon = @"ImageGroupListPersonalIcon";
static NSString* const ImageGroupListPersonalSelectedIcon = @"ImageGroupListPersonalSelectedIcon";
static NSString* const ImageListTitleSplit = @"ImageListTitleSplit";


static NSString* const ImageKbListEnterpriseBG = @"ImageKbListEnterpriseBG";
static NSString* const ImageKbListPersonalNotesSelectedBG = @"ImageKbListPersonalNotesSelectedBG";
static NSString* const ImageKbListPersonalGroupsSelectedBG = @"ImageKbListPersonalGroupsSelectedBG";
static NSString* const ImageKbListEnterpriseSelectedBG = @"ImageKbListEnterpriseSelectedBG";
static NSString* const ImageKbListExpandBG = @"ImageKbListExpandBG";
static NSString* const ImageKbListCardBackgroud = @"ImageKbListCardBackgroud";

static NSString* const ImageKbListMessageCenterBG = @"ImageKbListMessageCenterBG";
static NSString* const ImageKbListMessageCenterSelectedBG = @"ImageKbListMessageCenterSelectedBG";
static NSString* const ImageOfUnreadDocumentCount = @"ImageOfUnreadDocumentCount";

static NSString* const ColorOfGroupListCellHighlight = @"ColorOfGroupListCellHighlight";
static NSString* const ColorForKbListCellSeparatorLine = @"ColorForKbListCellSeparatorLine";
static NSString* const ColorForKbListCellText = @"ColorForKbListCellText";
static NSString* const ColorForKbListCellTextHighLight = @"ColorForKbListCellTextHighLight";
static NSString* const ColorKbListSectionTitleView = @"ColorKbListSectionTitleView";
static NSString* const ColorKbListSectionTitleShadowView = @"ColorKbListSectionTitleShadowView";
static NSString* const ColorForKbListSectionText = @"ColorForKbListSectionText";
static NSString* const ColorForKbListSectionTextShadow = @"ColorForKbListSectionTextShadow";
static NSString* const ColorAttachmentEditViewBackground = @"ColorAttachmentEditViewBackground";
static NSString* const ColorKbListCellSelectedView = @"ColorKbListCellSelectedView";
static NSString* const ImageOfKbListCellHighLightView = @"ImageOfKbListCellHighLightView";
static NSString* const ColorDocListSectionTitleView = @"ColorDocListSectionTitleView";
static NSString* const ColorDocListSectionTitleShadowView = @"ColorDocListSectionTitleShadowView";
static NSString* const ColorForDocListSectionText = @"ColorForDocListSectionText";
static NSString* const ColorForDocListSectionTextShadow = @"ColorForDocListSectionTextShadow";
static NSString* const BtnImageLeaveFullScreen = @"BtnImageLeaveFullScreen";
static NSString* const BtnImageEnterFullScreen = @"BtnImageEnterFullScreen";
static NSString* const BtnImagePasscodeFullBox = @"BtnImagePasscodeFullBox";
static NSString* const BtnImagePasscodeEmptyBox = @"BtnImagePasscodeEmptyBox";
static NSString* const BtnImageShowMoreAccount = @"BtnImageShowMoreAccount";
static NSString* const ImageOfAccountInLoginView = @"ImageOfAccountInLoginView";
static NSString* const ImageOfCategoryTableFooter = @"ImageOfCategoryTableFooter";
static NSString* const ImageOfTagTableFooter = @"ImageOfTagTableFooter";
static NSString* const ImageOfTreeItemClosed = @"ImageOfTreeItemClosed";
static NSString* const ImageOfTreeItemOpened = @"ImageOfTreeItemOpened";
static NSString* const ImageOfAttachmentTypeExcel = @"ImageOfAttachmentTypeExcel";
static NSString* const ImageOfAttachmentTypeHtml = @"ImageOfAttachmentTypeHtml";
static NSString* const ImageOfAttachmentTypePdf = @"ImageOfAttachmentTypePdf";
static NSString* const ImageOfAttachmentTypePpt = @"ImageOfAttachmentTypePpt";
static NSString* const ImageOfAttachmentDeleteIcon = @"ImageOfAttachmentDeleteIcon";
static NSString* const ImageOfAttachmentTypeTxt = @"ImageOfAttachmentTypeTxt";
static NSString* const ImageOfAttachmentTypeWav = @"ImageOfAttachmentTypeWav";
static NSString* const ImageOfAttachmentTypeWord = @"ImageOfAttachmentTypeWord";
static NSString* const ImageOfAttachmentTypeImg = @"ImageOfAttachmentTypeImg";
static NSString* const ImageOfAttachmentTypeOthers = @"ImageOfAttachmentTypeOthers";
static NSString* const ImageOfPullRefreshArrow = @"ImageOfPullRefreshArrow";
static NSString* const ColorForTreeFooterViewBackground = @"ColorForTreeFooterViewBackground";
static NSString* const ColorForTreeFooterViewText = @"ColorForTreeFooterViewText";
static NSString* const ImagesForStopRecording = @"ImagesForStopRecording";
static NSString* const ImageHighlitedDocumentGridItem = @"ImageHighlitedDocumentGridItem";
static NSString* const ImagesForGuideNewUser = @"ImagesForGuideNewUser";
static NSString* const ImagesForGuideUserUpdate = @"ImagesForGuideUserUpdate";
static NSString* const ImageOfRecordActiveState = @"ImageOfRecordActiveState";
static NSString* const ImageOfRecordInactiveState = @"ImageOfRecordInactiveState";
static NSString* const ImageOfRecordKeyboardUnder = @"ImageOfRecordKeyboardUnder";
static NSString* const ImageOfRecordKeyboardUp = @"ImageOfRecordKeyboardUp";
static NSString* const ColorDocumentListBackgroud = @"ColorDocumentListBackgroud";
static NSString* const ColorReadDocumentTitleLine = @"ColorReadDocumentTitleLine";
static NSString* const ColorOfDefaultBackgroud = @"ColorOfDefaultBackgroud";
static NSString* const ImagesOfRecordingProgress = @"ImagesOfRecordingProgress";
static NSString* const ImageIphoneListCamera = @"ImageIphoneListCamera";
static NSString* const ImageIphoneListRecord = @"ImageIphoneListRecord";
static NSString* const ImageIphoneListNew = @"ImageIphoneListNew";
static NSString* const ImageIphoneListShadow = @"ImageIphoneListShadow";
static NSString* const ColorIphoneListBarText = @"ColorIphoneListBarText";
//
static NSString* const ImageOfRecordStop = @"ImageOfRecordStop";
static NSString* const ImageOfRecordStopHighlighted = @"ImageOfRecordStopHighlighted";
static NSString* const ImageOfRecordStart = @"ImageOfRecordStart";
static NSString* const ImageOfRecordStartHighlighted = @"ImageOfRecordStartHighlighted";
//recording progress
static NSString* const ImageOfRecordingProgressCircle = @"ImageOfRecordingProgressCircle";
static NSString* const ImageOfRecordingProgressMac = @"ImageOfRecordingProgressMac";
static NSString* const ColorRecordingViewBackgroud = @"ColorRecordingViewBackgroud";

static NSString* const ImageOfIphoneTagIcon = @"ImageOfIphoneTagIcon";
static NSString* const ImageOfIphoneTagCellBackShadow = @"ImageOfIphoneTagCellBackShadow";
static NSString* const ImageOfIphoneTagCellFrontShadow = @"ImageOfIphoneTagCellFrontShadow";
static NSString* const ImageOfIPhoneTagCellBoxOpen = @"ImageOfIPhoneTagCellBoxOpen";
static NSString* const ImageOfIPhoneTagCellBoxOff = @"ImageOfIPhoneTagCellBoxOff";

static NSString* const ImageOfUnUpdateDocumentSymbol = @"ImageOfUnUpdateDocumentSymbol";
static NSString* const ImageOfReadViewProcessGradual = @"ImageOfReadViewProcessGradual";
static NSString* const ColorForReadViewProcessView = @"ColorForReadViewProcessView";


static NSString* const Imageofpurchasebuttonbackgroud = @"Imageofpurchasebuttonbackgroud";
static NSString* const ImageOfPurchaseButtonBackgroudhighlighted = @"ImageOfPurchaseButtonBackgroudhighlighted";

static NSString* const ImageOfWizNotePro = @"ImageOfWizNotePro";
static NSString* const ImageOfWizNoteFree = @"ImageOfWizNotePro";

static NSString* const ImageOfMessageGroupsColosed = @"ImageOfMessageGroupsColosed";
static NSString* const ImageOfMessageGroupsOpened = @"ImageOfMessageGroupsOpened";
static NSString* const ImageOfMessageSenderDefault = @"ImageOfMessageSenderDefault";
static NSString* const ImageOfMessageListItemBackground = @"ImageOfMessageListItemBackground";
static NSString* const ImageOfMessageGroupListBackground = @"ImageOfMessageGroupListBackground";

static NSString* const ImageOfReadViewPreviousEnable = @"ImageOfReadViewPreviousEnable";
static NSString* const ImageOfReadViewNextEnable = @"ImageOfReadViewNextEnable";
static NSString* const ImageOfCustomerBackBarButton = @"ImageOfCustomerBackBarButton";
static NSString* const ImageOfNoBackgroundBarButtonBG = @"ImageOfNoBackgroundBarButtonBG";

static NSString* const ColorOfGroupListBackground = @"ColorOfGroupListBackground";

//iphone define
static NSString* const ImageOfTabBarCategorySelected = @"ImageOfTabBarCategorySelected";
static NSString* const ImageOfTabBarAttributeSelected = @"ImageOfTabBarAttributeSelected";
static NSString* const ImageOfTabBarNoteSelected = @"ImageOfTabBarNoteSelected";
static NSString* const ImageOfTabBarTagSelected = @"ImageOfTabBarTagSelected";
static NSString* const ImageOfTabBarSearchSelected = @"ImageOfTabBarSearchSelected";
static NSString* const ImageOfTabBarBackGroud = @"ImageOfTabBarBackGroud";
static NSString* const ImageOfTabBarItemSelected = @"ImageOfTabBarItemSelected";
static NSString* const ImageOfTabBarItemSelectedLeft = @"ImageOfTabBarItemSelectedLeft";
static NSString* const ImageOfTabBarItemSelectedRight = @"ImageOfTabBarItemSelectedRight";

static NSString* const ImageOfNoNoteForCategory = @"ImageOfNoNoteForCategory";
static NSString* const ImageOfNoNoteForTag = @"ImageOfNoNoteForTag";
static NSString* const ImageOfNoNoteForSearch = @"ImageOfNoNoteForSearch";
static NSString* const ImageOfNoNoteForPersonalNotes = @"ImageOfNoNoteForPersonalNotes";
static NSString* const ImageOfNoMessages = @"ImageOfNoMessages";

static NSString* const ImageOfPlayProgressBackground = @"ImageOfPlayProgressBackground";
static NSString* const ImageOfLaunchBackground = @"ImageOfLaunchBackground";
static NSString* const ImageOfLaunchLogo = @"ImageOfLaunchLogo";
static NSString* const ImageOfLaunchWizName = @"ImageOfLaunchWizName";

static NSString* const ImageOfAttachmentCellBackground = @"ImageOfAttachmentCellBackground";
static NSString* const ImageOfMoreAttachmentButton = @"ImageOfMoreAttachmentButton";

static NSString* const ImageOfBarIconMarkMessageReaded = @"ImageOfBarIconMarkMessageReaded";
static NSString* const ColorOfRefreshHeaderBackground = @"ColorOfRefreshHeaderBackground";
static NSString* const ColorOfDefaultLines = @"ColorOfDefaultLines";
static NSString* const ColorOfDocumentCellBackground = @"ColorOfDocumentCellBackground";
static NSString* const ColorOfDefaultGrayText = @"ColorOfDefaultGrayText";
static NSString* const ColorOfReadViewTitleBackground = @"ColorOfReadViewTitleBackground";
static NSString* const ColorOfDefaultTintColor = @"ColorOfDefaultTintColor";
static NSString* const ColorOfTreeRootCellBackground = @"ColorOfTreeRootCellBackground";
static NSString* const ColorOfTreeChildCellBackground = @"ColorOfTreeChildCellBackground";
static NSString* const ColorOfTreeChildCellRedLines = @"ColorOfTreeChildCellRedLines";
static NSString* const ColorOfTagTreeCellBackground = @"ColorOfTagTreeCellBackground";
static NSString* const ColorOfMessageCellTimeLine = @"ColorOfMessageCellTimeLine";
static NSString* const ColorOfMessageCellAtTypeBackground = @"ColorOfMessageCellAtTypeBackground";
static NSString* const ColorOfMessageCellEditTypeBackground = @"ColorOfMessageCellEditTypeBackground";
static NSString* const ColorOfMessageCellCommentTypeBackground = @"ColorOfMessageCellCommentTypeBackground";
static NSString* const ImageOfFunctionMessagesNormal = @"ImageOfFunctionMessagesNormal";
static NSString* const ImageOfFunctionMessagesHilighted = @"ImageOfFunctionMessagesHilighted";
static NSString* const ImageOfFunctionFavariteNormal = @"ImageOfFunctionFavariteNormal";
static NSString* const ImageOfFunctionFavariteHilighted = @"ImageOfFunctionFavariteHilighted";
static NSString* const ImageOfFunctionSyncNormal = @"ImageOfFunctionSyncNormal";
static NSString* const ImageOfFunctionSyncHighlited = @"ImageOfFunctionSyncHighlited";
static NSString* const ImageOfFunctionUserAvaterNormal = @"ImageOfFunctionUserAvaterNormal";
static NSString* const ImageOfFunctionUserAvaterHighlited = @"ImageOfFunctionUserAvaterHighlited";
static NSString* const ImageOfFunctionAudioNormal = @"ImageOfFunctionAudioNormal";
static NSString* const ImageOfFunctionAudioHighlited = @"ImageOfFunctionAudioHighlited";
static NSString* const ImageOfFunctioncameraNormal = @"ImageOfFunctioncameraNormal";
static NSString* const ImageOfFunctioncameraHighlited = @"ImageOfFunctioncameraHighlited";
static NSString* const ImageOfFunctionNoteNormal = @"ImageOfFunctionNoteNormal";
static NSString* const ImageOfFunctionNoteHighlited = @"ImageOfFunctionNoteHighlited";
static NSString* const ImageOfFunctionHome = @"ImageOfFunctionHome";
static NSString* const ImageOfFunctionHomeHighlited = @"ImageOfFunctionHomeHighlited";
static NSString* const ImageOfFunctionCurrentList = @"ImageOfFunctionCurrentList";
static NSString* const ImageOfFunctionCurrentListHighlited = @"ImageOfFunctionCurrentListHighlited";
static NSString* const ColorOfAppBackgroud = @"ColorOfAppBackgroud";
static NSString* const ImageOfFunctionBackgroud = @"ImageOfFunctionBackgroud";
static NSString* const ImageOfMessageTypeAt = @"ImageOfMessageTypeAt";
static NSString* const ImageOfMessageTypeAll = @"ImageOfMessageTypeAll";
static NSString* const ImageOfMessageTypeEdited = @"ImageOfMessageTypeEdited";
static NSString* const ImageOfMessageTypeComment = @"ImageOfMessageTypeComment";
static NSString* const ColorOfWizSegementControlHilight = @"ColorOfWizSegementControlHilight";
static NSString* const ImageOfPasswordVisible = @"ImageOfPasswordVisible";
static NSString* const ImageOfPasswordInVisible = @"ImageOfPasswordInVisible";
static NSString* const ImageOfLoginTextFieldBackground = @"ImageOfLoginTextFieldBackground";
static NSString* const ColorOfNavigationBarTitle = @"ColorOfNavigationBarTitle";
static NSString* const StringOfNavigationBarTitleFont = @"StringOfNavigationBarTitleFont";
static NSString* const ColorOfForgetPasswordButtonTitle = @"ColorOfForgetPasswordButtonTitle";
static NSString* const ColorOfForgetPasswordButtonTitleHighlight = @"ColorOfForgetPasswordButtonTitleHighlight";
static NSString* const ColorOfSkipButtonTitle = @"ColorOfSkipButtonTitle";
static NSString* const ColorOfSkipButtonTitleHighlight = @"ColorOfSkipButtonTitleHighlight";
static NSString* const ColorOfLoginButtonTitle = @"ColorOfLoginButtonTitle";
static NSString* const ColorOfLoginButtonTitleHighlight = @"ColorOfLoginButtonTitleHighlight";
static NSString* const ColorOfRegisterButtonTitle = @"ColorOfRegisterButtonTitle";
static NSString* const ColorOfRegisterButtonTitleHighlight = @"ColorOfRegisterButtonTitleHighlight";
static NSString* const ColorOfOpenApiLoginButtonTitle = @"ColorOfOpenApiLoginButtonTitle";
static NSString* const ColorOfOpenApiLoginButtonTitleHighlight = @"ColorOfOpenApiLoginButtonTitleHighlight";
static NSString* const ImageOfBarIconComment = @"ImageOfBarIconComment";
static NSString* const ImageOfBarIconUnFavi = @"ImageOfBarIconUnFavi";
static NSString* const ImageOfBarIconfavied = @"ImageOfBarIconfavied";
static NSString* const BarIconAttachment = @"BarIconAttachment";
static NSString* const ImageOfTitleViewAttachmentNumberBG = @"ImageOfTitleViewAttachmentNumberBG";
static NSString* const ImageOfSortTypeDateCreateDesc = @"ImageOfSortTypeDateCreateDesc";
static NSString* const ImageOfSortTypeDateModifyDesc = @"ImageOfSortTypeDateModifyDesc";
static NSString* const ImageOfSortTypeNoteTitleAsc = @"ImageOfSortTypeNoteTitleAsc";
static NSString* const ImageOfAddNewFolder = @"ImageOfAddNewFolder";
static NSString* const ImageOfAddNewTag = @"ImageOfAddNewTag";
static NSString* const ImageOfSortDoumentButton = @"ImageOfSortDoumentButton";
static NSString* const ImageOfWebViewGoBackArrow = @"ImageOfWebViewGoBackArrow";
static NSString* const ImageOfWebViewGoForwardArrow = @"ImageOfWebViewGoForwardArrow";
static NSString* const ImageOfSmallInfoIcon = @"ImageOfSmallInfoIcon";
static NSString* const ImageOfCustomerLandScapeBackBarButton = @"ImageOfCustomerLandScapeBackBarButton";
static NSString* const ColorForCellSelectedView = @"ColorForCellSelectedView";
static NSString* const ImageOfProcessHUGCheckmark = @"ImageOfProcessHUGCheckmark";
static NSString* const ImageOfFunctionSetting = @"ImageOfFunctionSetting";
static NSString* const ImageOfFunctionSettingHighlited = @"ImageOfFunctionSettingHighlited";
static NSString* const ImageOfRightArrow = @"ImageOfRightArrow";
static NSString* const ImageOfViewPhotoCopyIcon = @"ImageOfViewPhotoCopyIcon";
static NSString* const ImageOfViewPhotoSaveIcon = @"ImageOfViewPhotoSaveIcon";
static NSString* const ImageOfViewPhotoShareIcon = @"ImageOfViewPhotoShareIcon";
static NSString* const ImageOfEditNoteSelectFolder = @"ImageOfEditNoteSelectFolder";
static NSString* const ImageOfEditNoteInfo = @"ImageOfEditNoteInfo";
static NSString* const ImageOfEditNoteAttachments = @"ImageOfEditNoteAttachments";
static NSString* const ImageOfGuideSkip = @"ImageOfGuideSkip";

//password protection
static NSString* const ImageOfPasswordProtectionBG = @"ImageOfPasswordProtectionBG";
static NSString* const ImageOfPasswordProtectionOne = @"ImageOfPasswordProtectionOne";
static NSString* const ImageOfPasswordProtectionOneSelected = @"ImageOfPasswordProtectionOneSelected";
static NSString* const ImageOfPasswordProtectionTwo = @"ImageOfPasswordProtectionTwo";
static NSString* const ImageOfPasswordProtectionTwoSelected = @"ImageOfPasswordProtectionTwoSelected";
static NSString* const ImageOfPasswordProtectionThree = @"ImageOfPasswordProtectionThree";
static NSString* const ImageOfPasswordProtectionThreeSelected = @"ImageOfPasswordProtectionThreeSelected";
static NSString* const ImageOfPasswordProtectionFour = @"ImageOfPasswordProtectionFour";
static NSString* const ImageOfPasswordProtectionFourSelected = @"ImageOfPasswordProtectionFourSelected";
static NSString* const ImageOfPasswordProtectionFive = @"ImageOfPasswordProtectionFive";
static NSString* const ImageOfPasswordProtectionFiveSelected = @"ImageOfPasswordProtectionFiveSelected";
static NSString* const ImageOfPasswordProtectionSix = @"ImageOfPasswordProtectionSix";
static NSString* const ImageOfPasswordProtectionSixSelected = @"ImageOfPasswordProtectionSixSelected";
static NSString* const ImageOfPasswordProtectionSeven = @"ImageOfPasswordProtectionSeven";
static NSString* const ImageOfPasswordProtectionSevenSelected = @"ImageOfPasswordProtectionSevenSelected";
static NSString* const ImageOfPasswordProtectionEight = @"ImageOfPasswordProtectionEight";
static NSString* const ImageOfPasswordProtectionEightSelected = @"ImageOfPasswordProtectionEightSelected";
static NSString* const ImageOfPasswordProtectionNine = @"ImageOfPasswordProtectionNine";
static NSString* const ImageOfPasswordProtectionNineSelected = @"ImageOfPasswordProtectionNineSelected";
static NSString* const ImageOfPasswordProtectionZero = @"ImageOfPasswordProtectionZero";
static NSString* const ImageOfPasswordProtectionZeroSelected = @"ImageOfPasswordProtectionZeroSelected";
static NSString* const ImageOfPasswordProtectionPS = @"ImageOfPasswordProtectionPS";
static NSString* const ImageOfPasswordProtectionPSSelected = @"ImageOfPasswordProtectionPSSelected";

static NSString* const PadImageOfMessageTag = @"PadImageOfMessageTag";
static NSString* const PadImageOfMessageTypeAll = @"PadImageOfMessageTypeAll";
static NSString* const PadImageOfMessageTypeAt = @"PadImageOfMessageTypeAt";
static NSString* const PadImageOfMessageTypeEdit = @"PadImageOfMessageTypeEdit";
static NSString* const PadImageOfMessageTypeReview = @"PadImageOfMessageTypeReview";
static NSString* const PadImageOfMessageNumberZero = @"PadImageOfMessageNumberZero";
static NSString* const PadImageOfMessageNumberPositive = @"PadImageOfMessageNumberPositive";
static NSString* const PadIconHomeWithUnreadMark = @"PadIconHomeWithUnreadMark";
static NSString* const PadColorOfLeftBarBackground = @"PadColorOfLeftBarBackground";
static NSString* const PadColorOfDocumentsListBackground = @"PadColorOfDocumentsListBackground";
static NSString* const PadColorOfDocumentItemBackground = @"PadColorOfDocumentItemBackground";

@interface WizInterfaceEngine : NSObject
+ (void)loadInterfaceTheme:(WizThemeType)type themeFileName:(NSString*)name;
+ (void)loadInterfaceTheme:(WizThemeType)type;
+ (NSArray*)imagesArrayForKind:(NSString*)kind;
@end
