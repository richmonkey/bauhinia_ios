//
//  AboutViewController.m
//  Message
//
//  Created by 杨朋亮 on 14-9-13.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "AboutViewController.h"
#import "UIView+Toast.h"
#import "Config.h"

@interface AboutViewController ()

@property (weak, nonatomic) IBOutlet UIButton *contactUsBtn;
@property (weak,nonatomic) IBOutlet UIButton *recommendBtn;
@property (strong, nonatomic) NSArray *reciver;

-(IBAction) contactUs:(UIButton*)btn;

@end

@implementation AboutViewController

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
    [self setTitle:@"关于"];
    
    [self.contactUsBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.recommendBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    self.reciver = @[@"daibou007@163.com"];
    [mc setSubject:@"Message,建议,意见及商务合作!"];
    [mc setToRecipients:self.reciver];
    [mc setMessageBody:@"Message!!!\n\n!" isHTML:NO];
    [self presentViewController:mc animated:YES completion:nil];
}

-(IBAction) recommend:(UIButton*)btn{
    //检测设备是否支持SMS发送功能
    Class smsClass = (NSClassFromString(@"MFMessageComposeViewController"));
    if (smsClass != nil){
        // We must always check whether the current device is configured for sending emails
        if ([smsClass canSendText]){
            [self displaySMSComposeSheet];//调用发送邮件的方法
        }
    }
}

-(void) displaySMSComposeSheet{
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate = self;
    
    Config *config = [Config instance];
    picker.body = [NSString stringWithFormat:@"我正在使用“羊蹄甲”。 %@ 可以给您的联系人发送消息，分享图片和音频。", config.downloadURL];
    [self presentViewController:picker
                       animated:YES
                     completion:NULL];
}

#pragma mark - MFMessageComposeViewControllerDelegate

-(void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    
    switch (result){
        case MessageComposeResultCancelled:
            NSLog(@"Result: SMS sending canceled");
            break;
        case MessageComposeResultSent:
            NSLog(@"Result: SMS sent");
             [self.view makeToast:@"推荐发送成功!"];
            break;
        case MessageComposeResultFailed:
            NSLog(@"Result: SMS sending failed");
            [self.view makeToast:@"推荐发送失败!"];
            break;
        default:
            NSLog(@"Result: SMS not sent");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
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

@end
