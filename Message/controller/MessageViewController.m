//
//  MessageViewController
//  Created by daozhu on 14-6-16.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "MessageViewController.h"
#import "IMessage.h"
#import "IMService.h"
#import "UserPresent.h"
#import "MessageDB.h"
#import "ConversationHeadButtonView.h"
#import "MessageHeaderActionsView.h"
#import "MessageTableSectionHeaderView.h"

#import "MessageShowThePotraitViewController.h"

#define navBarHeadButtonSize 35



@interface MessageViewController () <JSMessagesViewDelegate, JSMessagesViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>


@property (strong, nonatomic) NSMutableArray *messageArray;
@property (nonatomic,strong) UIImage *willSendImage;
@property (strong, nonatomic) NSMutableArray *timestamps;
@end

@implementation MessageViewController

@synthesize messageArray;



-(id) initWithConversation:(Conversation *) con{
    if (self = [super init]) {
        self.currentConversation = con;

    }
    return self;
}

- (void)loadView{
    [super loadView];
    
    UIButton *imgButton = [[UIButton alloc] initWithFrame: CGRectMake(0,0,navBarHeadButtonSize,navBarHeadButtonSize)];
    
    [imgButton setImage: [UIImage  imageNamed:@"head1.png"] forState: UIControlStateNormal];
    [imgButton addTarget:self action:@selector(navBarUserheadAction) forControlEvents:UIControlEventTouchUpInside];
    
    CALayer *imageLayer = [imgButton layer];   //获取ImageView的层
    [imageLayer setMasksToBounds:YES];
    [imageLayer setCornerRadius:imgButton.frame.size.width/2];
    
    UIBarButtonItem *navBarHeadButton = [[UIBarButtonItem alloc] initWithCustomView: imgButton];
    
    self.navigationItem.rightBarButtonItem = navBarHeadButton;
    
    self.headButtonView = [[[NSBundle mainBundle]loadNibNamed:@"ConversationHeadButtonView" owner:self options:nil] lastObject];
    self.headButtonView.center = self.navigationController.navigationBar.center;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = self;
    self.dataSource = self;
    if (!self.currentConversation.name) {
        
    self.title = @"消息";
    }else{
        self.title = self.currentConversation.name;
    }
    
    MessageHeaderActionsView *tableHeaderView = [[[NSBundle mainBundle]loadNibNamed:@"MessageHeaderActionsView" owner:self options:nil] lastObject];
    self.tableView.tableHeaderView = tableHeaderView;
    
    [self setBackgroundColor: [UIColor grayColor]];

    
    self.messageArray = [NSMutableArray array];
    
    IMessageIterator* iterator =  [[MessageDB instance] newPeerMessageIterator: self.currentConversation.cid];
    IMessage *msg = [iterator next];
    while (msg) {
        [self.messageArray insertObject:msg atIndex: 0];
        msg = [iterator next];
    }
    
    self.timestamps = [NSMutableArray array];
    for (IMessage* msg in self.messageArray) {
        [self.timestamps addObject:[NSString stringWithFormat:@"%d",msg.timestamp]];
    }
    
    [[IMService instance] addMessageObserver:self];
}


#pragma mark - MessageObserver

-(void)onPeerMessage:(IMessage*)msg{
    [JSMessageSoundEffect playMessageReceivedSound];
    NSLog(@"receive msg:%@",msg);
    [[MessageDB instance] insertPeerMessage:msg uid:msg.sender];
    
    [self.messageArray addObject:msg];
    
    [self.timestamps addObject: [NSDate dateWithTimeIntervalSinceNow:msg.timestamp]];
    
    [self.tableView reloadData];
    [self scrollToBottomAnimated:YES];
}
//服务器ack
-(void)onPeerMessageACK:(int)msgLocalID uid:(int64_t)uid{
    NSLog(@"receive msg ack:%d",msgLocalID);
    
}

//接受方ack
-(void)onPeerMessageRemoteACK:(int)msgLocalID uid:(int64_t)uid{
    
}

-(void)onGroupMessage:(IMessage*)msg{
    
}
-(void)onGroupMessageACK:(int)msgLocalID gid:(int64_t)gid{
    
}

//用户连线状态
-(void)onOnlineState:(int64_t)uid state:(BOOL)on{
    
}

//对方正在输入
-(void)onPeerInputing:(int64_t)uid{
    
}

