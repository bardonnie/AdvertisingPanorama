//
//  CommonString.m
//  Wiz
//
//  Created by Wei Shijun on 3/23/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "CommonString.h"
#import "WizObject.h"
NSString* getTagDisplayName(NSString* tagName)
{
    if ([tagName isEqualToString:@"$public-documents$"])
        return WizTagPublic;
    else if ([tagName isEqualToString:@"$share-with-friends$"])
        return WizTagProtected;
    else
        return tagName;
}
NSString* getGroupRoleNoteByPrivilige(int userGroup)
{
    switch (userGroup) {
        case WizUserPriviligeTypeAdmin:
            return NSLocalizedString(@"Admin", nil);
        case WizUserPriviligeTypeAuthor:
            return NSLocalizedString(@"Author", nil);
        case WizUserPriviligeTypeEditor:
            return NSLocalizedString(@"Editor", nil);
        case WizUserPriviligeTypeSuper:
            return NSLocalizedString(@"Super User", nil);
        case WizUserPriviligeTypeNone:
            return NSLocalizedString(@"None", nil);
        case WizUserPriviligeTypeDefaultGroup:
            return NSLocalizedString(@"Admin", nil);
        case WizUserPriviligeTypeReader:
            return NSLocalizedString(@"Reader", nil);
        default:
            return NSLocalizedString(@"None", nil);
            break;
    }
}
