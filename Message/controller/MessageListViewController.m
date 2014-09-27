//
//  MessageListTableViewController.m
//  Message
//
//  Created by daozhu on 14-6-19.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "MessageListViewController.h"
#import "MessageViewController.h"
#import "PeerMessageDB.h"
#import "IMessage.h"
#import "pinyin.h"
#import "MessageGroupConversationCell.h"
#import "UserDB.h"
#import "UIImageView+WebCache.h"
#import "UserPresent.h"
#import "JSBadgeView.h"

#define kPeerConversationCellHeight         60
#define kGroupConversationCellHeight        44

#define kActionSheetContact           0
#define kActionSheetSendHistory       1

@interface MessageListViewController ()

@end

@implementation MessageListViewController

@synthesize tableview;
@synthesize filteredArray;
@synthesize searchBar;
@synthesize searchDC;

-(id)init{
    self = [super init];
    if (self) {
        self.filteredArray =  [NSMutableArray array];
        self.conversations = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)viewDidLoad{
    
    [super viewDidLoad];

    self.title = @"对话";

    
    self.tableview = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
	self.tableview.delegate = self;
	self.tableview.dataSource = self;
	self.tableview.scrollEnabled = YES;
	self.tableview.showsVerticalScrollIndicator = NO;
	self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableview.separatorColor = [UIColor colorWithRed:208.0/255.0 green:208.0/255.0 blue:208.0/255.0 alpha:1.0];
    self.tableview.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	[self.view addSubview:self.tableview];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, kSearchBarHeight)];
	self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.searchBar.keyboardType = UIKeyboardTypeDefault;
	self.searchBar.delegate = self;
    [self.tableview setTableHeaderView:self.searchBar];
	
    self.searchDC = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self] ;
	self.searchDC.searchResultsDataSource = self;
	self.searchDC.searchResultsDelegate = self;

    [[ContactDB instance] addObserver:self];
    
    [[IMService instance] addMessageObserver:self];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(newMessage:) name:SEND_FIRST_MESSAGE_OK object:nil];
    
   [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(clearAllConversation:) name:CLEAR_ALL_CONVESATION object:nil];
    
   [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(clearSingleConvNewState:) name:CLEAR_SINGLE_CONV_NEW_MESSAGE_NOTIFY object:nil];
    
    UserDB *db = [UserDB instance];
    id<ConversationIterator> iterator =  [[PeerMessageDB instance] newConversationIterator];
    
    Conversation * conversation = [iterator next];
    while (conversation) {
        IMUser *user = [db loadUser:conversation.cid];
        conversation.name = [user displayName];
        conversation.avatarURL = user.avatarURL;
        [self.conversations addObject:conversation];
        conversation = [iterator next];
    }
    
    if ([[IMService instance] connectState] == STATE_CONNECTING) {
        [self showConectingState];
    }
    
    
    [self updateEmputyContentView];
    
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

-(void)onExternalChange {
    UserDB *db = [UserDB instance];
    for (Conversation *conv in self.conversations) {
        IMUser *user = [db loadUser:conv.cid];
        conv.name = user.contact.contactName;
    }
    [self.tableview reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.tableview) {
        
        return [self.conversations count];
    }else{
        return self.filteredArray.count;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kPeerConversationCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //peer
    MessageConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageConversationCell"];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"MessageConversationCell" owner:self options:nil] lastObject];
    }
    Conversation * covn = nil;
    if (tableView == self.tableview) {
        
         covn =   (Conversation*)[self.conversations objectAtIndex:(indexPath.row)];
    
    }else{
        
        covn =   (Conversation*)[self.filteredArray objectAtIndex:(indexPath.row)];
    }
    

    
    [cell.headView sd_setImageWithURL: [NSURL URLWithString:covn.avatarURL] placeholderImage:[UIImage imageNamed:@"PersonalChat"]];
    

    if (covn.message.content.type == MESSAGE_IMAGE) {
        cell.messageContent.text = @"一张图片";
    }else if(covn.message.content.type == MESSAGE_TEXT){
       cell.messageContent.text = covn.message.content.text;
    }else if(covn.message.content.type == MESSAGE_LOCATION){
        cell.messageContent.text = @"一个地理位置";
    }else if (covn.message.content.type == MESSAGE_AUDIO){
       cell.messageContent.text = @"一个音频";
    }
    
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: covn.message.timestamp];
    NSString *str = [PublicFunc getConversationTimeString:date ];
    cell.timelabel.text = str;
    cell.namelabel.text = covn.name; 
    
    cell.delegate = self;
   
    if (covn.newMsgCount > 0) {
        [cell showNewMessage:covn.newMsgCount];
    }
    
    return cell;
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.tableview) {
        return YES;
    }
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	
}

