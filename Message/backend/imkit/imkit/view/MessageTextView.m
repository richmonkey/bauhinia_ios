//
//  MessageTextView.m
//  Message
//
//  Created by houxh on 14-9-9.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "MessageTextView.h"
#import "Constants.h"
#import "StringUtil.h"

@implementation MessageTextView

- (id)initWithFrame:(CGRect)frame withType:(BubbleMessageType)type
{
    self = [super initWithFrame:frame withType:type];
    if (self) {

    }
    return self;
}

-(void)initializeWithMsg:(IMessage *)msg withMsgStateType:(BubbleMessageReceiveStateType)stateType{
    _text = [StringUtil runsForString:msg.content.text];
    
    CGSize textSize = [BubbleView textSizeForText:msg.content.text];
    
    BCTextFrame* textFrame = [[BCTextFrame alloc] initWithHTML:msg.content.text];
    textFrame.fontSize = 14.0;
    textFrame.width = textSize.width;
    
    CGFloat textX =  (self.type == BubbleMessageTypeOutgoing ? super.bubleBKView.frame.origin.x : 0.0f);
    CGRect textRect = CGRectMake(textX,
                                   0,
                                  textSize.width,
                                  textFrame.height + kMarginBottom);
    
    self.bcTextView = [[BCTextView alloc] initWithHTML:_text];
    self.bcTextView.backgroundColor = RGBACOLOR(100, 100, 100, 0);
    self.bcTextView.fontSize = 14.0f;
    self.bcTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self addSubview:self.bcTextView];
    [self.bcTextView setFrame:textRect];
    
    CGSize bubbleSize =
    CGSizeMake(self.bcTextView.frame.size.width + kBubblePaddingRight,
               self.bcTextView.frame.size.height);
    
    [self.bubleBKView setFrame:  CGRectMake(self.type == BubbleMessageTypeOutgoing ? self.frame.size.width - bubbleSize.width : 0.0f,
                                            0,
                                            bubbleSize.width,
                                             kPaddingTop+bubbleSize.height+kPaddingBottom+kMarginBottom)];
    
    textX = super.bubleBKView.image.leftCapWidth  + (self.type == BubbleMessageTypeOutgoing ? super.bubleBKView.frame.origin.x : 0.0f);
    
     textRect = CGRectMake(textX,
                              kPaddingTop,
                           textSize.width,
                           textSize.height+kPaddingTop);
    [self.bcTextView setFrame:textRect];
   
    
    [self setMsgStateType:stateType];
}

#pragma mark - Drawing
- (CGRect)bubbleFrame{

    CGSize bubbleSize =
    CGSizeMake(self.bcTextView.frame.size.width + kBubblePaddingRight,
               self.bcTextView.frame.size.height);
    return CGRectMake(self.type == BubbleMessageTypeOutgoing ? self.frame.size.width - bubbleSize.width : 0.0f,
                      0,
                      bubbleSize.width,
                      kPaddingTop+bubbleSize.height+ kMarginBottom + kPaddingBottom);
    
}

+(float) cellHeightForText:(NSString*)txt{
    
    CGSize textSize = [BubbleView textSizeForText:txt];
    
    BCTextFrame* textFrame = [[BCTextFrame alloc] initWithHTML:txt];
    textFrame.fontSize = 14.0;
    textFrame.width = textSize.width;
    
    return kPaddingTop+textFrame.height+ kMarginBottom + kPaddingBottom;
}


@end
