//
//  ContactsController.m
//

#import "ContactsController.h"
#import "MsgViewController.h"
#import "pinyin.h"


@implementation ContactsController

@synthesize _tableView;
@synthesize contacts;
@synthesize filteredArray;
@synthesize contactNameArray;
@synthesize contactNameDic;
@synthesize sectionArray;
@synthesize searchBar;
@synthesize searchDC;
@synthesize aBPersonNav;
//@synthesize aBNewPersonNav;

- (id)init{
  if (self = [super init]) {
    [self initData];
  }
  return self;
}

-(void)loadView{
  [super loadView];
  
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self._tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
	self._tableView.delegate = self;
	self._tableView.dataSource = self;
	self._tableView.scrollEnabled = YES;
	self._tableView.showsVerticalScrollIndicator = YES;
  self._tableView.separatorColor = [UIColor colorWithRed:208.0/255.0 green:208.0/255.0 blue:208.0/255.0 alpha:1.0];
  self._tableView.frame = CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height - 44);
	[self.view addSubview:self._tableView];
  
	
	self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
	self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.searchBar.keyboardType = UIKeyboardTypeDefault;
	self.searchBar.delegate = self;
	self._tableView.tableHeaderView = self.searchBar;
	
  self.searchDC = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self] ;
	self.searchDC.searchResultsDataSource = self;
	self.searchDC.searchResultsDelegate = self;
  
  
}


- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	[_tableView reloadData];
}


- (void)viewDidDisappear:(BOOL)animated{
	[super viewDidDisappear:animated];
}


-(void)initData{
  
  
	self.contacts = [[ContactDB instance] contactsArray];
  self.filteredArray =  [[NSMutableArray alloc] init];
	self.contactNameArray =  [[NSMutableArray alloc] init];
  self.sectionArray = [NSMutableArray array];
  
	NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
	self.contactNameDic = dic;
  
	if([contacts count] < 1)
	{
		[contactNameArray removeAllObjects];
		[contactNameDic removeAllObjects];
		for (int i = 0; i < 27; i++){
      [self.sectionArray replaceObjectAtIndex:i withObject:[NSMutableArray array]];
    }
		return;
	}
  
	[contactNameArray removeAllObjects];
	[contactNameDic removeAllObjects];
  
	for(ABContact *contact in contacts){
		
    NSString *phone;
		if([contact.phoneArray count] > 0){
			phone = [contact.phoneArray objectAtIndex:0];
		}
    
		if([contact.contactName length] > 0){
			[contactNameArray addObject:contact.contactName];
		}else{
			[contactNameArray addObject:phone];
    }
	}
  
	
	for (int i = 0; i < 27; i++) {
    [self.sectionArray addObject:[NSMutableArray array]];
  }
	for (NSString *string in contactNameArray)
	{
		if([ContactDB searchResult:string searchText:@"曾"]){
			sectionName = @"Z";
		}else if([ContactDB searchResult:string searchText:@"解"]){
			sectionName = @"X";
    }else if([ContactDB searchResult:string searchText:@"仇"]){
			sectionName = @"Q";
    }else if([ContactDB searchResult:string searchText:@"朴"]){
			sectionName = @"P";
    }else if([ContactDB searchResult:string searchText:@"查"]){
			sectionName = @"Z";
    }else if([ContactDB searchResult:string searchText:@"能"]){
			sectionName = @"N";
    }else if([ContactDB searchResult:string searchText:@"乐"]){
			sectionName = @"Y";
    }else if([ContactDB searchResult:string searchText:@"单"]){
			sectionName = @"S";
    }else{
      sectionName = [[NSString stringWithFormat:@"%c",pinyinFirstLetter([string characterAtIndex:0])] uppercaseString];
    }
		[self.contactNameDic setObject:string forKey:sectionName];
		NSUInteger firstLetter = [ALPHA rangeOfString:[sectionName substringToIndex:1]].location;
		if (firstLetter != NSNotFound){
      [[self.sectionArray objectAtIndex:firstLetter] addObject:string];
    }
	}
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
  if(aTableView == self._tableView){
    return 27;
  }else{
    return 1;
  }
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)aTableView
{
  
	if (aTableView == self._tableView)
	{
		NSMutableArray *indices = [NSMutableArray arrayWithObject:UITableViewIndexSearch];
		for (int i = 0; i < 27; i++){
			if ([[self.sectionArray objectAtIndex:i] count]){
				[indices addObject:[[ALPHA substringFromIndex:i] substringToIndex:1]];
      }
    }
		//[indices addObject:@"\ue057"]; // <-- using emoji
		return indices;
	}
	else{
    // search table
    return nil;
  }
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	if (title == UITableViewIndexSearch)
	{
		[self._tableView scrollRectToVisible:self.searchBar.frame animated:NO];
		return -1;
	}
	return [ALPHA rangeOfString:title].location;
}



- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
	if (aTableView == self._tableView)
	{
		if ([[self.sectionArray objectAtIndex:section] count] == 0){
      return nil;
    }
		return [NSString stringWithFormat:@"%@", [[ALPHA substringFromIndex:section] substringToIndex:1]];
	}
	else{
    return nil;
  }
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
  // Normal table
	if (aTableView == self._tableView){
    return [[self.sectionArray objectAtIndex:section] count];
	}else{
		[filteredArray removeAllObjects];
  }
  
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
    
		if ([ContactDB searchResult:name searchText:self.searchBar.text])
			[filteredArray addObject:string];
		else
		{
			if ([ContactDB searchResult:string searchText:self.searchBar.text])
				[filteredArray addObject:string];
			else {
				ABContact *contact = [ContactDB byNameToGetContact:string];
				NSArray *phoneArray = [ContactDB getPhoneNumberAndPhoneLabelArray:contact];
				NSString *phone = @"";
        
				if([phoneArray count] == 1)
				{
					NSDictionary *PhoneDic = [phoneArray objectAtIndex:0];
					phone = [ContactDB getPhoneNumberFromDic:PhoneDic];
					if([ContactDB searchResult:phone searchText:self.searchBar.text])
						[filteredArray addObject:string];
				}else  if([phoneArray count] > 1)
				{
					for(NSDictionary *dic in phoneArray)
					{
						phone = [ContactDB getPhoneNumberFromDic:dic];
						if([ContactDB searchResult:phone searchText:self.searchBar.text])
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


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	[self.searchBar setText:@""];
	self.searchBar.prompt = nil;
	[self.searchBar setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
	self._tableView.tableHeaderView = self.searchBar;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
  return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
  
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ContactCell"];
  }
  
	ABContact *contact = [self.contacts objectAtIndex:indexPath.row];
  [cell.textLabel setText:[contact.firstname stringByAppendingString:contact.lastname]];
  for (NSString *tel in contact.phoneArray) {
    [cell.detailTextLabel setText:tel];
  }
  
	return cell;
}


- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  /*
	[aTableView deselectRowAtIndexPath:indexPath animated:NO];
  [self.tabBarController setSelectedIndex:0];
  
  MsgViewController* msg = [[MsgViewController alloc] init];
  UINavigationController* navigation = [[UINavigationController alloc] initWithRootViewController:msg];
  navigation.view.backgroundColor = [UIColor grayColor];
  navigation.navigationBarHidden = NO;
  [self presentViewController:navigation animated:YES completion:nil];
  */
  
	ABPersonViewController *pvc = [[ABPersonViewController alloc] init] ;
  pvc.navigationItem.backBarButtonItem =[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelBtnAction:)] ;
  pvc.title = @"联系人详细";
	NSString *contactName = @"";
	if (aTableView == self._tableView){
		contactName = [[self.sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	}else{
		contactName = [self.filteredArray objectAtIndex:indexPath.row];
  }

	ABContact *contact = [ContactDB byNameToGetContact:contactName];
	pvc.displayedPerson = contact.record;
	pvc.allowsEditing = YES;
	pvc.personViewDelegate = self;
  
	self.aBPersonNav = [[UINavigationController alloc] initWithRootViewController:pvc];
  self.aBPersonNav.navigationBar.tintColor = SETCOLOR(redcolor,greencolor,bluecolor);
  self.aBPersonNav.view.backgroundColor = [UIColor grayColor];
	[self presentViewController: self.aBPersonNav animated:NO completion:nil];
}


// Override to support conditional editing of the table view.
//- (BOOL)tableView:(UITableView *)aTableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	if(aTableView == self._tableView)
//		// Return NO if you do not want the specified item to be editable.
//		return YES;
//	else
//		return NO;
//}


// Override to support editing the table view.
//- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//	NSString *contactName = @"";
//	if (aTableView == self._tableView)
//		contactName = [[self.sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//	else
//		contactName = [self.filteredArray objectAtIndex:indexPath.row];
//	ABContact *contact = [ContactDB byNameToGetContact:contactName];
//
//	if ([ModalAlert ask:@"真的要删除 %@?", contact.compositeName])
//	{
/*CATransition *animation = [CATransition animation];
 animation.delegate = self;
 animation.duration = 0.2;
 animation.timingFunction = UIViewAnimationCurveEaseInOut;
 animation.fillMode = kCAFillModeForwards;
 animation.removedOnCompletion = NO;
 animation.type = @"suckEffect";//110
 [_tableView.layer addAnimation:animation forKey:@"animation"];*/
//		[[self.sectionArray objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row];
//		[ContactDB removeSelfFromAddressBook:contact withErrow:nil];
//		[_tableView reloadData];
//	}
//	[_tableView  setEditing:NO];
//	editBtn.title = @"编辑";
//	isEdit = NO;
//}

/*
 -(void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag{
 [_tableView.layer removeAllAnimations];
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


//-(void)addContactItemBtn:(id)sender{
//	// create a new view controller
//	ABNewPersonViewController *npvc = [[ABNewPersonViewController alloc] init];
//	npvc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(addNewBackAction:)] ;
//	self.aBNewPersonNav = [[UINavigationController alloc] initWithRootViewController:npvc];
//	self.aBNewPersonNav.navigationBar.tintColor = SETCOLOR(redcolor,greencolor,bluecolor);
//	ABContact *contact = [ABContact contact];
//	npvc.displayedPerson = contact.record;
//	npvc.newPersonViewDelegate = self;
//	[self presentViewController:aBNewPersonNav animated:YES completion:nil];
//}


//- (void)addNewBackAction:(id)sender
//{
//	[self dismissViewControllerAnimated:YES completion:nil];
//}


#pragma mark NEW PERSON DELEGATE METHODS
//- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person
//{
//	if (person)
//	{
//		ABContact *contact = [ABContact contactWithRecord:person];
//self.title = [NSString stringWithFormat:@"Added %@", contact.compositeName];
//		if (![ABContactsHelper addContact:contact withError:nil])
//		{
//			// may already exist so remove and add again to replace existing with new
//			[ContactDB removeSelfFromAddressBook:contact withErrow:nil];
//			[ABContactsHelper addContact:contact withError:nil];
//		}
//	}
//	else
//	{
//	}
//	[_tableView reloadData];
//	[self dismissViewControllerAnimated:YES completion:nil];
//}


//-(void)editContactItemBtn:(id)sender
//{
//	if(isEdit == NO)
//	{
//		[_tableView setEditing:YES];
//		editBtn.title = @"完成";
//	}else {
//		[_tableView  setEditing:NO];
//		editBtn.title = @"编辑";
//	}
//	isEdit = !isEdit;
//}


//-(void)groupBtnAction:(id)sender{
//
//}


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
