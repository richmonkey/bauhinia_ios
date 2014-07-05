//
//  MessageListTableViewController.h
//  Message
//
//  Created by daozhu on 14-6-19.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageListTableViewController : UIViewController<UITableViewDelegate, UITableViewDataSource , UISearchBarDelegate >
{
  
	UITableView *_table;
	UISearchDisplayController *searchDC;
	UISearchBar *searchBar;
}

@property (strong ,nonatomic) NSMutableArray *conversations;

@end
