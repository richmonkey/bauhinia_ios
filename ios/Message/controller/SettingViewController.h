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

@class RCTBridge;

@interface SettingViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,TCPConnectionObserver,UIAlertViewDelegate,ZBarReaderDelegate>

@property (strong,nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSArray *cellTitleArray;
@property (weak,nonatomic) UITableViewCell *statusCell;
@property (strong,nonatomic) UIView* redScanLine;

- (instancetype)initWithComponent:(NSString *)component passProps:(NSDictionary *)passProps navigatorStyle:(NSDictionary*)navigatorStyle globalProps:(NSDictionary *)globalProps bridge:(RCTBridge *)bridge;

@end
