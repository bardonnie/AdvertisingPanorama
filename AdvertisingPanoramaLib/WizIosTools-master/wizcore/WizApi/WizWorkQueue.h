//
//  WizWorkQueue.h
//  WizIos
//
//  Created by dzpqzb on 12-12-20.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizDownloadThread.h"
typedef NSComparisonResult (^WizCompareBlock)(id obj1, id obj2);

extern void(^WizAddGenerateAbstractWork)(NSString*, NSString*, NSString*);
extern void(^WizAddDeleteAbstractWork)(NSString*, NSString*, NSString*);


@interface WizWorkOjbect : NSObject
@property (nonatomic, strong) NSString* key;
@end

@interface WizDownloadSourceWorkObject : WizWorkOjbect 
@property (nonatomic, strong) NSString* accountUserId;
@property (nonatomic, strong) NSString* kbguid;
- (id) initWithAccountUserId:(NSString*)accountUserId kbguid:(NSString*)kbguid;
@end

@interface WizAutoDownloadWorkObject : WizWorkOjbect
@property (nonatomic, strong) NSString* accountUserId;
@property (nonatomic, strong) NSString* kbguid;
@end



@interface WizSyncKbWorkObject : WizWorkOjbect
@property (nonatomic, strong) NSString* kbguid;
@property (nonatomic, strong) NSString* accountUserId;
@property (nonatomic, strong) NSString* kApiUrl;
@property (nonatomic, strong) NSString* token;
@property (nonatomic, assign) BOOL isUploadOnly;
@property (nonatomic, assign) int userPrivilige;
@property (nonatomic, strong) NSString* dbPath;
@property (nonatomic, assign) BOOL isPersonal;
@end

@interface WizCountWorkObject : WizWorkOjbect
@property (nonatomic, strong) NSString* kbguid;
@property (nonatomic, strong) NSString* accountUserId;
@end

@interface WizDownloadWorkObject :WizWorkOjbect
@property (nonatomic, strong) NSString* objGuid;
@property (nonatomic, strong) NSString* objType;
@property (nonatomic, strong) NSString* kbguid;
@property (nonatomic, strong) NSString* accountUserId;
@end
typedef enum {
    WizGenerateAbstractTypeDelete = 0,
    WizGenerateAbstractTypeReload = 1,
    WizGenerateAbstractTypeCreate = 2
} WizGenerateAbstractType;

@interface WizGenAbstractWorkObject : WizWorkOjbect
@property (nonatomic, strong) NSString* docGuid;
@property (nonatomic, strong) NSString* accountUserId;
@property (nonatomic, strong) NSString* kbguid;
@property (nonatomic, assign) WizGenerateAbstractType type;

@end


/**The multithread message.If you will send a work to a thread, you will use this class
 */
@class WizDownloadWorkQueue;
@interface WizWorkQueue : NSObject
+ (WizWorkQueue*) messageCountQueue;
/**Sync kb queue
 */
+ (WizWorkQueue*) kbSyncWorkQueue;
/**the user download queue
 */
+ (WizWorkQueue*) downloadWorkQueueMain;
/**Backgroud download queue
 */
+ (WizWorkQueue*) downloadSourceQueue;

+ (WizWorkQueue*) downloadWorkQueueBackgroud;
/**Generate abstract of docuament queue
 */
+ (WizWorkQueue*) genAbstractQueue;
+ (WizWorkQueue*) countingDocumentsQueue;

/**Generate docDisplayModel of docuament queue
 */
+ (WizWorkQueue*) docDisplayModelQueue;

- (void) addWorkObject:(WizWorkOjbect*)obj;
- (BOOL) hasMoreWorkObject;
- (id)   workObject;
- (void) removeWorkObject:(WizWorkOjbect*)obj;
- (void) removeAllWorkObject;
- (BOOL) hasWorkObjectByKey:(NSString*)key;
- (NSInteger) totalWorkObjectCount;
- (NSInteger) finishedWorkObjectCount;
- (void) addWorkObjects:(NSArray*)array useingCompareBlock:(WizCompareBlock)block;
@end

