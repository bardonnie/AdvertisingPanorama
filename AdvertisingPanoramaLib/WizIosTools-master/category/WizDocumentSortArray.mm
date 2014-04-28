//
//  WizDocumentSortArray.m
//  WizNote
//
//  Created by dzpqzb on 13-5-2.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizDocumentSortArray.h"
#import "NSString+WizString.h"
#import <objc/runtime.h>

static char WizNSArrayKeySortedType;


@implementation WizDocument (Sorted)
- (NSComparisonResult) compareWithDocument:(WizDocument*)doc byType:(CWizDocumentsSortedType)type
{
    switch (type) {
        case CWizDocumentsSortedTypeByCreatedDateAsc:
            return [self.dateCreated compare:doc.dateCreated];
            break;
        case CWizDocumentsSortedTypeByCreatedDateDesc:
            return [doc.dateCreated compare:self.dateCreated];
            break;
        case CWizDocumentsSortedTypeByModifiedDateAsc:
            return [self.dateModified compare:doc.dateModified];
            break;
        case CWizDocumentsSortedTypeByModifiedDateDesc:
            return [doc.dateModified  compare:self.dateModified];
        case CWizDocumentsSortedTypeByTitleAsc:
            return [self.title compareByChinese:doc.title];
        case CWizDocumentsSortedTypeByTitleDesc:
            return [doc.title compareByChinese:self.title];
        default:
            return NSOrderedSame;
            break;
    }
}

- (NSString*) groupKeyBySortedType:(CWizDocumentsSortedType)type
{
    if ([self localChanged] != WizEditDocumentTypeNoChanged) {
        return WizStrDocumentListUnSyncedSectionTitle;
    }
    switch (type) {
        case CWizDocumentsSortedTypeByTitleDesc:
        case CWizDocumentsSortedTypeByTitleAsc:
            return [self.title pinyinFirstLetter];
            break;
        case CWizDocumentsSortedTypeByModifiedDateDesc:
        case CWizDocumentsSortedTypeByModifiedDateAsc:
            return [self.dateModified stringYearAndMounth];
            break;
        case CWizDocumentsSortedTypeByCreatedDateDesc:
        case CWizDocumentsSortedTypeByCreatedDateAsc:
            return [self.dateCreated stringYearAndMounth];
            break;
        default:
            return @"#";
            break;
    }
}

@end

@implementation NSMutableArray (WizDocumentSortArray)
@dynamic sortedType;

- (BOOL) isSortedTypeReverse
{
    switch (self.sortedType) {
        case CWizDocumentsSortedTypeByCreatedDateAsc:
        case CWizDocumentsSortedTypeByModifiedDateAsc:
        case CWizDocumentsSortedTypeByTitleAsc:
            return NO;
            break;
        case CWizDocumentsSortedTypeByCreatedDateDesc:
        case CWizDocumentsSortedTypeByModifiedDateDesc:
        case CWizDocumentsSortedTypeByTitleDesc:
            return YES;
            break;
        default:
            return NO;
    }
}

- (CWizDocumentsSortedType) sortedType
{
    NSNumber* number = objc_getAssociatedObject(self, &WizNSArrayKeySortedType);
    if (!number) {
        return CWizDocumentsSortedTypeByModifiedDateDesc;
    }
    return (CWizDocumentsSortedType)[number integerValue];
}
- (void) setSortedType:(CWizDocumentsSortedType)sortedType
{
    objc_setAssociatedObject(self, &WizNSArrayKeySortedType, [NSNumber numberWithInt:sortedType], OBJC_ASSOCIATION_ASSIGN);
}

- (NSString*)groupKey
{
    if ([self count]) {
        id lastObject = [self lastObject];
        if ([lastObject isKindOfClass:[WizDocument class]]) {

            return [(WizDocument*)lastObject groupKeyBySortedType:self.sortedType];
        }
    }
    return @"#";
}
@end

static char WizSortedKeyStoredDictionary;

