//
//  MessageListViewController
//  Message
//
//  Created by daozhu on 14-6-19.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MessageConversationCell.h"
#import <gobelieve/IMService.h>
#import "ContactDB.h"

@class Conversation;
@class RCTBridge;

@interface ConversationViewController : UIViewController<UITableViewDelegate,
                                                        UITableViewDataSource,
                                                        UIActionSheetDelegate,
                                                        TCPConnectionObserver,
                                                        PeerMessageObserver,
                                                        GroupMessageObserver,
                                                        ContactDBObserver,
                                                        UIAlertViewDelegate>

@property (strong , nonatomic) NSMutableArray *conversations;
@property (strong , nonatomic) UISearchController *searchDC;
@property (strong , nonatomic) NSMutableArray *filteredArray;
@property (strong , nonatomic) UITableView *tableview;
@property (strong,nonatomic) UILabel *emputyLabel;

- (instancetype)initWithComponent:(NSString *)component passProps:(NSDictionary *)passProps navigatorStyle:(NSDictionary*)navigatorStyle globalProps:(NSDictionary *)globalProps bridge:(RCTBridge *)bridge;
@end
