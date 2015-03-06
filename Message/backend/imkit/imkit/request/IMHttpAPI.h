//
//  APIRequest.h
//  Message
//
//  Created by houxh on 14-7-26.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAHttpOperation.h"
#import <UIKit/UIKit.h>

@interface IMHttpAPI : NSObject

@property(nonatomic, copy) NSString *accessToken;

+(IMHttpAPI*)instance;

+(TAHttpOperation*)uploadImage:(UIImage*)image success:(void (^)(NSString *url))success fail:(void (^)())fail;

+(TAHttpOperation*)uploadAudio:(NSData*)data success:(void (^)(NSString *url))success fail:(void (^)())fail;

+(TAHttpOperation*)bindDeviceToken:(NSString*)deviceToken success:(void (^)())success fail:(void (^)())fail;

@end
