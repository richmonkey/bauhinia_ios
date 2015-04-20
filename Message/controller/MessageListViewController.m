//
//  MessageListTableViewController.m
//  Message
//
//  Created by daozhu on 14-6-19.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "MessageListViewController.h"
#import <imkit/MessageViewController.h>
#import <imkit/PeerMessageDB.h>
#import <imkit/GroupMessageDB.h>
#import <imkit/IMessage.h>
#import <imkit/PeerMessageViewController.h>
#import <imkit/GroupMessageViewController.h>
#import "pinyin.h"
#import "MessageGroupConversationCell.h"
#import "NewGroupViewController.h"
#import "UserDB.h"
#import "UIImageView+WebCache.h"
#import "UserPresent.h"
#import "JSBadgeView.h"

#import "APIRequest.h"
#import "LevelDB.h"
#import "GroupDB.h"

#define kPeerConversationCellHeight         60
#define kGroupConversationCellHeight        44

#define kActionSheetContact           0
#define kActionSheetSendHistory       1

#define kNewVersionTag 100

@interface MessageListViewController ()

@property (strong , nonatomic) NSString *versionUrl;

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

    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"新增群组"
                                                             style:UIBarButtonItemStyleDone
                                                            target:self
                                                            action:@selector(newGroup)];
    
    self.navigationItem.rightBarButtonItem = item;
    
    
    self.tableview = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
	self.tableview.delegate = self;
	self.tableview.dataSource = self;
	self.tableview.scrollEnabled = YES;
	self.tableview.showsVerticalScrollIndicator = NO;
	self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableview setBackgroundColor:RGBACOLOR(235, 235, 237, 1)];
    
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
    
    [[IMService instance] addPeerMessageObserver:self];
    [[IMService instance] addGroupMessageObserver:self];
    [[IMService instance] addConnectionObserver:self];

    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(newGroupMessage:) name:LATEST_GROUP_MESSAGE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(newMessage:) name:LATEST_PEER_MESSAGE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(clearAllConversation:) name:CLEAR_ALL_CONVESATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(clearSinglePeerNewState:) name:CLEAR_PEER_NEW_MESSAGE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(clearSingleGroupNewState:) name:CLEAR_GROUP_NEW_MESSAGE object:nil];

    UserDB *db = [UserDB instance];
    id<ConversationIterator> iterator =  [[PeerMessageDB instance] newConversationIterator];
    
    Conversation * conversation = [iterator next];
    while (conversation) {
        User *user = [db loadUser:conversation.cid];
        conversation.name = [user displayName];
        conversation.avatarURL = user.avatarURL;
        [self.conversations addObject:conversation];
        conversation = [iterator next];
    }
    
    iterator = [[GroupMessageDB instance] newConversationIterator];
    conversation = [iterator next];
    while (conversation) {
        conversation.name = [self getGroupName:conversation.cid];;
        conversation.avatarURL = @"";
        if (conversation.message.content.type == MESSAGE_GROUP_NOTIFICATION) {
            [self updateNotificationDesc:conversation.message];
        }
        [self.conversations addObject:conversation];
        conversation = [iterator next];
    }
    
    
    if ([[IMService instance] connectState] == STATE_CONNECTING) {
        [self showConectingState];
    }
    
    
    [self updateEmptyContentView];

    [self checkVersion];
}

-(void)checkVersion {
    [APIRequest checkVersion:@"ios"
                     success:^(NSDictionary *resp){
                         
                         self.versionUrl = [resp objectForKey:@"url"];
                         NSString *majorVersion = [resp objectForKey:@"major"];
                         NSString *minorVersion = [resp objectForKey:@"minor"];
                         
                         NSString *newVersion = [NSString stringWithFormat:@"%@.%@",majorVersion,minorVersion];
                         
                         NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                         NSString *currentVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
                         
                         if ([newVersion floatValue] > [currentVersion floatValue] ) {
                             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否更新羊蹄甲?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
                             alertView.tag = kNewVersionTag;
                             [alertView show];
                         }
                     }
                        fail:^{
                            
                        }];
}

