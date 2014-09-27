//
//  MessageListViewController
//  Message
//
//  Created by daozhu on 14-6-19.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MessageConversationCell.h"
#import "IMService.h"
#import "PublicFunc.h"
#import "ContactDB.h"

@class Conversation;

@interface MessageListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate,TLSwipeForOptionsCellDelegate,UIActionSheetDelegate, MessageObserver, ContactDBObserver>
{
  
	UITableView *tableview;
	UISearchDisplayController *searchDC;
	UISearchBar *searchBar;
	NSMutableArray *filteredArray;
}

@property (strong , nonatomic) NSMutableArray *conversations;
@property (strong , nonatomic) UISearchDisplayController *searchDC;
@property (strong , nonatomic) UISearchBar *searchBar;
@property (strong , nonatomic) NSMutableArray *filteredArray;
@property (strong , nonatomic) UITableView *tableview;
@property (strong,nonatomic) UILabel *emputyLabel;

@property (nonatomic, weak) UITableViewCell *cellDisplayingMenuOptions;
@property (nonatomic, weak) MessageConversationCell *mostRecentlySelectedMoreCell;

@end
