//
//  User.h
//  Message
//
//  Created by houxh on 14-7-6.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "ABContact.h"
#import "PhoneNumber.h"

typedef enum {
    UserOnlineStateNone = 0,
    UserOnlineStateOnline,
    UserOnlineStateOffline
} UserOnlineStateType;

@interface User : NSObject
@property(nonatomic, assign)int64_t uid;
@property(nonatomic)PhoneNumber *phoneNumber;
@property(nonatomic, copy)NSString *avatarURL;

//自定义状态
@property(nonatomic, copy)NSString *state;

//是否在线
@property(nonatomic, assign)UserOnlineStateType onlineState;

@end


@interface IMUser : User

@property(nonatomic)ABContact *contact;

-(NSString*) displayName;

@end