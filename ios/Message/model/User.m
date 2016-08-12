//
//  User.m
//  Message
//
//  Created by houxh on 14-7-6.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "User.h"

@implementation User

-(NSString*) displayName {
    if (self.contactName.length == 0){
        return  self.phoneNumber.number;
    }
    return self.contactName;
    
}

@end

