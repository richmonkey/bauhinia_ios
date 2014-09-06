//
//  IMessage.m
//  im
//
//  Created by houxh on 14-6-28.
//  Copyright (c) 2014年 potato. All rights reserved.
//

#import "IMessage.h"
#import <CoreLocation/CLLocation.h>

@interface MessageContent()
@property(nonatomic)NSDictionary *dict;
@property(nonatomic, copy)NSString *_raw;
@end

/*
 raw format
 {
    "text":"文本",
    "image":"image url",
    "audio":"audio url",
    "location":{
        "latitude":"纬度(浮点数)",
        "latitude":"经度(浮点数)"
    }
}*/

@implementation MessageContent

-(NSString*)text {
    return [self.dict objectForKey:@"text"];
}

-(NSString*)imageURL {
    return [self.dict objectForKey:@"image"];
}

-(NSString*)audioURL {
    return [self.dict objectForKey:@"audio"];
}

-(CLLocationCoordinate2D)location {
    CLLocationCoordinate2D lt;
    NSDictionary *location = [self.dict objectForKey:@"location"];
    lt.latitude = [[location objectForKey:@"latitude"] doubleValue];
    lt.longitude = [[location objectForKey:@"longitude"] doubleValue];
    return lt;
}


-(void)setRaw:(NSString *)raw {
    self._raw = raw;
    const char *utf8 = [raw UTF8String];
    if (utf8 == nil) return;
    NSData *data = [NSData dataWithBytes:utf8 length:strlen(utf8)];
    self.dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    
    if ([self.dict objectForKey:@"text"] != nil) {
        self.type = MESSAGE_TEXT;
    } else if ([self.dict objectForKey:@"image"] != nil) {
        self.type = MESSAGE_IMAGE;
    } else if ([self.dict objectForKey:@"audio"] != nil) {
        self.type = MESSAGE_AUDIO;
    } else if ([self.dict objectForKey:@"location"] != nil) {
        self.type = MESSAGE_LOCATION;
    } else {
        self.type = MESSAGE_UNKNOWN;
    }
}

-(NSString*)raw {
    return self._raw;
}

@end

@implementation IMessage

-(BOOL)isACK {
    return self.flags&MESSAGE_FLAG_ACK;
}

-(BOOL)isPeerACK {
    return self.flags&MESSAGE_FLAG_PEER_ACK;
}

-(BOOL)isFailure {
    return self.flags&MESSAGE_FLAG_FAILURE;
}

@end

@implementation Conversation


@end