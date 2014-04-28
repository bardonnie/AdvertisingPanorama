//
//  WizGlobalCache.m
//  WizCoreFunc
//
//  Created by dzpqzb on 12-12-24.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizGlobalCache.h"
#import "WizWorkQueue.h"
#import "WizFileManager.h"
#import "WizTempDataBase.h"
#import "WizGlobalData.h"
#import "WizGlobals.h"
#import "NSDate-Utilities.h"
#import "WizNotificationCenter.h"
#import <QuickLook/QuickLook.h>
#import "WizDBManager.h"
#import "MKNetworkEngine.h"
#import "MKNetworkOperation.h"
#import "WizGetUserImageOperation.h"
//
#import "WizMessageCountThread.h"
#import "WizGlobalCacheGenDocumentAbstractThread.h"
#import "WizGlobalCacheGenCountingDocumentsThread.h"
//

@class WizMessageCountThread;
@interface WizGlobalCache() <WizModifiedDcoumentDelegate,WizSyncKbDelegate, WizBizUserModifiedProtocol>
{
    WizMessageCountThread* messageCountThread;
    id<WizTemporaryDataBaseDelegate> tempDataBase;
    NSMutableDictionary* _dictUserIDToGUID;
    NSTimer *uNameTimer;
}

@end
//
//
//
//

static NSInteger WizMaxGeneraterAbstractThreadCount = 1;
static NSInteger WizDocumentCountThreadCount = 1;
static float WizCheckUserNameDataTimeInterval = 60;

//
@implementation WizGlobalCache
@synthesize allUserNameDictionary,allUserNameDictionaryNew;

- (void) reloadAllUserNameDictionary
{
    id<WizTemporaryDataBaseDelegate> db = [WizDBManager temporaryDataBase];
    NSArray* allUsers = [db allBizUsers];
    NSMutableDictionary* dic = [NSMutableDictionary new];
    for (WizBizUser* each  in allUsers) {
        if (each.alias) {
            if (each.userId) {
                [dic setObject:each.alias forKey:each.userId];
            }else if (each.guid) {
                [dic setObject:each.alias forKey:each.guid];
            }
        }
    }
    self.allUserNameDictionary = dic;
    self.isAllUserNameDirty = NO;
    [uNameTimer invalidate];
}

- (void) checkAllUserNameDictionary
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void)
    {
        if (self.isAllUserNameDirty) {
            [self reloadAllUserNameDictionary];
        }
    });
}

- (void) didUpdateBizUser:(WizBizUser *)user
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void)
    {
        self.isAllUserNameDirty = YES;
    });
}

- (id) init
{
    self = [super init];
    if (self) {
        
        
        double delayInSeconds = 6.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self reloadAllUserNameDictionary];
        });
        
       uNameTimer = [NSTimer scheduledTimerWithTimeInterval:WizCheckUserNameDataTimeInterval target:self selector:@selector(checkAllUserNameDictionary) userInfo:nil repeats:YES];
        [[WizNotificationCenter shareCenter] addBizUserModifiedObserver:self];
        messageCountThread = [[WizMessageCountThread alloc] init];
        [messageCountThread setThreadPriority:0.0];
        [messageCountThread start];
        allUserNameDictionary = [NSMutableDictionary new];
        allUserNameDictionaryNew = [[NSMutableDictionary alloc] init];
        [[WizNotificationCenter shareCenter] addSyncKbObserver:self];
        [[WizNotificationCenter shareCenter] addModifiedDocumentObserver:self];
        for (int i  = 0; i < WizMaxGeneraterAbstractThreadCount; i++) {
            WizGlobalCacheGenDocumentAbstractThread* thread = [[WizGlobalCacheGenDocumentAbstractThread alloc] init];
            [thread setThreadPriority:0.0];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
               [thread start];
            });
            
        }
        for (int i  = 0; i < WizDocumentCountThreadCount; i++) {
            WizGlobalCacheGenCountingDocumentsThread* thread = [[WizGlobalCacheGenCountingDocumentsThread alloc] init];
            [thread setThreadPriority:0.0];
            [thread start];
        }
    }
    return self;
}

- (void)dealloc {
    [[WizNotificationCenter shareCenter] removeObserver:self];
}

