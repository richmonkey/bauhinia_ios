//
//  MainTabBarController.m
//  Message
//
//  Created by houxh on 14-7-20.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "MainTabBarController.h"
#import "SettingViewController.h"
#import "ConversationViewController.h"
#import "MessageListViewController.h"
#import "ContactListTableViewController.h"

@interface MainTabBarController ()

@end

@implementation MainTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    ConversationViewController* conversationController = [[ConversationViewController alloc] init];
    conversationController.title = @"消息";
    
    conversationController.tabBarItem.title = @"消息";
    conversationController.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarIconChats"];
    conversationController.tabBarItem.image = [UIImage imageNamed:@"TabBarIconChatsOff"];
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:conversationController];
    
    ContactListTableViewController* contactViewController = [[ContactListTableViewController alloc] init];
    contactViewController.title = @"通讯录";
    
    contactViewController.tabBarItem.title = @"通讯录";
    contactViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarIconStatus"];
    contactViewController.tabBarItem.image = [UIImage imageNamed:@"TabBarIconStatusOff"];

    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:contactViewController];
    

    
    MessageListViewController* msgController = [[MessageListViewController alloc] init];
    msgController.title = @"对话";
    msgController.tabBarItem.title = @"对话";
    msgController.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarIconChats"];
    msgController.tabBarItem.image = [UIImage imageNamed:@"TabBarIconChatsOff"];
    
    UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:msgController];
    
    

    
    SettingViewController* settingController = [[SettingViewController alloc] init];
    settingController.title = @"设置";
    settingController.tabBarItem.title = @"设置";
    settingController.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarIconSettingsOn"];
    settingController.tabBarItem.image = [UIImage imageNamed:@"TabBarIconSettingsOff"];
    
    UINavigationController *nav4 = [[UINavigationController alloc] initWithRootViewController:settingController];
    
    
    self.viewControllers = [NSArray arrayWithObjects: nav1, nav2, nav3, nav4, nil];
    self.selectedIndex = 1;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
