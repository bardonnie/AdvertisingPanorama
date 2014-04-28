//
//  WizInfoDb.h
//  WizIos
//
//  Created by dzpqzb on 12-12-20.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#ifndef _FILE_WIZ_DATABASE
#import "WizDataBase.h"
#endif
#import "WizInfoDatabaseDelegate.h"
@interface WizInfoDb : WizDataBase <WizInfoDatabaseDelegate>
@property (nonatomic, strong) NSString* accountUserId;
@property (nonatomic, strong) NSString* kbguid;
- (id) initWithPath:(NSString *)dbPath modelName:(NSString *)modelName accountUserId:(NSString*)userId kbguid:(NSString*)kbguid;
@end
