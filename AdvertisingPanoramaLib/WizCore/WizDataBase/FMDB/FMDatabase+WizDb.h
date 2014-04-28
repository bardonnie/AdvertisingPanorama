//
//  FMDatabase+WizDb.h
//  WizIos
//
//  Created by dzpqzb on 12-12-20.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import "FMDatabase.h"
@interface FMDatabase (WizDb)
- (BOOL) constructDataBaseModel:(NSString*)modelName;
@end