-(void) newMessage:(NSNotification*) notification{
    IMessage *m = notification.object;
    NSLog(@"new message:%lld, %lld", m.sender, m.receiver);
    [self onNewMessage:m cid:m.receiver];
}

-(void) clearAllConversation:(NSNotification*) notification{
    [self reloadTheConversation];
    [self updateEmputyContentView];
}

-(void) clearSingleConvNewState:(NSNotification*) notification{
    int64_t usrid = [(NSNumber*)notification.object longLongValue];
    for (int index = 0 ; index < [self.conversations count] ; index++) {
        Conversation *conv = [self.conversations objectAtIndex:index];
        if (conv.cid == usrid) {
            if (conv.newMsgCount > 0) {
                conv.newMsgCount = 0;
                 NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
                 MessageConversationCell *cell = (MessageConversationCell*)[self.tableview cellForRowAtIndexPath:path];
                [cell clearNewMessage];
                [self resetConversationsViewControllerNewState];
            }
        }

    }
    
}

#pragma mark - UISearchBarDelegate

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

-(BOOL)searchResult:(NSString *)conversationName searchText:(NSString *)searchT{
	NSComparisonResult result = [conversationName compare:searchT options:NSCaseInsensitiveSearch
                                               range:NSMakeRange(0, searchT.length)];
	if (result == NSOrderedSame)
		return YES;
	else
		return NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.filteredArray removeAllObjects];
    
    for(Conversation *conv in self.conversations) {
        NSString *string = conv.name;
        if (string.length == 0) {
            continue;
        }
        
        NSString *name = [self getPinYin:string];
        
        if ([self searchResult:name searchText:self.searchBar.text]) {
            [self.filteredArray addObject:conv];
        } else if ([self searchResult:string searchText:self.searchBar.text]) {
            [self.filteredArray addObject:conv];
        }
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)asearchBar {

    [self.searchDisplayController setActive:YES animated:YES];
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[self.searchBar setText:@""];
}


#pragma mark - TLSwipeForOptionsCellDelegate Methods

-(void)orignalCellDidSelected:(MessageConversationCell *)cell{
    if (![cell selectionStyle] == UITableViewCellSelectionStyleNone) {

        if ([self.searchDisplayController isActive]) {
            [self.searchBar resignFirstResponder];
        }
        
        NSIndexPath  *path = [self.tableview indexPathForCell:cell];
        Conversation *con = [self.conversations objectAtIndex:path.row];
        IMUser *rmtUser = [[UserDB instance] loadUser: con.cid];
        
        MessageViewController* msgController = [[MessageViewController alloc] initWithRemoteUser: rmtUser];
        
        msgController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:msgController animated: YES];
    }
    
}

-(void)cellDidSelectDelete:(MessageConversationCell *)cell {
    
    if ([self.searchDC isActive]) {
        NSIndexPath * findPath =  [self.searchDC.searchResultsTableView indexPathForCell:cell];
        Conversation *con = [self.filteredArray objectAtIndex:findPath.row];
        
        [[PeerMessageDB instance] clearConversation:con.cid];
        
        [self.filteredArray removeObject:con];
        [self.conversations removeObject:con];
        
        [self.tableview reloadData];
        [self.searchDC.searchResultsTableView reloadData];
        
        if([self.filteredArray count] == 0){
            [self.searchDC setActive:NO];
        }
        
    }else{
        NSIndexPath * findPath =  [self.tableview indexPathForCell:cell];
        Conversation *con = [self.conversations objectAtIndex:findPath.row];
        [[PeerMessageDB instance] clearConversation:con.cid];
        [self.conversations removeObject:con];
        [self.tableview reloadData];
        
        [self updateEmputyContentView];
    }
}

