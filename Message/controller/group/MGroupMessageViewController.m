//
//  MGroupMessageViewController.m
//  Message
//
//  Created by houxh on 16/8/8.
//  Copyright © 2016年 daozhu. All rights reserved.
//

#import "MGroupMessageViewController.h"
#import "GroupSettingViewController.h"

@interface MGroupMessageViewController ()

@end

@implementation MGroupMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"设置"
                                                             style:UIBarButtonItemStyleDone
                                                            target:self
                                                            action:@selector(groupSetting)];
    
    self.navigationItem.rightBarButtonItem = item;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)groupSetting {
    GroupSettingViewController *ctrl = [[GroupSettingViewController alloc] init];
    ctrl.groupID = self.groupID;
    
//    [self presentViewController:ctrl animated:NO completion:^{
//
//    }];
    [self.navigationController pushViewController:ctrl animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
