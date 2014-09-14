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




@interface CheckVerifyCodeController ()

@property (weak, nonatomic) IBOutlet UITextField *verifyCodeTextField;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property  (nonatomic)               UIBarButtonItem *nextButton;

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
    
    [self.verifyCodeTextField becomeFirstResponder];
    [self.verifyCodeTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
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
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
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
                                [self alertError:@"验证码错误，请重新输入"];
                            }];
}

#pragma mark 弹出错误提示
- (void)alertError:(NSString *)error
{
    // 1.弹框
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登录失败" message:error delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
    
    // 2.发抖
    //    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    //    anim.repeatCount = 1;
    //    anim.values = @[@-10, @10, @-10];
    //    [self.loginView.layer addAnimation:anim forKey:nil];
}

-(void) verifySuccess{
    ProfileViewController * ctrl = [[ProfileViewController alloc] init];
    ctrl.editorState = ProfileEditorLoginingType;
    [self.navigationController pushViewController:ctrl animated: YES];

}


#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    
}

@end
