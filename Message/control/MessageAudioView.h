//
//  MessageAudioView.h
//  Message
//
//  Created by 杨朋亮 on 14-9-10.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "BubbleView.h"
#import <AVFoundation/AVFoundation.h>
#import "IMessage.h"

#define kAudioViewCellHeight 58 

@interface MessageAudioView : BubbleView <AVAudioPlayerDelegate>

@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIButton *microPhoneBtn;
@property (nonatomic, strong) UIImageView *headView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *timeLengthLabel;
@property (nonatomic, strong) UILabel *createTimeLabel;
@property (nonatomic, strong) NSTimer *timer;//监控音频播放进度

@property (nonatomic ,strong) IMessage *msg;

@property(nonatomic) AVAudioPlayer *player;

-(void)initializeWithMsg:(IMessage *)msg withType:(BubbleMessageType)type withMsgStateType:(BubbleMessageReceiveStateType)stateType;

@end
