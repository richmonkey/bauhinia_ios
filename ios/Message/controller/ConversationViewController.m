//
//  MessageListTableViewController.m
//  Message
//
//  Created by daozhu on 14-6-19.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "ConversationViewController.h"
#import <gobelieve/MessageViewController.h>
#import <gobelieve/PeerMessageDB.h>
#import <gobelieve/GroupMessageDB.h>
#import <gobelieve/IMessage.h>
#import <gobelieve/PeerMessageViewController.h>
#import <gobelieve/GroupMessageViewController.h>
#import "MGroupMessageViewController.h"
#import "GroupCreatorViewController.h"
#import "pinyin.h"
#import "UserDB.h"
#import "Profile.h"
#import "Config.h"
#import "APIRequest.h"
#import "LevelDB.h"
#import "GroupDB.h"
#import "AFNetworking.h"
#import "Token.h"
#import "NewCount.h"
#import "Conversation.h"

#define kPeerConversationCellHeight         60
#define kGroupConversationCellHeight        44

#define kActionSheetContact           0
#define kActionSheetSendHistory       1

#define kNewVersionTag 100

@interface ConversationViewController () <MessageViewControllerUserDelegate, GroupCreatorViewControllerDelegate>

@property(strong , nonatomic) NSString *versionUrl;

@property(nonatomic) int64_t currentUID;

@end

@implementation ConversationViewController

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
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(clearSinglePeerNewState:) name:CLEAR_PEER_NEW_MESSAGE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(clearSingleGroupNewState:) name:CLEAR_GROUP_NEW_MESSAGE object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];

    id<ConversationIterator> iterator =  [[PeerMessageDB instance] newConversationIterator];
    IMessage * msg = [iterator next];
    while (msg) {
        Conversation *conversation = [[Conversation alloc] init];
        conversation.message = msg;
        conversation.cid = [Token instance].uid == msg.sender ? msg.receiver : msg.sender;
        conversation.type = CONVERSATION_PEER;
        [self.conversations addObject:conversation];
        msg = [iterator next];
    }
    
    iterator = [[GroupMessageDB instance] newConversationIterator];
    msg = [iterator next];
    while (msg) {
        Conversation *conversation = [[Conversation alloc] init];
        conversation.message = msg;
        conversation.cid = msg.receiver;
        conversation.type = CONVERSATION_GROUP;
        [self.conversations addObject:conversation];
        msg = [iterator next];
    }
    
    for (Conversation *conv in self.conversations) {
        [self updateConversationName:conv];
        [self updateConversationDetail:conv];
        if (conv.type == CONVERSATION_PEER) {
            conv.newMsgCount = [NewCount getNewCount:conv.cid];
        } else if (conv.type == CONVERSATION_GROUP) {
            conv.newMsgCount = [NewCount getGroupNewCount:conv.cid];
        }
    }
    
    NSArray *sortedArray = [self.conversations sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        Conversation *c1 = obj1;
        Conversation *c2 = obj2;
        
        int t1 = c1.timestamp;
        int t2 = c2.timestamp;
        
        if (t1 < t2) {
            return NSOrderedDescending;
        } else if (t1 == t2) {
            return NSOrderedSame;
        } else {
            return NSOrderedAscending;
        }
    }];
    
    self.conversations = [NSMutableArray arrayWithArray:sortedArray];
    
    if ([[IMService instance] connectState] == STATE_CONNECTING) {
        [self showConectingState];
    }
    
    [self updateEmptyContentView];
    [self checkVersion];
    
    self.currentUID = [Profile instance].uid;
}


- (void)updateConversationDetail:(Conversation*)conv {
    conv.timestamp = conv.message.timestamp;
    if (conv.message.type == MESSAGE_IMAGE) {
        conv.detail = @"一张图片";
    }else if(conv.message.type == MESSAGE_TEXT){
        MessageTextContent *content = conv.message.textContent;
        conv.detail = content.text;
    }else if(conv.message.type == MESSAGE_LOCATION){
        conv.detail = @"一个地理位置";
    }else if (conv.message.type == MESSAGE_AUDIO){
        conv.detail = @"一个音频";
    } else if (conv.message.type == MESSAGE_GROUP_NOTIFICATION) {
        [self updateNotificationDesc:conv];
    }
}

-(void)updateConversationName:(Conversation*)conversation {
    if (conversation.type == CONVERSATION_PEER) {
        UserDB *db = [UserDB instance];
        User *user = [db loadUser:conversation.cid];
        conversation.name = [user displayName];
        conversation.avatarURL = user.avatarURL;
    } else if (conversation.type == CONVERSATION_GROUP) {
        conversation.avatarURL = @"";
        
        NSString *groupName = [self getGroupName:conversation.cid];
        if (groupName.length > 0) {
            conversation.name = groupName;
        } else {
            conversation.name = [NSString stringWithFormat:@"%lld", conversation.cid];
            [self asyncGetGroup:conversation.cid cb:^(IGroup *group) {
                if (group.name.length > 0) {
                    conversation.name = group.name;
          
                }
            }];
        }
    }
}

