//
//  MGroupMessageViewController.m
//  Message
//
//  Created by houxh on 16/8/8.
//  Copyright © 2016年 daozhu. All rights reserved.
//

#import "MGroupMessageViewController.h"
#import "GroupSettingViewController.h"
#import "GroupDB.h"
#import "Token.h"

@interface MGroupMessageViewController ()

@end

@implementation MGroupMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    Group *group = [[GroupDB instance] loadGroup:self.groupID];
    if (!group) {
        return;
    }
    
    //不是群组成员
    if ([group.members indexOfObject:[NSNumber numberWithLongLong:self.currentUID]] == NSNotFound) {
        CGFloat chatbarHeight = 5 * 2 + 36;
        CGRect frame = CGRectMake(0, self.view.frame.size.height - chatbarHeight, self.view.frame.size.width, chatbarHeight);
        UILabel *textView = [[UILabel alloc] initWithFrame:frame];
        textView.text = @"您不是群组的成员。";
        textView.font = [UIFont systemFontOfSize:15];
        textView.textAlignment = NSTextAlignmentCenter;
        textView.backgroundColor = RGBCOLOR(0xf5, 0xff, 0xfa);
        textView.lineBreakMode = NSLineBreakByWordWrapping;
        [self.view addSubview:textView];
        self.inputBar.hidden = YES;
        return;
    }

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
