//
//  Model.h
//  im
//
//  Created by houxh on 14-6-28.
//  Copyright (c) 2014年 potato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMessage.h"

//由近到远遍历消息
@interface IMessageIterator : NSObject
-(IMessage*)next;
@end

@interface ConversationIterator : NSObject
-(Conversation*)next;
@end


@interface MessageDB : NSObject
+(MessageDB*)instance;

-(IMessageIterator*)newPeerMessageIterator:(int64_t)uid;
-(ConversationIterator*)newConversationIterator;

-(BOOL)insertPeerMessage:(IMessage*)msg uid:(int64_t)uid;
-(BOOL)removePeerMessage:(int)msgLocalID uid:(int64_t)uid;
-(BOOL)clearConversation:(int64_t)uid;
-(BOOL)acknowledgePeerMessage:(int)msgLocalID uid:(int64_t)uid;
-(BOOL)acknowledgePeerMessageFromRemote:(int)msgLocalID uid:(int64_t)uid;
-(BOOL)markPeerMessageFailure:(int)msgLocalID uid:(int64_t)uid;

-(BOOL)insertGroupMessage:(IMessage*)msg;
-(BOOL)removeGroupMessage:(int)msgLocalID gid:(int64_t)gid;
-(BOOL)clearGroupConversation:(int64_t)gid;
-(BOOL)acknowledgeGroupMessage:(int)msgLocalID gid:(int64_t)gid;
-(BOOL)markGroupMessageFailure:(int)msgLocalID gid:(int64_t)gid;

@end