-(void)asyncGetGroup:(int64_t)groupID cb:(void (^)(IGroup*))cb {
    NSString *base = [NSString stringWithFormat:@"%@/", [Config instance].sdkAPIURL];
    NSURL *baseURL = [NSURL URLWithString:base];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    NSString *auth = [NSString stringWithFormat:@"Bearer %@", [Token instance].accessToken];
    [manager.requestSerializer setValue:auth forHTTPHeaderField:@"Authorization"];
    
    NSString *path = [NSString stringWithFormat:@"groups/%lld", groupID];
    [manager GET:path
       parameters:nil
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSLog(@"response:%@", responseObject);
              NSDictionary *dict = [responseObject objectForKey:@"data"];
              NSString *name = [dict objectForKey:@"name"];
              if (name.length > 0) {
                  [[GroupDB instance] setGroupTopic:groupID topic:name];
              }
              int64_t masterID = [[dict objectForKey:@"master"] longLongValue];
              if (masterID > 0) {
                  [[GroupDB instance] setGroupMaster:groupID master:masterID];
              }
              
              NSArray *members = [dict objectForKey:@"members"];
              for (NSDictionary *d in members) {
                  int64_t uid = [[d objectForKey:@"uid"] longLongValue];
                  [[GroupDB instance] addGroupMember:groupID member:uid];
              }
              
              if (name.length > 0) {
                  IGroup *group = [[IGroup alloc] init];
                  group.name = name;
                  group.gid = groupID;
                  cb(group);
              }
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"get gropu error");
              NSHTTPURLResponse* r = (NSHTTPURLResponse*)task.response;
              NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
              if (errorData) {
                  NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
                  NSLog(@"failure:%@ %@ %zd", error, [serializedData objectForKey:@"error"], r.statusCode);
                  NSString *e = [serializedData objectForKey:@"error"];
                  if (e.length > 0) {
                      NSLog(@"get group error:%@", e);
                  }
              }
          }
     ];
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


- (void)updateNotificationDesc:(Conversation*)conv {
    IMessage *message = conv.message;
    if (message.type == MESSAGE_GROUP_NOTIFICATION) {
        MessageGroupNotificationContent *notification = message.notificationContent;
        int type = notification.notificationType;
        if (type == NOTIFICATION_GROUP_CREATED) {
            if (self.currentUID == notification.master) {
                NSString *desc = [NSString stringWithFormat:@"您创建了\"%@\"群组", notification.groupName];
                notification.notificationDesc = desc;
                conv.detail = notification.notificationDesc;
            } else {
                NSString *desc = [NSString stringWithFormat:@"您加入了\"%@\"群组", notification.groupName];
                notification.notificationDesc = desc;
                conv.detail = notification.notificationDesc;
            }
        } else if (type == NOTIFICATION_GROUP_DISBANDED) {
            notification.notificationDesc = @"群组已解散";
            conv.detail = notification.notificationDesc;
        } else if (type == NOTIFICATION_GROUP_MEMBER_ADDED) {
            IUser *u = [self getUser:notification.member];
            if (u.name.length > 0) {
                NSString *name = u.name;
                NSString *desc = [NSString stringWithFormat:@"%@加入群", name];
                notification.notificationDesc = desc;
                conv.detail = notification.notificationDesc;
            } else {
                NSString *name = u.identifier;
                NSString *desc = [NSString stringWithFormat:@"%@加入群", name];
                notification.notificationDesc = desc;
                conv.detail = notification.notificationDesc;
                [self asyncGetUser:notification.member cb:^(IUser *u) {
                    NSString *desc = [NSString stringWithFormat:@"%@加入群", u.name];
                    notification.notificationDesc = desc;
                    //会话的最新消息未改变
                    if (conv.message == message) {
                        conv.detail = notification.notificationDesc;
                    }
                }];
            }
        } else if (type == NOTIFICATION_GROUP_MEMBER_LEAVED) {
            IUser *u = [self getUser:notification.member];
            if (u.name.length > 0) {
                NSString *name = u.name;
                NSString *desc = [NSString stringWithFormat:@"%@离开群", name];
                notification.notificationDesc = desc;
                conv.detail = notification.notificationDesc;
            } else {
                NSString *name = u.identifier;
                NSString *desc = [NSString stringWithFormat:@"%@离开群", name];
                notification.notificationDesc = desc;
                conv.detail = notification.notificationDesc;
                [self asyncGetUser:notification.member cb:^(IUser *u) {
                    NSString *desc = [NSString stringWithFormat:@"%@离开群", u.name];
                    notification.notificationDesc = desc;
                    //会话的最新消息未改变
                    if (conv.message == message) {
                        conv.detail = notification.notificationDesc;
                    }
                }];
            }
        } else if (type == NOTIFICATION_GROUP_NAME_UPDATED) {
            NSString *desc = [NSString stringWithFormat:@"群组更名为%@", notification.groupName];
            notification.notificationDesc = desc;
            conv.detail = notification.notificationDesc;
        }
    }
}

