//
//  IMService.h
//  im
//
//  Created by houxh on 14-6-26.
//  Copyright (c) 2014年 potato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"

#define STATE_UNCONNECTED 0
#define STATE_CONNECTING 1
#define STATE_CONNECTED 2
#define STATE_CONNECTFAIL 3

@class IMessage;

@protocol MessageObserver <NSObject>
-(void)onPeerMessage:(IMessage*)msg;

//服务器ack
-(void)onPeerMessageACK:(int)msgLocalID uid:(int64_t)uid;
//接受方ack
-(void)onPeerMessageRemoteACK:(int)msgLocalID uid:(int64_t)uid;

-(void)onPeerMessageFailure:(int)msgLocalID uid:(int64_t)uid;

-(void)onGroupMessage:(IMessage*)msg;
-(void)onGroupMessageACK:(int)msgLocalID gid:(int64_t)gid;

//用户连线状态
-(void)onOnlineState:(int64_t)uid state:(BOOL)on;

//对方正在输入
-(void)onPeerInputing:(int64_t)uid;

//同IM服务器连接的状态变更通知
-(void)onConnectState:(int)state;
@end

@interface IMService : NSObject

@property(nonatomic)NSString *host;
@property(nonatomic)int port;
@property(nonatomic, assign)int connectState;

+(IMService*)instance;

-(void)start:(int64_t)uid;
-(void)stop;

-(BOOL)sendPeerMessage:(IMessage*)msg;
-(BOOL)sendGroupMessage:(IMessage*)msg;

//正在输入
-(void)sendInputing:(MessageInputing*)inputing;

//订阅用户在线状态通知消息
-(void)subscribeState:(int64_t)uid;
-(void)unsubscribeState:(int64_t)uid;

-(void)addMessageObserver:(id<MessageObserver>)ob;
-(void)removeMessageObserver:(id<MessageObserver>)ob;
@end