- (void)updateNotificationDesc:(IMessage*)message {
    if (message.content.type == MESSAGE_GROUP_NOTIFICATION) {
        GroupNotification *notification = message.content.notification;
        int type = notification.type;
        if (type == NOTIFICATION_GROUP_CREATED) {
            if ([UserPresent instance].uid == notification.master) {
                NSString *desc = [NSString stringWithFormat:@"您创建了\"%@\"群组", notification.groupName];
                message.content.notificationDesc = desc;
            } else {
                NSString *desc = [NSString stringWithFormat:@"您加入了\"%@\"群组", notification.groupName];
                message.content.notificationDesc = desc;
            }
        } else if (type == NOTIFICATION_GROUP_DISBANDED) {
            message.content.notificationDesc = @"群组已解散";
        } else if (type == NOTIFICATION_GROUP_MEMBER_ADDED) {
            User *u = [[UserDB instance] loadUser:notification.member];
            NSString *desc = [NSString stringWithFormat:@"%@加入群", u.displayName];
            message.content.notificationDesc = desc;
        } else if (type == NOTIFICATION_GROUP_MEMBER_LEAVED) {
            User *u = [[UserDB instance] loadUser:notification.member];
            NSString *desc = [NSString stringWithFormat:@"%@离开群", u.displayName];
            message.content.notificationDesc = desc;
        }
    }
}

- (NSString*) getGroupName:(int64_t)groupID {
    NSString *name = [[GroupDB instance] getGroupTopic:groupID];
    if (!name) {
        name = @"";
    }
    return name;
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
        User *user = [db loadUser:conv.cid];
        conv.name = user.displayName;
        conv.avatarURL = user.avatarURL;
    }
    [self.tableview reloadData];
}

