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
#import "MessageHeaderActionsView.h"

@class ConversationHeadButtonView;

@interface MessageViewController : JSMessagesViewController <UIScrollViewDelegate,MessageObserver>


@property (strong,nonatomic) ConversationHeadButtonView *navigationBarButtonsView;
@property (weak,nonatomic) Conversation* currentConversation;
@property (nonatomic,strong) MessageHeaderActionsView *tableHeaderView;
@property (nonatomic, strong) NSMutableArray *headerArray;

- (id) initWithConversation:(Conversation *) con;

@end
