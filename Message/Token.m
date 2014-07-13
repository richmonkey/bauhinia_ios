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

@interface Token()
@property(nonatomic)dispatch_source_t refreshTimer;
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
    TAHttpOperation *request = [TAHttpOperation httpOperationWithTimeoutInterval:60];
    request.targetURL = [[Config instance].URL stringByAppendingString:@"/auth/refresh_token"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:self.refreshToken forKey:@"refresh_token"];
    NSDictionary *headers = [NSDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"];
    request.headers = headers;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    request.postBody = data;
    request.method = @"POST";
    request.successCB = ^(TAHttpOperation*commObj, NSURLResponse *response, NSData *data) {
        int statusCode = [(NSHTTPURLResponse*)response statusCode];
        if (statusCode != 200) {
            IMLog(@"refresh token fail");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self prepareTimer];
            });
            return;
        }
        NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        self.accessToken = [resp objectForKey:@"access_token"];
        self.refreshToken = [resp objectForKey:@"refresh_token"];
        self.expireTimestamp = time(NULL) + [[resp objectForKey:@"expires_in"] intValue];
        [self save];
        [self prepareTimer];
    };
    request.failCB = ^(TAHttpOperation*commObj, TAHttpOperationError error) {
        IMLog(@"refresh token fail");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self prepareTimer];
        });
    };
    [[NSOperationQueue mainQueue] addOperation:request];
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
