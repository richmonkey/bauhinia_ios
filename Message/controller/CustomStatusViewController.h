//
//  CustomStatusViewController.h
//  Message
//
//  Created by daozhu on 14-6-16.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomStatusViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>


@property (strong,nonatomic) NSMutableArray *statusArray;
@property (strong,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSString *currentStatus;
@end
