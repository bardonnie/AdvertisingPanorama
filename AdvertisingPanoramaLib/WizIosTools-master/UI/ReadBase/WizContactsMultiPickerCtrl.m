//
//  WizContactsMultiPickerCtrl.m
//  WizIphone7
//
//  Created by zhao on 3/27/14.
//  Copyright (c) 2014 dzpqzb inc. All rights reserved.
//

#import "WizContactsMultiPickerCtrl.h"
#import "NSString+TKUtilities.h"

@interface WizContactsMultiPickerCtrl(PrivateMethod)

- (void)saveAction:(id)sender;
- (void)dismissAction:(id)sender;

@end

@implementation WizContactsMultiPickerCtrl
@synthesize tableView = _tableView;
@synthesize delegate = _delegate;
@synthesize savedSearchTerm = _savedSearchTerm;
@synthesize savedScopeButtonIndex = _savedScopeButtonIndex;
@synthesize searchWasActive = _searchWasActive;
@synthesize searchBar = _searchBar;
@synthesize searchDisplayController;

#pragma mark -
#pragma mark Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _selectedCount = 0;
        _listContent = [NSMutableArray new];
        _filteredListContent = [NSMutableArray new];
    }
    return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
    if (!DEVICE_VERSION_BELOW_7) {
        [self.navigationController.navigationBar setBarTintColor:WizColorByKind(ColorOfDefaultTintColor)];
    }
    
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
    {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationBarBackgound"] forBarMetrics:UIBarMetricsDefault];
    }
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.tableView];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0)];
    self.searchBar.delegate = self;
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    if (DEVICE_VERSION_BELOW_7) {
        self.searchBar.frame = CGRectSetHeight(self.searchBar.frame, 44);
        self.tableView.tableHeaderView = self.searchBar;
//        self.searchBar.backgroundColor=[UIColor clearColor];
//        for (UIView *subview in self.searchBar.subviews)
//        {
//            if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
//            {
//                [subview removeFromSuperview];
//                break;
//            }
//        }
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"viewShadow.png"]];
//        [self.searchBar insertSubview:imageView atIndex:1];
    }
    self.searchDisplayController = [[UISearchDisplayController alloc]initWithSearchBar:_searchBar contentsController:self];
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;
    
    UILabel *customLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [customLab setTextColor:[UIColor whiteColor]];
    [customLab setText:NSLocalizedString(@"Contacts", nil)];
    [customLab setFont:[UIFont systemFontOfSize:18]];
    customLab.backgroundColor = [UIColor clearColor];
    customLab.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = customLab;
    
    UIButton *leftBarBtnItem = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [leftBarBtnItem addTarget:self action:@selector(dismissAction:) forControlEvents:UIControlEventTouchUpInside];
    [leftBarBtnItem setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [leftBarBtnItem setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc ]initWithCustomView:leftBarBtnItem]];
    
    UIButton *rightBarBtnItem = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    [rightBarBtnItem addTarget:self action:@selector(saveAction:) forControlEvents:UIControlEventTouchUpInside];
    [rightBarBtnItem setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    [rightBarBtnItem setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc ]initWithCustomView:rightBarBtnItem]];
    
    if (self.savedSearchTerm)
	{
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setText:_savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
	
	self.searchDisplayController.searchResultsTableView.scrollEnabled = YES;
	self.searchDisplayController.searchBar.showsCancelButton = NO;
    
    // Create addressbook data model
    NSMutableArray *addressBookTemp = [NSMutableArray array];
    ABAddressBookRef addressBooks = ABAddressBookCreate();
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBooks);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBooks);
    
    
    for (NSInteger i = 0; i < nPeople; i++)
    {
        WizAddressBook *addressBook = [[WizAddressBook alloc] init];
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        CFStringRef abName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        CFStringRef abLastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
        CFStringRef abFullName = ABRecordCopyCompositeName(person);
        
        NSString *nameString = (__bridge NSString *)abName;
        NSString *lastNameString = (__bridge NSString *)abLastName;
        
        if ((__bridge id)abFullName != nil) {
            nameString = (__bridge NSString *)abFullName;
        } else {
            if ((__bridge id)abLastName != nil)
            {
                nameString = [NSString stringWithFormat:@"%@ %@", nameString, lastNameString];
            }
        }
        
        addressBook.name = nameString;
        addressBook.recordID = (int)ABRecordGetRecordID(person);;
        addressBook.rowSelected = NO;
        
        ABPropertyID multiProperties[] = {
            kABPersonPhoneProperty,
            kABPersonEmailProperty
        };
        NSInteger multiPropertiesTotal = sizeof(multiProperties) / sizeof(ABPropertyID);
        for (NSInteger j = 0; j < multiPropertiesTotal; j++) {
            ABPropertyID property = multiProperties[j];
            ABMultiValueRef valuesRef = ABRecordCopyValue(person, property);
            NSInteger valuesCount = 0;
            if (valuesRef != nil) valuesCount = ABMultiValueGetCount(valuesRef);
            
            if (valuesCount == 0) {
                CFRelease(valuesRef);
                continue;
            }
            
            for (NSInteger k = 0; k < valuesCount; k++) {
                CFStringRef value = ABMultiValueCopyValueAtIndex(valuesRef, k);
                switch (j) {
                    case 0: {// Phone number
//                        addressBook.tel = [(__bridge NSString*)value telephoneWithReformat];
                        addressBook.tel = (__bridge NSString*)value;
                        break;
                    }
                    case 1: {// Email
                        addressBook.email = (__bridge NSString*)value;
                        break;
                    }
                }
                CFRelease(value);
            }
            CFRelease(valuesRef);
        }
        
        [addressBookTemp addObject:addressBook];
        
        if (abName) CFRelease(abName);
        if (abLastName) CFRelease(abLastName);
        if (abFullName) CFRelease(abFullName);
    }
    
    CFRelease(allPeople);
    CFRelease(addressBooks);
    
    // Sort data
    UILocalizedIndexedCollation *theCollation = [UILocalizedIndexedCollation currentCollation];
    for (WizAddressBook *addressBook in addressBookTemp) {
        NSInteger sect = [theCollation sectionForObject:addressBook
                                collationStringSelector:@selector(name)];
        addressBook.sectionNumber = sect;
    }
    
    NSInteger highSection = [[theCollation sectionTitles] count];
    NSMutableArray *sectionArrays = [NSMutableArray arrayWithCapacity:highSection];
    for (int i=0; i<=highSection; i++) {
        NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
        [sectionArrays addObject:sectionArray];
    }
    
    for (WizAddressBook *addressBook in addressBookTemp) {
        [(NSMutableArray *)[sectionArrays objectAtIndex:addressBook.sectionNumber] addObject:addressBook];
    }
    
    for (NSMutableArray *sectionArray in sectionArrays) {
        NSArray *sortedSection = [theCollation sortedArrayFromArray:sectionArray collationStringSelector:@selector(name)];
        [_listContent addObject:sortedSection];
    }
}

