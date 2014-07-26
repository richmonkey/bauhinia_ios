//
//  APIRequest.m
//  Message
//
//  Created by houxh on 14-7-26.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "APIRequest.h"
#import "Token.h"
#import "Config.h"

@implementation APIRequest
+(TAHttpOperation*)updateState:(NSString*)state success:(void (^)())success fail:(void (^)())fail {

    TAHttpOperation *request = [TAHttpOperation httpOperationWithTimeoutInterval:60];
    request.targetURL = [[Config instance].URL stringByAppendingString:@"/users/me"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:state forKey:@"state"];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"];
    NSString *auth = [NSString stringWithFormat:@"Bearer %@", [Token instance].accessToken];
    [headers setObject:auth forKey:@"Authorization"];
    request.headers = headers;
    request.postBody = data;
    request.method = @"PATCH";
    request.successCB = ^(TAHttpOperation*commObj, NSURLResponse *response, NSData *data) {
        NSInteger statusCode = [(NSHTTPURLResponse*)response statusCode];
        if (statusCode != 200) {
            IMLog(@"update state fail");
            fail();
            return;
        }
        IMLog(@"update state success");
        success();
    };
    request.failCB = ^(TAHttpOperation*commObj, TAHttpOperationError error) {
        IMLog(@"update state fail");
        fail();
        
    };
    [[NSOperationQueue mainQueue] addOperation:request];
    return request;
}
@end
