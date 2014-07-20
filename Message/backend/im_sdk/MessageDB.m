//
//  Model.m
//  im
//
//  Created by houxh on 14-6-28.
//  Copyright (c) 2014年 potato. All rights reserved.
//

#import "MessageDB.h"
#include <sys/stat.h>
#include <dirent.h>
#import "util.h"

#define HEADER_SIZE 32
#define IMMAGIC 0x494d494d
#define IMVERSION (1<<16) //1.0

@interface MessageDB()
-(NSString*)getMessagePath;

-(NSString*)getPeerPath:(int64_t)uid;

-(NSString*)getGroupPath:(int64_t)gid;

@end

@interface ReverseFile : NSObject
@property(nonatomic)int fd;
@property(nonatomic)int pos;
-(id)initWithFD:(int)fd;
-(int)read:(char*)p length:(int)len;
@end

@implementation ReverseFile

-(id)initWithFD:(int)fd {
    self = [super init];
    if (self) {
        self.pos = (int)lseek(fd, 0, SEEK_END);
        self.fd = fd;
    }
    return self;
}

-(void)dealloc {
    close(self.fd);
}

-(int)read:(char*)p length:(int)len {
    int n = pread(self.fd, p, len, self.pos - len);
    self.pos = self.pos - len;
    return n;
}

@end

@interface IMessageIterator()
@property(nonatomic)ReverseFile *file;

-(id)initWithPath:(NSString*)path;
@end

@implementation IMessageIterator

-(id)initWithPath:(NSString*)path {
    self = [super init];
    if (self) {
        [self openFile:path];
    }
    return self;
}

-(void)openFile:(NSString*)path {

    int fd = open([path UTF8String], O_RDONLY);
    if (fd == -1) {
        NSLog(@"open file fail:%@", path);
        return;
    }
    char header[HEADER_SIZE];
    int n = read(fd, header, HEADER_SIZE);
    if (n != HEADER_SIZE) {
        close(fd);
        return;
    }
    int32_t magic = readInt32(header);
    int32_t version = readInt32(header + 4);
    if (magic != IMMAGIC || version != IMVERSION) {
        NSLog(@"file damage");
        close(fd);
        return;
    }
    self.file = [[ReverseFile alloc] initWithFD:fd];
}

-(IMessage*)nextMessage {
    char buf[64*1024];
    if (!self.file) return nil;
    int n = [self.file read:buf length:8];
    if (n != 8) {
        return nil;
    }
    int len = readInt32(buf);
    int magic = readInt32(buf + 4);
    if (magic != IMMAGIC) {
        return nil;
    }
    if (len + 8 > 64*1024) {
        return nil;
    }
    
    n = [self.file read:buf length:len+8];
    if (n != len + 8) {
        return nil;
    }
    IMessage *msg = [[IMessage alloc] init];
    char *p = buf + 8;
    msg.flags = readInt32(p);
    p += 4;
    msg.timestamp = readInt32(p);
    p += 4;
    msg.sender = readInt64(p);
    p += 8;
    msg.receiver = readInt64(p);
    p += 8;
    MessageContent *content = [[MessageContent alloc] init];
    content.raw = [[NSString alloc] initWithBytes:p length:len - 24 encoding:NSUTF8StringEncoding];
    msg.content = content;
    return msg;
}

-(IMessage*)next {
    while (YES) {
        IMessage *msg = [self nextMessage];
        if (msg.flags & MESSAGE_FLAG_DELETE) {
            continue;
        }
        return msg;
    }
}
@end

@interface ConversationIterator()
@property(nonatomic)DIR *dirp;
@end

@implementation ConversationIterator
-(id)init {
    self = [super init];
    if (self) {
        [self openDir];
    }
    return self;
}

-(void)dealloc {
    if (self.dirp) {
        closedir(self.dirp);
    }
}
-(void)openDir {
    NSString *path = [[MessageDB instance] getMessagePath];
    DIR *dirp = opendir([path UTF8String]);
    if (dirp == NULL) {
        NSLog(@"readdir error:%d", errno);
        return;
    }
    self.dirp = dirp;
}

