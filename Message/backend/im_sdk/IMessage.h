//
//  IMessage.h
//  im
//
//  Created by houxh on 14-6-28.
//  Copyright (c) 2014年 potato. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MESSAGE_TEXT 1

#define MESSAGE_FLAG_DELETE 1
#define MESSAGE_FLAG_ACK 2
#define MESSAGE_FLAG_PEER_ACK 4
#define MESSAGE_FLAG_FAILURE 8

@interface MessageContent : NSObject
@property(nonatomic)int type;
@property(nonatomic)NSString *raw;
@end

@interface MessageContent(Text)
@property(nonatomic, readonly)NSString *text;
@end

@interface IMessage : NSObject
@property(nonatomic) int msgLocalID;
@property(nonatomic) int flags;
@property(nonatomic) int64_t sender;
@property(nonatomic) int64_t receiver;
@property(nonatomic) MessageContent *content;
@property(nonatomic) int timestamp;
@property(nonatomic, readonly) BOOL isACK;
@property(nonatomic, readonly) BOOL isPeerACK;
@property(nonatomic, readonly) BOOL isFailure;
@end


#define CONVERSATION_PEER 1
#define CONVERSATION_GROUP 2
@interface Conversation : NSObject
@property(nonatomic)int type;
@property(nonatomic, assign)int64_t cid;
@property(nonatomic, copy)NSString *name;
@property(nonatomic)IMessage *message;
@end