//
//  MessageTextView.h
//  Message
//
//  Created by houxh on 14-9-9.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BubbleView.h"
#import "IMessage.h"

#import "BCTextFrame.h"

@interface MessageTextView : BubbleView

@property (nonatomic, copy) NSString *text;


-(id) initWithFrame:(CGRect)frame withType:(BubbleMessageType)type;

-(void) initializeWithMsg:(IMessage *)msg withMsgStateType:(BubbleMessageReceiveStateType)stateType;

+(float) cellHeightForText:(NSString*)txt;

@end
