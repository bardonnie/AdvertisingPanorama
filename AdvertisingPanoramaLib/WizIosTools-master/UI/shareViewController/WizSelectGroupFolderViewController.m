//
//  WizSelectGroupFolderViewController.m
//  WizNote
//
//  Created by dzpqzb on 13-4-2.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizSelectGroupFolderViewController.h"

@interface WizSelectGroupFolderViewController ()

@end

@implementation WizSelectGroupFolderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (NSMutableDictionary*) allFoldersDictionary
{
    id<WizInfoDatabaseDelegate> db =[WizDBManager getMetaDataBaseForKbguid:self.group.guid accountUserId:self.group.accountUserId];
    NSMutableDictionary *dictionary= [NSMutableDictionary dictionaryWithDictionary:[db tagTreeDictionary]];
    if (self.isViewRootTag){
        [dictionary setValue:@"" forKey:@""];
    }
    return dictionary;
}

- (void) reloadFoldersData
{
    if(allFloders == nil)
    {
        allFloders =[NSMutableArray array];
    }

    folderDictionay = [self allFoldersDictionary];
    [allFloders removeAllObjects];
    [allFloders addObjectsFromArray:[folderDictionay allKeys]];
    if(selectedFloder == nil)
    {
        selectedFloder = [NSMutableArray array];
        NSString* sFolder = [self.selectDelegate selectedFolderOld];
        if (nil == sFolder || [sFolder isBlock]) {
            sFolder = @"";
        }
        [selectedFloder addObject:sFolder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
