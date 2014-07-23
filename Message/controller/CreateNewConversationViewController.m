//
//  CreateNewConversationViewController.m
//  Message
//
//  Created by daozhu on 14-7-13.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "CreateNewConversationViewController.h"
#import "pinyin.h"
#import "LevelDB.h"
#import "TAHttpOperation.h"
#import "Config.h"
#import "UserDB.h"
#import "Token.h"
#import "IMessage.h"
#import "MessageViewController.h"

@interface CreateNewConversationViewController ()
@property (nonatomic) NSArray *contacts;
@property (nonatomic) NSMutableArray *filteredArray;
@property (nonatomic) NSMutableArray *sectionArray;

@property (nonatomic) UITableView *tableView;
@property (nonatomic) UISearchDisplayController *searchDC;
@property (nonatomic) UISearchBar *searchBar;
@property (nonatomic) UINavigationController *aBPersonNav;
@end

@implementation CreateNewConversationViewController

- (id)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"选择联系人"];
    
    self.navigationItem.rightBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@"取消"
    
                                                                           style:UIBarButtonItemStyleBordered
                                                                          target:self
                                                                          action:@selector(cancelBtnAction:)] ;
    self.tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.scrollEnabled = YES;
	self.tableView.showsVerticalScrollIndicator = YES;
    self.tableView.separatorColor = [UIColor colorWithRed:208.0/255.0 green:208.0/255.0 blue:208.0/255.0 alpha:1.0];
    
    int top = [UIApplication sharedApplication].statusBarFrame.size.height;
    self.tableView.frame = CGRectMake(0, top, self.view.frame.size.width, self.view.frame.size.height - top);
	[self.view addSubview:self.tableView];
    
	
	self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
	self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.searchBar.keyboardType = UIKeyboardTypeDefault;
	self.searchBar.delegate = self;
	self.tableView.tableHeaderView = self.searchBar;
	
    self.searchDC = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self] ;
	self.searchDC.searchResultsDataSource = self;
	self.searchDC.searchResultsDelegate = self;
    

    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
	[super viewDidDisappear:animated];
}

-(NSString*)getSectionName:(NSString*)string {
    NSString *sectionName;
    if([self searchResult:string searchText:@"曾"]){
        sectionName = @"Z";
    }else if([self searchResult:string searchText:@"解"]){
        sectionName = @"X";
    }else if([self searchResult:string searchText:@"仇"]){
        sectionName = @"Q";
    }else if([self searchResult:string searchText:@"朴"]){
        sectionName = @"P";
    }else if([self searchResult:string searchText:@"查"]){
        sectionName = @"Z";
    }else if([self searchResult:string searchText:@"能"]){
        sectionName = @"N";
    }else if([self searchResult:string searchText:@"乐"]){
        sectionName = @"Y";
    }else if([self searchResult:string searchText:@"单"]){
        sectionName = @"S";
    }else{
        NSString *first = [NSString stringWithFormat:@"%c",pinyinFirstLetter([string characterAtIndex:0])];
        sectionName = [first uppercaseString];
    }
    return sectionName;
}

