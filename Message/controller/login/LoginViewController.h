//
//  LoginViewController.h
//  QQ空间-HD
//
//  Created by apple on 13-9-11.
//  Copyright (c) 2013年 itcast. All rights reserved.
//  登录界面

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *loginView;
- (IBAction)login;
@property (weak, nonatomic) IBOutlet UITextField *mobile;
@property (weak, nonatomic) IBOutlet UITextField *pwd;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@end