-(void)cellDidSelectMore:(MessageConversationCell *)cell {
    self.mostRecentlySelectedMoreCell = cell;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle: nil otherButtonTitles:@"联系资讯", @"清除对话", nil];
    actionSheet.destructiveButtonIndex= 2 ;
    
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        
    }
    else if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [self cellDidSelectDelete:self.mostRecentlySelectedMoreCell];
    }else if(buttonIndex == kActionSheetContact){
       //TODO
        if ([self.searchDC isActive]) {
            NSIndexPath * findPath =  [self.searchDC.searchResultsTableView indexPathForCell:self.mostRecentlySelectedMoreCell];
            Conversation *con = [self.filteredArray objectAtIndex:findPath.row];
            IMUser *rmtUser = [[UserDB instance] loadUser: con.cid];
            
            [self.searchDC setActive:NO];
            
        }else{
            NSIndexPath * findPath =  [self.tableview indexPathForCell:self.mostRecentlySelectedMoreCell];
            Conversation *con = [self.conversations objectAtIndex:findPath.row];
            [[PeerMessageDB instance] clearConversation:con.cid];
            [self.conversations removeObject:con];
            [self.tableview reloadData];
        }
    }
    
}

#pragma mark - Action




-(void)onNewMessage:(IMessage*)msg cid:(int64_t)cid{
    int index = -1;
    for (int i = 0; i < [self.conversations count]; i++) {
        Conversation *con = [self.conversations objectAtIndex:i];
        if (con.type == CONVERSATION_PEER && con.cid == cid) {
            con.message = msg;
            index = i;
            break;
        }
    }
    
    if (index != -1) {
        Conversation *con = [self.conversations objectAtIndex:index];
        con.message = msg;
        
        con.newMsgCount += 1;
        NSNotification* notification = [[NSNotification alloc] initWithName:ON_NEW_MESSAGE_NOTIFY object: nil userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        
        NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
    } else {
        Conversation *con = [[Conversation alloc] init];
        con.message = msg;
       
        if ([UserPresent instance].uid == msg.receiver) {
            con.newMsgCount += 1;
            NSNotification* notification = [[NSNotification alloc] initWithName:ON_NEW_MESSAGE_NOTIFY object: nil userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
        
        con.type = CONVERSATION_PEER;
        con.cid = cid;
        
        UserDB *db = [UserDB instance];
        IMUser *user = [db loadUser:con.cid];
        con.name = [user displayName];
        con.avatarURL = user.avatarURL;
        [self.conversations insertObject:con atIndex:0];
        NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
        NSArray *array = [NSArray arrayWithObject:path];
        [self.tableview insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationMiddle];
    }
    
     [self updateEmputyContentView];
    
}

-(void)onPeerMessage:(IMMessage*)im {
    
    IMessage *m = [[IMessage alloc] init];
    m.sender = im.sender;
    m.receiver = im.receiver;
    m.msgLocalID = im.msgLocalID;
    MessageContent *content = [[MessageContent alloc] init];
    content.raw = im.content;
    m.content = content;
    m.timestamp = time(NULL);
    
    MessageContent *c = m.content;
    if (c.type == MESSAGE_TEXT) {
        IMLog(@"message:%@", c.text);
    }
    [self onNewMessage:m cid:m.sender];
    
    
}

//服务器ack
-(void)onPeerMessageACK:(int)msgLocalID uid:(int64_t)uid {
    
}
//接受方ack
-(void)onPeerMessageRemoteACK:(int)msgLocalID uid:(int64_t)uid {
    
}

-(void)onPeerMessageFailure:(int)msgLocalID uid:(int64_t)uid {
    
}

-(void)onGroupMessage:(IMMessage*)msg {
    
}

-(void)onGroupMessageACK:(int)msgLocalID gid:(int64_t)gid {
    
}

-(void)onGroupMessageFailure:(int)msgLocalID gid:(int64_t)gid{
    
}

//用户连线状态
-(void)onOnlineState:(int64_t)uid state:(BOOL)on {
    
}

//对方正在输入
-(void)onPeerInputing:(int64_t)uid {
    
}

//同IM服务器连接的状态变更通知
-(void)onConnectState:(int)state {
    if (state == STATE_CONNECTING) {
        [self showConectingState];
    }else if(state == STATE_CONNECTED){
        self.navigationItem.title = @"对话";
        self.navigationItem.titleView = nil;
    }else if(state == STATE_CONNECTFAIL){
    }else if(state == STATE_UNCONNECTED){
    }
}
#pragma mark - function

-(void) showConectingState{
    UIView *titleview = [[UIView alloc] init];
    [titleview setFrame:CGRectMake(0, 0, 100, 44)];
    UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    aiView.hidesWhenStopped = NO;
    CGRect rect = aiView.frame;
    rect.origin.y = (titleview.frame.size.height - rect.size.height)/2;
    [aiView setFrame: rect];
    [aiView startAnimating];
    [titleview addSubview: aiView];
    
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(aiView.frame.size.width + 2, aiView.frame.origin.y, 100, aiView.frame.size.height)];
    [lable setText:@"连接中.."];
    [lable setFont:[UIFont systemFontOfSize:14]];
    [lable setTextAlignment: NSTextAlignmentLeft];
    [titleview addSubview: lable];
    
    titleview.center = CGPointMake(self.view.frame.size.width/2 , 22);
    self.navigationItem.titleView = titleview;
}

- (void) updateEmputyContentView{
    if ([self.conversations count] == 0) {
        self.emputyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 40)];
        [self.emputyLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.emputyLabel setBackgroundColor:RGBACOLOR(240, 240, 240, 1.0f)];
        [self.emputyLabel setText:@"可以到通讯录选择一个人发起对话"];
        [self.emputyLabel setTextAlignment:NSTextAlignmentCenter];
        [self.emputyLabel setTextColor:RGBACOLOR(20, 20, 20, 0.8f)];
        [self.emputyLabel setCenter:CGPointMake(self.view.center.x, self.view.center.y - 20)];
        CALayer *labelLayer = [self.emputyLabel layer];
        [self.emputyLabel setHidden:NO];
        [labelLayer setMasksToBounds:YES];
        [labelLayer setCornerRadius: 16];
        [self.view addSubview:self.emputyLabel];
        [self.tableview setHidden:YES];
    }else{
        if (self.emputyLabel) {
            [self.emputyLabel setHidden:YES];
            [self.emputyLabel removeFromSuperview];
            self.emputyLabel = nil;
        }
        [self.tableview setHidden:NO];
    }
}

-(void) reloadTheConversation{
    
    [self.conversations removeAllObjects];
    
    UserDB *db = [UserDB instance];
    id<ConversationIterator> iterator =  [[PeerMessageDB instance] newConversationIterator];
    
    Conversation * conversation = [iterator next];
    while (conversation) {
        IMUser *user = [db loadUser:conversation.cid];
        conversation.name = [user displayName];
        conversation.avatarURL = user.avatarURL;
        [self.conversations addObject:conversation];
        conversation = [iterator next];
    }
    
    [self.tableview reloadData];
    
}

-(void) resetConversationsViewControllerNewState{
    BOOL shouldClearNewCount = YES;
    for (Conversation *conv in self.conversations) {
        if (conv.newMsgCount > 0) {
            shouldClearNewCount = NO;
            break;
        }
    }
    
    if (shouldClearNewCount) {
        NSNotification* notification = [[NSNotification alloc] initWithName:CLEAR_TAB_BAR_NEW_MESSAGE_NOTIFY object: nil userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

@end
