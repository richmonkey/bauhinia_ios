//
//  MessageViewController.h
//  Message
//
//  Created by daozhu on 14-6-16.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "IMService.h"
#import "IMessage.h"
#import "MessageListViewController.h"
#import "user.h"

#import "JSBubbleMessageCell.h"
#import "JSMessageSoundEffect.h"
#import "UIButton+JSMessagesView.h"
#import "MBProgressHUD.h"

#define INPUT_HEIGHT 46.0f

#import "MessageInputView.h"

@class ConversationHeadButtonView;


@interface MessageViewController : UIViewController < UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIScrollViewDelegate,MessageObserver,UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (strong, nonatomic) NSMutableArray *messageArray;
@property (nonatomic,strong) UIImage *willSendImage;
@property (strong, nonatomic) NSMutableArray *timestamps;

@property (nonatomic) ConversationHeadButtonView *navigationBarButtonsView;
@property (nonatomic) int  inputTimestamp;
@property (nonatomic) IMUser *remoteUser;
@property (nonatomic) NSTimer  *inputStatusTimer;

-(id) initWithRemoteUser:(IMUser*) rmtUser;

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) MessageInputView *inputToolBarView;
@property (assign, nonatomic, readonly) UIEdgeInsets originalTableViewContentInset;

- (void)setup;

#pragma mark - Actions
- (void)sendPressed:(UIButton *)sender;

#pragma mark - Messages view controller
- (void)scrollToBottomAnimated:(BOOL)animated;

#pragma mark - Keyboard notifications
- (void)handleWillShowKeyboard:(NSNotification *)notification;
- (void)handleWillHideKeyboard:(NSNotification *)notification;

@end
