//
//  ContactsController.m
//  Phone
//
//  Created by angel li on 10-9-13.
//  Copyright 2010 Lixf. All rights reserved.
//

#import "ContactsController.h"
#import "ContactData.h"
#import "ModalAlert.h"

#import "pinyin.h"

#import "MsgViewController.h"


@implementation ContactsController

@synthesize DataTable;
@synthesize contacts;
@synthesize filteredArray;
@synthesize contactNameArray;
@synthesize contactNameDic;
@synthesize sectionArray;
@synthesize searchBar;
@synthesize searchDC;
@synthesize aBPersonNav;
@synthesize aBNewPersonNav;


- (void)viewDidLoad {
  [super viewDidLoad];
  
  if(addressBook == nil){
		addressBook = ABAddressBookCreate();
  }
  
	isGroup = NO;
	
  self.DataTable = [[UITableView alloc] initWithFrame:self.view.frame];
  [self.view addSubview: self.DataTable];
  
	// Create a search bar
	self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
	self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.searchBar.keyboardType = UIKeyboardTypeDefault;
	self.searchBar.delegate = self;
	self.DataTable.tableHeaderView = self.searchBar;
	
	// Create the search display controller
	self.searchDC = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self] ;
	self.searchDC.searchResultsDataSource = self;
	self.searchDC.searchResultsDelegate = self;
	
	
	NSMutableArray *filterearray =  [[NSMutableArray alloc] init];
	self.filteredArray = filterearray;
  
	
	NSMutableArray *namearray =  [[NSMutableArray alloc] init];
	self.contactNameArray = namearray;
  
	
	NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
	self.contactNameDic = dic;
  
}


- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	[DataTable reloadData];
}


- (void)viewDidDisappear:(BOOL)animated{
	[super viewDidDisappear:animated];
  
  if(addressBook){
		CFRelease(addressBook);
  }
  
}


-(void)initData{
  
	self.contacts = [ContactData contactsArray];
	if([contacts count] <1)
	{
		[contactNameArray removeAllObjects];
		[contactNameDic removeAllObjects];
		for (int i = 0; i < 27; i++) [self.sectionArray replaceObjectAtIndex:i withObject:[NSMutableArray array]];
		return;
	}
	[contactNameArray removeAllObjects];
	[contactNameDic removeAllObjects];
	for(ABContact *contact in contacts)
	{
		NSString *phone;
		NSArray *phoneCount = [ContactData getPhoneNumberAndPhoneLabelArray:contact];
		if([phoneCount count] > 0)
		{
			NSDictionary *PhoneDic = [phoneCount objectAtIndex:0];
			phone = [ContactData getPhoneNumberFromDic:PhoneDic];
		}
		if([contact.contactName length] > 0)
			[contactNameArray addObject:contact.contactName];
		else
			[contactNameArray addObject:phone];
	}
	
	self.sectionArray = [NSMutableArray array];
	for (int i = 0; i < 27; i++) [self.sectionArray addObject:[NSMutableArray array]];
	for (NSString *string in contactNameArray)
	{
		if([ContactData searchResult:string searchText:@"曾"])
			sectionName = @"Z";
		else if([ContactData searchResult:string searchText:@"解"])
			sectionName = @"X";
		else if([ContactData searchResult:string searchText:@"仇"])
			sectionName = @"Q";
		else if([ContactData searchResult:string searchText:@"朴"])
			sectionName = @"P";
		else if([ContactData searchResult:string searchText:@"查"])
			sectionName = @"Z";
		else if([ContactData searchResult:string searchText:@"能"])
			sectionName = @"N";
		else if([ContactData searchResult:string searchText:@"乐"])
			sectionName = @"Y";
		else if([ContactData searchResult:string searchText:@"单"])
			sectionName = @"S";
		else
			sectionName = [[NSString stringWithFormat:@"%c",pinyinFirstLetter([string characterAtIndex:0])] uppercaseString];
		[self.contactNameDic setObject:string forKey:sectionName];
		NSUInteger firstLetter = [ALPHA rangeOfString:[sectionName substringToIndex:1]].location;
		if (firstLetter != NSNotFound) [[self.sectionArray objectAtIndex:firstLetter] addObject:string];
	}
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
	if(aTableView == self.DataTable) return 27;
	return 1;
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)aTableView
{
	if (aTableView == self.DataTable)  // regular table
	{
		NSMutableArray *indices = [NSMutableArray arrayWithObject:UITableViewIndexSearch];
		for (int i = 0; i < 27; i++)
			if ([[self.sectionArray objectAtIndex:i] count])
				[indices addObject:[[ALPHA substringFromIndex:i] substringToIndex:1]];
		//[indices addObject:@"\ue057"]; // <-- using emoji
		return indices;
	}
	else return nil; // search table
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	if (title == UITableViewIndexSearch)
	{
		[self.DataTable scrollRectToVisible:self.searchBar.frame animated:NO];
		return -1;
	}
	return [ALPHA rangeOfString:title].location;
}



- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
	if (aTableView == self.DataTable)
	{
		if ([[self.sectionArray objectAtIndex:section] count] == 0) return nil;
		return [NSString stringWithFormat:@"%@", [[ALPHA substringFromIndex:section] substringToIndex:1]];
	}
	else return nil;
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
	[self initData];
	// Normal table
	if (aTableView == self.DataTable) return [[self.sectionArray objectAtIndex:section] count];
	else
		[filteredArray removeAllObjects];
	// Search table
	for(NSString *string in contactNameArray)
	{
		NSString *name = @"";
		for (int i = 0; i < [string length]; i++)
		{
			if([name length] < 1)
				name = [NSString stringWithFormat:@"%c",pinyinFirstLetter([string characterAtIndex:i])];
			else
				name = [NSString stringWithFormat:@"%@%c",name,pinyinFirstLetter([string characterAtIndex:i])];
		}
		if ([ContactData searchResult:name searchText:self.searchBar.text])
			[filteredArray addObject:string];
		else
		{
			if ([ContactData searchResult:string searchText:self.searchBar.text])
				[filteredArray addObject:string];
			else {
				ABContact *contact = [ContactData byNameToGetContact:string];
				NSArray *phoneArray = [ContactData getPhoneNumberAndPhoneLabelArray:contact];
				NSString *phone = @"";
				
				if([phoneArray count] == 1)
				{
					NSDictionary *PhoneDic = [phoneArray objectAtIndex:0];
					phone = [ContactData getPhoneNumberFromDic:PhoneDic];
					if([ContactData searchResult:phone searchText:self.searchBar.text])
						[filteredArray addObject:string];
				}else  if([phoneArray count] > 1)
				{
					for(NSDictionary *dic in phoneArray)
					{
						phone = [ContactData getPhoneNumberFromDic:dic];
						if([ContactData searchResult:phone searchText:self.searchBar.text])
						{
							[filteredArray addObject:string];
							break;
						}
					}
				}
				
			}
		}
	}
	return self.filteredArray.count;
}



- (void)searchBarTextDidBeginEditing:(UISearchBar *)asearchBar{
	self.searchBar.prompt = @"输入字母、汉字或电话号码搜索";
}