//同IM服务器连接的状态变更通知
-(void)onConnectState:(int)state{
    
    if (state == STATE_CONNECTING) {
        UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        aiView.hidesWhenStopped = NO; //I added this just so I could see it
        self.navigationItem.titleView = aiView;
    }else if(state == STATE_CONNECTED){

        self.navigationItem.titleView = self.headButtonView;
        
    }else if(state == STATE_CONNECTFAIL){
        [self.headButtonView.nameLabel setText: @"小张"];
        
        [self.headButtonView.conectInformationLabel setText:@"最近登录时间昨天下午"];

        self.navigationItem.titleView = self.headButtonView;
        
    }else{
        
        [self.headButtonView.nameLabel setText: @"小张"];
        [self.headButtonView.conectInformationLabel setText:@"最近登录时间昨天下午"];

        self.navigationItem.titleView = self.headButtonView;
        
    }
}

#pragma mark - UITextViewDelegate

-(void)textViewDidBeginEditing:(UITextView *)textView{
    [super textViewDidBeginEditing:textView];
    
    MessageInputing *inputing = [[MessageInputing alloc ] init];
    
    inputing.sender = [UserPresent instance].uid;
    inputing.receiver =self.currentConversation.cid;
    
    [[IMService instance] sendInputing: inputing];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messageArray.count;
}

#pragma mark -  UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    MessageTableSectionHeaderView *sectionHeader = [[[NSBundle mainBundle]loadNibNamed:@"MessageTableSectionHeaderView" owner:self options:nil] lastObject];
    
    return sectionHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}

#pragma mark - Messages view delegate
- (void)sendPressed:(UIButton *)sender withText:(NSString *)text {
    
    IMessage *msg = [[IMessage alloc] init];
    
    msg.sender = [UserPresent instance].uid;
    msg.receiver = self.currentConversation.cid;
    
    MessageContent *content = [[MessageContent alloc] init];
    content.raw = text;
    msg.content = content;
    msg.timestamp = time(NULL);
    
    [[MessageDB instance] insertPeerMessage:msg uid:msg.receiver];
    
    BOOL r = [[IMService instance] sendPeerMessage:msg];
    NSLog(@"send result:%d", r);
    
    
    [self.messageArray addObject: msg];
    [self.timestamps addObject:[NSDate date]];
    
    [JSMessageSoundEffect playMessageSentSound];
    

    NSNotification* notification = [[NSNotification alloc] initWithName:SEND_FIRST_MESSAGE_OK object: msg userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:SEND_FIRST_MESSAGE_OK object: notification ];
    
    
    
    [self finishSend];
        
    
    
    
}

- (void)cameraPressed:(id)sender{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    IMessage * msg =  [self.messageArray objectAtIndex:indexPath.row];
    if(msg.sender == [UserPresent instance].uid){
        return JSBubbleMessageTypeOutgoing;
    }else{
        return JSBubbleMessageTypeIncoming;
    }
    
}

- (JSBubbleMessageStyle)messageStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return JSBubbleMessageStyleFlat;
}

- (JSBubbleMediaType)messageMediaTypeForRowAtIndexPath:(NSIndexPath *)indexPath{
    return JSBubbleMediaTypeText;
}

- (UIButton *)sendButton
{
    return [UIButton defaultSendButton];
}

- (JSInputBarStyle)inputBarStyle
{
    /*
     JSInputBarStyleDefault,
     JSInputBarStyleFlat
     
     */
    return JSInputBarStyleFlat;
}

//  Optional delegate method
//  Required if using `JSMessagesViewTimestampPolicyCustom`
//
//  - (BOOL)hasTimestampForRowAtIndexPath:(NSIndexPath *)indexPath
//

#pragma mark - Messages view data source
- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.messageArray objectAtIndex:indexPath.row]){
        return ((IMessage*)[self.messageArray objectAtIndex:indexPath.row]).content.raw;
    }
    return nil;
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.timestamps objectAtIndex:indexPath.row];
}

- (UIImage *)avatarImageForIncomingMessage
{
    return [UIImage imageNamed:@"head1.png"];
}

- (UIImage *)avatarImageForOutgoingMessage
{
    return [UIImage imageNamed:@"head2.png"];
}

- (id)dataForRowAtIndexPath:(NSIndexPath *)indexPath{
    //  if([[self.messageArray objectAtIndex:indexPath.row] objectForKey:@"Image"]){
    //    return [[self.messageArray objectAtIndex:indexPath.row] objectForKey:@"Image"];
    //  }
    return nil;
    
}

#pragma UIImagePicker Delegate

#pragma mark - Image picker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	NSLog(@"Chose image!  Details:  %@", info);
    
    self.willSendImage = [info objectForKey:UIImagePickerControllerEditedImage];
    //  [self.messageArray addObject:[NSDictionary dictionaryWithObject:self.willSendImage forKey:@"Image"]];
    [self.timestamps addObject:[NSDate date]];
    [self.tableView reloadData];
    [self scrollToBottomAnimated:YES];
    
	
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)navBarUserheadAction{
    NSLog(@"头像");
    
    MessageShowThePotraitViewController *controller = [[MessageShowThePotraitViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];

}

@end