NSString* (^WizUserAvatarKeyByGuid)(NSString*) = ^(NSString*key)
{
    return [NSString stringWithFormat:@"WizUserAvatar%@",key];
};

- (void) getUserAvatarByGuid:(NSString*)userGuid
{
    
}

- (void) setUserAvatar:(UIImage*)image forUserGuid:(NSString*)guid
{
    NSString* key = WizUserAvatarKeyByGuid(guid);
    if (image) {
        @synchronized(self)
        {
            [self setObject:image forKey:key];
        }
        NSDictionary* userInfo = @{@"Avart":image,@"user_guid":guid};
        [[NSNotificationCenter defaultCenter] postNotificationName:WizMessageGetUserAvartImageMessage object:nil userInfo:userInfo];
    }
}

- (void) cacheUserAvatarByGuid:(NSString*)guid
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString* tempory = [WizFileManager userAvatarCacheDirectory];
        NSString* imagePath = [tempory stringByAppendingPathComponent:guid];
        if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
            NSError* error = nil;
            NSDictionary* fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:imagePath error:&error];
            if (fileAttributes && !error) {
                NSDate* modifiedDate = [fileAttributes fileModificationDate];
                if ([modifiedDate isToday]) {
                    UIImage* image = [UIImage imageWithContentsOfFile:imagePath];
                    @synchronized(self){
                        [self setUserAvatar:image forUserGuid:guid];
                    }
                    return ;
                }
            }
        }
        UIImage* image = nil;
        @synchronized(self){
            image = [self objectForKey:guid];
        }
        if (image == nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                UIImage* defaultImage = WizImageByKind(ImageOfMessageSenderDefault);
                @synchronized(self){
                    [self setObject:defaultImage forKey:guid];
                }
            });
        }

        static MKNetworkEngine* userPhotoEngine ;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            userPhotoEngine = [[MKNetworkEngine alloc]initWithHostName:@"as.wiz.cn/wizas"];
        });
        MKNetworkOperation* op = [userPhotoEngine operationWithPath:[NSString stringWithFormat:@"a/users/avatar/%@?default=false",guid]];
        [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            MULTIBACK(^{
                UIImage* image = completedOperation.responseImage;
                image = [self resizableImage:image];
                image = [self roundedRectImage:image];
                if (image) {
                    NSData* data =  UIImagePNGRepresentation(image);
                    [data writeToFile:imagePath atomically:YES];
                    [[WizGlobalCache shareInstance] setUserAvatar:image  forUserGuid:guid];
                }
            });
        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
            NSLog(@"error!");
        }];
        [userPhotoEngine enqueueOperation:op];
    
    });
}

- (UIImage *)resizableImage:(UIImage *)image
{
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat squareWidth = width >= height ? height : width;
    
    UIGraphicsBeginImageContext(CGSizeMake(squareWidth, squareWidth));
    if (width >= height) {
        [image drawInRect:CGRectMake(-((width - height)/2.0), 0, width, height)];
    }else {
        [image drawInRect:CGRectMake(0, -((height - width)/2.0), width, height)];
    }
    
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}

- (UIImage *)roundedRectImage:(UIImage *)srcimage
{
    UIImageView *bkImageViewTmp = [[UIImageView alloc] initWithImage:srcimage];
    
    int width = srcimage.size.width;
    int height = srcimage.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);

    float squareWidth = width >= height ? height : width;
    CGRect drawRect = CGRectSetCenter(bkImageViewTmp.frame, CGSizeMake(squareWidth, squareWidth));
    
    CGContextBeginPath(context);
    [self addRoundedRectToPath:context withrect:drawRect radius:squareWidth/2];
    
    CGContextClosePath(context);
    CGContextClip(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), srcimage.CGImage);
    
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIImage    *newImage = [UIImage imageWithCGImage:imageMasked];
    
    CGImageRelease(imageMasked);
    
    return newImage;
}

-(void)addRoundedRectToPath:(CGContextRef)context withrect:(CGRect)rect radius:(float)radius
{
//    //画左上角
    CGContextAddArc(context, rect.origin.x + radius,
                    rect.origin.y + radius, radius, M_PI, M_PI/2, 1);
//
    
//    //画左下角弧线
    CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + radius,
                    radius, -M_PI / 2, 0.0f, 1);
