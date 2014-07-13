//
//  IMessage.m
//  im
//
//  Created by houxh on 14-6-28.
//  Copyright (c) 2014年 potato. All rights reserved.
//

#import "IMessage.h"


@implementation MessageContent
-(int)type {
    return MESSAGE_TEXT;
}
-(NSString*)text {
    return self.raw;
}
@end

@implementation IMessage


@end

@implementation Conversation


@end