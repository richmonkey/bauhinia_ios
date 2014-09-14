//
//  AudioDownloader.m
//  Message
//
//  Created by houxh on 14-9-14.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "AudioDownloader.h"
#import "TAHttpOperation.h"
#import "FileCache.h"

@interface AudioDownloader()
@property(nonatomic)NSMutableArray *observers;
@property(nonatomic)NSMutableArray *messages;
@end

@implementation AudioDownloader
+(AudioDownloader*)instance {
    static AudioDownloader *box;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!box) {
            box = [[AudioDownloader alloc] init];
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

-(void)addDownloaderObserver:(id<AudioDownloaderObserver>)ob {
    [self.observers addObject:ob];
}

-(void)removeDownloaderObserver:(id<AudioDownloaderObserver>)ob {
    [self.observers removeObject:ob];
}

-(BOOL)isDownloading:(IMessage*)msg {
    for (IMessage *message in self.messages) {
        if (message.receiver == msg.receiver &&
            message.sender == msg.sender &&
            message.msgLocalID == msg.msgLocalID) {
            return YES;
        }
    }
    return NO;
}

-(void)onDownloadSuccess:(IMessage*)msg {
    for (id<AudioDownloaderObserver> ob in self.observers) {
        [ob onAudioDownloadSuccess:msg];
    }
}

-(void)onDownloadFail:(IMessage*)msg {
    for (id<AudioDownloaderObserver> ob in self.observers) {
        [ob onAudioDownloadFail:msg];
    }
}

-(TAHttpOperation*)downloadAudio:(NSString*)url success:(void (^)(NSData *data))success fail:(void (^)())fail {
    TAHttpOperation *request = [TAHttpOperation httpOperationWithTimeoutInterval:60];
    request.targetURL = url;
    request.method = @"GET";
    
    request.successCB = ^(TAHttpOperation*commObj, NSURLResponse *response, NSData *data) {
        success(data);
    };
    request.failCB = ^(TAHttpOperation*commObj, TAHttpOperationError error) {
        fail();
    };
    [[NSOperationQueue mainQueue] addOperation:request];
    return request;
    
}

-(void)downloadAudio:(IMessage*)msg {
    if ([self isDownloading:msg]) {
        return;
    }
    [self.messages addObject:msg];
    [self downloadAudio: msg.content.audio.url
                success:^(NSData *data) {
                    [self.messages removeObject:msg];
                    FileCache *cache = [FileCache instance];
                    [cache storeFile:data forKey:msg.content.audio.url];
                    [self onDownloadSuccess:msg];
                }
                   fail:^{
                       [self.messages removeObject:msg];
                       [self onDownloadFail:msg];
                   }];
}

@end
