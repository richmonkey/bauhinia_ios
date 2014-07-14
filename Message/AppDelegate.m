//
//  AppDelegate.m
//  Message
//
//  Created by daozhu on 14-6-16.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "AppDelegate.h"

#import "IMService.h"
#import "IMessage.h"
#import "MessageDB.h"
#import "LoginViewController.h"
#import "Token.h"
#import "UserPresent.h"
#import "Config.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  //配置im server地址
  [IMService instance].host = [Config instance].host;
  [IMService instance].port = [Config instance].port;
  
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  application.statusBarHidden = NO;
    
    
  Token *token = [Token instance];
  if (token.accessToken) {
      [token startRefreshTimer];
      [[IMService instance] start:[UserPresent instance].uid];
      ConversationViewController* conversationController = [[ConversationViewController alloc] init];
      conversationController.title = @"消息";
      
      conversationController.tabBarItem.title = @"消息";
      conversationController.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarIconChats"];
       conversationController.tabBarItem.image = [UIImage imageNamed:@"TabBarIconChatsOff"];
      
      UINavigationController *conversationNavigationController = [[UINavigationController alloc] initWithRootViewController:conversationController];
      
      ContactListTableViewController* contactViewController = [[ContactListTableViewController alloc] init];
      contactViewController.title = @"通讯录";
      
      contactViewController.tabBarItem.title = @"通讯录";
      contactViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarIconStatus"];
      contactViewController.tabBarItem.image = [UIImage imageNamed:@"TabBarIconStatusOff"];

      
      MessageListViewController* msgController = [[MessageListViewController alloc] init];
      msgController.title = @"对话";
      msgController.tabBarItem.title = @"对话";
      msgController.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarIconChats"];
      msgController.tabBarItem.image = [UIImage imageNamed:@"TabBarIconChatsOff"];

      
      UINavigationController *messageListNavigationController = [[UINavigationController alloc] initWithRootViewController:msgController];
      
      SettingViewController* settingController = [[SettingViewController alloc] init];
      settingController.title = @"设置";
      settingController.tabBarItem.title = @"设置";
      settingController.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarIconSettingsOn"];
      settingController.tabBarItem.image = [UIImage imageNamed:@"TabBarIconSettingsOff"];

      UITabBarController *tabController = [[UITabBarController alloc] init] ;
      tabController.viewControllers = [NSArray arrayWithObjects: conversationNavigationController,contactViewController,messageListNavigationController, settingController,nil];
      
      msgController.mainTabController = tabController;
      
      self.window.rootViewController = tabController;
  } else {
      self.viewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
      self.window.rootViewController = self.viewController;
  }
  self.window.backgroundColor = [UIColor whiteColor];
  [self.window makeKeyAndVisible];
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
