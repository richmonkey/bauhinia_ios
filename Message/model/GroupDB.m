//
//  GroupDB.m
//  leveldb_ios
//
//  Created by houxh on 14-7-5.
//  Copyright (c) 2014年 potato. All rights reserved.
//

#import "GroupDB.h"
#import "LevelDB.h"

@implementation GroupDB

+(GroupDB*)instance {
  static GroupDB *db;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    if (!db) {
      db = [[GroupDB alloc] init];
    }
  });
  return db;
}

-(NSString*)groupKeyFromGroupID:(int64_t)groupID {
    NSString *key = [NSString stringWithFormat:@"groups_%lld", groupID];
    return key;
}

-(BOOL)addGroup:(Group*)group {
    LevelDB *db = [LevelDB defaultLevelDB];
    NSString *key = [self groupKeyFromGroupID:group.groupID];
    
    NSString *k1 = [key stringByAppendingString:@"_topic"];
    NSString *k2 = [key stringByAppendingString:@"_master"];
    NSString *k3 = [key stringByAppendingString:@"_disbanded"];
    
    [db setString:group.topic forKey:k1];
    [db setInt:group.masterID forKey:k2];
    [db setInt:group.disbanded forKey:k3];
    
    for (NSNumber *uid in group.members) {
        [self addGroupMember:group.groupID member:[uid longLongValue]];
    }
    return YES;
}

-(BOOL)removeGroup:(int64_t)groupID {
  LevelDB *db = [LevelDB defaultLevelDB];
  NSString *key = [self groupKeyFromGroupID:groupID];
  
  Group *group = [self loadGroup:groupID];
  if (!group) {
    return NO;
  }
  
  NSString *k1 = [key stringByAppendingString:@"_topic"];
  NSString *k2 = [key stringByAppendingString:@"_master"];

  [db removeValueForKey:k1];
  [db removeValueForKey:k2];
  
  
  for (NSNumber *member in group.members) {
    [self removeGroupMember:group.groupID member:[member longLongValue]];
  }
  return YES;
}

-(BOOL)disbandGroup:(int64_t)groupID {
    LevelDB *db = [LevelDB defaultLevelDB];
    NSString *key = [self groupKeyFromGroupID:groupID];
    
    NSString *k3 = [key stringByAppendingString:@"_disbanded"];
    
    [db setInt:1 forKey:k3];
    return YES;
}

-(NSString*)groupMemberKey:(int64_t)groupID member:(int64_t)uid {
  return [NSString stringWithFormat:@"group_member_%lld_%lld", groupID, uid];
}

-(BOOL)addGroupMember:(int64_t)groupID member:(int64_t)uid {
  LevelDB *db = [LevelDB defaultLevelDB];
  NSString *key = [self groupMemberKey:groupID member:uid];
  [db setString:@"1" forKey:key];
  return YES;
}

-(BOOL)removeGroupMember:(int64_t)groupID member:(int64_t)uid {
  LevelDB *db = [LevelDB defaultLevelDB];
  NSString *key = [self groupMemberKey:groupID member:uid];
  [db removeValueForKey:key];
  return YES;
}

-(NSArray*)loadAllGroup {
  LevelDB *db = [LevelDB defaultLevelDB];
  LevelDBIterator *iter = [db newIterator];
  NSString *t = @"groups_";
  
  NSMutableArray *groups = [NSMutableArray array];
  Group *group = nil;
  for ([iter seek:t]; [iter isValid]; [iter next]) {
    NSString *k = [iter key];
    if (![k hasPrefix:@"groups_"]) {
      break;
    }
    if ([k hasSuffix:@"_topic"]) {
      NSRange range = NSMakeRange(7, k.length-7-6);
      int64_t groupID = [[k substringWithRange:range] longLongValue];
      NSString *topic = [iter value];
      if (groupID == 0) {
        continue;
      }
      group.topic = topic;
      if (group.groupID == groupID && group.masterID > 0) {
        [groups addObject:group];
      }
    } else if ([k hasSuffix:@"_master"]) {
      NSRange range = NSMakeRange(7, k.length-7-7);
      int64_t groupID = [[k substringWithRange:range] longLongValue];
      int64_t master = [[iter value] longLongValue];
      if (groupID == 0 || master == 0) {
        continue;
      }
      
      group = [[Group alloc] init];
      group.masterID = master;
      group.groupID = groupID;
    }
  }
  return groups;
}

-(NSMutableArray*)loadGroupMember:(Group*)group {
  LevelDB *db = [LevelDB defaultLevelDB];
  LevelDBIterator *iter = [db newIterator];
  int64_t groupID = group.groupID;
  NSString *t = @"group_member_";
  for ([iter seek:t]; [iter isValid]; [iter next]) {
    NSString *key = [iter key];
    NSArray *ary = [key componentsSeparatedByString:@"_"];
    if ([ary count] != 4) {
      break;
    }
    if (![[ary objectAtIndex:0] isEqualToString:@"group"] ||
        ![[ary objectAtIndex:1] isEqualToString:@"member"]) {
      break;
    }
    int64_t gid = [[ary objectAtIndex:2] longLongValue];
    int64_t uid = [[ary objectAtIndex:3] longLongValue];
    if (gid != groupID) {
      break;
    }
    [group addMember:uid];
  }
  return nil;
}

-(Group*)loadGroup:(int64_t)groupID {
    LevelDB *db = [LevelDB defaultLevelDB];
    NSString *key = [self groupKeyFromGroupID:groupID];
    
    NSString *k1 = [key stringByAppendingString:@"_topic"];
    NSString *k2 = [key stringByAppendingString:@"_master"];
    NSString *k3 = [key stringByAppendingString:@"_disbanded"];
    
    
    Group *group = [[Group alloc] init];
    group.groupID = groupID;
    group.topic = [db stringForKey:k1];
    group.masterID = [db intForKey:k2];
    group.disbanded = [db intForKey:k3];
    if (group.groupID == 0 || group.masterID == 0 || group.topic == nil) {
        return nil;
    }
    
    [self loadGroupMember:group];
    
    return group;
}

-(NSString*)getGroupTopic:(int64_t)groupID {
    LevelDB *db = [LevelDB defaultLevelDB];
    NSString *key = [self groupKeyFromGroupID:groupID];
    
    NSString *k1 = [key stringByAppendingString:@"_topic"];
    return [db stringForKey:k1];
}

-(void)setGroupTopic:(int64_t)groupID topic:(NSString*)topic {
    LevelDB *db = [LevelDB defaultLevelDB];
    NSString *key = [self groupKeyFromGroupID:groupID];
    
    NSString *k1 = [key stringByAppendingString:@"_topic"];
    
    [db setString:topic forKey:k1];
}

@end
