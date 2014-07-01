//
//  UserPresent.h
//  Message
//
//  Created by daozhu on 14-7-1.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserPresent : NSObject

@property (strong, nonatomic)NSString* username;
@property (assign, nonatomic)UInt64 userid;
@property (strong,nonatomic)NSString* password;


+(UserPresent*)instance;


@end
