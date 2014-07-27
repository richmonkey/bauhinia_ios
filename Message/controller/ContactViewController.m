//
//  ContactViewController.m
//  Message
//
//  Created by daozhu on 14-6-16.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "ContactViewController.h"
#import "MessageListViewController.h"
#import "AppDelegate.h"
#import "User.h"
#import "UserDB.h"
#import "IMessage.h"
#import "MessageViewController.h"
#import "ContactIMUserTableViewCell.h"
#import "ContactHeaderView.h"
#import "ContactPhoneTableViewCell.h"

/*
 ----------
 tableheaderView
 名字
 字母简写
 职务
 公司
 
 ----------
 cell
 头像 电话类型
    电话
 ------
 cell
     自定义状态                      最后上线时间
 
 ----------
 tablebottomview
 发送信息
 
 */



@interface ContactViewController ()



@end

@implementation ContactViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)loadView {
    CGRect rect = CGRectMake(0, 0, 320, 480);
    self.view = [[UIView alloc] initWithFrame:rect];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.tableview = [[UITableView alloc] initWithFrame:rect style: UITableViewStyleGrouped];
    self.tableview.dataSource = self;
    self.tableview.delegate = self;
    [self.view addSubview:self.tableview];
    
    ContactHeaderView *headerView = [[[NSBundle mainBundle]loadNibNamed:@"ContactHeaderView" owner:self options:nil] lastObject];
    [self.tableview setTableHeaderView: headerView];
    
    if (self.contact.contactName && [self.contact.contactName length]!= 0) {
        [headerView.nameLabel setText:self.contact.contactName];
    }else{
       [headerView.nameLabel setText:@" "];
    }
    
    if ([self getUserCount] > 0) {
  
        rect = CGRectMake(0, 0, self.view.frame.size.width, 50);
        self.sendIMBtn = [UIButton  buttonWithType:UIButtonTypeCustom];
        [self.sendIMBtn setFrame:rect];
        [self.sendIMBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [self.sendIMBtn setTitle:@"发送信息" forState:UIControlStateNormal];
        [self.sendIMBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        
        [self.sendIMBtn addTarget:self action:@selector(onSendMessage) forControlEvents:UIControlEventTouchUpInside];
        [self.tableview setTableFooterView: self.sendIMBtn];
    }
 }


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([self getUserCount] > 0) {
        return [self getUserCount];
    } else {
        return [self.contact.phoneDictionaries count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self getUserCount] > 0) {

        ContactIMUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactIMUserTableViewCell"];
        
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"ContactIMUserTableViewCell" owner:self options:nil] lastObject];
        }
        
        IMUser *u = [self.contact.users objectAtIndex:indexPath.row];
        [cell.phoneNumberLabel setText:u.phoneNumber.number];
        [cell.personnalStatusLabel setText:u.state];

        return cell;
    } else {
        ContactPhoneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactPhoneTableViewCell"];
        
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"ContactPhoneTableViewCell" owner:self options:nil] lastObject];
        }
        NSDictionary *phoneDic = [self.contact.phoneDictionaries objectAtIndex:indexPath.row];
        [cell.phoneNumLabel setText:[phoneDic objectForKey:@"value"]];
        [cell.phoneTypeLabel setText:[phoneDic objectForKey:@"label"]];
        
        return cell;
        
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 108;
}

-(NSInteger)getUserCount{
    return [self.contact.users count];
}

-(void)presentMessageViewController:(IMUser*)user {
    MessageViewController* msgController = [[MessageViewController alloc] initWithRemoteUser: user];
    [self.navigationController pushViewController:msgController animated:YES];
}


-(void)onSendMessage {
    if ([self.contact.users count] == 1) {
        NSLog(@"send message");
        User *u = [self.contact.users objectAtIndex:0];
        IMUser *mu = [[UserDB instance] loadUser:u.uid];
        MessageViewController* msgController = [[MessageViewController alloc] initWithRemoteUser:mu];
        [self.navigationController pushViewController:msgController animated:YES];
    } else if ([self.contact.users count] > 1) {
    
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
