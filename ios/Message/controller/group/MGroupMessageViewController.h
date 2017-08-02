//
//  MGroupMessageViewController.h
//  Message
//
//  Created by houxh on 16/8/8.
//  Copyright © 2016年 daozhu. All rights reserved.
//

#import <gobelieve/GroupMessageViewController.h>

@class RCTBridge;
@interface MGroupMessageViewController : GroupMessageViewController
- (instancetype)initWithComponent:(NSString *)component passProps:(NSDictionary *)passProps navigatorStyle:(NSDictionary*)navigatorStyle globalProps:(NSDictionary *)globalProps bridge:(RCTBridge *)bridge;
@end
