//
//  MessageConversationCell.m
//  Message
//
//  Created by daozhu on 14-7-6.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "MessageConversationCell.h"

@implementation MessageConversationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [self setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
    
    CALayer *imageLayer = [self.headView layer];   //获取ImageView的层
    
    [imageLayer setMasksToBounds:YES];
    
    [imageLayer setCornerRadius:self.headView.frame.size.width/2];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
