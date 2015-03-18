//
//  GroupMessageDB.h
//  Message
//
//  Created by houxh on 14-7-22.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IMessage.h"
#import "MessageDB.h"

@interface GroupConversationIterator : NSObject<ConversationIterator>

@end

@interface GroupMessageIterator : NSObject<IMessageIterator>

@end

@interface GroupMessageDB : NSObject
+(GroupMessageDB*)instance;

-(id<IMessageIterator>)newMessageIterator:(int64_t)uid;
-(id<IMessageIterator>)newMessageIterator:(int64_t)uid last:(int)lastMsgID;
-(id<ConversationIterator>)newConversationIterator;

-(BOOL)insertGroupMessage:(IMessage*)msg;
-(BOOL)removeGroupMessage:(int)msgLocalID gid:(int64_t)gid;
-(BOOL)clearGroupConversation:(int64_t)gid;
-(BOOL)acknowledgeGroupMessage:(int)msgLocalID gid:(int64_t)gid;
-(BOOL)markGroupMessageFailure:(int)msgLocalID gid:(int64_t)gid;

@end