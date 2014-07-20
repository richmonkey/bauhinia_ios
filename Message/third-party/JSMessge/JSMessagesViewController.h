//
//  JSMessagesViewController.h
//
//  Created by Jesse Squires on 2/12/13.
//  Copyright (c) 2013 Hexed Bits. All rights reserved.
//
//  http://www.hexedbits.com
//
//
//  Largely based on work by Sam Soffes
//  https://github.com/soffes
//
//  SSMessagesViewController
//  https://github.com/soffes/ssmessagesviewcontroller
//
//


#import <UIKit/UIKit.h>


#import "JSBubbleMessageCell.h"
#import "JSMessageInputView.h"
#import "JSMessageSoundEffect.h"
#import "UIButton+JSMessagesView.h"


#define kAllowsMedia		YES


@protocol JSMessagesViewDelegate <NSObject>
@required
- (void)sendPressed:(UIButton *)sender withText:(NSString *)text;
- (void)cameraPressed:(id)sender;
- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath;
- (JSBubbleMediaType)messageMediaTypeForRowAtIndexPath:(NSIndexPath *)indexPath;

@end



@protocol JSMessagesViewDataSource <NSObject>
@required
- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (id)dataForRowAtIndexPath:(NSIndexPath *)indexPath;
@end



@interface JSMessagesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIGestureRecognizerDelegate,JSMessageInputViewDelegate>

@property (weak, nonatomic) id<JSMessagesViewDelegate> delegate;
@property (weak, nonatomic) id<JSMessagesViewDataSource> dataSource;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) JSMessageInputView *inputToolBarView;
@property (assign, nonatomic) CGFloat previousTextViewContentHeight;
@property (assign, nonatomic, readonly) UIEdgeInsets originalTableViewContentInset;

#pragma mark - Initialization
- (UIButton *)sendButton;

#pragma mark - Actions
- (void)sendPressed:(UIButton *)sender;

#pragma mark - Messages view controller
- (void)finishSend;
- (void)scrollToBottomAnimated:(BOOL)animated;

#pragma mark - Keyboard notifications
- (void)handleWillShowKeyboard:(NSNotification *)notification;
- (void)handleWillHideKeyboard:(NSNotification *)notification;
- (void)keyboardWillShowHide:(NSNotification *)notification;

@end