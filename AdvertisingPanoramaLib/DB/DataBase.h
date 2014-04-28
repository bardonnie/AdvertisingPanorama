//
//  DataBase.h
//  LicaiBao
//
//  Created by mac on 14-3-9.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface DataBase : NSObject

+ (DataBase *)shareDataBase;

- (void)createDataBase;
- (void)createTabel;
- (void)insertFund:(WizDocument *)wizDoc;
- (FMResultSet *)select;

@end
