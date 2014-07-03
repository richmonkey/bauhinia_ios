//
//  ContactsController.h
//  Phone
//
//  Created by angel li on 10-9-13.
//  Copyright 2010 Lixf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABContactsHelper.h"
#import "ABContact.h"
@interface ContactsController : UIViewController <UITableViewDelegate, UITableViewDataSource,ABNewPersonViewControllerDelegate,
ABPersonViewControllerDelegate,UISearchBarDelegate>{
	 UINavigationBar *NavBar;
	 UINavigationBar *ContactNavBar;
	 UITableView *DataTable;
	 UIBarButtonItem *editBtn;
	 UIBarButtonItem *groupBtn;
	UISearchDisplayController *searchDC;
	UISearchBar *searchBar;
	UINavigationController *aBPersonNav;
	UINavigationController *aBNewPersonNav;
	NSMutableArray *filteredArray;
	NSMutableArray *contactNameArray;
	NSMutableDictionary *contactNameDic;
	NSMutableArray *sectionArray;
	NSArray *contacts;
	NSString *sectionName;
	CGFloat redcolor, greencolor, bluecolor;
	BOOL isSearch, isEdit, isGroup;
}
@property (retain) UITableView *DataTable;
@property (retain) NSArray *contacts;
@property (retain) NSMutableArray *filteredArray;
@property (retain) NSMutableArray *contactNameArray;
@property (retain) NSMutableDictionary *contactNameDic;
@property (retain) NSMutableArray *sectionArray;
@property (retain) UISearchDisplayController *searchDC;
@property (retain) UISearchBar *searchBar;
@property (retain) UINavigationController *aBPersonNav;
@property (retain) UINavigationController *aBNewPersonNav;


//添加联系人
-(void)initData;
-(void)addContactItemBtn:(id)sender;
-(void)editContactItemBtn:(id)sender;
-(void)groupBtnAction:(id)sender;
@end