-(IMessage*)getLastPeerMessage:(int64_t)uid {
    IMessageIterator *iter = [[MessageDB instance] newPeerMessageIterator:uid];
    IMessage *msg;
    msg = [iter next];
    return msg;
}

-(Conversation*)next {
    if (!self.dirp) return nil;
    
    struct dirent *dp;
    while ((dp = readdir(self.dirp)) != NULL) {
        NSString *name = [[NSString alloc] initWithBytes:dp->d_name length:dp->d_namlen encoding:NSUTF8StringEncoding];
        NSLog(@"type:%d name:%@", dp->d_type, name);
        if (dp->d_type == DT_REG) {
            if ([name hasPrefix:@"p_"]) {
                Conversation *c = [[Conversation alloc] init];
                int64_t uid = [[name substringFromIndex:2] longLongValue];
                c.cid = uid;
                c.type = CONVERSATION_PEER;
                c.message = [self getLastPeerMessage:uid];
                if (c.message) return c;
            } else if ([name hasPrefix:@"g_"]) {
                
            } else {
                NSLog(@"skip file:%@", name);
            }
        }
    }
    return nil;
}
@end

@implementation MessageDB
+(MessageDB*)instance {
    static MessageDB *m;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!m) {
            m = [[MessageDB alloc] init];
        }
    });
    return m;
}

-(id)init {
    self = [super init];
    if (self) {
        NSString *path = [self getMessagePath];
        int r = mkdir([path UTF8String], 0755);
        if (r == -1 && errno != EEXIST) {
            NSLog(@"mkdir error:%d", errno);
        }
    }
    return self;
}

-(NSString*)getDocumentPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

-(NSString*)getMessagePath {
    NSString *s = [self getDocumentPath];
    return [NSString stringWithFormat:@"%@/message", s];
}
-(NSString*)getPeerPath:(int64_t)uid {
    NSString *s = [self getDocumentPath];
    return [NSString stringWithFormat:@"%@/message/p_%lld", s, uid];
}

-(NSString*)getGroupPath:(int64_t)gid {
    NSString *s = [self getDocumentPath];
    return [NSString stringWithFormat:@"%@/message/g_%lld", s, gid];
}
//4字节magic ＋ 4字节version ＋ 24字节padding
-(BOOL)writeHeader:(int)fd {
    char buf[HEADER_SIZE] = {0};
    writeInt32(IMMAGIC, buf);
    writeInt32(IMVERSION, buf + 4);
    int n = write(fd, buf, HEADER_SIZE);
    if (n != HEADER_SIZE) return NO;
    return YES;
}

//4字节magic + 4字节消息长度 + 消息主体 + 4字节消息长度 + 4字节magic
//消息主体：4字节标志 ＋ 4字节时间戳 + 8字节发送者id + 8字节接受者id ＋ 消息内容
-(BOOL)writeMessage:(IMessage*)msg fd:(int)fd {
    char buf[64*1024];
    char *p = buf;
    
    const char *raw = [msg.content.raw UTF8String];
    int len = strlen(raw) + 8 + 8 + 4 + 4;
    
    if (4 + 4 + len + 4 + 4 > 64*1024) return NO;
    
    writeInt32(IMMAGIC, p);
    p += 4;
    writeInt32(len, p);
    p += 4;
    writeInt32(msg.flags, p);
    p += 4;
    writeInt32(msg.timestamp, p);
    p += 4;
    writeInt64(msg.sender, p);
    p += 8;
    writeInt64(msg.receiver, p);
    p += 8;
    memcpy(p, raw, strlen(raw));
    p += strlen(raw);
    writeInt32(len, p);
    p += 4;
    writeInt32(IMMAGIC, p);
    p += 4;
    int size = p - buf;
    int n = write(fd, buf, size);
    if (n != size) return NO;
    return YES;
}

-(BOOL)insertIMessage:(IMessage*)msg path:(NSString*)path {
    int fd = open([path UTF8String], O_WRONLY|O_APPEND|O_CREAT, 0644);
    if (fd == -1) {
        NSLog(@"open file fail:%@", path);
        return NO;
    }

    off_t size = lseek(fd, 0, SEEK_END);
    if (size < HEADER_SIZE && size > 0) {
        ftruncate(fd, 0);
        size = 0;
    }
    
    if (size == 0) {
        [self writeHeader:fd];
    }
    off_t seq = lseek(fd, 0, SEEK_CUR);
    msg.msgLocalID = (int)seq;
    [self writeMessage:msg fd:fd];
    close(fd);
    return NO;
}

