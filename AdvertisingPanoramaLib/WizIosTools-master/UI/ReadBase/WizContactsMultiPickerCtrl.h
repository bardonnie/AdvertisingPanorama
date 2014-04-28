//
//  WizContactsMultiPickerCtrl.h
//  WizIphone7
//
//  Created by zhao on 3/27/14.
//  Copyright (c) 2014 dzpqzb inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <malloc/malloc.h>
#import "WizAddressBook.h"
#import "SVProgressHUD.h"

@class WizAddressBook, WizContactsMultiPickerCtrl;

@protocol WizContactsMultiPickerCtrlDelegate <NSObject>
@required
- (void)contactsMultiPickerController:(WizContactsMultiPickerCtrl*)picker didFinishPickingDataWithInfo:(NSArray*)data;
- (void)contactsMultiPickerControllerDidCancel:(WizContactsMultiPickerCtrl*)picker;
@end

@interface WizContactsMultiPickerCtrl : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate>
{
@private
    NSUInteger _selectedCount;
    NSMutableArray *_listContent;
	NSMutableArray *_filteredListContent;
    float lastContentOffset;
}

@property (nonatomic, assign) id<WizContactsMultiPickerCtrlDelegate> delegate;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) UISearchBar *searchBar;
@property (nonatomic) UISearchDisplayController* searchDisplayController;

@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;
@end