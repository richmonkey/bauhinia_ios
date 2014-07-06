//
//  UserDB.m
//  Message
//
//  Created by houxh on 14-7-6.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "UserDB.h"
#import "LevelDB.h"

@implementation UserDB
+(UserDB*)instance {
    static UserDB *db;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!db) {
            db = [[UserDB alloc] init];
        }
    });
    return db;
}

-(NSString*)userKey:(int64_t)uid {
    return [NSString stringWithFormat:@"users_%lld", uid];
}

-(BOOL)addUser:(User*)user {
    LevelDB *db = [LevelDB defaultLevelDB];
    NSString *key = [self userKey:user.uid];

    if (user.avatarURL.length) {
        NSString *k = [key stringByAppendingString:@"_avatar"];
        [db setString:user.avatarURL forKey:k];
    }
    if (user.state.length) {
        NSString *k = [key stringByAppendingString:@"_state"];
        [db setString:user.state forKey:k];
    }
    return YES;
}

-(User*)loadUser:(int64_t)uid {
    LevelDB *db = [LevelDB defaultLevelDB];
    NSString *key = [self userKey:uid];
    NSString *k1 = [key stringByAppendingString:@"_avatar"];
    NSString *k2 = [key stringByAppendingString:@"_state"];
    User *u = [[User alloc] init];
    u.uid = uid;
    u.avatarURL = [db stringForKey:k1];
    u.state = [db stringForKey:k2];
    if (u.avatarURL == nil && u.state == nil) {
        return nil;
    }
    return u;
}

-(NSString*)loadUserState:(int64_t)uid {
    LevelDB *db = [LevelDB defaultLevelDB];
    NSString *key = [self userKey:uid];
    NSString *k2 = [key stringByAppendingString:@"_state"];
    return [db stringForKey:k2];
}
@end