//
//    //画右上角
    CGContextAddArc(context, rect.origin.x + rect.size.width - radius,
                        rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
//
  
//    //画右下角弧线
        CGContextAddArc(context, rect.origin.x + rect.size.width - radius, rect.origin.y + radius,
                        radius, 0.0f, -M_PI / 2, 1);
//
    CGContextClosePath(context);
}


- (UIImage*) userAvatarByGuid:(NSString*)guid
{
    if (!guid) {
        return nil;
    }
    
    UIImage* image = nil;
    @synchronized(self)
    {
        image = [self objectForKey:WizUserAvatarKeyByGuid(guid)];
    }
    if (image)
    {
        return image;
    }
    else
    {
        [self cacheUserAvatarByGuid:guid];
        return nil;
    }
}


- (void) setUserAvatar:(UIImage*)image forGuid:(NSString*)guid
{
    @synchronized(self)
    {
        [self setObject:image forKey:WizUserAvatarKeyByGuid(guid)];
    }
}


NSString* (^WizCacheKeyUnreadMessage)(NSString*)= ^(NSString* accountUserId)
{
    return [NSString stringWithFormat:@"dzpqzb.com@%@",accountUserId];
};


- (int64_t) unreadMessageCountOfAccount:(NSString*)accountUserId type:(WizMessageType)type
{
    
    NSDictionary* dic = nil;
    @synchronized(self)
    {
        dic = [self objectForKey:WizCacheKeyUnreadMessage(accountUserId)];
    }
    if (!dic) {
        [messageCountThread addCommand:accountUserId];
        return 0;
    }
    else
    {
        NSString* key =  WizUnreadCountMessageKeyUserIdType(accountUserId,type);
        return [[dic objectForKey:key ] longLongValue];
    }
}
- (int64_t) unreadMessageCountOfAccount:(NSString*)accountUserId  kbguid:(NSString*)kbguid type:(WizMessageType)type
{
    
    NSDictionary* dic = nil;
    @synchronized(self)
    {
        dic = [self objectForKey:WizCacheKeyUnreadMessage(accountUserId)];
    }
    if (!dic) {
        [messageCountThread addCommand:accountUserId];
        return 0;
    }
    else
    {
        NSString* key =  WizUnreadCountMessageKeyUserIdKbguidType(accountUserId,kbguid,type);
        return [[dic objectForKey:key ] longLongValue];
    }
}


- (void) setUnreadCountDictionary:(NSDictionary*)dic accountUserId:(NSString*)accountUserId
{
    @synchronized(self)
    {
        if (dic) {
            [self setObject:dic forKey:WizCacheKeyUnreadMessage(accountUserId) cost:1];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:WizMessageCountChangedMessage object:nil userInfo:@{WizNotificationUserInfoAccountUserId: accountUserId}];
}


+ (id) shareInstance
{
    static WizGlobalCache* cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       cache =  [WizGlobalData shareInstanceFor:[WizGlobalCache class]];
    });
    return cache;
}

- (void) addAbstract:(WizAbstract*)abstract forDocumentGuid:(NSString *)docGuid kbguid:(NSString *)kbguid accountUserId:(NSString *)accountUserId
{
    @synchronized(self)
    {
        [self setObject:abstract forKey:docGuid];
    }
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithCapacity:1];
        [userInfo addKbguid:kbguid];
    [userInfo addAccountUserId:accountUserId];
    [userInfo addDocumentGuid:docGuid];
    [userInfo setObject:abstract forKey:@"abstract"];
    [userInfo setObject:accountUserId forKey:WizNotificationUserInfoAccountUserId];
    [[NSNotificationCenter defaultCenter] postNotificationName:WizGeneraterAbstractMessage object:nil userInfo:userInfo];
}