- (void)newGroup {
    NewGroupViewController *ctl = [[NewGroupViewController alloc] initWithNibName:@"NewGroupViewController" bundle:nil];
    UINavigationController * navCtr = [[UINavigationController alloc] initWithRootViewController: ctl];
    [self presentViewController:navCtr animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableview) {
        return [self.conversations count];
    }else{
        return self.filteredArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kPeerConversationCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //peer
    MessageConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageConversationCell"];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"MessageConversationCell" owner:self options:nil] lastObject];
    }
    Conversation * conv = nil;
    if (tableView == self.tableview) {
        conv = (Conversation*)[self.conversations objectAtIndex:(indexPath.row)];
    } else {
        conv = (Conversation*)[self.filteredArray objectAtIndex:(indexPath.row)];
    }
    if(conv.type == CONVERSATION_PEER){
        [cell.headView sd_setImageWithURL: [NSURL URLWithString:conv.avatarURL] placeholderImage:[UIImage imageNamed:@"PersonalChat"]];
    }else if (conv.type == CONVERSATION_GROUP){
        [cell.headView sd_setImageWithURL:[NSURL URLWithString:conv.avatarURL] placeholderImage:[UIImage imageNamed:@"GroupChat"]];
    }
    if (conv.message.content.type == MESSAGE_IMAGE) {
        cell.messageContent.text = @"一张图片";
    }else if(conv.message.content.type == MESSAGE_TEXT){
       cell.messageContent.text = conv.message.content.text;
    }else if(conv.message.content.type == MESSAGE_LOCATION){
        cell.messageContent.text = @"一个地理位置";
    }else if (conv.message.content.type == MESSAGE_AUDIO){
       cell.messageContent.text = @"一个音频";
    } else if (conv.message.content.type == MESSAGE_GROUP_NOTIFICATION) {
        cell.messageContent.text = conv.message.content.notificationDesc;
    }
    
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: conv.message.timestamp];
    NSString *str = [PublicFunc getConversationTimeString:date ];
    cell.timelabel.text = str;
    cell.namelabel.text = conv.name;
   
    if (conv.newMsgCount > 0) {
        [cell showNewMessage:conv.newMsgCount];
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
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        if ([self.searchDC isActive]) {
            Conversation *con = [self.filteredArray objectAtIndex:indexPath.row];
            
            if (con.type == CONVERSATION_PEER) {
                [[PeerMessageDB instance] clearConversation:con.cid];
            } else {
                [[GroupMessageDB instance] clearConversation:con.cid];
            }
            
            [self.filteredArray removeObject:con];
            [self.conversations removeObject:con];
            
            /*IOS8中删除最后一个cell的时，报一个错误
            [RemindersCell _setDeleteAnimationInProgress:]: message sent to deallocated instance
            在重新刷新tableView的时候延迟一下*/
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.tableview reloadData];
                [self.searchDC.searchResultsTableView reloadData];
            });
            
            if([self.filteredArray count] == 0){
                [self.searchDC setActive:NO];
            }
            
        }else{
            Conversation *con = [self.conversations objectAtIndex:indexPath.row];
            if (con.type == CONVERSATION_PEER) {
                [[PeerMessageDB instance] clearConversation:con.cid];
            } else {
                [[GroupMessageDB instance] clearConversation:con.cid];
            }
            [self.conversations removeObject:con];
            
            /*IOS8中删除最后一个cell的时，报一个错误
             [RemindersCell _setDeleteAnimationInProgress:]: message sent to deallocated instance
             在重新刷新tableView的时候延迟一下*/
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.tableview reloadData];
            });
            
            [self updateEmptyContentView];
        }
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.searchDisplayController isActive]) {
        [self.searchBar resignFirstResponder];
    }
    
    Conversation *con = [self.conversations objectAtIndex:indexPath.row];
    if (con.type == CONVERSATION_PEER) {
        User *rmtUser = [[UserDB instance] loadUser: con.cid];
        
        PeerMessageViewController* msgController = [[PeerMessageViewController alloc] init];
        msgController.peerUID = rmtUser.uid;
        
        msgController.peerName = rmtUser.displayName;
        
        msgController.currentUID = [UserPresent instance].uid;
        
        msgController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:msgController animated: YES];
        

    } else {
        
        GroupMessageViewController* msgController = [[GroupMessageViewController alloc] init];
        msgController.isShowUserName = YES;
        msgController.getUserName = ^ NSString*(int64_t uid) {
            if (uid == 0) {
                return nil;
            }
            User *u = [[UserDB instance] loadUser:uid];
            return u.displayName;
        };
        
        msgController.groupID = con.cid;
        
        msgController.groupName = con.name;
        
        msgController.currentUID = [UserPresent instance].uid;
        
        msgController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:msgController animated: YES];

    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)newGroupMessage:(NSNotification*)notification {
    IMessage *m = notification.object;
    NSLog(@"new message:%lld, %lld", m.sender, m.receiver);
    [self onNewGroupMessage:m cid:m.receiver];
}

- (void)newMessage:(NSNotification*) notification {
    IMessage *m = notification.object;
    NSLog(@"new message:%lld, %lld", m.sender, m.receiver);
    [self onNewMessage:m cid:m.receiver];
}

- (void)clearAllConversation:(NSNotification*) notification{
    [self reloadTheConversation];
    [self updateEmptyContentView];
}

