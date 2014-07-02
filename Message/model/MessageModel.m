//
//  MessageModel.m
//  Message
//
//  Created by daozhu on 14-7-1.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "MessageModel.h"

@implementation MessageModel

-(id)initWithMessage:(IMessage* )msg{
  if (self = [super init]) {
    self.msgId = msg.msgLocalID;
    self.sender = msg.sender;
    self.receiver = msg.receiver;
    self.type = msg.content.type;
    self.raw = msg.content.raw;
    self.timestamp = msg.timestamp;
  }
  return self;
}

@end
