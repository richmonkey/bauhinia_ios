//
//  MessageImageView.h
//  Message
//
//  Created by houxh on 14-9-9.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BubbleView.h"
#import "IMessage.h"

#define  kMessageImagViewHeight 120

@interface MessageImageView : BubbleView

@property (weak, nonatomic) UIViewController *dgtController;
@property (nonatomic) UIImageView *imageView;

@property (nonatomic) id data;

- (id)initWithFrame:(CGRect)frame withType:(BubbleMessageType)type;
-(void)initializeWithMsg:(IMessage *)msg withMsgStateType:(BubbleMessageReceiveStateType)stateType;
-(void) setUploading:(BOOL)uploading;

@end
