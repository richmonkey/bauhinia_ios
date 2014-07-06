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

@class ConversationHeadButtonView;

@interface MessageViewController : JSMessagesViewController <MessageObserver>


@property (strong,nonatomic) ConversationHeadButtonView *headButtonView;

@end
