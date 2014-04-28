//
//  FileSize.h
//  AdvertisingPanorama
//
//  Created by mac on 14-3-13.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Util.h"

@interface FileSize : NSObject {
    
}
// This method converts a given # of bytes into human readable format (KB, MB, GB)
+ (NSString *)stringFromFileSize:(int)theSize;
// Returns the size of a file in bytes
+ (int)sizeOfFile:(NSString *)path;
// Returns the size of a folder in bytes
+ (int)sizeOfFolder:(NSString *)path;
@end

