//
//  GroupDB.h
//  leveldb_ios
//
//  Created by houxh on 14-7-5.
//  Copyright (c) 2014年 potato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Group.h"

@interface GroupDB : NSObject
+(GroupDB*)instance;

-(BOOL)addGroup:(Group*)group;
-(BOOL)removeGroup:(int64_t)groupID;

-(BOOL)addGroupMember:(int64_t)groupID member:(int64_t)uid;
-(BOOL)removeGroupMember:(int64_t)groupID member:(int64_t)uid;

-(NSArray*)loadAllGroup;
-(Group*)loadGroup:(int64_t)groupID;
@end
