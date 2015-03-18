//
//  NewGroupViewController.m
//  Message
//
//  Created by houxh on 15/3/18.
//  Copyright (c) 2015年 daozhu. All rights reserved.
//

#import "NewGroupViewController.h"
#import "AddGroupMemberTableViewController.h"
#import "UIView+Toast.h"

@interface NewGroupViewController ()

@end

@implementation NewGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"下一步"
                                                             style:UIBarButtonItemStyleDone
                                                            target:self
                                                            action:@selector(next)];
    
    self.navigationItem.rightBarButtonItem = item;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


- (void)next {
    NSString *nameGroup = self.nameTextField.text;
    nameGroup = [nameGroup stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (nameGroup.length == 0) {
        [self.view makeToast:@"请输入群名称!" duration:1.0f position:@"center"];
        return;
    }
    
    AddGroupMemberTableViewController *ctl = [[AddGroupMemberTableViewController alloc] initWithGroupName:nameGroup];
    [self.navigationController pushViewController:ctl animated:YES];
}


@end
