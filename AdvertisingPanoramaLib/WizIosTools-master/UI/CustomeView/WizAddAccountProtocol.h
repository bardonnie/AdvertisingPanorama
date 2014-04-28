//
//  WizAddAccountProtocol.h
//  WizNote
//
//  Created by dzpqzb on 13-4-24.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    WizAddAccountTypeLogin,
    WizAddAccountTypeRegister,
    WizAddAccountTypeNone
}WizAddAccountType;

@protocol WizAddAccountProtocol <NSObject>
@property (nonatomic, assign) WizAddAccountType addAccountType;
@end
