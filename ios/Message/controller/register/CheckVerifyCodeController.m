//
//  CheckVerifyCodeController.m
//  Message
//
//  Created by 杨朋亮 on 14/9/14.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "CheckVerifyCodeController.h"
#import "APIRequest.h"
#import "MBProgressHUD.h"
#import "Profile.h"
#import "TAHttpOperation.h"
#import "Config.h"
#import "Token.h"
#import "AppDelegate.h"
#import "UserDB.h"

#import "ProfileViewController.h"

#import "UIView+Toast.h"
#import "UIApplication+Util.h"

#import <React/RCTEventDispatcher.h>
#import "RCCManager.h"

@interface CheckVerifyCodeController ()

@property (weak, nonatomic) IBOutlet   UITextField *verifyCodeTextField;
@property  (nonatomic)                 UIBarButtonItem *nextButton;
@property (weak, nonatomic) IBOutlet   UIButton *l_timeButton;
@property (strong, nonatomic)          NSArray *reciver;

@end

@implementation CheckVerifyCodeController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"输入验证码"];
    
    self.nextButton = [[UIBarButtonItem alloc]
                       initWithTitle:@"验证"
                       style:UIBarButtonItemStylePlain
                       target:self
                       action:@selector(nextAction)];
    [self.navigationItem setRightBarButtonItem:self.nextButton];
    [self.nextButton setEnabled:NO];
    
    [self.navigationItem setHidesBackButton:YES];
    
    [self.verifyCodeTextField becomeFirstResponder];
    [self.verifyCodeTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.l_timeButton addTarget:self action:@selector(contactUs:) forControlEvents:UIControlEventTouchUpInside];
    [self.l_timeButton setHidden:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [self.verifyCodeTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) textFieldDidChange:(id) sender {
    UITextField *_field = (UITextField *)sender;
    if ([_field text].length == 6) {
        [self.nextButton setEnabled:YES];
    }else{
        [self.nextButton setEnabled:NO];
    }
}

-(void) nextAction {
    NSLog(@"验证码");
    
    UIWindow *foreWindow  = [[UIApplication sharedApplication] foregroundWindow];
    UIView *backView =[[UIView alloc] initWithFrame:foreWindow.frame];
    [backView setBackgroundColor:RGBACOLOR(134, 136, 137, 0.95f)];
    [foreWindow addSubview:backView];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:backView animated:YES];
    
    [APIRequest requestAuthToken:self.verifyCodeTextField.text zone:@"86" number:self.phoneNumberStr deviceToken:@""
                         success:^(NSDictionary *resp) {
                             
                             NSString *accessToken = [resp objectForKey:@"access_token"];
                             NSString *refreshToken = [resp objectForKey:@"refresh_token"];
                             int expireTimestamp = (int)time(NULL) + [[resp objectForKey:@"expires_in"] intValue];
                             int64_t uid = [[resp objectForKey:@"uid"] longLongValue];
                             NSString *state = [resp objectForKey:@"state"];
                             NSString *name = [resp objectForKey:@"name"];
                             NSString *avatar = [resp objectForKey:@"avatar"];
                             
                             
                             Token *token = [Token instance];
                             token.accessToken = accessToken;
                             token.refreshToken = refreshToken;
                             token.expireTimestamp = expireTimestamp;
                             token.uid = uid;
                             [token save];
                             
                             [Profile instance].uid = uid;
                             [Profile instance].phoneNumber = [[PhoneNumber alloc] initWithPhoneNumber:self.phoneNumberStr];
                             [Profile instance].state = state;
                             [Profile instance].name = name;
                             [Profile instance].avatarURL = avatar;
                             [[Profile instance] save];
                             [hud hide:NO];
                             [backView removeFromSuperview];
                             [self verifySuccess];
                             IMLog(@"auth token success");
                         }
                            fail:^{
                                IMLog(@"auth token fail");
                                [hud hide:NO];
                                [backView removeFromSuperview];
                                [self.view makeToast:@"验证码不正确!" duration:1.0f position:@"center"];
                                
                                [self performSelector:@selector(showContactButton) withObject:nil afterDelay:1.5f];
                                
                            }];
}


-(void) verifySuccess{
    RCTBridge *bridge = [[RCCManager sharedIntance] getBridge];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    NSDictionary *token = @{@"uid":@([Token instance].uid),
                            @"gobelieveToken":[Token instance].accessToken};
    NSDictionary *body = @{@"token":token};
    [bridge.eventDispatcher sendAppEventWithName:@"open_app_main" body:body];

}

-(void) showContactButton{
    [self.l_timeButton setHidden:NO];
}

-(void) contactUs:(UIButton*)btn{
    //检测设备是否支持邮件发送功能
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil)
    {
        // We must always check whether the current device is configured for sending emails
        if ([mailClass canSendMail])
        {
            [self displayComposerSheet];//调用发送邮件的方法
        }
    }
}

-(void) displayComposerSheet{
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    self.reciver = @[@"daibou007@163.com"];
    [mc setSubject:@"Message,获取短信验证码失败"];
    [mc setToRecipients:self.reciver];
    [mc setMessageBody:@"Message!!!\n\n!" isHTML:NO];
    [self presentViewController:mc animated:YES completion:nil];
    
}

#pragma - mark  MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail send canceled...");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved...");
            [self.view makeToast:@"邮件保存成功!"];
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent...");
            [self.view makeToast:@"发送成功!"];
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail send errored: %@...", [error localizedDescription]);
            [self.view makeToast:@"发送失败!"];
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    
}


@end
