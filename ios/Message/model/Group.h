//
//  Group.h
//  leveldb_ios
//
//  Created by houxh on 14-7-5.
//  Copyright (c) 2014年 potato. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Group : NSObject
@property(nonatomic, assign)int64_t groupID;
@property(nonatomic, assign)int64_t masterID;
@property(nonatomic, copy)NSString *topic;
@property(nonatomic, readonly)NSArray *members;
@property(nonatomic, assign)BOOL disbanded;

-(void)addMember:(int64_t)uid;
-(void)removeMember:(int64_t)uid;
@end