@implementation NSMutableArray (WizMutableSortedArray)
@dynamic sortedDictionary;
- (WizDocument*) documentForIndexPath:(NSIndexPath *)indexPath
{
    return [[self objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}
- (NSMutableDictionary*) sortedDictionary
{
    NSMutableDictionary* dic = objc_getAssociatedObject(self, &WizSortedKeyStoredDictionary);
    if (!dic) {
        dic = [NSMutableDictionary new];
        objc_setAssociatedObject(self, &WizSortedKeyStoredDictionary, dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return dic;
}
- (void) sortDocumentGroups
{
    BOOL isReverse = self.isSortedTypeReverse;
    [self sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if (!isReverse) {
            return [[obj1 groupKey] compare:[obj2 groupKey] options:NSCaseInsensitiveSearch];
        }
        else
        {
            return [[obj2 groupKey] compare:[obj1 groupKey] options:NSCaseInsensitiveSearch];
        }
    }];
}
- (void) reloadDocuments:(NSArray*)documents
{
    [self removeAllObjects];
    NSMutableDictionary* sortedDic = self.sortedDictionary;
    CWizDocumentsSortedType type = self.sortedType;
    for (WizDocument* doc in documents) {
        NSString* groupKey = [doc groupKeyBySortedType:type];
        NSMutableArray* array = [sortedDic objectForKey:groupKey];
        if (!array) {
            array = [NSMutableArray new];
            array.sortedType = self.sortedType;
            [sortedDic setObject:array forKey:groupKey];
        }
        [array addObject:doc];
    }
    NSArray* allGroups = [sortedDic allValues];
    [self addObjectsFromArray:allGroups];
    for(NSMutableArray* each in self)
    {
        [each sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
           return [(WizDocument*)obj1 compareWithDocument:obj2 byType:type]; 
        }];
    }
    [self sortDocumentGroups];
}
- (NSIndexPath*) indexOfDocument:(NSString*)documentGuid
{
    for (int s = 0; s < [self count]; s++) {
        NSArray* sectionArray = [self objectAtIndex:s];
        for (int i = 0 ; i < [sectionArray count]; ++i ) {
            WizDocument* doc = [sectionArray objectAtIndex:i];
            if ([doc.guid isEqualToString:documentGuid]) {
                return [NSIndexPath indexPathForRow:i  inSection:s];
            }
        }
    }
    return [NSIndexPath indexPathForRow:NSNotFound inSection:NSNotFound];
}
- (NSIndexPath*) insertDocument:(WizDocument*)document
{
    CWizDocumentsSortedType type = self.sortedType;
    NSString* groupKey = [document groupKeyBySortedType:self.sortedType];
    NSMutableArray* array = [self.sortedDictionary objectForKey:groupKey];
    int section = [self indexOfObject:array];
    if (!array) {
        array = [NSMutableArray array];
        array.sortedType = self.sortedType;
        [self.sortedDictionary setObject:array forKey:groupKey];
    }
    [array addObject:document];
    [array sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(WizDocument*)obj1 compareWithDocument:obj2 byType:type];
    }];
    if (section == NSNotFound) {
        [self addObject:array];
        [self sortDocumentGroups];
    }
    return [self indexOfDocument:document.guid];
}
- (NSArray*) updateDocument:(WizDocument *)doc
{
    NSIndexPath* removeIndex = [self removeDocument:doc.guid];
    NSIndexPath* inserIndex = [self insertDocument:doc];
    if (removeIndex && inserIndex) {
        return @[removeIndex, inserIndex];
    }
    return Nil;
}
- (NSIndexPath*) removeDocument:(NSString *)documentGuid
{
    NSIndexPath* indexPath = [self indexOfDocument:documentGuid];
    if (indexPath.section != NSNotFound && indexPath.row != NSNotFound) {
        NSMutableArray* array = [self objectAtIndex:indexPath.section];
        [array removeObjectAtIndex:indexPath.row];
        if ([array count] == 0 ) {
            indexPath = [NSIndexPath indexPathForRow:NSNotFound inSection:indexPath.section];
            [self removeObject:array];
        }
    }
    return indexPath;
}
- (NSInteger) allDocumentCount
{
    int sum = 0;
    for (NSArray* each in self) {
        sum += [each count];
    }
    return sum;
}

@end