- (WizAbstract*) abstractForDoc:(NSString*)docGuid kbguid:(NSString *)kbguid accountUserId:(NSString *)accountUserId
{
    WizAbstract* abstract = [self objectForKey:docGuid];
    if (!abstract) {
        WizAddGenerateAbstractWork(docGuid, kbguid, accountUserId);
    }
    return abstract;
}
- (void) clearCacheForDocument:(NSString *)guid kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId
{
    @synchronized(self)
    {
        [self removeObjectForKey:guid];
        NSMutableDictionary* userInfo = [NSMutableDictionary new];
        [userInfo addDocumentGuid:guid];
        [userInfo addKbguid:kbguid];
        [userInfo addAccountUserId:accountUserId];
        [[NSNotificationCenter defaultCenter] postNotificationName:WizGeneraterAbstractMessage object:nil userInfo:userInfo];
    }
}

- (NSString*)getUserAliasByUserId:(NSString*)userId kbguid:(NSString*)kbguid accountId:(NSString*)accountId
{
    WizGroup* group = [[WizAccountManager defaultManager]groupFroKbguid:kbguid accountUserId:accountId];
    id<WizTemporaryDataBaseDelegate> tdb = [WizDBManager temporaryDataBase];
    WizBizUser* bizUser = [tdb  bizUserFromUserId:userId userBizGuid:group.bizGuid];
    if (!bizUser || !bizUser.alias || [bizUser.alias isEqualToString:@""]) {
        return userId;
    }
    return bizUser.alias;
}


-(NSString *)keyForKb:(NSString *)kbGuid userId:(NSString *)userId{
    NSString *temp=kbGuid==nil?WizGlobalPersonalKbguid:kbGuid;

    return [NSString stringWithFormat:@"%@ %@",userId,temp];
}

- (WizDocumentCount*) tagCount:(NSString*)tagGuid kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId
{
    NSDictionary* dictionary = nil;
   NSString* tagKey = WizCacheKeyTagUsrIdKbguid(accountUserId, kbguid);
    @synchronized(self)
    {
         dictionary = [self objectForKey:tagKey];
    }
    if (dictionary) {
        if (tagGuid) {
           return [dictionary objectForKey:tagGuid] ;
        }
        else
        {
            return nil;
        }
    }
    else
    {
        [self makeCountCacheDirtyByKbGuid:kbguid accountUserId:accountUserId];
        return nil;
    }
    
}
- (WizDocumentCount*) folderCount:(NSString*)folder kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId
{
    NSDictionary* dictionary = nil;
    NSString* folderKey = WizCacheKeyFolderUsrIdKbguid(accountUserId, kbguid);
    @synchronized(self)
    {
        dictionary = [self objectForKey:folderKey];
    }
    if (dictionary) {
        if (folder) {
            return [dictionary objectForKey:folder] ;
        }
        else
        {
            return nil;
        }
    }
    else
    {
        [self makeCountCacheDirtyByKbGuid:kbguid accountUserId:accountUserId];
        return nil;
    }
}


NSString* (^WizCacheKeyByUserIdKbguidPrefix)(NSString*,NSString*,NSString*) = ^(NSString*userid, NSString* kbguid, NSString* prefix)
{
    return [NSString stringWithFormat:@"cache %@ %@ %@ ",prefix, userid,kbguid];
};

NSString* (^WizCacheKeyFolderUsrIdKbguid)(NSString*,NSString*) = ^(NSString* userId, NSString* kbguid)
{
    kbguid = !kbguid || [kbguid isEqualToString:@""] ? WizGlobalPersonalKbguid : kbguid;
    return WizCacheKeyByUserIdKbguidPrefix(userId, kbguid, @"folder");
};

NSString* (^WizCacheKeyTagUsrIdKbguid)(NSString*,NSString*) = ^(NSString* userId, NSString* kbguid)
{
    kbguid = !kbguid || [kbguid isEqualToString:@""] ? WizGlobalPersonalKbguid : kbguid;
    return WizCacheKeyByUserIdKbguidPrefix(userId, kbguid, @"tag");
};
- (void) setFolderCountDictionary:(NSDictionary*)folderDic tagDic:(NSDictionary*)tagDic kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId
{
    @synchronized (self) {
        if (folderDic) {
            NSString *folderkey= WizCacheKeyFolderUsrIdKbguid(accountUserId,kbguid);
            [self setObject:folderDic forKey:folderkey];
        }
        if (tagDic) {
            NSString *tagKey= WizCacheKeyTagUsrIdKbguid(accountUserId, kbguid);
            [self setObject:tagDic forKey:tagKey];
        }
    }
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:kbguid==nil?@"":kbguid forKey:@"guid"];
    [[NSNotificationCenter defaultCenter] postNotificationName:WizReflushDocumentCountInFolder object:nil userInfo:userInfo];
}