-(void)loadData{
    self.contacts = [[ContactDB instance] contactsArray];
    
    self.filteredArray =  [NSMutableArray array];
    self.sectionArray = [NSMutableArray arrayWithCapacity:27];
    
    for (int i = 0; i < 27; i++){
        [self.sectionArray addObject:[NSMutableArray array]];
    }
    
	if([self.contacts count] == 0) {
        return;
	}
    
	for (IMContact *contact in self.contacts) {
        NSString *string = contact.contactName;
        
        NSString *sectionName;
        if ([string length] > 0) {
            sectionName = [self getSectionName:string];
            NSUInteger firstLetter = [ALPHA rangeOfString:sectionName].location;
            if (firstLetter != NSNotFound){
                [[self.sectionArray objectAtIndex:firstLetter] addObject:contact];
            } else {
                firstLetter = [ALPHA rangeOfString:@"#"].location;
                [[self.sectionArray objectAtIndex:firstLetter] addObject:contact];
            }
        } else {
            NSUInteger firstLetter = [ALPHA rangeOfString:@"#"].location;
            [[self.sectionArray objectAtIndex:firstLetter] addObject:contact];
        }
	}
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    if (aTableView == self.tableView){
        return 27;
    } else {
        return 1;
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)aTableView {
	if (aTableView == self.tableView) {
		NSMutableArray *indices = [NSMutableArray arrayWithObject:UITableViewIndexSearch];
		for (int i = 0; i < 27; i++){
			if ([[self.sectionArray objectAtIndex:i] count]){
                NSRange range = NSMakeRange(i, 1);
				[indices addObject:[ALPHA substringWithRange:range]];
            }
        }
		return indices;
	} else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	if (title == UITableViewIndexSearch) {
		[self.tableView scrollRectToVisible:self.searchBar.frame animated:NO];
		return -1;
	}
	return [ALPHA rangeOfString:title].location;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
	if (aTableView == self.tableView) {
		if ([[self.sectionArray objectAtIndex:section] count] == 0) {
            return nil;
        }
        NSRange range = NSMakeRange(section, 1);
        return [ALPHA substringWithRange:range];
	} else {
        return nil;
    }
}

//获取每一个字符的拼音的首字符
-(NSString*)getPinYin:(NSString*)string {
    NSString *name = @"";
    for (int i = 0; i < [string length]; i++)
    {
        if([name length] < 1)
            name = [NSString stringWithFormat:@"%c",pinyinFirstLetter([string characterAtIndex:i])];
        else
            name = [NSString stringWithFormat:@"%@%c",name,pinyinFirstLetter([string characterAtIndex:i])];
    }
    return name;
}

-(BOOL)searchResult:(NSString *)contactName searchText:(NSString *)searchT{
	NSComparisonResult result = [contactName compare:searchT options:NSCaseInsensitiveSearch
                                               range:NSMakeRange(0, searchT.length)];
	if (result == NSOrderedSame)
		return YES;
	else
		return NO;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	if (aTableView == self.tableView){
        return [[self.sectionArray objectAtIndex:section] count];
	} else {
        return self.filteredArray.count;
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.filteredArray removeAllObjects];
    
    for(IMContact *contact in self.contacts) {
        NSString *string = contact.contactName;
        if (string.length == 0) {
            continue;
        }
        
        NSString *name = [self getPinYin:string];
        
        if ([self searchResult:name searchText:self.searchBar.text]) {
            [self.filteredArray addObject:contact];
        } else if ([self searchResult:string searchText:self.searchBar.text]) {
            [self.filteredArray addObject:contact];
        }
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)asearchBar {
	self.searchBar.prompt = @"输入字母、汉字或电话号码搜索";
    [self.searchDisplayController setActive:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[self.searchBar setText:@""];
	self.searchBar.prompt = nil;
	self.tableView.tableHeaderView = self.searchBar;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView == tableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ContactCell"];
        }
        
        NSArray *section = [self.sectionArray objectAtIndex:indexPath.section];
        IMContact *contact = [section objectAtIndex:indexPath.row];
        [cell.textLabel setText:contact.contactName];
        if ([contact.users count]) {
            if ([contact.users count] > 1) {
                [cell.detailTextLabel setText:@"多重自定义状态"];
            } else {
                User *u = [contact.users objectAtIndex:0];
                [cell.detailTextLabel setText:u.state];
            }
        }
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ContactCell"];
        }
        
        IMContact *contact = [self.filteredArray objectAtIndex:indexPath.row];
        [cell.textLabel setText:contact.contactName];
        return cell;
    }
}


- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"新建会话");
    IMContact *contact = [self.contacts objectAtIndex:indexPath.row];
    
    Conversation *newconversation = [[Conversation alloc] init];
    newconversation.cid = 13635273142;
    newconversation.name = contact.nickname;
    NSNotification* notification = [[NSNotification alloc] initWithName:CREATE_NEW_CONVERSATION object:newconversation userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:CREATE_NEW_CONVERSATION object: notification ];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}


#pragma mark - Action

- (void)cancelBtnAction:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark NEW PERSON DELEGATE METHODS
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
