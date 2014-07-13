//
//  MessageListTableViewController.m
//  Message
//
//  Created by daozhu on 14-6-19.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "MessageListViewController.h"
#import "MessageViewController.h"
#import "MessageDB.h"
#import "IMessage.h"

#import "MessageGroupConversationCell.h"
#import "MessageConversationActionTableViewCell.h"
#import "UserDB.h"
#import "CreateNewConversationViewController.h"

#define kPeerConversationCellHeight         50
#define kGroupConversationCellHeight        44
#define kConversationActionCellHeight       44

@interface MessageListViewController ()

@end

@implementation MessageListViewController

@synthesize _table;
@synthesize filteredArray;
@synthesize searchBar;
@synthesize searchDC;
@synthesize conversations;

-(id)init{
    self = [super init];
    if (self) {
        self.conversations = [[NSMutableArray alloc] init];
        UserDB *db = [UserDB instance];
        ConversationIterator * iterator =  [[MessageDB instance] newConversationIterator];
        
        Conversation * conversation = [iterator next];
        while (conversation) {
            IMUser *user = [db loadUser:conversation.cid];
            conversation.name = user.contact.contactName;
            [self.conversations addObject:conversation];
            conversation = [iterator next];
        }
        [[IMService instance] addMessageObserver:self];
        
        [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(newConversation:) name:CREATE_NEW_CONVERSATION object:nil];
    }
    return self;
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];

}


//- (void)viewDidAppear:(BOOL)animated{
//    
//    self.mainTabController.tabBar.hidden = NO;
//
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"对话";
    
    UIBarButtonItem *editorButton = [[UIBarButtonItem alloc] initWithTitle:@"编辑"
                                                                     style:UIBarButtonItemStyleDone
                                                                    target:self
                                                                    action:@selector(editorAction)];
    self.navigationItem.leftBarButtonItem = editorButton;
    
    UIBarButtonItem *newButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(newAction)];
    
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
     
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self._table) {
       
        return [self.conversations count] + 1;
    }else{
        return 1;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return kConversationActionCellHeight;
    }else{
        return kPeerConversationCellHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        MessageConversationActionTableViewCell *actionCell = [tableView dequeueReusableCellWithIdentifier:@"MessageConversationActionTableViewCell"];
        if (actionCell == nil) {
            actionCell = [[[NSBundle mainBundle]loadNibNamed:@"MessageConversationActionTableViewCell" owner:self options:nil] lastObject];
        }
        
        [actionCell.broadCastListBtn addTarget:self action:@selector(broadcastAction) forControlEvents:UIControlEventTouchUpInside];
        
        [actionCell.creatGroupBtn addTarget:self action:@selector(createGroupAction) forControlEvents:UIControlEventTouchUpInside];
        
        [actionCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return actionCell;
        
    }else{
        Conversation * covn =   (Conversation*)[self.conversations objectAtIndex:(indexPath.row - 1)];
        
        //if (covn.type == CONVERSATION_PEER) {
        //peer
        MessageConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageConversationCell"];
        
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"MessageConversationCell" owner:self options:nil] lastObject];
        }
        
        cell.messageContent.text = covn.message.content.raw;
        [cell.headView setImage:[UIImage imageNamed:@"head1.png"]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
        [dateFormatter setDateFormat:@"yyyy-mm-dd"];
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970: covn.message.timestamp];
        NSLog(@"date:%@",[date description]);
        
        cell.timelabel.text = [date description];
        cell.namelabel.text = covn.name;
        
        //            cell.rightUtilityButtons = [self createCellRightButtons];
        
        cell.delegate = self;
        
        return cell;
        /*  }
         
         else{
         //group
         MessageGroupConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageGroupConversationCell"];
         
         if (cell == nil) {
         cell = [[[NSBundle mainBundle]loadNibNamed:@"MessageGroupConversationCell" owner:self options:nil] lastObject];
         }
         cell.titlelabel.text = @"群组";
         cell.messageContent.text = covn.message.content.raw;
         [cell.gHeadView setImage:[UIImage imageNamed:@"head2.png"]];
         
         NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
         dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
         [dateFormatter setDateFormat:@"yyyy-mm-dd"];
         
         NSDate *date = [NSDate dateWithTimeIntervalSince1970: covn.message.timestamp];
         NSLog(@"date:%@",[date description]);
         
         cell.timelabel.text = [date description];
         cell.namelabel.text = @"您";
         return cell;
         
         }*/
        
        
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleNone;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	
}

-(void) newConversation:(NSNotification*) notification{

    Conversation *con = [notification object];
    MessageViewController* msgController = [[MessageViewController alloc] initWithConversation: con];
    [self setHidesBottomBarWhenPushed:YES];

    [self.navigationController pushViewController:msgController animated:NO];
}

#pragma mark - TLSwipeForOptionsCellDelegate Methods

-(void)orignalCellDidSelected:(MessageConversationCell *)cell{
    if (![cell selectionStyle] == UITableViewCellSelectionStyleNone) {
        NSIndexPath  *path = [self._table indexPathForCell:cell];
        Conversation *con = [self.conversations objectAtIndex:path.row - 1];
        
        MessageViewController* msgController = [[MessageViewController alloc] initWithConversation: con];

        [self setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:msgController animated:NO];
    }
    
}

-(void)cellDidSelectDelete:(MessageConversationCell *)cell {
    
    NSLog(@"删除！！！");
    
}

-(void)cellDidSelectMore:(MessageConversationCell *)cell {
    self.mostRecentlySelectedMoreCell = cell;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle: nil otherButtonTitles:@"联系资讯", @"发送对话记录", @"清除对话", nil];
    actionSheet.destructiveButtonIndex= 2 ;
    
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        
    }
    else if (buttonIndex == actionSheet.destructiveButtonIndex) {
        NSIndexPath *indexPath = [self._table indexPathForCell:self.mostRecentlySelectedMoreCell];
        
        
        [self._table deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
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

    CreateNewConversationViewController *newcontroller = [[CreateNewConversationViewController alloc] init];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController: newcontroller];
    [self presentViewController: navigationController animated:YES completion:nil ];
    
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

-(void)onPeerMessage:(IMessage*)msg {
    MessageContent *c = msg.content;
    if (c.type == MESSAGE_TEXT) {
        IMLog(@"message:%@", c.text);
    }
}

//服务器ack
-(void)onPeerMessageACK:(int)msgLocalID uid:(int64_t)uid {
    
}
//接受方ack
-(void)onPeerMessageRemoteACK:(int)msgLocalID uid:(int64_t)uid {
    
}

-(void)onGroupMessage:(IMessage*)msg {
    
}

-(void)onGroupMessageACK:(int)msgLocalID gid:(int64_t)gid {
    
}

//用户连线状态
-(void)onOnlineState:(int64_t)uid state:(BOOL)on {
    
}

//对方正在输入
-(void)onPeerInputing:(int64_t)uid {
    
}

//同IM服务器连接的状态变更通知
-(void)onConnectState:(int)state {
    
}
@end