#pragma mark -
#pragma mark UITableViewDataSource & UITableViewDelegate

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else {
        if (iPad || DEVICE_VERSION_BELOW_7) {
            return nil;
        }
        return [[NSArray arrayWithObject:UITableViewIndexSearch] arrayByAddingObjectsFromArray:
                [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]];
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 0;
    } else {
        if (title == UITableViewIndexSearch) {
            [tableView scrollRectToVisible:self.searchDisplayController.searchBar.frame animated:NO];
            return -1;
        } else {
            return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index-1];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
	} else {
        return [_listContent count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else {
        return [[_listContent objectAtIndex:section] count] ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return 0;
    return [[_listContent objectAtIndex:section] count] ? tableView.sectionHeaderHeight : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [_filteredListContent count];
    } else {
        return [[_listContent objectAtIndex:section] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCustomCellID = @"QBPeoplePickerControllerCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCustomCellID];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCustomCellID];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	WizAddressBook *addressBook = nil;
	if (tableView == self.searchDisplayController.searchResultsTableView)
        addressBook = (WizAddressBook *)[_filteredListContent objectAtIndex:indexPath.row];
	else
        addressBook = (WizAddressBook *)[[_listContent objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if ([[addressBook.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0) {
        cell.textLabel.text = addressBook.name;
    } else {
        cell.textLabel.font = [UIFont italicSystemFontOfSize:cell.textLabel.font.pointSize];
        cell.textLabel.text = @"No Name";
    }
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setFrame:CGRectMake(30.0, 0.0, 28, 28)];
	[button setBackgroundImage:[UIImage imageNamed:@"sendme"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"sendme_selected"] forState:UIControlStateSelected];
	[button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
    [button setSelected:addressBook.rowSelected];
    
	cell.accessoryView = button;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		[self tableView:self.searchDisplayController.searchResultsTableView accessoryButtonTappedForRowWithIndexPath:indexPath];
		[self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	else {
		[self tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
    
    [self.navigationItem.rightBarButtonItem setEnabled:(_selectedCount > 0)];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	WizAddressBook *addressBook = nil;
    
	if (tableView == self.searchDisplayController.searchResultsTableView)
		addressBook = (WizAddressBook*)[_filteredListContent objectAtIndex:indexPath.row];
	else
        addressBook = (WizAddressBook*)[[_listContent objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (!addressBook.email) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"No mail information of this contact!", nil)];
        return;
    }
    
    BOOL checked = !addressBook.rowSelected;
    addressBook.rowSelected = checked;
    if (checked) _selectedCount++;
    else _selectedCount--;
    
    [self.navigationItem.rightBarButtonItem setEnabled:(_selectedCount > 0 ? YES : NO)];
    
    UITableViewCell *cell =[self.tableView cellForRowAtIndexPath:indexPath];
    UIButton *button = (UIButton *)cell.accessoryView;
    [button setSelected:checked];
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
}

- (void)checkButtonTapped:(id)sender event:(id)event
{
	NSSet *touches = [event allTouches];
	UITouch *touch = [touches anyObject];
	CGPoint currentTouchPosition = [touch locationInView:self.tableView];
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
	
	if (indexPath != nil)
	{
		[self tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
	}
}

#pragma mark -
#pragma mark Save action

- (void)saveAction:(id)sender
{
	NSMutableArray *objects = [NSMutableArray new];
    for (NSArray *section in _listContent) {
        for (WizAddressBook *addressBook in section)
        {
            if (addressBook.rowSelected && addressBook.email)
                [objects addObject:addressBook.email];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(contactsMultiPickerController:didFinishPickingDataWithInfo:)])
        [self.delegate contactsMultiPickerController:self didFinishPickingDataWithInfo:objects];
}

- (void)dismissAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(contactsMultiPickerControllerDidCancel:)])
        [self.delegate contactsMultiPickerControllerDidCancel:self];
    else
        [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)_searchBar
{
	[self.searchDisplayController.searchBar setShowsCancelButton:NO];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)_searchBar
{
	[self.searchDisplayController setActive:NO animated:YES];
	[self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
	[self.searchDisplayController setActive:NO animated:YES];
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark ContentFiltering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[_filteredListContent removeAllObjects];
    for (NSArray *section in _listContent) {
        for (WizAddressBook *addressBook in section)
        {
            NSComparisonResult result = [addressBook.name compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
            if (result == NSOrderedSame)
            {
                [_filteredListContent addObject:addressBook];
            }
        }
    }
}

- (void) searchBar:(UISearchBar *)searchBar_ textDidChange:(NSString *)searchText
{
    [self filterContentForSearchText:searchText scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    lastContentOffset = scrollView.contentOffset.y;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    if (lastContentOffset < scrollView.contentOffset.y && !DEVICE_VERSION_BELOW_7) {
        self.searchBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 0);;
        self.tableView.tableHeaderView = self.searchBar;
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.tableView.contentOffset.y < (-100) && !DEVICE_VERSION_BELOW_7) {
        [UIView animateWithDuration:.3f animations:^(void){
            self.searchBar.frame = CGRectMake(0, 60, self.view.bounds.size.width, 44);
            self.tableView.tableHeaderView = self.searchBar;
        } completion:^(BOOL finished){
        }];
    }
}

@end
