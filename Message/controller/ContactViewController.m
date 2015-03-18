//
//  ContactViewController.m
//  Message
//
//  Created by daozhu on 14-6-16.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "ContactViewController.h"
#import "MessageListViewController.h"
#import "AppDelegate.h"
#import "User.h"
#import "UserDB.h"
#import <imkit/PeerMessageViewController.h>
#import "ContactIMUserTableViewCell.h"
#import "ContactHeaderView.h"
#import "ContactPhoneTableViewCell.h"

#import "UIImageView+Letters.h"
#import "UIImageView+WebCache.h"
#import "pinyin.h"
#import "UserPresent.h"
#import "UIView+Toast.h"
#import "Config.h"

/*
 ----------
 tableheaderView
 名字
 字母简写
 职务
 公司
 
 ----------
 cell
 头像 电话类型
    电话
 ------
 cell
     自定义状态                      最后上线时间
 
 ----------
 tablebottomview
 发送信息
 
 */



@interface ContactViewController ()

@property  (nonatomic,strong)    UIButton *shareButton;

@end

@implementation ContactViewController

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
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.tableview = [[UITableView alloc] initWithFrame:rect style: UITableViewStyleGrouped];
    self.tableview.dataSource = self;
    self.tableview.delegate = self;
    [self.view addSubview:self.tableview];
    
    ContactHeaderView *headerView = [[[NSBundle mainBundle]loadNibNamed:@"ContactHeaderView" owner:self options:nil] lastObject];
    
    
    [self.tableview setTableHeaderView: headerView];
    
    if (self.contact.contactName && [self.contact.contactName length]!= 0) {
        [headerView.nameLabel setText:self.contact.contactName];
    }else{
       [headerView.nameLabel setText:@" "];
    }
   
    [self handleHeadViewImage:headerView];
    
    if ([self getUserCount] > 0) {
  
        rect = CGRectMake(0, 0, self.view.frame.size.width, 50);
        self.sendIMBtn = [[UIButton  alloc] initWithFrame: rect];
        [self.sendIMBtn setBackgroundColor:RGBACOLOR(47, 174, 136, 0.9f)];
        [self.sendIMBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [self.sendIMBtn setTitle:@"发送信息" forState:UIControlStateNormal];
        [self.sendIMBtn setTitleColor:RGBACOLOR(239, 239, 239, 1.0f) forState:UIControlStateNormal];
        [self.sendIMBtn setTitleColor:RGBACOLOR(199, 199, 199, 1.0f) forState:UIControlStateHighlighted];
        
        [self.sendIMBtn addTarget:self action:@selector(onSendMessage) forControlEvents:UIControlEventTouchUpInside];
        [self.tableview setTableFooterView: self.sendIMBtn];
    }else{
        rect = CGRectMake(0, 0, self.view.frame.size.width, 50);
        self.shareButton = [[UIButton  alloc] initWithFrame: rect];
        [self.shareButton setBackgroundColor:RGBACOLOR(47, 174, 136, 0.9f)];
        [self.shareButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [self.shareButton setTitle:@"邀请好友" forState:UIControlStateNormal];
        [self.shareButton setTitleColor:RGBACOLOR(239, 239, 239, 1.0f) forState:UIControlStateNormal];
        [self.shareButton setTitleColor:RGBACOLOR(199, 199, 199, 1.0f) forState:UIControlStateHighlighted];
        
        [self.shareButton addTarget:self action:@selector(recommend:) forControlEvents:UIControlEventTouchUpInside];
        [self.tableview setTableFooterView: self.shareButton];
    }
    
 }

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([self getUserCount] > 0) {
        return [self getUserCount];
    } else {
        return [self.contact.phoneDictionaries count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self getUserCount] > 0) {

        ContactIMUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactIMUserTableViewCell"];
        
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"ContactIMUserTableViewCell" owner:self options:nil] lastObject];
        }
        
        IMUser *u = [self.contact.users objectAtIndex:indexPath.row];
        [cell.phoneNumberLabel setText:u.phoneNumber.number];
        if (u.state.length > 0) {
            [cell.personnalStatusLabel setText:u.state];
        }else{
            [cell.personnalStatusLabel setText:@"~没有状态~"];
        }
        return cell;
    } else {
        ContactPhoneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactPhoneTableViewCell"];
        
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"ContactPhoneTableViewCell" owner:self options:nil] lastObject];
        }
        NSDictionary *phoneDic = [self.contact.phoneDictionaries objectAtIndex:indexPath.row];
        [cell.phoneNumLabel setText:[phoneDic objectForKey:@"value"]];
        [cell.phoneTypeLabel setText:[phoneDic objectForKey:@"label"]];
        
        return cell;
        
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 108;
}

-(NSInteger)getUserCount{
    return [self.contact.users count];
}

