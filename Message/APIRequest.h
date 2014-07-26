//
//  APIRequest.h
//  Message
//
//  Created by houxh on 14-7-26.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAHttpOperation.h"

@interface APIRequest : NSObject
+(TAHttpOperation*)updateState:(NSString*)state success:(void (^)())success fail:(void (^)())fail;
@end
