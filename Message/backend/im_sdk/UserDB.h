//
//  UserDB.h
//  Message
//
//  Created by houxh on 14-7-6.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface UserDB : NSObject
+(UserDB*)instance;

-(BOOL)addUser:(User*)user;
-(User*)loadUser:(int64_t)uid;
-(NSString*)loadUserState:(int64_t)uid;

@end
