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
#import "IMessage.h"
#import "MessageViewController.h"

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
    // Do any additional setup after loading the view from its nib.
    CGRect rect = CGRectMake(10, 380, 100, 50);
    UIButton *button = [[UIButton alloc] initWithFrame:rect];
    [button setTitle:@"发送信息" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];

    [button addTarget:self action:@selector(onSendMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    rect = CGRectMake(10, 50, 150, 50);
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    if ([self.contact.users count] == 1) {
        IMUser *u = [self.contact.users objectAtIndex:0];
        [label setText:u.phoneNumber.number];
    }
    [self.view addSubview:label];
}


-(void)presentMessageViewController:(IMUser*)user {
    MessageViewController* msgController = [[MessageViewController alloc] initWithRemoteUser: user];
    [self.navigationController pushViewController:msgController animated:YES];
}
-(void)onSendMessage {
    if ([self.contact.users count] == 1) {
        NSLog(@"send message");
        IMUser *u = [self.contact.users objectAtIndex:0];
        [self presentMessageViewController: u];
    } else if ([self.contact.users count] > 1) {
        //选择用户
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
