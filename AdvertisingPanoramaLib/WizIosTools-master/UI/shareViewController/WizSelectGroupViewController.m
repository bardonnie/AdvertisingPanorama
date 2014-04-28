//
//  WizSelectGroupViewController.m
//  WizNote
//
//  Created by dzpqzb on 13-5-20.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizSelectGroupViewController.h"
@interface WizSelectGroupViewController()
{
    NSString* personalFolderKey;
    NSString* lastHeadTitle;
}
@property (nonatomic, strong) NSMutableSet* selectedAccountUserIds;
@property (nonatomic, strong) NSMutableArray* groupsArray;
@end

@implementation WizSelectGroupViewController
@synthesize groupsArray = _groupsArray;
@synthesize selectedAccountUserIds;
@synthesize delegate;
@synthesize minPrivilige;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        minPrivilige = 0;
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
    }
    return self;
}

- (id)initWithRootKey:(NSString *)rootKey
{
    self = [super initWithRootKey:rootKey];
    if (self) {
        willArchiveTree = NO;
        personalFolderKey = nil;
    }
    return self;
}

- (void) didSelectedEnd
{
    NSMutableSet* set = [NSMutableSet set];
    for (WizMapTreeNode* node in selectedAccountUserIds) {
        NSDictionary* dic = nil;
        if (node.kbGuid == nil) {
            dic = [NSDictionary dictionaryWithObject:[node.key substringFromIndex:[personalFolderKey length]] forKey:WizGlobalPersonalKbguid];
        }else{
            if ([node.key hasPrefix:WizGroupGuid]) {
                node.key = [node.key substringFromIndex:[WizGroupGuid length]];
            }
            dic = [NSDictionary dictionaryWithObject:node.key forKey:node.kbGuid];
        }
        [set addObject:dic];
    }
    [self.delegate didSelectedGroups:set];
}

- (void)cancelSelect
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void) viewDidLoad
{
    [super viewDidLoad];
    NSArray* dataArray = [[WizAccountManager defaultManager]allGroupedGroupsForAccountUserId:self.accountUserId];
    _groupsArray = [dataArray mutableCopy];
    
    self.selectedAccountUserIds = [NSMutableSet set];
    if (self.parentViewController.presentingViewController) {
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImage:WizImageByKind(BarIconCancel) target:self action:@selector(cancelSelect)];
    }else{
        self.navigationItem.leftBarButtonItem = nil;
    }
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:WizImageByKind(BarIconDone) target:self action:@selector(didSelectedEnd)];
    personalFolderKey = [rootTree.rootKey stringByAppendingString:WizStrPersonalNotes];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

- (void)reloadNodes:(WizMapTree *)tree
{
    for (NSArray* eachArray in _groupsArray) {
        if ([eachArray count]) {
            WizGroup* group = [eachArray objectAtIndex:0];
            if ([group isKindOfClass:[WizGroup class]] && group.guid) {
                WizMapTreeNode* node = [[WizMapTreeNode alloc]init];
                node.title = group.bizName;
                node.key = group.bizName;
                node.parentKey = rootTree.rootKey;
                [tree addMapTreeNode:node forKey:node.key];
            }
            BOOL hasGroupCanNewNote = NO;
            for (WizGroup* eachGroup in eachArray) {
                if ([WizUserPrivilige canNewNote:eachGroup.userGroup]) {
                    hasGroupCanNewNote = YES;
                    [self reloadNodes:tree group:eachGroup];
                }
            }
            if (!hasGroupCanNewNote) {
                [tree removeMapTreeNode:group.bizName];
            }
        }
    }
}



- (void) reloadNodes:(WizMapTree *)tree group:(WizGroup*)group
{
    id<WizInfoDatabaseDelegate> db = [WizDBManager getMetaDataBaseForKbguid:group.guid accountUserId:_accountUserId];
    if (group.guid == nil) {
        NSSet* modelFolders = [[NSSet setWithArray:[tree.treeNodes allKeys]] copy];
        NSSet* dbFolders = [db allFolders];
        NSMutableSet* localFolders = [NSMutableSet set];
        for (WizFolder* each in dbFolders) {
            if (![each.key hasPrefix:@"/"]) {
                each.key = [@"/" stringByAppendingString:each.key];
            }
            if ([each.key hasPrefix:WizDeletedItemsKey]) {
                continue;
            }
            if ([each.key isEqualToString:rootTree.rootKey]) {
                continue;
            }
            [localFolders addObject:[personalFolderKey stringByAppendingString:each.key]];
        }
        for (NSString* each in localFolders) {
            if (![modelFolders containsObject:each]) {
                [self addTreeNoteByKey:each mapTree:tree];
            }
        }
    }else{
        NSMutableArray* tags = [NSMutableArray arrayWithArray:[db allTagsForTree]];
        WizTag* groupTag = [[WizTag alloc] init];
        groupTag.guid = [WizGroupGuid stringByAppendingString:group.guid];
        groupTag.title = [NSString stringWithFormat:@" %@",group.title];
        groupTag.parentGUID = group.bizName;
        groupTag.localChanged = NO;
        groupTag.dateInfoModified = [NSDate date];
        [tags addObject:groupTag];
        NSSet* modelFolders = [[NSSet setWithArray:[tree.treeNodes allKeys]] copy];
        NSMutableSet* localFolders = [NSMutableSet set];
        NSMutableDictionary* localTagsDic = [NSMutableDictionary dictionary];
        
        for (WizTag* each in tags) {
            [localTagsDic setObject:each forKey:each.guid];
            [localFolders addObject:each.guid];
        }
        for (NSString* each in localFolders) {
            if (![modelFolders containsObject:each]) {
                WizTag* tag = [localTagsDic objectForKey:each];
                WizMapTreeNode* node = [[WizMapTreeNode alloc] init];
                if (tag.parentGUID == nil || [tag.parentGUID isEqualToString:@""]) {
                    node.parentKey = [WizGroupGuid stringByAppendingString:group.guid];
                }
                else
                {
                    node.parentKey = tag.parentGUID;
                }
                node.key = tag.guid;
                node.title = tag.title;
                node.isExpanded = NO;
                node.kbGuid = group.guid;
                [tree addMapTreeNode:node forKey:tag.guid];
            }
        }
    }
}