- (NSString*) getGroupName:(int64_t)groupID {
    NSString *name = [[GroupDB instance] getGroupTopic:groupID];
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
    GroupCreatorViewController *ctrl = [[GroupCreatorViewController alloc] init];
    ctrl.delegate = self;
    [self presentViewController:ctrl animated:YES completion:nil];
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
    ConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageConversationCell"];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"MessageConversationCell" owner:self options:nil] lastObject];
    }
    
    
    Conversation * conv = nil;
    if (tableView == self.tableview) {
        conv = (Conversation*)[self.conversations objectAtIndex:(indexPath.row)];
    } else {
        conv = (Conversation*)[self.filteredArray objectAtIndex:(indexPath.row)];
    }
    [cell setConversation:conv];
    
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
        msgController.userDelegate = self;
        
        msgController.peerUID = rmtUser.uid;
        msgController.peerName = rmtUser.displayName;
        msgController.currentUID = [Profile instance].uid;
        
        msgController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:msgController animated: YES];
        

    } else {
        
        MGroupMessageViewController* msgController = [[MGroupMessageViewController alloc] init];
        msgController.isShowUserName = YES;
        msgController.userDelegate = self;
        
        msgController.groupID = con.cid;
        
        msgController.groupName = con.name;
        
        msgController.currentUID = [Profile instance].uid;
        
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

- (void)clearSinglePeerNewState:(NSNotification*) notification {
    int64_t usrid = [(NSNumber*)notification.object longLongValue];
    for (int index = 0 ; index < [self.conversations count] ; index++) {
        Conversation *conv = [self.conversations objectAtIndex:index];
        if (conv.type == CONVERSATION_PEER && conv.cid == usrid) {
            if (conv.newMsgCount > 0) {
                conv.newMsgCount = 0;
                [NewCount setNewCount:0 uid:conv.cid];
                NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
                ConversationCell *cell = (ConversationCell*)[self.tableview cellForRowAtIndexPath:path];
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
                [NewCount setGroupNewCount:0 gid:conv.cid];
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

-(void)onNewGroupMessage:(IMessage*)msg cid:(int64_t)cid {
    [self onNewGroupMessage:msg cid:cid name:nil];
}

-(void)onNewGroupMessage:(IMessage*)msg cid:(int64_t)cid name:(NSString*)name {
    int index = -1;
    for (int i = 0; i < [self.conversations count]; i++) {
        Conversation *con = [self.conversations objectAtIndex:i];
        if (con.type == CONVERSATION_GROUP && con.cid == cid) {
            index = i;
            break;
        }
    }
    if (index != -1) {
        Conversation *con = [self.conversations objectAtIndex:index];
        con.message = msg;
        
        [self updateConversationDetail:con];
        if (self.currentUID != msg.sender) {
            con.newMsgCount += 1;
            [NewCount setGroupNewCount:con.newMsgCount gid:con.cid];
            [self setNewOnTabBar];
        }
        if (name.length > 0) {
            con.name = name;
        }
        
        if (index != 0) {
            //置顶
            [self.conversations removeObjectAtIndex:index];
            [self.conversations insertObject:con atIndex:0];
            [self.tableview reloadData];
        }
    } else {
        Conversation *con = [[Conversation alloc] init];
        con.message = msg;
        [self updateConversationDetail:con];
        
        if (self.currentUID != msg.sender) {
            con.newMsgCount += 1;
            [NewCount setGroupNewCount:con.newMsgCount gid:con.cid];
            [self setNewOnTabBar];
        }
        
        con.type = CONVERSATION_GROUP;
        con.cid = cid;
        [self updateConversationName:con];
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
            index = i;
            break;
        }
    }
    
    if (index != -1) {
        Conversation *con = [self.conversations objectAtIndex:index];
        con.message = msg;
        
        [self updateConversationDetail:con];
        
        if (self.currentUID == msg.receiver) {
            con.newMsgCount += 1;
            [NewCount setNewCount:con.newMsgCount uid:con.cid];
            [self setNewOnTabBar];
        }
        
        if (index != 0) {
            //置顶
            [self.conversations removeObjectAtIndex:index];
            [self.conversations insertObject:con atIndex:0];
            [self.tableview reloadData];
        }
    } else {
        Conversation *con = [[Conversation alloc] init];
        con.type = CONVERSATION_PEER;
        con.cid = cid;
        con.message = msg;
        
        [self updateConversationName:con];
        [self updateConversationDetail:con];
        
        if (self.currentUID == msg.receiver) {
            con.newMsgCount += 1;
            [NewCount setNewCount:con.newMsgCount uid:con.cid];
            [self setNewOnTabBar];
        }
        
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
    m.rawContent = im.content;
    m.timestamp = im.timestamp;
    
    int64_t cid;
    if (self.currentUID == m.sender) {
        cid = m.receiver;
    } else {
        cid = m.sender;
    }
    
    [self onNewMessage:m cid:cid];
}

-(void)onGroupMessage:(IMMessage *)im {
    IMessage *m = [[IMessage alloc] init];
    m.sender = im.sender;
    m.receiver = im.receiver;
    m.msgLocalID = im.msgLocalID;
    m.rawContent = im.content;
    m.timestamp = im.timestamp;
    
    
    [self onNewGroupMessage:m cid:m.receiver];
}

-(void)onGroupNotification:(NSString*)text {
    MessageGroupNotificationContent *notification = [[MessageGroupNotificationContent alloc] initWithNotification:text];
    int64_t groupID = notification.groupID;
    
    IMessage *msg = [[IMessage alloc] init];
    msg.sender = 0;
    msg.receiver = groupID;
    if (notification.timestamp > 0) {
        msg.timestamp = notification.timestamp;
    } else {
        msg.timestamp = (int)time(NULL);
    }
    msg.rawContent = notification.raw;
    
    NSString *name = nil;
    GroupDB *db = [GroupDB instance];
    int type = notification.notificationType;
    if (type == NOTIFICATION_GROUP_CREATED) {
        Group *g = [[Group alloc] init];
        g.groupID = notification.groupID;
        g.topic = notification.groupName;
        g.masterID = notification.master;
        
        for (NSNumber *member in notification.members) {
            [g addMember:[member longLongValue]];
        }
        [db addGroup:g];
    } else if (type == NOTIFICATION_GROUP_DISBANDED) {
        [db disbandGroup:notification.groupID];
    } else if (type == NOTIFICATION_GROUP_MEMBER_ADDED) {
        [db addGroupMember:notification.groupID member:notification.member];
    } else if (type == NOTIFICATION_GROUP_MEMBER_LEAVED) {
        [db removeGroupMember:notification.groupID member:notification.member];
    } else if (type == NOTIFICATION_GROUP_NAME_UPDATED) {
        [db setGroupTopic:notification.groupID topic:notification.groupName];
        name = notification.groupName;
    }

    [self onNewGroupMessage:msg cid:msg.receiver name:name];
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


- (void)appWillResignActive {
    NSLog(@"app will resign active");
    int c = 0;
    for (Conversation *conv in self.conversations) {
        c += conv.newMsgCount;
    }
    NSLog(@"unread count:%d", c);
    [[IMService instance] sendUnreadCount:c];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:c];
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
#pragma mark - MessageViewControllerUserDelegate
//从本地获取用户信息, IUser的name字段为空时，显示identifier字段
- (IUser*)getUser:(int64_t)uid {
    UserDB *db = [UserDB instance];
    User *user = [db loadUser:uid];
    
    IUser *u = [[IUser alloc] init];
    u.identifier = [NSString stringWithFormat:@"%lld", uid];
    u.name = [user displayName];
    u.avatarURL = user.avatarURL;
    return u;
}
//从服务器获取用户信息
- (void)asyncGetUser:(int64_t)uid cb:(void(^)(IUser*))cb {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            UserDB *db = [UserDB instance];
            User *user = [db loadUser:uid];
            
            IUser *u = [[IUser alloc] init];
            u.identifier = [NSString stringWithFormat:@"%lld", uid];
            u.name = [user displayName];
            u.avatarURL = user.avatarURL;
            cb(u);
        });
    });
}
#pragma mark - GroupCreatorViewControllerDelegate
-(void)onGroupCreated:(int64_t)gid name:(NSString*)name {
    NSLog(@"group created:%lld %@", gid, name);
    [self dismissViewControllerAnimated:NO completion:nil];
    
    MGroupMessageViewController* msgController = [[MGroupMessageViewController alloc] init];
    msgController.isShowUserName = YES;
    msgController.userDelegate = self;
    
    msgController.groupID = gid;
    
    msgController.groupName = name;
    
    msgController.currentUID = [Profile instance].uid;
    
    msgController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:msgController animated: YES];
}

-(void)onGroupCreateCanceled {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
