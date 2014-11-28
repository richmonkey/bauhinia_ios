//
//  DraftDB.m
//  Message
//
//  Created by houxh on 14-11-28.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "DraftDB.h"
#import "LevelDB.h"

@implementation DraftDB
+(DraftDB*)instance {
    static DraftDB *db;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!db) {
            db = [[DraftDB alloc] init];
        }
    });
    return db;
}
-(NSString*)getDraft:(int64_t)uid {
    LevelDB *db = [LevelDB defaultLevelDB];
    NSString *key = [NSString stringWithFormat:@"draft_%lld", uid];
    return [db stringForKey:key];
}

-(void)setDraft:(int64_t)uid draft:(NSString*)draft {
    LevelDB *db = [LevelDB defaultLevelDB];
    NSString *key = [NSString stringWithFormat:@"draft_%lld", uid];
    [db setString:draft forKey:key];
}

@end
