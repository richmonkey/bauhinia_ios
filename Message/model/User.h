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

@interface User : NSObject
@property(nonatomic, assign)int64_t uid;
@property(nonatomic)PhoneNumber *phoneNumber;
@property(nonatomic, copy)NSString *avatarURL;

//自定义状态
@property(nonatomic, copy)NSString *state;

//是否在线
@property(nonatomic, assign)BOOL online;

@end


@interface IMUser : User

@property(nonatomic)ABContact *contact;

@end