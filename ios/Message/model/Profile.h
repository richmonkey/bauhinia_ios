//
//  Profile.h
//  Message
//
//  Created by daozhu on 14-7-1.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhoneNumber.h"

@interface Profile : NSObject
+(Profile*)instance;

@property(nonatomic, assign)int64_t uid;
@property(nonatomic)PhoneNumber *phoneNumber;
@property(nonatomic, copy)NSString *avatarURL;

//自定义状态
@property(nonatomic, copy)NSString *state;

//最后上线时间
@property(nonatomic, assign)int64_t lastUpTimestamp;

@property(nonatomic) NSString *contactName;
-(NSString*) displayName;

-(void)save;

@end
