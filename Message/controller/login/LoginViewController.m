//
//  LoginViewController.m

//

#import "LoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Foundation/NSJSONSerialization.h>
#import "SettingViewController.h"
#import "ConversationViewController.h"
#import "MessageListViewController.h"
#import "ContactListTableViewController.h"
#import "IMService.h"
#import "UserPresent.h"
#import "TAHttpOperation.h"
#import "Config.h"
#import "Token.h"
#import "UserDB.h"

@interface LoginViewController ()
@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    self.mobile.text = @"13635273143";
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

    
    // 3.登录成功
    // 3.1.开始动画
    [_indicator startAnimating];
    
    // 3.2.让整个登录界面停止跟用户交互
    self.view.userInteractionEnabled = NO;
    
    [self requestAuthToken:self.pwd.text zone:@"86" number:self.mobile.text];
}

- (IBAction)onVerifyCode:(id)sender {
    NSString *number = _mobile.text;
    if (number.length != 11) return;
    [self requestVerifyCode:@"86" number:number];
}


- (void)requestVerifyCode:(NSString*)zone number:(NSString*)number {
    TAHttpOperation *request = [TAHttpOperation httpOperationWithTimeoutInterval:60];
    request.targetURL = [[Config instance].URL stringByAppendingFormat:@"/verify_code?zone=%@&number=%@", zone, number];
    request.method = @"POST";
    request.successCB = ^(TAHttpOperation*commObj, NSURLResponse *response, NSData *data) {
        NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSString *code = [resp objectForKey:@"code"];
        IMLog(@"code:%@", code);
    };
    request.failCB = ^(TAHttpOperation*commObj, TAHttpOperationError error) {
        IMLog(@"获取验证码失败");
        [self alertError:@"获取验证码失败"];
    };
    IMLog(@"target URL:%@", request.targetURL);
    [[NSOperationQueue mainQueue] addOperation:request];
}

- (void)requestAuthToken:(NSString*)code zone:(NSString*)zone number:(NSString*)number {
    TAHttpOperation *request = [TAHttpOperation httpOperationWithTimeoutInterval:60];
    request.targetURL = [[Config instance].URL stringByAppendingString:@"/auth/token"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:code forKey:@"code"];
    [dict setObject:zone forKey:@"zone"];
    [dict setObject:number forKey:@"number"];
    NSDictionary *headers = [NSDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"];
    request.headers = headers;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    request.postBody = data;
    request.method = @"POST";
    request.successCB = ^(TAHttpOperation*commObj, NSURLResponse *response, NSData *data) {
        int statusCode = [(NSHTTPURLResponse*)response statusCode];
        if (statusCode != 200) {
            [self loginFail];
            return;
        }
        NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        Token *token = [Token instance];
        token.accessToken = [resp objectForKey:@"access_token"];
        token.refreshToken = [resp objectForKey:@"refresh_token"];
        token.expireTimestamp = time(NULL) + [[resp objectForKey:@"expires_in"] intValue];
        token.uid = [[resp objectForKey:@"user_id"] longLongValue];
        [token save];
        
        [UserPresent instance].uid = [[resp objectForKey:@"user_id"] longLongValue];
        [UserPresent instance].phoneNumber = [[PhoneNumber alloc] initWithPhoneNumber:self.mobile.text];
        [[UserDB instance] addUser:[UserPresent instance]];
        
        [self loginSuccess];
        IMLog(@"auth token success");
    };
    request.failCB = ^(TAHttpOperation*commObj, TAHttpOperationError error) {
        IMLog(@"auth token fail");
        [self loginFail];
    };
    [[NSOperationQueue mainQueue] addOperation:request];
}

-(void)loginFail {
    [self.indicator stopAnimating];
    self.view.userInteractionEnabled = YES;
    [self alertError:@"验证码错误，请重新输入"];
}

#pragma mark 登录成功
- (void)loginSuccess
{
    
    [[IMService instance] start:[UserPresent instance].uid];
    // 1.停止动画
    [self.indicator stopAnimating];
    
    // 2.让登录界面可以跟用户交互
    self.view.userInteractionEnabled = YES;
    
    ConversationViewController* conversationController = [[ConversationViewController alloc] init];
    conversationController.title = @"消息";
    
    UINavigationController *conversationNavigationController = [[UINavigationController alloc] initWithRootViewController:conversationController];
    
    ContactListTableViewController* contactViewController = [[ContactListTableViewController alloc] init];
    contactViewController.title = @"通讯录";
    
    
    
    MessageListViewController* msgController = [[MessageListViewController alloc] init];
    msgController.title = @"对话";
    
    UINavigationController *messageListNavigationController = [[UINavigationController alloc] initWithRootViewController:msgController];
    
    SettingViewController* settingController = [[SettingViewController alloc] init];
    settingController.title = @"设置";
    
    UITabBarController *tabController = [[UITabBarController alloc] init] ;
    tabController.viewControllers = [NSArray arrayWithObjects: conversationNavigationController,contactViewController,messageListNavigationController, settingController,nil];
    
    
    msgController.mainTabController = tabController;
    
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

@end