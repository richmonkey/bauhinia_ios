//
//  NewCount.m
//  kefu
//
//  Created by houxh on 16/4/28.
//  Copyright © 2016年 beetle. All rights reserved.
//

#import "NewCount.h"
#import "LevelDB.h"
@implementation NewCount
+(int)getNewCount:(int64_t)uid {
    LevelDB *db = [LevelDB defaultLevelDB];
    
    NSString *key = [NSString stringWithFormat:@"news_peer_%lld", uid];
    return (int)[db intForKey:key];
}

+(void)setNewCount:(int)count uid:(int64_t)uid {
    LevelDB *db = [LevelDB defaultLevelDB];
    
    NSString *key = [NSString stringWithFormat:@"news_peer_%lld", uid];
    [db setInt:count forKey:key];
}

+(int)getGroupNewCount:(int64_t)gid {
    LevelDB *db = [LevelDB defaultLevelDB];
    
    NSString *key = [NSString stringWithFormat:@"news_group_%lld", gid];
    return (int)[db intForKey:key];
}

+(void)setGroupNewCount:(int)count gid:(int64_t)gid {
    LevelDB *db = [LevelDB defaultLevelDB];
    
    NSString *key = [NSString stringWithFormat:@"news_group_%lld", gid];
    [db setInt:count forKey:key];
}
@end
