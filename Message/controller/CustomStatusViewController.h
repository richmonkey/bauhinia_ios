//
//  CustomStatusViewController.h
//  Message
//
//  Created by daozhu on 14-6-16.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface CustomStatusViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>


@property (nonatomic) NSMutableArray *statusArray;
@property (nonatomic) UITableView *tableView;
@property (nonatomic, copy) NSString *currentStatus;
@end
