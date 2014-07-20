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
#import "CreateNewConversationViewController.h"

@interface MessageListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate,TLSwipeForOptionsCellDelegate,UIActionSheetDelegate, MessageObserver>
{
  
	UITableView *_table;
	UISearchDisplayController *searchDC;
	UISearchBar *searchBar;
	NSMutableArray *filteredArray;
}

@property (strong , nonatomic) NSMutableArray *conversations;
@property (strong , nonatomic) UISearchDisplayController *searchDC;
@property (strong , nonatomic) UISearchBar *searchBar;
@property (strong , nonatomic) NSMutableArray *filteredArray;
@property (strong , nonatomic) UITableView *_table;

@property (nonatomic, weak) UITableViewCell *cellDisplayingMenuOptions;
@property (nonatomic, weak) UITableViewCell *mostRecentlySelectedMoreCell;

@end