- (void) addTreeNoteByKey:(NSString*)key  mapTree:(WizMapTree*)tree
{
    if ([key isEqualToString:rootTree.rootKey]) {
        return;
    }
    NSString* parentFolder = [key stringByDeletingLastPathComponent];
    if ([parentFolder lastIndexOf:rootTree.rootKey] != parentFolder.length-1) {
        parentFolder = [parentFolder stringByAppendingString:@"/"];
        [self addTreeNoteByKey:parentFolder mapTree:tree];
    }
    if ([tree indexPathOfNodeKey:key]) {
        return;
    }
    if ([tree treeNodeForKey:key]) {
        return;
    }
    
    WizMapTreeNode* node = [[WizMapTreeNode alloc] init];
    node.key = key;
    node.parentKey = parentFolder;
    node.isExpanded = NO;
    node.title = [key lastPathComponent];
    [tree addMapTreeNode:node forKey:key];
}

- (void)decorateTreeCell:(WizTreeViewCell *)cell
{
    WizMapTreeNode* node = [rootTree treeNodeForKey:cell.treeNodeKeyString];
    if (node == nil) {
        return;
    }
    cell.titleLabel.text = getTagDisplayName(getFolderDisplayName(node.title));
}

#pragma mark - tableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WizMapTreeNode* node = [rootTree treeNodeForKey:[rootTree nodeKeyOfIndexPath:indexPath]];
    if ([node.parentKey isEqualToString:rootTree.rootKey]) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        [self onExpandedNodeByKey:node.key];
        return;
    }
    WizGroup* newGroup = [[WizAccountManager defaultManager]groupFroKbguid:node.kbGuid accountUserId:self.accountUserId];
    if (newGroup.guid == nil) {
        
    }else{
        WizTag* tag = [[WizTag alloc] init];
        if ([node.key hasPrefix:WizGroupGuid]) {
            tag.guid = [node.key substringFromIndex:[WizGroupGuid length]];
        }else{
            tag.guid = node.key;
        }
        tag.title = node.title;
        tag.parentGUID = node.parentKey;
    }
    
    if ([self.selectedAccountUserIds containsObject:node]) {
        [self.selectedAccountUserIds removeObject:node];
    }
    else
    {
        [self.selectedAccountUserIds addObject:node];
    }
//    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    if (iPad) {
        [self didSelectedEnd];
        [delegate dismissPopoverController:[NSString stringWithFormat:@"/%@/%@/",node.parentKey,node.title]];
    }
}

//- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString* cellIndentifier = @"asdhfjkashdfa";
//    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
//    }
//    WizGroup* group = [[self.groupArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    NSString* groupGuid = group.guid?group.guid:WizGlobalPersonalKbguid;
//    if ([self.selectedAccountUserIds containsObject:groupGuid]) {
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    }
//    else
//    {
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }
//    cell.textLabel.text = group.title;
//    return cell;
//}

//- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (section < 0) {
//        return nil;
//    }
//    WizMapTreeNode* node = [rootTree treeNodeForKey:[rootTree nodeKeyOfIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]]];
//    WizGroup* group = [[WizAccountManager defaultManager]groupFroKbguid:node.kbGuid accountUserId:self.accountUserId];
//    NSLog(@"%@  %@",lastHeadTitle,group.bizName);
//    if (lastHeadTitle && [lastHeadTitle isEqualToString:group.bizName]) {
//        return nil;
//    }
//    lastHeadTitle = group.bizName;
//    return lastHeadTitle;
//}


//- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    WizGroup* group = [[_groupsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    NSString* groupGuid = group.guid?group.guid:WizGlobalPersonalKbguid;
//    if ([self.selectedAccountUserIds containsObject:groupGuid]) {
//        [self.selectedAccountUserIds removeObject:groupGuid];
//    }
//    else
//    {
//        [self.selectedAccountUserIds addObject:groupGuid];
//    }
//    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//}

@end
