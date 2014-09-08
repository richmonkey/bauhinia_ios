//
//  JSMessageInputView.h
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

#import <UIKit/UIKit.h>

@interface MessageInputView : UIImageView

@property (nonatomic) UITextView *textView;
@property (nonatomic) UIButton *sendButton;
@property (nonatomic) UIButton *recordButton;
@property (nonatomic) UIButton* mediaButton;

@property (nonatomic) UIView *recordingView;
@property (nonatomic) UILabel *timerLabel;
@property (nonatomic) UILabel *slipLabel;

- (id)initWithFrame:(CGRect)frame;

- (void)slipLabelFrame:(double)x;
- (void)resetLabelFrame;


+ (CGFloat)textViewLineHeight;
+ (CGFloat)maxLines;
+ (CGFloat)maxHeight;

@end