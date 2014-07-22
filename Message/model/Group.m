//
//  Group.m
//  leveldb_ios
//
//  Created by houxh on 14-7-5.
//  Copyright (c) 2014年 potato. All rights reserved.
//

#import "Group.h"
@interface Group()
@property(nonatomic)NSMutableArray *_members;
@end

@implementation Group

-(id)init {
  self = [super init];
  if (self) {
    self._members = [NSMutableArray array];
  }
  return self;
}

-(NSArray*)members {
  return self._members;
}

-(void)addMember:(int64_t)uid {
  NSNumber *n = [NSNumber numberWithLongLong:uid];
  NSUInteger i = [self.members indexOfObject:n];
  if (i != NSNotFound) {
    return;
  }
  [self._members addObject:n];
}

-(void)removeMember:(int64_t)uid {
  NSNumber *n = [NSNumber numberWithLongLong:uid];
  [self._members removeObject:n];
}
@end