- (void)clearSinglePeerNewState:(NSNotification*) notification {
    int64_t usrid = [(NSNumber*)notification.object longLongValue];
    for (int index = 0 ; index < [self.conversations count] ; index++) {
        Conversation *conv = [self.conversations objectAtIndex:index];
        if (conv.type == CONVERSATION_PEER && conv.cid == usrid) {
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

- (void)clearSingleGroupNewState:(NSNotification*) notification{
    int64_t groupID = [(NSNumber*)notification.object longLongValue];
    for (int index = 0 ; index < [self.conversations count] ; index++) {
        Conversation *conv = [self.conversations objectAtIndex:index];
        if (conv.type == CONVERSATION_GROUP && conv.cid == groupID) {
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
        NSString *contentStr = conv.message.content.text;
        
        if ([self searchResult:name searchText:self.searchBar.text]) {
            [self.filteredArray addObject:conv];
        } else if ([self searchResult:string searchText:self.searchBar.text]) {
            [self.filteredArray addObject:conv];
        } else if([self searchResult:contentStr searchText:self.searchBar.text]){
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

-(void)onNewGroupMessage:(IMessage*)msg cid:(int64_t)cid{
    int index = -1;
    for (int i = 0; i < [self.conversations count]; i++) {
        Conversation *con = [self.conversations objectAtIndex:i];
        if (con.type == CONVERSATION_GROUP && con.cid == cid) {
            con.message = msg;
            index = i;
            break;
        }
    }
    
    if (index != -1) {
        Conversation *con = [self.conversations objectAtIndex:index];
        con.message = msg;
        if ([UserPresent instance].uid != msg.sender) {
            con.newMsgCount += 1;
            [self setNewOnTabBar];
        }
        NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
    } else {
        Conversation *con = [[Conversation alloc] init];
        con.message = msg;
        
        if ([UserPresent instance].uid != msg.sender) {
            con.newMsgCount += 1;
            [self setNewOnTabBar];
        }
        
        con.type = CONVERSATION_GROUP;
        con.cid = cid;
        con.name = [self getGroupName:cid];
        con.avatarURL = @"";
        [self.conversations insertObject:con atIndex:0];
        NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
        NSArray *array = [NSArray arrayWithObject:path];
        [self.tableview insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationMiddle];
    }
    
    [self updateEmptyContentView];
}


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
        if ([UserPresent instance].uid == msg.receiver) {
            con.newMsgCount += 1;
            [self setNewOnTabBar];
        }
        NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
    } else {
        Conversation *con = [[Conversation alloc] init];
        con.message = msg;
       
        if ([UserPresent instance].uid == msg.receiver) {
            con.newMsgCount += 1;
            [self setNewOnTabBar];
        }
        
        con.type = CONVERSATION_PEER;
        con.cid = cid;
        
        UserDB *db = [UserDB instance];
        User *user = [db loadUser:con.cid];
        con.name = [user displayName];
        con.avatarURL = user.avatarURL;
        [self.conversations insertObject:con atIndex:0];
        NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
        NSArray *array = [NSArray arrayWithObject:path];
        [self.tableview insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationMiddle];
    }
    
    [self updateEmptyContentView];
}

-(void)onPeerMessage:(IMMessage*)im {
    IMessage *m = [[IMessage alloc] init];
    m.sender = im.sender;
    m.receiver = im.receiver;
    m.msgLocalID = im.msgLocalID;
    MessageContent *content = [[MessageContent alloc] init];
    content.raw = im.content;
    m.content = content;
    m.timestamp = (int)time(NULL);
    
    MessageContent *c = m.content;
    if (c.type == MESSAGE_TEXT) {
        IMLog(@"message:%@", c.text);
    }
    [self onNewMessage:m cid:m.sender];
}

-(void)onGroupMessage:(IMMessage *)im {
    IMessage *m = [[IMessage alloc] init];
    m.sender = im.sender;
    m.receiver = im.receiver;
    m.msgLocalID = im.msgLocalID;
    MessageContent *content = [[MessageContent alloc] init];
    content.raw = im.content;
    m.content = content;
    m.timestamp = (int)time(NULL);
    
    MessageContent *c = m.content;
    if (c.type == MESSAGE_TEXT) {
        IMLog(@"message:%@", c.text);
    }
    [self onNewGroupMessage:m cid:m.receiver];
}

-(void)onGroupNotification:(NSString*)text {
    GroupNotification *notification = [[GroupNotification alloc] initWithRaw:text];
    if (notification.type == NOTIFICATION_GROUP_CREATED) {
        [self onGroupCreated:notification];
    } else if (notification.type == NOTIFICATION_GROUP_DISBANDED) {
        [self onGroupDisband:notification];
    } else if (notification.type == NOTIFICATION_GROUP_MEMBER_ADDED) {
        [self onGroupMemberAdd:notification];
    } else if (notification.type == NOTIFICATION_GROUP_MEMBER_LEAVED) {
        [self onGroupMemberLeave:notification];
    }
}
-(void)onGroupCreated:(GroupNotification*)notification {
    int64_t groupID = notification.groupID;
    NSString *groupName = notification.groupName;
    int64_t master = notification.master;
    NSArray *members = notification.members;
    
    Group *group = [[Group alloc] init];
    group.groupID = groupID;
    group.topic = groupName;

    group.masterID = master;
    for (NSNumber *n in members) {
        [group addMember:[n longLongValue]];
    }
    
    [[GroupDB instance] addGroup:group];
    
    IMessage *msg = [[IMessage alloc] init];
    msg.sender = 0;
    msg.receiver = groupID;
    msg.timestamp = (int)time(NULL);
    MessageContent *content = [[MessageContent alloc] initWithNotification:notification];
    msg.content = content;
    
    [self updateNotificationDesc:msg];
    [self onNewGroupMessage:msg cid:msg.receiver];
}

-(void)onGroupDisband:(GroupNotification*)notification {
    int64_t groupID = notification.groupID;
    
    [[GroupDB instance] disbandGroup:groupID];
    
    IMessage *msg = [[IMessage alloc] init];
    msg.sender = 0;
    msg.receiver = groupID;
    msg.timestamp = (int)time(NULL);
    MessageContent *content = [[MessageContent alloc] initWithNotification:notification];
    msg.content = content;
    
    [self updateNotificationDesc:msg];
    
    [self onNewGroupMessage:msg cid:msg.receiver];
}

-(void)onGroupMemberAdd:(GroupNotification*)notification {
    int64_t member = notification.member;
    int64_t groupID = notification.groupID;
    
    [[GroupDB instance] addGroupMember:groupID member:member];
    
    IMessage *msg = [[IMessage alloc] init];
    msg.sender = 0;
    msg.receiver = groupID;
    msg.timestamp = (int)time(NULL);
    MessageContent *content = [[MessageContent alloc] initWithNotification:notification];
    msg.content = content;
    
    [self updateNotificationDesc:msg];
    
    [self onNewGroupMessage:msg cid:msg.receiver];
}

-(void)onGroupMemberLeave:(GroupNotification*)notification {
    int64_t member = notification.member;
    int64_t groupID = notification.groupID;
    
    [[GroupDB instance] removeGroupMember:groupID member:member];
    
    IMessage *msg = [[IMessage alloc] init];
    msg.sender = 0;
    msg.receiver = groupID;
    msg.timestamp = (int)time(NULL);
    MessageContent *content = [[MessageContent alloc] initWithNotification:notification];
    msg.content = content;
    
    [self updateNotificationDesc:msg];
    
    [self onNewGroupMessage:msg cid:msg.receiver];
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

- (void) updateEmptyContentView{
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
        User *user = [db loadUser:conversation.cid];
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
        [self clearNewOnTarBar];
    }
}

- (void)setNewOnTabBar {
    UITabBar *tabBar = self.tabBarController.tabBar;
    UITabBarItem * cc =  [tabBar.items objectAtIndex: 2];
    [cc setBadgeValue:@""];
}

- (void)clearNewOnTarBar {
    UITabBar *tabBar = self.tabBarController.tabBar;
    UITabBarItem * cc =  [tabBar.items objectAtIndex: 2];
    [cc setBadgeValue:nil];
}

#pragma mark - UIAlertViewDelegate
/**
 *  新版本检测回调
 *  @return
 */
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 1){
        if (self.versionUrl) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: self.versionUrl]];
        }
    }
}

@end
