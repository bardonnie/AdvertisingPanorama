//
//  AD_NetWork.m
//  AdvertisingPanorama
//
//  Created by mac on 14-2-19.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//

#import "AD_NetWork.h"

#import "Reachability.h"

@implementation AD_NetWork

@synthesize delegate;
@synthesize tmpPath;
@synthesize wizDocArray;

static AD_NetWork *_shareNetWork;

+ (AD_NetWork *)shareNetWork
{
    if (!_shareNetWork) {
        _shareNetWork = [[AD_NetWork alloc] init];
    }
    return _shareNetWork;
}

+ (NSArray *)addProgramaArray
{
    NSString *programaPath = [[NSBundle mainBundle] pathForResource:@"Programa" ofType:@"plist"];
    NSArray *programaArray = [[NSArray alloc] initWithContentsOfFile:programaPath];
    return programaArray;
}

- (void)addWizObserver
{
    [[WizNotificationCenter shareCenter] addSyncKbObserver:self];
    [[WizNotificationCenter shareCenter] addGenerateAbstractObserver:self];
}

- (void)updateAccount
{
    Reachability *r = [Reachability reachabilityWithHostname:@"www.apple.com"];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
            // 没有网络连接
            [self didSyncKbEnd:KBGUID];
            break;
        case ReachableViaWWAN:
            // 使用3G网络
        case ReachableViaWiFi:
            // 使用wifi
            [self syncAccountWiz];
            break;
    }
}

- (void)syncAccountWiz
{
    [[WizAccountManager defaultManager] updateAccount:USER_ID password:USER_PASSWORD personalKbguid:KBGUID];
    [[WizAccountManager defaultManager] registerActiveAccount:USER_ID];
    [[WizSyncCenter shareCenter] syncAccount:USER_ID password:USER_PASSWORD isGroup:YES isUploadOnly:NO];
//    [SVProgressHUD showWithStatus:@"正在加载..." maskType:SVProgressHUDMaskTypeBlack];
}

- (void)startDownloadWithURL:(NSString *)url
{
    NSString *URLTmp = url;
    //转码成UTF-8  否则可能会出现错误
    NSString *URLTmp1 = [URLTmp stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    URLTmp = URLTmp1;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString: URLTmp]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {        
        [delegate downloadFinish:[[NSData alloc] initWithData:operation.responseData]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Failure: %@", error);
         [delegate downloadFaild];
     }];
    [operation start];
}

- (void)qqPostRequest
{
    NSString *URLTmp = @"http://open.t.qq.com/api/t/add";
    //转码成UTF-8  否则可能会出现错误
    NSString *URLTmp1 = [URLTmp stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    URLTmp = URLTmp1;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: URLTmp]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"json" forHTTPHeaderField:@"format"];
    [request setValue:@"测试" forHTTPHeaderField:@"content"];
    [request setValue:[NSString stringWithFormat:@"%@",[self getIPAddress]] forHTTPHeaderField:@"clientip"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", operation.responseString);
        
        NSString *requestTmp = [NSString stringWithString:operation.responseString];
        [delegate downloadFinish:[[NSData alloc] initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Failure: %@", error);
         [delegate downloadFaild];
     }];
    [operation start];
}

- (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    //retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        //Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if (temp_addr->ifa_addr->sa_family == AF_INET) {
                //Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String: temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    //Get NSString from C String
                    address =[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *) temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    //Free memory
    freeifaddrs(interfaces);
    NSLog(@"addrees----%@",address);
    return address;
}

- (void)didSyncKbEnd:(NSString *)kbguid
{
    if ([kbguid isEqualToString:KBGUID])
    {
        NSLog(@"kbguid - %@",kbguid);
        wizDocArray = [self accountManager:kbguid];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WizDownloadFinish" object:wizDocArray userInfo:nil];
        NSLog(@"wiz - %@",wizDocArray);
    }
    [SVProgressHUD showSuccessWithStatus:@"加载完成"];
}

- (void)offLineDownload
{
    // 离线下载
    [[WizSettings defaultSettings] setOfflineDownloadDuration:WizOfflineDownloadLastMonth kbguid:KBGUID  accountUserId:USER_ID];
    [[WizAutoDownloadThread shareInstance] cancelAllWork];
    [[WizSyncCenter shareCenter] autoDownloadDocumentByKbguid:KBGUID  accountUserId:USER_ID];
}

- (void) didGenerateAbstract:(NSString *)guid
{
    //WizDocument *doc = [titleArray objectAtIndex:docNum];
    WizAbstract *abs = [[WizGlobalCache shareInstance] abstractForDoc:guid accountUserId:USER_ID];
    if (abs) {
        NSLog(@"abs - %@",abs);
    }
}

- (void)didSyncKbFaild:(NSString *)kbguid error:(NSError *)error
{
    NSLog(@"error - %@",error);
    [SVProgressHUD showErrorWithStatus:@"加载失败"];
}

- (void)didSyncKbStart:(NSString *)kbguid
{
    NSLog(@"startKbguid - %@",kbguid);
}

- (NSMutableArray *)accountManager:(NSString *)kbGuid
{    
    NSMutableArray *articleArray = [[NSMutableArray alloc] init];
    // 文章数组
    for (int i = 0; i<[AD_NetWork addProgramaArray].count; i++)
    {
        [articleArray addObject:[self requestPart:[[[AD_NetWork addProgramaArray] objectAtIndex:i] objectForKey:@"id"]]];
//        NSLog(@"guid - %@",[[[AD_NetWork addProgramaArray] objectAtIndex:i] objectForKey:@"id"]);
    }
    
//    NSLog(@"articleArray.count - %d",articleArray.count);
    
    for (NSMutableArray* eachArray in articleArray) {
        [eachArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            WizDocument* doc1 = (WizDocument*)obj1;
            WizDocument* doc2 = (WizDocument*)obj2;
            return [doc2.dateModified compare:doc1.dateModified];
        }];
    }
    return articleArray;
}

- (NSArray *)requestPart:(NSString *)partGuid
{
    id<WizInfoDatabaseDelegate>dataDelegate = [WizDBManager getMetaDataBaseForKbguid:KBGUID accountUserId:USER_ID];

    NSMutableArray *array =(NSMutableArray *)[dataDelegate documentsByTag:partGuid];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:NO];
    [array sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    return array;
}

@end
