//
//  LoginViewController.m
//  QQ空间-HD
//
//  Created by apple on 13-9-11.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "LoginViewController.h"
#import <QuartzCore/QuartzCore.h>
//#import "HomeViewController.h"
#import "SettingViewController.h"
#import "ConversationViewController.h"
#import "MessageListTableViewController.h"
#import "ContactsController.h"
#import "IMService.h"
#import "UserPresent.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // 设置背景颜色
  self.view.backgroundColor = [UIColor grayColor];
  
#if TARGET_IPHONE_SIMULATOR
  
  //Simulator
  self.mobile.text = @"13635273143";
  
#else
  // Device
  self.mobile.text = @"13635273142";
  
#endif
  
}


#pragma mark 即将旋转屏幕的时候自动调用
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  [UIView animateWithDuration:duration animations:^{
    CGFloat width = 0,height = 0;
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
      width = 640;
      height  = 320;
      //      self.loginView.center = CGPointMake(width/2, height/2);
    }else{
      width = 320;
      height = 640;
      //      self.loginView.center = self.view.center;
    }
    self.view.frame = CGRectMake(0, 0, width,height);
    self.loginView.center = CGPointMake(width/2, height/2);
    self.loginView.frame = CGRectMake(0, 0, 120, 120);
    
  }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
  return YES;
}

- (BOOL)shouldAutorotate {
  return YES;
}


//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//  return UIInterfaceOrientationPortrait;
//}

//- (NSUInteger)supportedInterfaceOrientations
//{
//  return UIInterfaceOrientationMaskPortrait;
//}


#pragma mark 弹出错误提示
- (void)alertError:(NSString *)error
{
  // 1.弹框
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登录失败" message:error delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
  [alert show];
  
  // 2.发抖
  CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
  anim.repeatCount = 1;
  anim.values = @[@-10, @10, @-10];
  [_loginView.layer addAnimation:anim forKey:nil];
}

#pragma mark 登录
- (IBAction)login {
  
  if (_mobile.text.length == 0) {
    [self alertError:@"请输入帐号"];
    return;
  }
  
  
  if (_pwd.text.length == 0) {
    [self alertError:@"请输入密码"];
    return;
  }
  
#if TARGET_IPHONE_SIMULATOR
  //Simulator
  [UserPresent instance].username = @"小张";
  [UserPresent instance].userid = [self.mobile.text intValue];
#else
  // Device
  [UserPresent instance].username = @"小王";
  [UserPresent instance].userid = [self.mobile.text intValue];
  
#endif

  // 3.登录成功
  // 3.1.开始动画
  [_indicator startAnimating];
  
  // 3.2.让整个登录界面停止跟用户交互
  self.view.userInteractionEnabled = NO;
  
  // 3.3.通过定时器跳到主界面
  [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(loginSuccess) userInfo:nil repeats:NO];
}

#pragma mark 登录成功
- (void)loginSuccess
{
  // 1.停止动画
  [_indicator stopAnimating];
  
  // 2.让登录界面可以跟用户交互
  self.view.userInteractionEnabled = YES;
  
  // 3.跳到主界面
  //[self performSegueWithIdentifier:@"home" sender:nil];
  
  //    HomeViewController *homeviewcontroller = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
  //    [self presentViewController:homeviewcontroller animated:NO completion:nil];
  
  
  MessageListTableViewController* msgController = [[MessageListTableViewController alloc] init];
  msgController.title = @"消息";
  
  
  ContactsController* contactViewController = [[ContactsController alloc] init];
  contactViewController.title = @"通讯录";
  
  ConversationViewController* conversationController = [[ConversationViewController alloc] init];
  conversationController.title = @"对话";
  
  SettingViewController* settingController = [[SettingViewController alloc] init];
  settingController.title = @"设置";
  
  UITabBarController *tabController = [[UITabBarController alloc] init] ;
  tabController.viewControllers = [NSArray arrayWithObjects:msgController, contactViewController,settingController,conversationController, nil];
  
  UITabBarItem *tabBarItem1 = [self.tabBarController.tabBar.items objectAtIndex:0];
  UITabBarItem *tabBarItem2 = [self.tabBarController.tabBar.items objectAtIndex:1];
  UITabBarItem *tabBarItem3 = [self.tabBarController.tabBar.items objectAtIndex:2];
  UITabBarItem *tabBarItem4 = [self.tabBarController.tabBar.items objectAtIndex:3];
  
  [tabBarItem1 setImage:[UIImage imageNamed:@"message.png"]];
  [tabBarItem2 setImage:[UIImage imageNamed:@"contact.png"]];
  [tabBarItem3 setImage:[UIImage imageNamed:@"setting.png"]];
  [tabBarItem4 setImage:[UIImage imageNamed:@"conversation.png"]];
  
  
  [[[UIApplication sharedApplication] delegate] window].rootViewController = tabController;
  
  
  
  
}

#pragma mark 记住密码
- (IBAction)rmbPwd:(UIButton *)sender {
  // 1.取反
  sender.selected = !sender.isSelected;
  
  // 2.取消选中自动登录
  if (!sender.isSelected) {
    _autoLogin.selected = NO;
  }
}
#pragma mark 自动登录
- (IBAction)autoLogin:(UIButton *)sender {
  // 1.取反
  sender.selected = !sender.isSelected;
  
  // 2.选中记住密码
  if (sender.isSelected) {
    _rmbPwd.selected = YES;
  }
}
@end