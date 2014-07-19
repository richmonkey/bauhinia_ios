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
#import "JSMessageTextView.h"


typedef enum
{
  JSInputBarStyleDefault,
  JSInputBarStyleFlat
} JSInputBarStyle;


@protocol JSMessageInputViewDelegate <NSObject>

@optional
- (JSInputBarStyle)inputBarStyle;

@end


@interface JSMessageInputView : UIImageView

@property (strong, nonatomic) JSMessageTextView *textView;
@property (strong, nonatomic) UIButton *sendButton;

#pragma mark - Initialization
- (id)initWithFrame:(CGRect)frame delegate:(id<UITextViewDelegate, JSMessageInputViewDelegate>)delegate;

#pragma mark - Message input view
- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight;

+ (CGFloat)textViewLineHeight;
+ (CGFloat)maxLines;
+ (CGFloat)maxHeight;
+ (JSInputBarStyle)inputBarStyle;

@end