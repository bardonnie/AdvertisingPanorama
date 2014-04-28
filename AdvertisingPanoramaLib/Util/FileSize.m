//
//  FileSize.m
//  AdvertisingPanorama
//
//  Created by mac on 14-3-13.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//

#import "FileSize.h"

@implementation FileSize

+ (NSString *)stringFromFileSize:(int)theSize
{
    float floatSize = theSize;
//    if (theSize<1023)
//        return([NSString stringWithFormat:@"%i bytes",theSize]);
    floatSize = floatSize / 1024;
    if (floatSize<1023)
        return([NSString stringWithFormat:@"%1.1f KB",floatSize]);
    floatSize = floatSize / 1024;
    if (floatSize<1023)
        return([NSString stringWithFormat:@"%1.1f MB",floatSize]);
    floatSize = floatSize / 1024;
    
    return([NSString stringWithFormat:@"%1.1f GB",floatSize]);
}

+ (int)sizeOfFile:(NSString *)path
{
    NSDictionary *fattrib = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    int fileSize = (int)[fattrib fileSize];
    return fileSize;
}

+ (int)sizeOfFolder:(NSString*)folderPath
{
    NSArray *contents;
    NSEnumerator *enumerator;
    NSString *path;
    contents = [[NSFileManager defaultManager] subpathsAtPath:folderPath];
    enumerator = [contents objectEnumerator];
    int fileSizeInt = 0;
    while (path = [enumerator nextObject]) {
        NSDictionary *fattrib = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:path] error:nil];
        fileSizeInt +=[fattrib fileSize];
    }
    return fileSizeInt;
}

@end
