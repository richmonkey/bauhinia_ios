//
//  IMContact.h
//  Message
//
//  Created by houxh on 14-7-6.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABContact.h"
#import "User.h"

@interface IMSimpleContact : NSObject
@property(nonatomic, copy)NSString *name;
@property(nonatomic, copy)NSString *state;
@property(nonatomic, assign)ABRecordID recordID;
@end

@interface IMContact : NSObject
@property(nonatomic)ABContact *contact;
@property(nonatomic)NSArray *users;
@end

