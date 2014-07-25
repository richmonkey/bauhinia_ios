//
//  MessageViewController.h
//  Message
//
//  Created by daozhu on 14-6-16.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSMessagesViewController.h"
#import "IMService.h"
#import "IMessage.h"
#import "MessageListViewController.h"
#import "user.h"



@class ConversationHeadButtonView;

@interface MessageViewController : JSMessagesViewController <UIScrollViewDelegate,MessageObserver>


@property (nonatomic) ConversationHeadButtonView *navigationBarButtonsView;
@property (nonatomic) int  inputTimestamp;
@property (nonatomic) IMUser *curUser;
@property (nonatomic) IMUser *remoteUser;
@property (nonatomic) NSTimer  *inputStatusTimer;

-(id) initWithRemoteUser:(IMUser*) rmtUser;

@end
