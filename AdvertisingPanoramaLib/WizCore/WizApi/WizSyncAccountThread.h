//
//  WizSyncAccountThread.h
//  WizIos
//
//  Created by dzpqzb on 12-12-20.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum
{
    WizSyncAccountTypeAll,
    WizSyncAccountTypePesonal,
    WizSyncAccountTypeKbguid
} WizSyncAccountType;

/**Sync account thread
 The thread start when user use it. Then account login to get a token, the setup some sync kb commonds, and send them to the sync kb queue. if all the sync kb commond is done, the thread is over. or the thread sleep 0.5 seconds.
 */

@interface WizSyncAccountThread : NSThread
/**This is a init method. You must send the params use this method.
 @param accountUserId 
 @param password
 @param isUploadOnly A parameter that show the task is just upload the loacl changed only.
 @param type 
 @param kbguid  knowlagde guid
 */
- (id) initWithAccountUserId:(NSString*)accountUserId password:(NSString*)password isUploadOnly:(BOOL)isUploadOnly syncType:(WizSyncAccountType)type kbguid:(NSString*)kbguid_;
@end
