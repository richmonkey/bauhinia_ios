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

#define kAudioCellWidth 200

#define kHeadViewWidth   40
#define kHeadViewHeight  40
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
        // Initialization code
        
//        [self setBackgroundColor:[UIColor grayColor]];
        
        CGRect rect = CGRectMake(kMargin, 0, kPlayBtnWidth, kPlayBtnHeight);
        rect.origin.y = (kAudioViewCellHeight - kPlayBtnHeight  + kblank)/2;
        self.playBtn = [[UIButton alloc] initWithFrame: rect];
        [self.playBtn setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
        [self.playBtn setImage:[UIImage imageNamed:@"PlayPressed"] forState:UIControlStateSelected];
        
        [self.playBtn addTarget:self action:@selector(AudioAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.playBtn];
        rect.origin.x = self.playBtn.frame.origin.x + self.playBtn.frame.size.width;
        rect.origin.y = (kAudioViewCellHeight - kProgressViewHeight  + kblank)/2;
        rect.size.width = kAudioCellWidth - kMargin - kHeadViewWidth - kPlayBtnWidth - 2*kblank;
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
        [self.timeLengthLabel setText:@"111"];
        
        rect.origin.x = kAudioCellWidth - kHeadViewWidth - kmicroBtnWidth  - kblank;
        rect.origin.y = kAudioViewCellHeight - kmicroBtnHeight - kblank;
        rect.size.width = kmicroBtnWidth;
        rect.size.height = kmicroBtnHeight;
        self.microPhoneBtn = [[UIButton alloc] initWithFrame:rect ];
        [self.microPhoneBtn setImage:[UIImage imageNamed:@"MicBlueIncoming"] forState:UIControlStateNormal];
        [self.microPhoneBtn addTarget:self action:@selector(AudioAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.microPhoneBtn];
       
        rect.origin.x = kAudioCellWidth - kHeadViewWidth - kblank;
        rect.origin.y = (kAudioViewCellHeight - kHeadViewHeight + kblank)/2;
        rect.size.width = kHeadViewWidth;
        rect.size.height = kHeadViewHeight;
        self.headView = [[UIImageView alloc] initWithFrame:rect];
        self.headView.layer.cornerRadius = 4;
        self.headView.layer.masksToBounds = YES;
        [self.headView setImage:[UIImage imageNamed:@"head1"]];
        [self addSubview:self.headView];
        
    }
    return self;
}

-(void)setMsg:(IMessage *)msg{
    _msg = msg;
    
    [self.timeLengthLabel setText:[self getTimeLengthStr:self.msg.content.audio.duration]];
    
}

-(void)AudioAction:(UIButton*)btn{

    if (self.player && [self.player isPlaying]) {
        [self.player stop];
        [self.playBtn setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
        [self.playBtn setImage:[UIImage imageNamed:@"PlayPressed"] forState:UIControlStateSelected];
        if (self.timer && [self.timer isValid]) {
            [self.timer invalidate];
            self.timer = nil;
        }
    }else{
        FileCache *fileCache = [FileCache instance];
        NSString *url = self.msg.content.audio.url;
        NSString *path = [fileCache queryCacheForKey:url];
        if (path != nil) {
            
            [self.playBtn setImage:[UIImage imageNamed:@"PauseOS7"] forState:UIControlStateNormal];
            [self.playBtn setImage:[UIImage imageNamed:@"PausePressed"] forState:UIControlStateSelected];
            
            if (![[self class] isHeadphone]) {
                //打开外放
                UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
                AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
                UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
                AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
            }
            NSURL *u = [NSURL fileURLWithPath:path];
            self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:u error:nil];
            [self.player setDelegate:self];
            
            //设置为与当前音频播放同步的Timer
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
            
            self.progressView.progress = 0;
            
            [self.player play];
        }
    }

}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"player finished");
    [self.playBtn setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
    [self.playBtn setImage:[UIImage imageNamed:@"PlayPressed"] forState:UIControlStateSelected];
    if (self.timer && [self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"player decode error");
}

- (void)updateSlider {
    self.progressView.progress = self.player.currentTime/self.player.duration;
    NSLog(@"%f",self.player.currentTime);
    [self.timeLengthLabel setText:[self getTimeLengthStr:self.player.currentTime*10]];
    [self setNeedsDisplay];
}

+ (BOOL)isHeadphone
{
    UInt32 propertySize = sizeof(CFStringRef);
    CFStringRef route = nil;
    OSStatus error = AudioSessionGetProperty(kAudioSessionProperty_AudioRoute
                                             ,&propertySize,&route);
    //return @"Headphone" or @"Speaker" and so on.
    //根据状态判断是否为耳机状态
    if (!error && (route != NULL) && [(__bridge NSString*)route rangeOfString:@"Head"].location != NSNotFound) {
        return YES;
    }
    else {
        return NO;
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
    // Drawing code
    UIImage *image = (self.selectedToShowCopyMenu) ? [self bubbleImageHighlighted] : [self bubbleImage];
    
    CGRect bubbleFrame = [self bubbleFrame];
	[image drawInRect:bubbleFrame];
    
    [self drawMsgStateSign: rect];
}


-(NSString*)getTimeLengthStr:(int)duration{
    
    int minate = self.msg.content.audio.duration/60;
    int second = self.msg.content.audio.duration%60;
    NSString *returnStr = nil;
    if (minate > 10) {
        if (second > 10) {
            returnStr = [NSString stringWithFormat:@"%d:%d",minate,second];
        }else{
            returnStr = [NSString stringWithFormat:@"%d:0%d",minate,second];
        }
    }else{
        if (second > 10) {
            returnStr = [NSString stringWithFormat:@"0%d:%d",minate,second];
        }else{
            returnStr = [NSString stringWithFormat:@"0%d:0%d",minate,second];
        }
    
    }
    return  returnStr;

}


@end
