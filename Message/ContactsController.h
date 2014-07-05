//
//  ContactsController.h
//  Phone
//
//  Created by angel li on 10-9-13.
//  Copyright 2010 Lixf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABContact.h"
#import "ContactDB.h"

@interface ContactsController : UIViewController <UITableViewDelegate, UITableViewDataSource,
                                                    ABPersonViewControllerDelegate, UISearchBarDelegate> {
    UITableView *_tableView;
    UIBarButtonItem *editBtn;
    UIBarButtonItem *groupBtn;
	UISearchDisplayController *searchDC;
	UISearchBar *searchBar;
	UINavigationController *aBPersonNav;
	NSMutableArray *filteredArray;
	NSMutableArray *contactNameArray;
	NSMutableDictionary *contactNameDic;
	NSMutableArray *sectionArray;
	NSArray *contacts;
	NSString *sectionName;
	CGFloat redcolor, greencolor, bluecolor;
	BOOL isSearch, isEdit, isGroup;
}

@property (nonatomic) UITableView *_tableView;
@property (nonatomic) NSArray *contacts;
@property (nonatomic) NSMutableArray *filteredArray;
@property (nonatomic) NSMutableArray *contactNameArray;
@property (nonatomic) NSMutableDictionary *contactNameDic;
@property (nonatomic) NSMutableArray *sectionArray;
@property (nonatomic) UISearchDisplayController *searchDC;
@property (nonatomic) UISearchBar *searchBar;
@property (nonatomic) UINavigationController *aBPersonNav;

@end
