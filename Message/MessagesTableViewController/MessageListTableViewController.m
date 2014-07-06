//
//  MessageListTableViewController.m
//  Message
//
//  Created by daozhu on 14-6-19.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "MessageListTableViewController.h"
#import "MsgViewController.h"
#import "MessageDB.h"
#import "IMessage.h"
#import "MessageConversationCell.h"
#import "MessageGroupConversationCell.h"
#import "MessageConversationActionTableViewCell.h"


@interface MessageListTableViewController ()

@end

@implementation MessageListTableViewController

@synthesize _table;
@synthesize filteredArray;
@synthesize searchBar;
@synthesize searchDC;
@synthesize conversations;

-(id)init{
    self = [super init];
    if (self) {
        self.conversations = [[NSMutableArray alloc] init];
        ConversationIterator * iterator =  [[MessageDB instance] newConversationIterator];
        
        Conversation * conversation = [iterator next];
        while (conversation) {
            [self.conversations addObject:conversation];
            conversation = [iterator next];
        }
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"对话";
    
    UIBarButtonItem *editorButton = [[UIBarButtonItem alloc] initWithTitle:@"编辑"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(editorAction)];
    self.navigationItem.leftBarButtonItem = editorButton;
    
    UIBarButtonItem *newButton = [[UIBarButtonItem alloc] initWithTitle:@"新建"
                                                                     style:UIBarButtonItemStyleDone
                                                                    target:self
                                                                    action:@selector(newAction)];
    self.navigationItem.rightBarButtonItem = newButton;
    
    
    self._table = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
	self._table.delegate = self;
	self._table.dataSource = self;
	self._table.scrollEnabled = YES;
	self._table.showsVerticalScrollIndicator = NO;
	self._table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    self._table.separatorColor = [UIColor colorWithRed:208.0/255.0 green:208.0/255.0 blue:208.0/255.0 alpha:1.0];
    self._table.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	[self.view addSubview:self._table];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
	self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.searchBar.keyboardType = UIKeyboardTypeDefault;
	self.searchBar.delegate = self;
	self._table.tableHeaderView = self.searchBar;
	
    self.searchDC = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self] ;
	self.searchDC.searchResultsDataSource = self;
	self.searchDC.searchResultsDelegate = self;
    
    
    
    
    //    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
    //      self.edgesForExtendedLayout = UIRectEdgeNone;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self._table) {
        // Return the number of rows in the section.
        return [self.conversations count] + 1;
    }else{
//        for (Conversation *covn in self.conversations ) {
//            if (covn.) {
//                statements
//            }
//        }
        
        return 1;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 44;
    }else{
        return 70;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        MessageConversationActionTableViewCell *actionCell = [tableView dequeueReusableCellWithIdentifier:@"MessageConversationActionTableViewCell"];
        if (actionCell == nil) {
            NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"MessageConversationActionTableViewCell" owner:self options:nil];
            
            actionCell = [nib objectAtIndex:0];
            [actionCell.broadCastListBtn addTarget:self action:@selector(broadcastAction) forControlEvents:UIControlEventTouchUpInside];
            
            [actionCell.creatGroupBtn addTarget:self action:@selector(createGroupAction) forControlEvents:UIControlEventTouchUpInside];
        }
        
        return actionCell;
        
    }else{
        MessageConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageConversationCell"];
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"MessageConversationCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        Conversation * covn =   (Conversation*)[self.conversations objectAtIndex:(indexPath.row - 1)];
        cell.messageContent.text = covn.message.content.raw;
        [cell.headView setImage:[UIImage imageNamed:@"head1.png"]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
        [dateFormatter setDateFormat:@"yyyy-mm-dd"];
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970: covn.message.timestamp];
        NSLog(@"date:%@",[date description]);
        
        cell.timelabel.text = [date description];
        cell.namelabel.text = @"小张";
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MsgViewController* msg = [[MsgViewController alloc] init];
    UINavigationController* navigation = [[UINavigationController alloc] initWithRootViewController:msg];
    navigation.view.backgroundColor = [UIColor grayColor];
    navigation.navigationBarHidden = NO;
    [self presentViewController:navigation animated:YES completion:nil];
    
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)asearchBar{
	self.searchBar.prompt = @"搜索";
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	[self.searchBar setText:@""];
	self.searchBar.prompt = nil;
	[self.searchBar setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
	self._table.tableHeaderView = self.searchBar;
}

#pragma mark - Action

- (void) editorAction{
    NSLog(@"editorAction");
}

- (void) newAction{
    NSLog(@"newAction");
}

- (void) broadcastAction{
    NSLog(@"broadcastAction");
}

-(void) createGroupAction{
    NSLog(@"createGroupAction");
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
