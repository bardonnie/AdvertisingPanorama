//
//  WizGetUserImageOperation.m
//  WizNote
//
//  Created by dzpqzb on 13-7-12.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizGetUserImageOperation.h"

@implementation WizGetUserImageOperation
@synthesize userGuid = _userGuid;
- (id) initWithUserGuid:(NSString *)userGuid
{
    self = [super init];
    if (self) {
        _userGuid = userGuid;
    }
    return self;
}

- (void) main
{
//    NSLog(@"WizGetUserImageOperation start");
    @autoreleasepool {
        NSString* tempory = [WizFileManager globalTempDirectory];
        NSString* imagePath = [tempory stringByAppendingPathComponent:_userGuid];
        NSData* data = [NSData dataWithContentsOfFile:imagePath];
//        UIImage* image = nil;
        if (data) {
//            image = [UIImage imageWithData:data];
        }
        else
        {
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://as.wiz.cn/wizas/a/users/avatar/{%@}",_userGuid]]];
            NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            if (data) {
//                image = [UIImage imageWithData:data];
                [data writeToFile:imagePath atomically:YES];
            }
        }
    }
}

@end

