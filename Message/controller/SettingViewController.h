//
//  SettingViewController.h
//  Message
//
//  Created by daozhu on 14-6-16.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <gobelieve/IMService.h>
#import "ZBarReaderViewController.h"


@interface SettingViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,TCPConnectionObserver,UIAlertViewDelegate,ZBarReaderDelegate>

@property (strong,nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSArray *cellTitleArray;
@property (weak,nonatomic) UITableViewCell *statusCell;
@property (strong,nonatomic) UIView* redScanLine;

@end
