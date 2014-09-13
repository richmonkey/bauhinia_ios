//
//  MessageAudioView.m
//  Message
//
//  Created by 杨朋亮 on 14-9-10.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "MessageAudioView.h"
#import "FileCache.h"
#import "MessageViewController.h"
#import <QuartzCore/QuartzCore.h>


#define kblank 5
#define kMargin 20

#define kAudioCellWidth 210

#define kPlayBtnWidth    26
#define kPlayBtnHeight   27
#define kmicroBtnWidth   14
#define kmicroBtnHeight  21
#define ktimeLabelWidth  60
#define ktimeLabelHeight 20

#define kProgressViewHeight 3



@implementation MessageAudioView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect rect = CGRectMake(kMargin, 0, kPlayBtnWidth, kPlayBtnHeight);
        rect.origin.y = (kAudioViewCellHeight - kPlayBtnHeight  + kblank)/2;
        self.playBtn = [[UIButton alloc] initWithFrame: rect];
        [self.playBtn setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
        [self.playBtn setImage:[UIImage imageNamed:@"PlayPressed"] forState:UIControlStateSelected];

        [self addSubview:self.playBtn];
        rect.origin.x = self.playBtn.frame.origin.x + self.playBtn.frame.size.width;
        rect.origin.y = (kAudioViewCellHeight - kProgressViewHeight  + kblank)/2;
        rect.size.width = kAudioCellWidth - kMargin - kPlayBtnWidth - 2*kblank;
        rect.size.height = kProgressViewHeight;
        self.progressView = [[UIProgressView alloc] initWithFrame:rect];
        [self.progressView setProgressViewStyle:UIProgressViewStyleDefault];
        [self.progressView setBackgroundColor:[UIColor greenColor]];
        self.progressView.progress = 0.0f;
        [self.progressView setTrackTintColor:[UIColor grayColor]];
        [self.progressView setTintColor:[UIColor blueColor]];
        [self addSubview:self.progressView];
        
        rect.size.height = ktimeLabelHeight;
        rect.size.width = ktimeLabelWidth;
        rect.origin.x = self.progressView.frame.origin.x;
        rect.origin.y = kAudioViewCellHeight - ktimeLabelHeight;
        self.timeLengthLabel = [[UILabel alloc] initWithFrame:rect];
        [self.timeLengthLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [self addSubview:self.timeLengthLabel];
        
        rect.origin.x = kAudioCellWidth - kmicroBtnWidth  - kblank;
        rect.origin.y = kAudioViewCellHeight - kmicroBtnHeight - kblank;
        rect.size.width = kmicroBtnWidth;
        rect.size.height = kmicroBtnHeight;
        self.microPhoneBtn = [[UIButton alloc] initWithFrame:rect ];
        [self.microPhoneBtn setImage:[UIImage imageNamed:@"MicBlueIncoming"] forState:UIControlStateNormal];
        [self addSubview:self.microPhoneBtn];
        
    }
    return self;
}

-(void)initializeWithMsg:(IMessage *)msg withType:(BubbleMessageType)type withMsgStateType:(BubbleMessageReceiveStateType)stateType{
    [super setType:type];
    [super setMsgStateType:stateType];
    _msg = msg;
    [self updatePosition];
    
    int minute = self.msg.content.audio.duration/60;
    int second = self.msg.content.audio.duration%60;
    NSString *str = [NSString stringWithFormat:@"%02d:%02d",minute,second];
    [self.timeLengthLabel setText:str];
}


-(void)updatePosition{
    CGSize bubbleSize = CGSizeMake(kAudioCellWidth, kAudioViewCellHeight);
    
    CGRect rect = self.playBtn.frame;
    rect.origin.x = kMargin + floorf(self.type == BubbleMessageTypeOutgoing ? self.frame.size.width - bubbleSize.width  : 0.0f);
     self.playBtn.frame = rect;
    
    rect = self.progressView.frame;
    rect.origin.x = self.playBtn.frame.origin.x + self.playBtn.frame.size.width;
    rect.size.width = kAudioCellWidth - kMargin - kPlayBtnWidth - 2*kblank - 20;
    self.progressView.frame = rect;
    
    rect = self.timeLengthLabel.frame;
    rect.origin.x = self.progressView.frame.origin.x ;
    self.timeLengthLabel.frame = rect;
    
    rect = self.microPhoneBtn.frame;
    rect.origin.x = kAudioCellWidth - kmicroBtnWidth  - kblank + floorf(self.type == BubbleMessageTypeOutgoing ? self.frame.size.width - bubbleSize.width - 20 : 0.0f);
    self.microPhoneBtn.frame = rect;
    
}

-(void)setPlaying:(BOOL)playing {
    if (playing) {
        [self.playBtn setImage:[UIImage imageNamed:@"PauseOS7"] forState:UIControlStateNormal];
        [self.playBtn setImage:[UIImage imageNamed:@"PausePressed"] forState:UIControlStateSelected];
        self.progressView.progress = 0;
    } else {
        [self.playBtn setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
        [self.playBtn setImage:[UIImage imageNamed:@"PlayPressed"] forState:UIControlStateSelected];
        self.progressView.progress = 0.0f;
    }
}

#pragma mark - Drawing
- (CGRect)bubbleFrame{
    
    CGSize bubbleSize = CGSizeMake(kAudioCellWidth, kAudioViewCellHeight);
    return CGRectMake(floorf(self.type == BubbleMessageTypeOutgoing ? self.frame.size.width - bubbleSize.width : 0.0f),
                      floorf(kMarginTop),
                      floorf(bubbleSize.width),
                      floorf(bubbleSize.height));
    
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    UIImage *image = (self.selectedToShowCopyMenu) ? [self bubbleImageHighlighted] : [self bubbleImage];
    CGRect bubbleFrame = [self bubbleFrame];
	[image drawInRect:bubbleFrame];
    [self drawMsgStateSign: rect];
}

@end
