//
//  MsgViewController.m
//  Message
//
//  Created by daozhu on 14-6-16.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "MsgViewController.h"
#import "IMessage.h"
//#import "MessageDB.h"
#import "IMService.h"
#import "UserPresent.h"
//#import "MessageModel.h"
#import "MessageDB.h"

@interface MsgViewController () <JSMessagesViewDelegate, JSMessagesViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) NSMutableArray *messageArray;
@property (nonatomic,strong) UIImage *willSendImage;
@property (strong, nonatomic) NSMutableArray *timestamps;
@end

@implementation MsgViewController

@synthesize messageArray;

-(id)init{
  
  if (self = [super init]) {
//    self.userDB = [[SUserDB alloc] init];
  }
  return self;
}

//- (void)loadView{
//  [super loadView];

//  UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"Title"];
//  item.rightBarButtonItem = rightButton;
//  item.hidesBackButton = YES;
//  [bar pushNavigationItem:item animated:NO];
//  self.navigationController.navigationItem.leftBarButtonItem = rightButton;
//}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
  [super viewDidLoad];
  self.delegate = self;
  self.dataSource = self;
  
  self.title = @"Message";
  
  self.messageArray = [NSMutableArray array];
  
  IMessageIterator* iterator =  [[MessageDB instance] newPeerMessageIterator: 13635273142];
  IMessage *msg = [iterator next];
  while (msg) {
    [self.messageArray insertObject:msg atIndex: 0];
    msg = [iterator next];
  }
  
//  NSArray *msges = [self.userDB findWithSenderId:13635273142 limit:100];
//  if ([msges count] != 0) {
//    [self.messageArray addObjectsFromArray:msges];
//  }
  
  self.timestamps = [NSMutableArray array];
  for (IMessage* msg in self.messageArray) {
    [self.timestamps addObject:[NSString stringWithFormat:@"%d",msg.timestamp]];
  }
  
  
  UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                 style:UIBarButtonItemStyleDone
                                                                target:self
                                                                action:@selector(back)];
  self.navigationItem.leftBarButtonItem = backButton;
  
  [[IMService instance] addMessageObserver:self];
}

-(void)back{
  [self dismissViewControllerAnimated:YES completion:nil];
  
}
#pragma mark - MessageObserver data source
-(void)onPeerMessage:(IMessage*)msg{
  [JSMessageSoundEffect playMessageReceivedSound];
   NSLog(@"receive msg:%@",msg);
  [[MessageDB instance] insertPeerMessage:msg uid:msg.sender];
//  MessageModel *msgM = [[MessageModel alloc] initWithMessage: msg];
//  msg.msgLocalID =  (int)[self.userDB saveMessage:msgM];
  [self.messageArray addObject:msg];

  [self.timestamps addObject: [NSDate dateWithTimeIntervalSinceNow:msg.timestamp]];
  
  [self.tableView reloadData];
  [self scrollToBottomAnimated:YES];
}
-(void)onPeerMessageACK:(int)msgLocalID uid:(int64_t)uid{
  NSLog(@"receive msg ack:%d",msgLocalID);
}
-(void)onGroupMessage:(IMessage*)msg{
  
}
-(void)onGroupMessageACK:(int)msgLocalID gid:(int64_t)gid{
  
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.messageArray.count;
}

#pragma mark - Messages view delegate
- (void)sendPressed:(UIButton *)sender withText:(NSString *)text
{
  
  
  IMessage *msg = [[IMessage alloc] init];
  msg.sender = [UserPresent instance].userid;
  //  msg.receiver = 13635273143;
  msg.receiver = 13635273142;
  MessageContent *content = [[MessageContent alloc] init];
  content.raw = text;
  msg.content = content;
  msg.timestamp = time(NULL);
  
  [[MessageDB instance] insertPeerMessage:msg uid:msg.receiver];
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    BOOL r = [[IMService instance] sendPeerMessage:msg];
    NSLog(@"send result:%d", r);
//    MessageModel *msgM = [[MessageModel alloc] initWithMessage: msg];
//    msg.msgLocalID = (int)[self.userDB saveMessage:msgM];
    
    [self.messageArray addObject: msg];
    [self.timestamps addObject:[NSDate date]];
    
//    if((self.messageArray.count - 1) % 2)
    [JSMessageSoundEffect playMessageSentSound];
//    else
//      [JSMessageSoundEffect playMessageReceivedSound];
    
    [self finishSend];
    
  });
  
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
  if(msg.sender == [UserPresent instance].userid){
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

- (JSMessagesViewTimestampPolicy)timestampPolicy
{
  /*
   JSMessagesViewTimestampPolicyAll = 0,
   JSMessagesViewTimestampPolicyAlternating,
   JSMessagesViewTimestampPolicyEveryThree,
   JSMessagesViewTimestampPolicyEveryFive,
   JSMessagesViewTimestampPolicyCustom
   */
  return JSMessagesViewTimestampPolicyEveryThree;
}

- (JSMessagesViewAvatarPolicy)avatarPolicy
{
  /*
   JSMessagesViewAvatarPolicyIncomingOnly = 0,
   JSMessagesViewAvatarPolicyBoth,
   JSMessagesViewAvatarPolicyNone
   */
  return JSMessagesViewAvatarPolicyBoth;
}

- (JSAvatarStyle)avatarStyle
{
  /*
   JSAvatarStyleCircle = 0,
   JSAvatarStyleSquare,
   JSAvatarStyleNone
   */
  return JSAvatarStyleCircle;
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

@end
