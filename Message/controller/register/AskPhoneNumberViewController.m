//
//  AskPhoneNumberViewController.m
//  Message
//
//  Created by 杨朋亮 on 14/9/14.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "AskPhoneNumberViewController.h"
#import "APIRequest.h"
#import "MBProgressHUD.h"
#import "CheckVerifyCodeController.h"



@interface AskPhoneNumberViewController ()

@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property  (nonatomic)               UIBarButtonItem *nextButton;


@end

@implementation AskPhoneNumberViewController

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
    
    [self setTitle:@"您的电话号码"];
    
    self.nextButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"下一步"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(nextAction)];
    [self.navigationItem setRightBarButtonItem:self.nextButton];
    [self.nextButton setEnabled:NO];
    
    [self.phoneTextField becomeFirstResponder];
    [self.phoneTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidAppear:(BOOL)animated{
    [self.phoneTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) textFieldDidChange:(id) sender {
    UITextField *_field = (UITextField *)sender;
    NSLog(@"%@",[_field text]);
    if ([_field text].length == 11) {
        [self.nextButton setEnabled:YES];
    }else{
        [self.nextButton setEnabled:NO];
    }
}

-(void) nextAction {
    
    NSLog(@"验证码");
    NSString *number = self.phoneTextField.text;
    if (number.length != 11) return;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [APIRequest requestVerifyCode:@"86" number:number success:^(NSString *code){
        IMLog(@"code:%@", code);
        [hud hide:YES];
        CheckVerifyCodeController * ctrl = [[CheckVerifyCodeController alloc] init];
        ctrl.phoneNumberStr = number;
        [self.navigationController pushViewController:ctrl animated: YES];
        
    } fail:^{
        IMLog(@"获取验证码失败");
        [hud hide:NO];
        [self alertError:@"获取验证码失败"];
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

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField{

    
}



@end
