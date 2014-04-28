//
//  WizDBManager.h
//  WizUIDesign
//
//  Created by dzpqzb on 13-1-13.
//  Copyright (c) 2013年 cn.wiz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizInfoDatabaseDelegate.h"
#import "WizTemporaryDataBaseDelegate.h"
static const int WizDBVersionOfCacheDataBase = 1;
static const int WizDBVersionOfInfoDataBase = 1;

/**The database interface of all databases.
 数据库层使用sqlite数据库，在使用一个数据的时候使用该类中的方法，获取一个数据库链接。你不用手动关闭数据库链接，在超出作用域后，链接会自动关闭。
 */
@interface WizDBManager : NSObject
+ (void) addAddtionModelName:(NSString*)name;
/**获取一个群组数据库链接
 传入群组的guid和与其相关的账号名。数据路路径从WizFileManager中获取
 */
+ (id<WizInfoDatabaseDelegate>) getMetaDataBaseForKbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
/**获取临时数据库链接，其主要负责存储摘要和搜索历史信息。
 */
+ (id<WizTemporaryDataBaseDelegate>) temporaryDataBase;
@end
