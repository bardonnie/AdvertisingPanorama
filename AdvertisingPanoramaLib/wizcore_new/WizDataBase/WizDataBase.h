//
//  WizDataBase.h
//  WizIos
//
//  Created by dzpqzb on 12-12-20.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#define _FILE_WIZ_DATABASE

#import <Foundation/Foundation.h>
#import "FMDatabase+WizDb.h"
@interface WizDataBase : NSObject
{
    FMDatabase* dataBase;
}
- (id) initWithPath:(NSString*)dbPath modelName:(NSString*)modelName;
- (int) currentVersion;
- (BOOL) addColoumnByModelName:(NSString*)modelName;
@end
