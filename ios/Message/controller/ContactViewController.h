//
//  ContactViewController.h
//  Message
//
//  Created by daozhu on 14-6-16.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMContact.h"
#import <MessageUI/MessageUI.h>

@interface ContactViewController : UIViewController <UITableViewDataSource,UITableViewDelegate, UIActionSheetDelegate,MFMessageComposeViewControllerDelegate>

@property (nonatomic)IMContact *contact;
@property (nonatomic)UITableView *tableview;
@property (nonatomic)UIButton  *sendIMBtn;
@property (nonatomic)UIButton *inviteBtn;
@end
