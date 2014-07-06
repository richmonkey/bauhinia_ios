//
//  MessageGroupConversationCell.h
//  Message
//
//  Created by daozhu on 14-7-6.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageGroupConversationCell : UITableViewCell

@property (weak, nonatomic)     IBOutlet UIImageView* gHeadView;
@property (weak, nonatomic)     IBOutlet UILabel* titlelabel;
@property (weak, nonatomic)     IBOutlet UILabel* namelabel;
@property (weak, nonatomic)     IBOutlet UILabel* messageContent;
@property (weak, nonatomic)     IBOutlet UILabel* timelabel;

@end
