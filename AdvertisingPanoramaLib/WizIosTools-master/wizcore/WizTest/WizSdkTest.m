//
// Created by chenjingke on 13-5-23.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "WizSdkTest.h"
#import "WizInfoDb.h"


@implementation WizSdkTest {

}

static WizSdkTest *tester;

+ (id)sharedTester {
    if (tester == nil)
        tester = [[WizSdkTest alloc] init];
    return tester;
}


- (void)runTest {
    [self dbTest];
}

- (void)dbTest {
    id <WizInfoDatabaseDelegate> db = [WizDBManager getMetaDataBaseForKbguid:@"" accountUserId:@""];

    //Document
    int count = [db documentCount];
    WizDocument *document = [[WizDocument alloc] init];
    NSString *guid = @"";
    document.guid = [WizGlobals genGUID];
    document.title = @"11111";
    NSAssert([db updateDocument:document], @"!updateDocument");
    document.title = @"22222";
    NSAssert([db updateDocument:document], @"!updateDocument");
    guid = document.guid;
    document.guid = [WizGlobals genGUID];
    document.title = @"33333";
    NSAssert([db updateDocument:document], @"!updateDocument");

    int count2 = (int) [db documentCount];
    NSAssert(count2 - count == 2, @"!countError");
    document = [db documentFromGUID:guid];
    NSAssert(document != nil, @"!documentFromGUID");
    NSAssert([document.title isEqualToString:@"22222"], @"!document.title error");


    NSArray *waitForUploads = [db documentForUpload];
    NSAssert([waitForUploads count] >= 2, @"!upload document count error");
    BOOL contains = NO;
    for (WizDocument *doc in waitForUploads) {
        if ([doc.guid isEqualToString:guid]) {
            contains = YES;
            break;
        }
    }
    NSAssert(contains, @"!not contains new insert doc");


    //删除测试
    [db deleteDocument:guid];
    [db addDeletedGUIDRecord:guid type:WizObjectTypeDocument];
    WizDocument *doc = [db documentFromGUID:guid];
    NSAssert(doc == nil, @"!deleted");
    NSArray *deleted = [db deletedGUIDsForUpload];
    BOOL containsDeletedGuid = NO;
    for (WizDeletedGuid *deleteGuid in deleted) {
        if ([deleteGuid.guid isEqualToString:guid]) {
            containsDeletedGuid = YES;
            break;
        }
    }
    NSAssert(containsDeletedGuid, @"!not added in deletedGuid");


    //新建tag
    WizTag *tag = [[WizTag alloc] init];
    tag.guid = [WizGlobals genGUID];
    tag.title = @"tagNew";
    [db updateTag:tag];
    WizTag *tag2 = [[WizTag alloc] init];
    tag2.guid = [WizGlobals genGUID];
    tag2.title = @"tagNew2";
    tag2.parentGUID = tag.guid;
    WizTag *tag3 = [[WizTag alloc] init];
    tag3.guid = [WizGlobals genGUID];
    tag3.title = @"tagNew3";
    tag3.parentGUID = tag.guid;
    [db updateTags:@[tag2, tag3]];
    WizTag *checkTag = [db tagFromGuid:tag2.guid];
    NSAssert([tag.guid isEqualToString:checkTag.parentGUID], @"!tag not right");
    NSAssert([@"tagNew2" isEqualToString:checkTag.title], @"!tag not right");

    WizDocument *newDocument = [[WizDocument alloc] init];
    newDocument.guid = [WizGlobals genGUID];
    newDocument.title = @"testTagAndDocument";
    newDocument.tagGuids = tag2.guid;
    NSAssert([db updateDocument:newDocument], @"!updateDocument");

    //子标签文件测试
    NSArray *tArray = [db documentsAndSubTagDocumentsByTag:tag.guid];
    NSAssert(tArray.count == 1, @"!documentsAndSubTagDocumentsByTag");
    WizDocument *tDoc = (WizDocument *) ([tArray objectAtIndex:0]);
    NSAssert([tDoc.title isEqualToString:newDocument.title], @"!documentsAndSubTagDocumentsByTag documentTitle");

}

@end