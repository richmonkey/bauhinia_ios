//
//  CustomStatusViewController.h
//  Message
//
//  Created by daozhu on 14-6-16.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@class RCTBridge;

@interface CustomStatusViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic) NSMutableArray *statusArray;
@property (nonatomic) UITableView *tableView;
@property (nonatomic, copy) NSString *currentStatus;

- (instancetype)initWithComponent:(NSString *)component passProps:(NSDictionary *)passProps navigatorStyle:(NSDictionary*)navigatorStyle globalProps:(NSDictionary *)globalProps bridge:(RCTBridge *)bridge;
@end
