//
//  IM.m
//  im
//
//  Created by houxh on 14-6-21.
//  Copyright (c) 2014年 potato. All rights reserved.
//

#import "Message.h"
#import "util.h"

#define HEAD_SIZE 8

@implementation IMMessage

@end

@implementation Message
-(NSData*)pack {
    char buf[64*1024] = {0};
    char *p = buf;

    writeInt32(self.seq, p);
    p += 4;
    *p = (uint8_t)self.cmd;
    p += 4;
    
    if (self.cmd == MSG_HEARTBEAT) {
        return [NSData dataWithBytes:buf length:HEAD_SIZE];
    } else if (self.cmd == MSG_AUTH) {
        int64_t uid = [(NSNumber*)self.body longLongValue];
        writeInt64(uid, p);
        return [NSData dataWithBytes:buf length:HEAD_SIZE+8];
    } else if (self.cmd == MSG_IM) {
        IMMessage *m = (IMMessage*)self.body;
        writeInt64(m.sender, p);
        p += 8;
        writeInt64(m.receiver, p);
        p += 8;
        const char *s = [m.content UTF8String];
        int l = strlen(s);
        if ((l + 24) > 64*1024) {
            return nil;
        }
        memcpy(p, s, l);
        return [NSData dataWithBytes:buf length:24+l];
    } else if (self.cmd == MSG_ACK) {
        writeInt32([(NSNumber*)self.body intValue], p);
        return [NSData dataWithBytes:buf length:8+4];
    }
    return nil;
}

-(BOOL)unpack:(NSData*)data {
    const char *p = [data bytes];
    self.seq = readInt32(p);
    p += 4;
    self.cmd = *p;
    p += 4;
    NSLog(@"seq:%d cmd:%d", self.seq, self.cmd);
    if (self.cmd == MSG_RST) {
        return YES;
    } else if (self.cmd == MSG_AUTH_STATUS) {
        int status = readInt32(p);
        self.body = [NSNumber numberWithInt:status];
        return YES;
    } else if (self.cmd == MSG_IM) {
        IMMessage *m = [[IMMessage alloc] init];
        m.sender = readInt64(p);
        p += 8;
        m.receiver = readInt64(p);
        p += 8;
        m.content = [[NSString alloc] initWithBytes:p length:data.length-24 encoding:NSUTF8StringEncoding];
        self.body = m;
        return YES;
    } else if (self.cmd == MSG_ACK) {
        int seq = readInt32(p);
        self.body = [NSNumber numberWithInt:seq];
        return YES;
    }

    return NO;
}

@end
