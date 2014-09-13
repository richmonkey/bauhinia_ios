//
//  Outbox.m
//  Message
//
//  Created by houxh on 14-9-13.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "Outbox.h"
#import "APIRequest.h"
#import "FileCache.h"
#import "SDImageCache.h"
#import "IMService.h"
#import "LevelDB.h"
#import "PeerMessageDB.h"

@interface Outbox()
@property(nonatomic) NSMutableArray *observers;
@property(nonatomic) NSMutableArray *messages;
@end

@implementation Outbox
+(Outbox*)instance {
    static Outbox *box;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!box) {
            box = [[Outbox alloc] init];
        }
    });
    return box;
}


-(id)init {
    self = [super init];
    if (self) {
        self.observers = [NSMutableArray array];
        self.messages = [NSMutableArray array];
    }
    return self;
}

-(BOOL)isUploading:(IMessage *)msg {
    for (IMessage *message in self.messages) {
        if (message.receiver == msg.receiver && message.msgLocalID == msg.msgLocalID) {
            return YES;
        }
    }
    return NO;
}



- (void)sendMessage:(IMessage*)msg {
    Message *m = [[Message alloc] init];
    m.cmd = MSG_IM;
    IMMessage *im = [[IMMessage alloc] init];
    im.sender = msg.sender;
    im.receiver = msg.receiver;
    im.msgLocalID = msg.msgLocalID;
    
    im.content = msg.content.raw;
    m.body = im;
    
    [[IMService instance] sendPeerMessage:im];
}

-(void)onUploadImageSuccess:(IMessage*)msg URL:url {
    for (id<OutboxObserver> observer in self.observers) {
        [observer onImageUploadSuccess:msg URL:url];
    }

    [[LevelDB defaultLevelDB] setString:url forKey:msg.content.imageURL];
    
    MessageContent *content = [[MessageContent alloc] init];
    NSDictionary *dic = @{@"image":url};
    NSString* newStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:0 error:nil] encoding:NSUTF8StringEncoding];
    content.raw = newStr;
    MessageContent *old = msg.content;
    msg.content = content;
    [self sendMessage:msg];
    msg.content = old;
}

-(void)onUploadImageFail:(IMessage*)msg {
    [[PeerMessageDB instance] markPeerMessageFailure:msg.msgLocalID uid:msg.receiver];
    for (id<OutboxObserver> observer in self.observers) {
        [observer onImageUploadFail:msg];
    }
}

-(void)onUploadAudioSuccess:(IMessage*)msg URL:url {
    for (id<OutboxObserver> observer in self.observers) {
        [observer onAudioUploadSuccess:msg URL:url];
    }
    
    [[LevelDB defaultLevelDB] setString:url forKey:msg.content.audio.url];
    
    MessageContent *old = msg.content;
    NSNumber *d = [NSNumber numberWithInt:old.audio.duration];
    NSDictionary *dic = @{@"audio":@{@"url":url, @"duration":d}};
    NSString* newStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:0 error:nil] encoding:NSUTF8StringEncoding];
    MessageContent *content = [[MessageContent alloc] init];
    content.raw =  newStr;
    msg.content = content;
    [self sendMessage:msg];
    msg.content = old;
}

-(void)onUploadAudioFail:(IMessage*)msg {
    [[PeerMessageDB instance] markPeerMessageFailure:msg.msgLocalID uid:msg.receiver];
    for (id<OutboxObserver> observer in self.observers) {
        [observer onAudioUploadFail:msg];
    }
}

-(BOOL)uploadImage:(IMessage*)msg {
    SDImageCache *cache = [SDImageCache sharedImageCache];
    UIImage *image = [cache imageFromDiskCacheForKey:msg.content.imageURL];
    if (image == nil) {
        return NO;
    }
    
    [self.messages addObject:msg];
    [APIRequest uploadImage:image
                    success:^(NSString *url) {
                        [self.messages removeObject:msg];
                        if([url length] > 0){
                            NSLog(@"upload image success url:%@", url);
                            [self onUploadImageSuccess:msg URL:url];
                        } else {
                            NSLog(@"upload image fail");
                            [self onUploadAudioFail:msg];
                        }
                    }
                       fail:^() {
                           NSLog(@"upload image fail");
                           [self.messages removeObject:msg];
                           [self onUploadImageFail:msg];
                       }];
    return YES;
}

-(BOOL)uploadAudio:(IMessage*)msg {
    FileCache *cache = [FileCache instance];
    NSString *path = [cache queryCacheForKey:msg.content.audio.url];

    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data == nil) {
        return NO;
    }

    [APIRequest uploadAudio:data
                    success:^(NSString *url) {
                        [self.messages removeObject:msg];
                        if ([url length] > 0) {
                            NSLog(@"upload audio success url:%@", url);
                            [self onUploadAudioSuccess:msg URL:url];
                        } else {
                            NSLog(@"upload audio fail");
                            [self onUploadAudioFail:msg];
                        }
                    }fail:^{
                        NSLog(@"upload audio fail");
                        [self.messages removeObject:msg];
                        [self onUploadAudioFail:msg];
                    }];
    
    return YES;
}

-(void)addBoxObserver:(id<OutboxObserver>)ob {
    [self.observers addObject:ob];
}

-(void)removeBoxObserver:(id<OutboxObserver>)ob {
    [self.observers removeObject:ob];
}

@end
