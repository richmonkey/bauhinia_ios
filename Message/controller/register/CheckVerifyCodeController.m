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
#import "IMService.h"
#import "UserPresent.h"
#import "TAHttpOperation.h"
#import "Config.h"
#import "Token.h"
#import "AppDelegate.h"
#import "UserDB.h"

#import "ProfileViewController.h"

#import "UIView+Toast.h"
#import "UIApplication+Util.h"




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
    [self startTime];
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
    NSLog(@"%@",[_field text]);
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
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [APIRequest requestAuthToken:self.verifyCodeTextField.text zone:@"86" number:self.phoneNumberStr deviceToken:delegate.deviceToken
                         success:^(int64_t uid, NSString* accessToken, NSString *refreshToken, int expireTimestamp, NSString *state){
                             Token *token = [Token instance];
                             token.accessToken = accessToken;
                             token.refreshToken = refreshToken;
                             token.expireTimestamp = expireTimestamp;
                             token.uid = uid;
                             [token save];
                             
                             [UserPresent instance].uid = uid;
                             [UserPresent instance].phoneNumber = [[PhoneNumber alloc] initWithPhoneNumber:self.phoneNumberStr];
                             [UserPresent instance].state = state;
                             [[UserDB instance] addUser:[UserPresent instance]];
                             [hud hide:NO];
                             [self verifySuccess];
                             IMLog(@"auth token success");
                         }
                            fail:^{
                                IMLog(@"auth token fail");
                                [hud hide:NO];
                                [self.view makeToast:@"验证码不正确!" duration:1.0f position:@"center"];
                            }];
}


-(void) verifySuccess{
    ProfileViewController * ctrl = [[ProfileViewController alloc] init];
    ctrl.editorState = ProfileEditorLoginingType;
    [self.navigationController pushViewController:ctrl animated: YES];

}

-(void)startTime{
    __block int timeout = 30; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout <= 0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [self.l_timeButton setTitle:@"获取验证码失败,联系我们" forState:UIControlStateNormal];
                self.l_timeButton.userInteractionEnabled = YES;
            });
        }else{
            int seconds = timeout % 60;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                NSLog(@"____%@",strTime);
                [self.l_timeButton setTitle:[NSString stringWithFormat:@"剩余(%@秒)",strTime] forState:UIControlStateNormal];
                self.l_timeButton.userInteractionEnabled = NO;
                
            });
            timeout--;
            
        }
    });
    dispatch_resume(_timer);
    
}

-(IBAction) contactUs:(UIButton*)btn{
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
    self.reciver = @[@"11@11.com"];
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