-(BOOL)insertPeerMessage:(IMessage*)msg uid:(int64_t)uid{
    NSString *path = [self getPeerPath:uid];
    return [self insertIMessage:msg path:path];
}

-(BOOL)addFlag:(int)msgLocalID path:(NSString*)path flag:(int)flag {
    int fd = open([path UTF8String], O_RDWR);
    if (fd == -1) {
        NSLog(@"open file fail:%@", path);
        return NO;
    }
    char buf[8+4];
    int n = pread(fd, buf, 12, msgLocalID);
    if (n != 12) {
        return NO;
    }
    int magic = readInt32(buf);
    if (magic != IMMAGIC) {
        NSLog(@"invalid message local id:%d", msgLocalID);
        return NO;
    }
    int flags = readInt32(buf + 8);
    flags |= flag;
    writeInt32(flags, buf);
    n = pwrite(fd, buf, 4, msgLocalID + 8);
    if (n != 4) {
        NSLog(@"write error:%d", errno);
        return NO;
    }
    return YES;
}

-(BOOL)removePeerMessage:(int)msgLocalID uid:(int64_t)uid{
    NSString *path = [self getPeerPath:uid];
    return [self addFlag:msgLocalID path:path flag:MESSAGE_FLAG_DELETE];
}

-(BOOL)clearConversation:(int64_t)uid {
    NSString *path = [self getPeerPath:uid];
    int r = unlink([path UTF8String]);
    if (r == -1) {
        NSLog(@"unlink error:%d", errno);
        return (errno == ENOENT);
    }
    return YES;
}

-(BOOL)acknowledgePeerMessage:(int)msgLocalID uid:(int64_t)uid {
    NSString *path = [self getPeerPath:uid];
    return [self addFlag:msgLocalID path:path flag:MESSAGE_FLAG_ACK];
}

-(BOOL)acknowledgePeerMessageFromRemote:(int)msgLocalID uid:(int64_t)uid {
    NSString *path = [self getPeerPath:uid];
    return [self addFlag:msgLocalID path:path flag:MESSAGE_FLAG_PEER_ACK];
}

-(BOOL)markPeerMessageFailure:(int)msgLocalID uid:(int64_t)uid {
    NSString *path = [self getPeerPath:uid];
    return [self addFlag:msgLocalID path:path flag:MESSAGE_FLAG_FAILURE];
}

-(BOOL)insertGroupMessage:(IMessage*)msg {
    NSString *path = [self getGroupPath:msg.receiver];
    return [self insertIMessage:msg path:path];
}

-(BOOL)removeGroupMessage:(int)msgLocalID gid:(int64_t)gid{
    NSString *path = [self getGroupPath:gid];
    return [self addFlag:msgLocalID path:path flag:MESSAGE_FLAG_DELETE];
}

-(BOOL)clearGroupConversation:(int64_t)gid {
    NSString *path = [self getGroupPath:gid];
    int r = unlink([path UTF8String]);
    if (r == -1) {
        NSLog(@"unlink error:%d", errno);
        return (errno == ENOENT);
    }
    return YES;
}

-(BOOL)acknowledgeGroupMessage:(int)msgLocalID gid:(int64_t)gid {
    NSString *path = [self getGroupPath:gid];
    return [self addFlag:msgLocalID path:path flag:MESSAGE_FLAG_ACK];
}

-(BOOL)markGroupMessageFailure:(int)msgLocalID gid:(int64_t)gid {
    NSString *path = [self getGroupPath:gid];
    return [self addFlag:msgLocalID path:path flag:MESSAGE_FLAG_FAILURE];
}

-(IMessageIterator*)newPeerMessageIterator:(int64_t)uid {
    NSString *path = [[MessageDB instance] getPeerPath:uid];
    return [[IMessageIterator alloc] initWithPath:path];
}
-(ConversationIterator*)newConversationIterator {
    return [[ConversationIterator alloc] init];
}
@end
