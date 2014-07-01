//
//  MessageModel.h
//  Message
//
//  Created by daozhu on 14-7-1.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageModel : NSObject

@property(nonatomic) int msgId;
//@property(nonatomic) BOOL ack;
@property(nonatomic) int64_t sender;
@property(nonatomic) int64_t receiver;
@property(nonatomic) int type;
@property(nonatomic) NSString *raw;
@property(nonatomic) int timestamp;

@end
