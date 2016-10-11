//
//  NewCount.h
//  kefu
//
//  Created by houxh on 16/4/28.
//  Copyright © 2016年 beetle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewCount : NSObject
+(int)getNewCount:(int64_t)uid;
+(void)setNewCount:(int)count uid:(int64_t)uid;
+(int)getGroupNewCount:(int64_t)gid;
+(void)setGroupNewCount:(int)count gid:(int64_t)gid;
@end
