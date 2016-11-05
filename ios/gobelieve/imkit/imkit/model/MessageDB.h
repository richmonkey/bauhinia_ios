/*                                                                            
  Copyright (c) 2014-2015, GoBelieve     
    All rights reserved.		    				     			
 
  This source code is licensed under the BSD-style license found in the
  LICENSE file in the root directory of this source tree. An additional grant
  of patent rights can be found in the PATENTS file in the same directory.
*/

//
//  Model.h
//  im
//
//  Created by houxh on 14-6-28.
//  Copyright (c) 2014年 potato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMessage.h"

//由近到远遍历消息
@protocol IMessageIterator
-(IMessage*)next;
@end

@protocol ConversationIterator
-(Conversation*)next;
@end

@class ReverseFile;

@interface MessageDB : NSObject
+(void)setDBPath:(NSString*)dir;
+(NSString*)getDBPath;

+(NSString*)getDocumentPath;
+(BOOL)writeHeader:(int)fd;
+(BOOL)checkHeader:(int)fd;
+(BOOL)writeMessage:(IMessage*)msg fd:(int)fd;
+(BOOL)insertIMessage:(IMessage*)msg path:(NSString*)path;
+(BOOL)addFlag:(int)msgLocalID path:(NSString*)path flag:(int)flag;
+(BOOL)eraseFlag:(int)msgLocalID path:(NSString*)path flag:(int)flag;
+(BOOL)clearMessages:(NSString*)path;
+(IMessage*)readMessage:(ReverseFile*)file;
@end
