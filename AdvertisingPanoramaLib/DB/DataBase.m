//
//  DataBase.m
//  LicaiBao
//
//  Created by mac on 14-3-9.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//

#import "DataBase.h"

@implementation DataBase
{
    FMDatabase *_dataBase;
}

static DataBase *_shareDataBase;

+ (DataBase *)shareDataBase
{
    if (!_shareDataBase)
    {
        _shareDataBase = [[DataBase alloc] init];
    }
    return _shareDataBase;
}

- (void)createDataBase
{
    _dataBase = [[FMDatabase alloc] initWithPath:[NSString stringWithFormat:@"%@/Documents/%@/%@.db",NSHomeDirectory(),USER_ID,KBGUID]];
    if([_dataBase open])
    {
        NSLog(@"数据库打开成功");
    }
    else
    {
        NSLog(@"数据库打开失败");
    }
}

- (void)createTabel
{
    [_dataBase executeUpdate:@"create table funds(fundID integer primary key autoincrement,code text,name text,company text,seven0 text,net0 text,seven1 text,net1 text,seven2 text,net2 text,seven3 text,net3 text,seven4 text,net4 text,seven5 text,net5 text,seven6 text,net6 text)"];
    [_dataBase close];
}

//- (void)insertFund:(LC_Fund *)fund
//{
//    _dataBase = [[FMDatabase alloc] initWithPath:[NSString stringWithFormat:@"%@/tmp/funds.db",NSHomeDirectory()]];
//    if(![_dataBase open])
//    {
//        NSLog(@"打开数据库失败");
//        return;
//    }
//    NSLog(@"--%d",[fund.fundCode intValue]);
//    [_dataBase executeUpdate:@"insert into funds(code,name,company,seven0,net0) values(?,?,?,?,?)",fund.fundCode,fund.name,fund.company,fund.sevenDay,fund.earnings];
//    [_dataBase close];
//}

- (FMResultSet *)select
{
    _dataBase = [[FMDatabase alloc] initWithPath:[NSString stringWithFormat:@"%@/Documents/%@/%@.db",NSHomeDirectory(),USER_ID,KBGUID]];
    if(![_dataBase open])
    {
        NSLog(@"打开数据库失败");
        return nil;
    }
    // 查询操作
    // rs为查询结果集
    FMResultSet *rs = [_dataBase executeQuery:@"select * from WIZ_DOCUMENT"];
    // 遍历结果集
    return rs;
}

@end
