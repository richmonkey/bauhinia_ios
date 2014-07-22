//
//  PeerMessageHandler.m
//  Message
//
//  Created by houxh on 14-7-22.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "PeerMessageHandler.h"
#import "MessageDB.h"
#import "Message.h"

@implementation PeerMessageHandler
+(PeerMessageHandler*)instance {
    static PeerMessageHandler *m;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!m) {
            m = [[PeerMessageHandler alloc] init];
        }
    });
    return m;
}

-(BOOL)handleMessage:(IMMessage*)msg {
    IMMessage *im = msg;
    IMessage *m = [[IMessage alloc] init];
    m.sender = im.sender;
    m.receiver = im.receiver;
    MessageContent *content = [[MessageContent alloc] init];
    content.raw = im.content;
    m.content = content;
    m.timestamp = time(NULL);
    BOOL r = [[MessageDB instance] insertPeerMessage:m uid:im.sender];
    if (r) {
        msg.msgLocalID = m.msgLocalID;
    }
    return r;
}

-(BOOL)handleMessageACK:(int)msgLocalID uid:(int64_t)uid {
    return [[MessageDB instance] acknowledgePeerMessage:msgLocalID uid:uid];
}

-(BOOL)handleMessageRemoteACK:(int)msgLocalID uid:(int64_t)uid {
    MessageDB *db = [MessageDB instance];
    return [db acknowledgePeerMessageFromRemote:msgLocalID uid:uid];
}

-(BOOL)handleMessageFailure:(int)msgLocalID uid:(int64_t)uid {
    MessageDB *db = [MessageDB instance];
    return [db markPeerMessageFailure:msgLocalID uid:uid];
}

@end
