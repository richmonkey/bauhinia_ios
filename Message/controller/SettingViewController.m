//
//  SettingViewController.m
//  Message
//
//  Created by daozhu on 14-6-16.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "SettingViewController.h"


#define kNetStatusSection 2
#define kNetStatusRow     0
#define kClearAllConversationSection 3

@interface SettingViewController ()

@end

@implementation SettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.cellTitleArray = @[ @[@"关于",@"告诉朋友"],
                                 @[@"个人资讯",@"账号",@"对话设置",@"通知"],
                                 @[@"网络状态",@"系统状态"],
                                 @"清除所有对话记录"
                                ];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - KTabBarHeight - KNavigationBarHeight - kStatusBarHeight);
    self.tableView = [[UITableView alloc] initWithFrame:rect style: UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    
}

- (void)viewDidAppear:(BOOL)animated{

}

-(void)viewDidDisappear:(BOOL)animated{

}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return [self.cellTitleArray count];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   
    id array = [self.cellTitleArray objectAtIndex:section];
    if ([array isKindOfClass:[NSString class]]) {
        return 1;
    }else if([array isKindOfClass:[NSArray class]]){
        return [(NSArray*)array count];
    }
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    UITableViewCell *cell = nil;
    NSLog(@"%d,%d",indexPath.section,indexPath.row);
    if (indexPath.section != kClearAllConversationSection) {
        if(indexPath.section == kNetStatusSection && indexPath.row == kNetStatusRow){
            cell  = [tableView dequeueReusableCellWithIdentifier:@"statuscell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"statuscell"];
            }
            [cell.detailTextLabel setTextColor:[UIColor greenColor]];
            [cell.detailTextLabel setText:@"状态"];
        }else{
            cell  = [tableView dequeueReusableCellWithIdentifier:@"simplecell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"simplecell"];
            }
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
        
    }else if(indexPath.section == kClearAllConversationSection){
        cell = [tableView dequeueReusableCellWithIdentifier:@"clearCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"clearcell"];
            [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
            [cell.textLabel setTextColor:[UIColor redColor]];
        }
    }
    
    id array = [self.cellTitleArray objectAtIndex:indexPath.section];
    if ([array isKindOfClass:[NSString class]]) {
        [cell.textLabel setText: array];
    }else if([array isKindOfClass:[NSArray class]]){
        [cell.textLabel setText: [array objectAtIndex:indexPath.row]];
    }
    return cell;
}


#pragma mark - UITableViewDelegate


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
