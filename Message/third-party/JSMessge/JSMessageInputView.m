//
//  JSMessageInputView.m
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
//
//


#import "JSMessageInputView.h"
#import "JSBubbleView.h"
#import "NSString+JSMessagesView.h"
#import "UIImage+JSMessagesView.h"
#import "UIColor+JSMessagesView.h"

#define SEND_BUTTON_WIDTH 78.0f

static id<JSMessageInputViewDelegate> __delegate;

@interface JSMessageInputView ()

- (void)setup;
- (void)setupTextView;

@end



@implementation JSMessageInputView

@synthesize sendButton;

#pragma mark - Initialization
- (id)initWithFrame:(CGRect)frame delegate:(id<UITextViewDelegate, JSMessageInputViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if(self) {
        __delegate = delegate;
        [self setup];
        self.textView.delegate = delegate;
    }
    return self;
}

+ (JSInputBarStyle)inputBarStyle
{
    if ([__delegate respondsToSelector:@selector(inputBarStyle)])
        return [__delegate inputBarStyle];
    
    return JSInputBarStyleDefault;
}

- (void)dealloc
{
    self.textView = nil;
    self.sendButton = nil;
}

- (BOOL)resignFirstResponder
{
    [self.textView resignFirstResponder];
    return [super resignFirstResponder];
}
#pragma mark - Setup
- (void)setup
{
    self.image = [UIImage inputBar];
    self.backgroundColor = [UIColor whiteColor];
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    self.opaque = YES;
    self.userInteractionEnabled = YES;
    [self setupTextView];
}

- (void)setupTextView
{
    CGFloat width = self.frame.size.width - SEND_BUTTON_WIDTH;
    CGFloat height = [JSMessageInputView textViewLineHeight];
    
    // JeremyStone
    JSInputBarStyle style = [JSMessageInputView inputBarStyle];
    
    if (style == JSInputBarStyleDefault)
    {
        self.textView = [[JSMessageTextView  alloc] initWithFrame:CGRectMake(6.0f, 3.0f, width, height)];
        self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.textView.backgroundColor = [UIColor redColor];
    }
    else
    {
        self.textView = [[JSMessageTextView  alloc] initWithFrame:CGRectMake(8.0f, 6.0f, width, height)];
        self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.textView.backgroundColor = [UIColor clearColor];

        self.textView.layer.borderColor = [[UIColor colorWithWhite:.8 alpha:1.0] CGColor];
        self.textView.layer.borderWidth = 0.65f;
        self.textView.layer.cornerRadius = 6.0f;
    }
    
//    self.textView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
//    self.textView.keyboardAppearance = UIKeyboardAppearanceDefault;
//    self.textView.keyboardType = UIKeyboardTypeDefault;
//    self.textView.returnKeyType = UIReturnKeyDefault;
//    self.textView.scrollEnabled = YES;
//    self.textView.scrollsToTop = NO;
//    self.textView.userInteractionEnabled = YES;
//    self.textView.textColor = [UIColor blackColor];
//    self.textView.font = [JSBubbleView font];
//    self.textView.scrollIndicatorInsets = UIEdgeInsetsMake(10.0f, 0.0f, 10.0f, 0.0f);

    [self addSubview:self.textView];
    
    if (style == JSInputBarStyleDefault)
    {
        UIImageView *inputFieldBack = [[UIImageView alloc] initWithFrame:CGRectMake(self.textView.frame.origin.x - 1.0f,
                                                                                    0.0f,
                                                                                    self.textView.frame.size.width + 2.0f,
                                                                                    self.frame.size.height)];
        inputFieldBack.image = [UIImage inputField];
        inputFieldBack.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        inputFieldBack.backgroundColor = [UIColor clearColor];
        [self addSubview:inputFieldBack];
    }
}

#pragma mark - Setters
- (void)setSendButton:(UIButton *)btn
{
    if(sendButton)
        [sendButton removeFromSuperview];
    
    sendButton = btn;
    [self addSubview:self.sendButton];
}

#pragma mark - Message input view
- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight
{
    CGRect prevFrame = self.textView.frame;
    
    int numLines = MAX([self.textView numberOfLinesOfText],
                       [self.textView.text numberOfLines]);

    NSLog(@"number line == %d",numLines);
    
    self.textView.frame = CGRectMake(prevFrame.origin.x,
                                     prevFrame.origin.y,
                                     prevFrame.size.width,
                                     prevFrame.size.height + changeInHeight);
    
    self.textView.contentInset = UIEdgeInsetsMake((numLines >= 6 ? 4.0f : 0.0f),
                                                  0.0f,
                                                  (numLines >= 6 ? 4.0f : 0.0f),
                                                  0.0f);
    
    self.textView.scrollEnabled = (numLines >= 4);
    
    if(numLines >= 6) {
        CGPoint bottomOffset = CGPointMake(0.0f, self.textView.contentSize.height - self.textView.bounds.size.height);
        [self.textView setContentOffset:bottomOffset animated:YES];
    }
}

+ (CGFloat)textViewLineHeight
{
    return 36.0f; // for fontSize 16.0f
}

+ (CGFloat)maxLines
{
    return 4.0f;
}

+ (CGFloat)maxHeight
{
    return ([JSMessageInputView maxLines] + 1.0f) * [JSMessageInputView textViewLineHeight];
}

@end