// Via Jack Lucky
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	[self.searchBar setText:@""];
	self.searchBar.prompt = nil;
	[self.searchBar setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
	self.DataTable.tableHeaderView = self.searchBar;
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCellStyle style =  UITableViewCellStyleSubtitle;
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"ContactCell"];
	if (!cell) cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"ContactCell"] ;
	NSString *contactName;
	
	// Retrieve the crayon and its color
	if (aTableView == self.DataTable)
		contactName = [[self.sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	else
		contactName = [self.filteredArray objectAtIndex:indexPath.row];
	cell.textLabel.text = [NSString stringWithCString:[contactName UTF8String] encoding:NSUTF8StringEncoding];
	
	ABContact *contact = [ContactData byNameToGetContact:contactName];
	if(contact)
	{
		NSArray *phoneArray = [ContactData getPhoneNumberAndPhoneLabelArray:contact];
		if([phoneArray count] > 0)
		{
			NSDictionary *dic = [phoneArray objectAtIndex:0];
			NSString *phone = [ContactData getPhoneNumberFromDic:dic];
			cell.detailTextLabel.text = phone;
		}
	}
	else
		cell.detailTextLabel.text = @"";
	return cell;
}


- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[aTableView deselectRowAtIndexPath:indexPath animated:NO];
  [self.tabBarController setSelectedIndex:0];
  
  MsgViewController* msg = [[MsgViewController alloc] init];
  UINavigationController* navigation = [[UINavigationController alloc] initWithRootViewController:msg];
  navigation.view.backgroundColor = [UIColor grayColor];
  navigation.navigationBarHidden = NO;
  [self presentViewController:navigation animated:YES completion:nil];
  
  
//	ABPersonViewController *pvc = [[ABPersonViewController alloc] init] ;
//  pvc.navigationItem.backBarButtonItem =[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelBtnAction:)] ;
//  pvc.title = @"联系人详细";
//	NSString *contactName = @"";
//	if (aTableView == self.DataTable){
//		contactName = [[self.sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//	}else{
//		contactName = [self.filteredArray objectAtIndex:indexPath.row];
//  }
//	
//	ABContact *contact = [ContactData byNameToGetContact:contactName];
//	pvc.displayedPerson = contact.record;
//	pvc.allowsEditing = YES;
//	pvc.personViewDelegate = self;
//	self.aBPersonNav = [[UINavigationController alloc] initWithRootViewController:pvc];
//  self.aBPersonNav.navigationBar.tintColor = SETCOLOR(redcolor,greencolor,bluecolor);
//  self.aBPersonNav.view.backgroundColor = [UIColor grayColor];
//	[self presentViewController: self.aBPersonNav animated:NO completion:nil];
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)aTableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(aTableView == self.DataTable)
		// Return NO if you do not want the specified item to be editable.
		return YES;
	else
		return NO;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *contactName = @"";
	if (aTableView == self.DataTable)
		contactName = [[self.sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	else
		contactName = [self.filteredArray objectAtIndex:indexPath.row];
	ABContact *contact = [ContactData byNameToGetContact:contactName];
	
	if ([ModalAlert ask:@"真的要删除 %@?", contact.compositeName])
	{
		/*CATransition *animation = [CATransition animation];
     animation.delegate = self;
     animation.duration = 0.2;
     animation.timingFunction = UIViewAnimationCurveEaseInOut;
     animation.fillMode = kCAFillModeForwards;
     animation.removedOnCompletion = NO;
     animation.type = @"suckEffect";//110
     [DataTable.layer addAnimation:animation forKey:@"animation"];*/
		[[self.sectionArray objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row];
		[ContactData removeSelfFromAddressBook:contact withErrow:nil];
		[DataTable reloadData];
	}
	[DataTable  setEditing:NO];
	editBtn.title = @"编辑";
	isEdit = NO;
}

/*
 -(void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag{
 [DataTable.layer removeAllAnimations];
 [super.view.layer removeAllAnimations];
 }
 */

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
	[self dismissViewControllerAnimated:YES completion:nil];
	return NO;
}

#pragma mark - Action

- (void)cancelBtnAction:(id)sender{
	[self dismissViewControllerAnimated:YES completion:nil];
}


-(void)addContactItemBtn:(id)sender{
	// create a new view controller
	ABNewPersonViewController *npvc = [[ABNewPersonViewController alloc] init];
	npvc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(addNewBackAction:)] ;
	self.aBNewPersonNav = [[UINavigationController alloc] initWithRootViewController:npvc];
	self.aBNewPersonNav.navigationBar.tintColor = SETCOLOR(redcolor,greencolor,bluecolor);
	ABContact *contact = [ABContact contact];
	npvc.displayedPerson = contact.record;
	npvc.newPersonViewDelegate = self;
	[self presentViewController:aBNewPersonNav animated:YES completion:nil];
}


- (void)addNewBackAction:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark NEW PERSON DELEGATE METHODS
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person
{
	if (person)
	{
		ABContact *contact = [ABContact contactWithRecord:person];
		//self.title = [NSString stringWithFormat:@"Added %@", contact.compositeName];
		if (![ABContactsHelper addContact:contact withError:nil])
		{
			// may already exist so remove and add again to replace existing with new
			[ContactData removeSelfFromAddressBook:contact withErrow:nil];
			[ABContactsHelper addContact:contact withError:nil];
		}
	}
	else
	{
	}
	[DataTable reloadData];
	[self dismissViewControllerAnimated:YES completion:nil];
}


-(void)editContactItemBtn:(id)sender
{
	if(isEdit == NO)
	{
		[DataTable setEditing:YES];
		editBtn.title = @"完成";
	}else {
		[DataTable  setEditing:NO];
		editBtn.title = @"编辑";
	}
	isEdit = !isEdit;
}


-(void)groupBtnAction:(id)sender{
	
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (void)dealloc {
  
}
@end
