//
//  MessageGroupConversationCell.m
//  Message
//
//  Created by daozhu on 14-7-6.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "MessageGroupConversationCell.h"

@implementation MessageGroupConversationCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];

    // Initialization code
    CALayer *imageLayer = [self.gHeadView layer];   //获取ImageView的层
    
    [imageLayer setMasksToBounds:YES];
    
    [imageLayer setCornerRadius:self.gHeadView.frame.size.width/2];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
