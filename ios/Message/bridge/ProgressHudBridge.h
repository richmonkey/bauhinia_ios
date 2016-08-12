//
//  ProgressHubBridge.h
//  Message
//
//  Created by houxh on 16/8/11.
//  Copyright © 2016年 daozhu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RCTBridgeModule.h"
@interface ProgressHudBridge : NSObject<RCTBridgeModule>
@property(nonatomic, weak) UIView *view;
@end
