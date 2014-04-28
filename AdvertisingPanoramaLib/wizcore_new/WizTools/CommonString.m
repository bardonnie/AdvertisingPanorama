//
//  CommonString.m
//  Wiz
//
//  Created by Wei Shijun on 3/23/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "CommonString.h"
#import "WizObject.h"
extern   NSString* getTagDisplayName(NSString* tagName)
{
    if ([tagName isEqualToString:@"$public-documents$"])
        return WizTagPublic;
    else if ([tagName isEqualToString:@"$share-with-friends$"])
        return WizTagProtected;
    else
        return tagName;
}

extern  NSString* getFolderDisplayName(NSString* folderName)
{
    if ([folderName isEqualToString:@"My Notes"]) {
        return NSLocalizedString(@"My Notes", nil);
    }
    else if([folderName isEqualToString:@"Deleted Items"]){
        return NSLocalizedString(@"Deleted Items", nil);
    }
    else if([folderName isEqualToString:@"My Emails"]){
        return WizStrMyEmails;
    }
    else{
        return folderName;
    }
}


extern  NSString* getGroupRoleNoteByPrivilige(int userGroup)
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
