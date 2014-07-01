//
//  IMService.h
//  im
//
//  Created by houxh on 14-6-26.
//  Copyright (c) 2014年 potato. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IMessage;
@class Message;

@protocol MessageObserver <NSObject>
-(void)onPeerMessage:(IMessage*)msg;
-(void)onPeerMessageACK:(int)msgLocalID uid:(int64_t)uid;
-(void)onGroupMessage:(IMessage*)msg;
-(void)onGroupMessageACK:(int)msgLocalID gid:(int64_t)gid;
@end

@interface IMService : NSObject
+(IMService*)instance;
-(void)start ;
-(void)stop;
-(void)setUserID:(NSString*)uidStr;

-(BOOL)sendPeerMessage:(IMessage*)msg;
-(BOOL)sendGroupMessage:(IMessage*)msg;

-(void)addMessageObserver:(id<MessageObserver>)ob;
-(void)removeMessageObserver:(id<MessageObserver>)ob;
@end

