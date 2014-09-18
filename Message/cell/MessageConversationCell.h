//
//  MessageConversationCell.h
//  Message
//
//  Created by daozhu on 14-7-6.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@class MessageConversationCell;


@protocol TLSwipeForOptionsCellDelegate <NSObject>

- (void)cellDidSelectDelete:(MessageConversationCell *)cell;

- (void)cellDidSelectMore:(MessageConversationCell *)cell;

- (void)orignalCellDidSelected:(MessageConversationCell *)cell;

@end


@interface MessageConversationCell : UITableViewCell

@property (weak, nonatomic)     IBOutlet UIView* myContentView;
@property (weak, nonatomic)     IBOutlet UIImageView* headView;
@property (weak, nonatomic)     IBOutlet UILabel* namelabel;
@property (weak, nonatomic)     IBOutlet UILabel* messageContent;
@property (weak, nonatomic)     IBOutlet UILabel* timelabel;

@property (nonatomic, weak) id<TLSwipeForOptionsCellDelegate> delegate;


@end