-(void) makeCountCacheDirtyByKbGuid:(NSString *)kbguid accountUserId:(NSString *)accountUserId {
        kbguid = !kbguid || [kbguid isEqualToString:@""] ? WizGlobalPersonalKbguid : kbguid;
        WizWorkQueue *queue= [WizWorkQueue countingDocumentsQueue];
        WizCountWorkObject *obj= [[WizCountWorkObject alloc] init];
        obj.accountUserId=accountUserId;
        obj.kbguid=kbguid;
        [queue addWorkObject:obj];
}

#pragma mark delegate
- (void)didDeletedDocument:(NSString *)guid kbguid:(NSString *)kbguid accountUserId:(NSString *)accountUserId
{
    [self makeCountCacheDirtyByKbGuid:kbguid accountUserId:accountUserId];
}

- (void) didInserteDocumentOnLocal:(WizDocument *)document kbguid:(NSString *)kbguid accountUserId:(NSString *)accountUserId
{
    [self makeCountCacheDirtyByKbGuid:kbguid accountUserId:accountUserId];
//    TODO wenlin
//    WizAddGenerateAbstractWork(document.guid, kbguid, accountUserId);
//    WizAddCreateDocDisplayModelWork(document,kbguid,accountUserId);
}

- (void)didSyncKbEnd:(NSString *)kbguid {
    [self makeCountCacheDirtyByKbGuid:kbguid accountUserId:[WizAccountManager defaultManager].activeAccountUserId];
    
}


- (void) didUpdateDocumentOnLocal:(WizDocument *)document kbguid:(NSString *)kbguid accountUserId:(NSString *)accountUserId
{
   [self makeCountCacheDirtyByKbGuid:kbguid accountUserId:[[WizAccountManager defaultManager] activeAccountUserId]];
    WizAddGenerateAbstractWork(document.guid, kbguid, accountUserId);
}

//- (void) didUpdateDocumentOnServer:(WizDocument *)document kbguid:(NSString *)kbguid accountUserId:(NSString *)accountUserId
//{
//    TODO wenlin
//    [self makeCountCacheDirtyByKbGuid:kbguid accountUserId:[[WizAccountManager defaultManager] activeAccountUserId]];
//    WizAddGenerateAbstractWork(document.guid, kbguid, accountUserId);
//}

- (void) didInserteDocumentsOnServerKbguid:(NSString *)kbguid accountUserId:(NSString *)accountUserId
{
    [self makeCountCacheDirtyByKbGuid:kbguid accountUserId:[[WizAccountManager defaultManager] activeAccountUserId]];
}


- (NSString*) groupUserGuidByUserId:(NSString*)userId
{
    @synchronized(self){
        
        if (_dictUserIDToGUID == nil)
        {
            id<WizTemporaryDataBaseDelegate> db = [WizDBManager temporaryDataBase];
            NSArray* all = [db allBizUsers];
            _dictUserIDToGUID  = [NSMutableDictionary new];
            for (WizBizUser* user in all) {
                if (user.guid && user.userId) {
                        [_dictUserIDToGUID setObject:user.guid forKey:user.userId];
                }
            }
        }
        return [_dictUserIDToGUID objectForKey:userId];
    }
}


- (NSString*) groupUserAliasByUserId:(NSString*)userId kbguid:(NSString*)kbguid accountUserId:(NSString*)accountId bizGuid:(NSString*)bizGuid
{
    if (![@"PersonalGroup" isEqualToString:bizGuid]) {
        id<WizTemporaryDataBaseDelegate> db = [WizDBManager temporaryDataBase];
//        WizBizUser* user = [db bizUserFromUserId:userId userBizGuid:bizGuid];
        WizBizUser* user = [db bizUserFromUserId:userId userBizGuid:kbguid];
        if (user.alias) {
            return user.alias;
        }else{
            return [userId componentsSeparatedByString:@"@"][0];
        }
    } else {
        return [userId componentsSeparatedByString:@"@"][0];
    }
}

@end
