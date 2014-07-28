//
//  MessageViewController.h
//  Message
//
//  Created by daozhu on 14-6-16.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMService.h"
#import "IMessage.h"
#import "MessageListViewController.h"
#import "user.h"

#import "JSBubbleMessageCell.h"
#import "JSMessageInputView.h"
#import "JSMessageSoundEffect.h"
#import "UIButton+JSMessagesView.h"
#import "JSDismissiveTextView.h"

#define kAllowsMedia	NO	
#define INPUT_HEIGHT 46.0f


@class ConversationHeadButtonView;


@interface MessageViewController : UIViewController < UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIScrollViewDelegate,MessageObserver,UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIGestureRecognizerDelegate,JSMessageInputViewDelegate,JSDismissiveTextViewDelegate>

@property (strong, nonatomic) NSMutableArray *messageArray;
@property (nonatomic,strong) UIImage *willSendImage;
@property (strong, nonatomic) NSMutableArray *timestamps;

@property (nonatomic) ConversationHeadButtonView *navigationBarButtonsView;
@property (nonatomic) int  inputTimestamp;
@property (nonatomic) IMUser *remoteUser;
@property (nonatomic) NSTimer  *inputStatusTimer;

-(id) initWithRemoteUser:(IMUser*) rmtUser;

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) JSMessageInputView *inputToolBarView;
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
