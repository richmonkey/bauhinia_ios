//
//  Token.m
//  Message
//
//  Created by houxh on 14-7-8.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "Token.h"
#import "LevelDB.h"
#import "TAHttpOperation.h"
#import "Config.h"
#import "APIRequest.h"

@interface Token()
@property(nonatomic)dispatch_source_t refreshTimer;
@property(nonatomic)int refreshFailCount;
@end

@implementation Token

+(Token*)instance {
    static Token *tok;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!tok) {
            tok = [[Token alloc] init];
            [tok load];
        }
    });
    return tok;
}

-(id)init {
    self = [super init];
    if (self) {
        dispatch_queue_t queue = dispatch_get_main_queue();
        self.refreshTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
        dispatch_source_set_event_handler(self.refreshTimer, ^{
            [self refreshAccessToken];
        });
    }
    return self;
}

-(void)refreshAccessToken {
    [APIRequest refreshAccessToken:self.refreshToken
                           success:^(NSString *accessToken, NSString *refreshToken, int expireTimestamp) {
                               self.accessToken = accessToken;
                               self.refreshToken = refreshToken;
                               self.expireTimestamp = expireTimestamp;
                               [self save];
                               [self prepareTimer];
                               
                           }
                              fail:^{
                                  self.refreshFailCount = self.refreshFailCount + 1;
                                  int64_t timeout;
                                  if (self.refreshFailCount > 60) {
                                      timeout = 60*NSEC_PER_SEC;
                                  } else {
                                      timeout = (int64_t)self.refreshFailCount*NSEC_PER_SEC;
                                  }
                                  
                                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, timeout), dispatch_get_main_queue(), ^{
                                      [self prepareTimer];
                                  });
                                  
                              }];
}

-(void)prepareTimer {
    int now = time(NULL);
    if (now >= self.expireTimestamp - 1) {
        dispatch_time_t w = dispatch_walltime(NULL, 0);
        dispatch_source_set_timer(self.refreshTimer, w, DISPATCH_TIME_FOREVER, 0);
    } else {
        dispatch_time_t w = dispatch_walltime(NULL, (self.expireTimestamp - now - 1)*NSEC_PER_SEC);
        dispatch_source_set_timer(self.refreshTimer, w, DISPATCH_TIME_FOREVER, 0);
    }
}

-(void)startRefreshTimer {
    [self prepareTimer];
    dispatch_resume(self.refreshTimer);
}

-(void)stopRefreshTimer {
    dispatch_suspend(self.refreshTimer);
}

-(void)load {
    LevelDB *db = [LevelDB defaultLevelDB];
    self.accessToken = [db stringForKey:@"access_token"];
    self.refreshToken = [db stringForKey:@"refresh_token"];
    self.expireTimestamp = (int)[db intForKey:@"token_expire"];
    self.uid = [db intForKey:@"token_uid"];
}

-(void)save {
    LevelDB *db = [LevelDB defaultLevelDB];
    [db setString:self.accessToken forKey:@"access_token"];
    [db setString:self.refreshToken forKey:@"refresh_token"];
    [db setInt:self.expireTimestamp forKey:@"token_expire"];
    [db setInt:self.uid forKey:@"token_uid"];
}

@end
