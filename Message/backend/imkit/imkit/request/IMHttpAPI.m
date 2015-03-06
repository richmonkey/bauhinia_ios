//
//  APIRequest.m
//  Message
//
//  Created by houxh on 14-7-26.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "IMHttpAPI.h"

#define API_URL @"http://gobelieve.io"
@implementation IMHttpAPI


+(IMHttpAPI*)instance {
    return nil;
}

+(TAHttpOperation*)uploadImage:(UIImage*)image success:(void (^)(NSString *url))success fail:(void (^)())fail {
    NSData *data = UIImagePNGRepresentation(image);
    TAHttpOperation *request = [TAHttpOperation httpOperationWithTimeoutInterval:60];
    request.targetURL = [API_URL stringByAppendingString:@"/images"];
    request.method = @"POST";
    request.postBody = data;
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithObject:@"image/png" forKey:@"Content-Type"];
    NSString *auth = [NSString stringWithFormat:@"Bearer %@", [IMHttpAPI instance].accessToken];
    [headers setObject:auth forKey:@"Authorization"];
    request.headers = headers;
    
    request.successCB = ^(TAHttpOperation*commObj, NSURLResponse *response, NSData *data) {
        NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSString *src_url = [resp objectForKey:@"src_url"];
        success(src_url);
    };
    request.failCB = ^(TAHttpOperation*commObj, TAHttpOperationError error) {
        fail();
    };
    [[NSOperationQueue mainQueue] addOperation:request];
    return request;

}


+(TAHttpOperation*)uploadAudio:(NSData*)data success:(void (^)(NSString *url))success fail:(void (^)())fail {
    TAHttpOperation *request = [TAHttpOperation httpOperationWithTimeoutInterval:60];
    request.targetURL = [API_URL stringByAppendingString:@"/audios"];
    request.method = @"POST";
    request.postBody = data;
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithObject:@"application/plain" forKey:@"Content-Type"];
    NSString *auth = [NSString stringWithFormat:@"Bearer %@", [IMHttpAPI instance].accessToken];
    [headers setObject:auth forKey:@"Authorization"];
    request.headers = headers;

    request.successCB = ^(TAHttpOperation*commObj, NSURLResponse *response, NSData *data) {
        NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSString *src_url = [resp objectForKey:@"src_url"];
        success(src_url);
    };
    request.failCB = ^(TAHttpOperation*commObj, TAHttpOperationError error) {
        fail();
    };
    [[NSOperationQueue mainQueue] addOperation:request];
    return request;
}

+(TAHttpOperation*)bindDeviceToken:(NSString*)deviceToken success:(void (^)())success fail:(void (^)())fail {
    TAHttpOperation *request = [TAHttpOperation httpOperationWithTimeoutInterval:60];
    request.targetURL = [API_URL stringByAppendingString:@"/device/bind"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:deviceToken forKey:@"apns_device_token"];
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"];
    NSString *auth = [NSString stringWithFormat:@"Bearer %@", [IMHttpAPI instance].accessToken];
    [headers setObject:auth forKey:@"Authorization"];
    
    request.headers = headers;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    request.postBody = data;
    request.method = @"POST";
    request.successCB = ^(TAHttpOperation*commObj, NSURLResponse *response, NSData *data) {
        int statusCode = [(NSHTTPURLResponse*)response statusCode];
        if (statusCode != 200) {
//            IMLog(@"bind device token fail");
            fail();
            return;
        }
        success();
    };
    request.failCB = ^(TAHttpOperation*commObj, TAHttpOperationError error) {
//        IMLog(@"bind device token fail");
        fail();
    };
    [[NSOperationQueue mainQueue] addOperation:request];
    return request;
}

@end
