//
//  LoginViewController.m

//

#import "LoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Foundation/NSJSONSerialization.h>
#import "SettingViewController.h"
#import "CustomStatusViewController.h"
#import "MessageListViewController.h"
#import "ContactListTableViewController.h"
#import "IMService.h"
#import "UserPresent.h"
#import "TAHttpOperation.h"
#import "Config.h"
#import "Token.h"
#import "UserDB.h"
#import "AppDelegate.h"
#import "MainTabBarController.h"
#import "APIRequest.h"
#import "MBProgressHUD.h"

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
}


#pragma mark 即将旋转屏幕的时候自动调用
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration animations:^{
        CGFloat width = 0,height = 0;
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            width = 640;
            height  = 320;
        } else {
            width = 320;
            height = 640;
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
- (IBAction)onTap:(id)sender
{
    [self.mobile   resignFirstResponder];
    [self.pwd  resignFirstResponder];
}

#pragma mark- UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self animateTextField:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self animateTextField:NO];
}


- (void)animateTextField:(BOOL)up
{
    const int movementDistance = 50;
    const float movementDuration = 0.3f;
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    
    [UIView setAnimationBeginsFromCurrentState: YES];
    
    [UIView setAnimationDuration: movementDuration];
    
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    
    [UIView commitAnimations];
    
}

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
    [self.loginView.layer addAnimation:anim forKey:nil];
}

#pragma mark 登录
- (IBAction)login {
    
    if (self.mobile.text.length == 0) {
        [self alertError:@"请输入帐号"];
        return;
    }
    
    if (self.pwd.text.length == 0) {
        [self alertError:@"请输入密码"];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [APIRequest requestAuthToken:self.pwd.text zone:@"86" number:self.mobile.text deviceToken:delegate.deviceToken
                         success:^(int64_t uid, NSString* accessToken, NSString *refreshToken, int expireTimestamp, NSString *state){
                             Token *token = [Token instance];
                             token.accessToken = accessToken;
                             token.refreshToken = refreshToken;
                             token.expireTimestamp = expireTimestamp;
                             token.uid = uid;
                             [token save];
                             
                             [UserPresent instance].uid = uid;
                             [UserPresent instance].phoneNumber = [[PhoneNumber alloc] initWithPhoneNumber:self.mobile.text];
                             [UserPresent instance].state = state;
                             [[UserDB instance] addUser:[UserPresent instance]];
                             [hud hide:NO];
                             [self loginSuccess];
                             IMLog(@"auth token success");
                         }
                            fail:^{
                                IMLog(@"auth token fail");
                                [hud hide:NO];
                                [self alertError:@"验证码错误，请重新输入"];
                            }];
}

- (IBAction)onVerifyCode:(id)sender {
    NSString *number = _mobile.text;
    if (number.length != 11) return;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [APIRequest requestVerifyCode:@"86" number:number success:^(NSString *code){
        self.pwd.text = code;
        IMLog(@"code:%@", code);
        [hud hide:YES];
    } fail:^{
        IMLog(@"获取验证码失败");
        [hud hide:NO];
        [self alertError:@"获取验证码失败"];
    }];
}

#pragma mark 登录成功
- (void)loginSuccess
{
    [[Token instance] startRefreshTimer];
    [[IMService instance] start:[UserPresent instance].uid];
    
    UITabBarController *tabController = [[MainTabBarController alloc] init];
    UINavigationController *navCtl = [[UINavigationController alloc] initWithRootViewController:tabController];
    navCtl.navigationBarHidden = YES;
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    delegate.tabBarController = tabController;
    delegate.window.rootViewController = navCtl;
}

@end