-(void)presentMessageViewController:(IMUser*)user {
    PeerMessageViewController* msgController = [[PeerMessageViewController alloc] init];
    msgController.peerUID = user.uid;
    if ([user.contact.contactName length] == 0) {
        msgController.peerName = user.displayName;
    }else{
        msgController.peerName = user.contact.contactName;
        
    }
    msgController.currentUID = [UserPresent instance].uid;
    
    [self.navigationController pushViewController:msgController animated:YES];
}


-(void)onSendMessage {
    
    if ([self.contact.users count] == 1) {
        NSLog(@"send message");
        User *u = [self.contact.users objectAtIndex:0];
        IMUser *mu = [[UserDB instance] loadUser:u.uid];
        PeerMessageViewController* msgController = [[PeerMessageViewController alloc] init];
        msgController.peerUID = mu.uid;
        if ([mu.contact.contactName length] == 0) {
            msgController.peerName = mu.displayName;
        }else{
            msgController.peerName = mu.contact.contactName;
            
        }
        msgController.currentUID = [UserPresent instance].uid;
        
        [self.navigationController pushViewController:msgController animated:YES];
    } else if ([self.contact.users count] > 1) {
        if (self.contact.users.count == 2) {
            User *u0 = [self.contact.users objectAtIndex:0];
            User *u1 = [self.contact.users objectAtIndex:1];
            UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                          initWithTitle:nil
                                          delegate:self
                                          cancelButtonTitle:@"取消"
                                          destructiveButtonTitle:nil
                                          otherButtonTitles:u0.phoneNumber.number, u1.phoneNumber.number, nil];
            actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
            [actionSheet showInView:self.view];
        } else if (self.contact.users.count == 3) {
            User *u0 = [self.contact.users objectAtIndex:0];
            User *u1 = [self.contact.users objectAtIndex:1];
            User *u2 = [self.contact.users objectAtIndex:2];
            UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                          initWithTitle:nil
                                          delegate:self
                                          cancelButtonTitle:@"取消"
                                          destructiveButtonTitle:nil
                                          otherButtonTitles:u0.phoneNumber.number, u1.phoneNumber.number, u2.phoneNumber.number, nil];
            actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
            [actionSheet showInView:self.view];
        } else {
            User *u0 = [self.contact.users objectAtIndex:0];
            User *u1 = [self.contact.users objectAtIndex:1];
            User *u2 = [self.contact.users objectAtIndex:2];
            User *u3 = [self.contact.users objectAtIndex:3];
            UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                          initWithTitle:nil
                                          delegate:self
                                          cancelButtonTitle:@"取消"
                                          destructiveButtonTitle:nil
                                          otherButtonTitles:u0.phoneNumber.number, u1.phoneNumber.number, u2.phoneNumber.number, u3.phoneNumber.number, nil];
            actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
            [actionSheet showInView:self.view];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    NSAssert(buttonIndex < self.contact.users.count, @"");
        
    User *u = [self.contact.users objectAtIndex:buttonIndex];
    IMUser *mu = [[UserDB instance] loadUser:u.uid];
    PeerMessageViewController* msgController = [[PeerMessageViewController alloc] init];
    msgController.peerUID = mu.uid;
    if ([mu.contact.contactName length] == 0) {
        msgController.peerName = mu.displayName;
    }else{
        msgController.peerName = mu.contact.contactName;
        
    }
    msgController.currentUID = [UserPresent instance].uid;
    
    [self.navigationController pushViewController:msgController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) handleHeadViewImage:(ContactHeaderView *)headerView{
    if ([self.contact.users count] > 0) {
        for(IMUser* usr in self.contact.users) {
            if (usr.avatarURL.length > 0) {
               [headerView.headView sd_setImageWithURL:[[NSURL alloc] initWithString:usr.avatarURL] placeholderImage:[UIImage imageNamed:@"PersonalChat"]];
            }
        }
    }else{
        if (self.contact.contactName && [self.contact.contactName length]!= 0) {
            NSString *nameChars;
            if([self.contact.contactName length] >= 2){
                nameChars = [NSString stringWithFormat:@"%c %c",pinyinFirstLetter([self.contact.contactName characterAtIndex:0]),pinyinFirstLetter([self.contact.contactName characterAtIndex:1])];
            }else if([self.contact.contactName length] == 1){
                nameChars = [NSString stringWithFormat:@"%c",pinyinFirstLetter([self.contact.contactName characterAtIndex:0])];
            }
            [headerView.headView setImageWithString:nameChars];
        }
    }
}

-(void) recommend:(id)sender{
    
    //检测设备是否支持SMS发送功能
    Class smsClass = (NSClassFromString(@"MFMessageComposeViewController"));
    if (smsClass != nil){
        // We must always check whether the current device is configured for sending emails
        if ([smsClass canSendText]){
            [self displaySMSComposeSheet];
        }
    }
}

-(void) displaySMSComposeSheet{
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate = self;
    
    Config *config = [Config instance];
    picker.body = [NSString stringWithFormat:@"我正在使用“羊蹄甲”。 %@ 可以给我发送消息，分享图片和音频。", config.downloadURL];
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



@end
