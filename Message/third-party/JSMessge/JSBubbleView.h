//
//  JSBubbleView.h
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


#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

extern CGFloat const kJSAvatarSize;

typedef enum {
    MessageReceiveStateNone = 0,
    MessageReceiveStateServer,
    MessageReceiveStateClient
}MessageReceiveStateType;

typedef enum {
    JSBubbleMessageTypeIncoming = 0,
    JSBubbleMessageTypeOutgoing
} JSBubbleMessageType;

typedef enum {
    JSBubbleMediaTypeText = 0,
    JSBubbleMediaTypeImage,
}JSBubbleMediaType;


@interface JSBubbleView : UIView

@property (assign, nonatomic) JSBubbleMessageType type;
@property (nonatomic,assign) JSBubbleMediaType mediaType;
@property (nonatomic,strong) UIImageView *imageView;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) id data;
@property (assign, nonatomic) BOOL selectedToShowCopyMenu;
@property (nonatomic) MessageReceiveStateType msgStateType;
@property (nonatomic,strong) UIImageView *receiveStateImgSign;
@property (nonatomic) CGRect contentFrame;

#pragma mark - Initialization
- (id)initWithFrame:(CGRect)rect
         bubbleType:(JSBubbleMessageType)bubleType
       messageState:(MessageReceiveStateType)msgState
          mediaType:(JSBubbleMediaType)bubbleMediaType;

#pragma mark - Drawing
- (CGRect)bubbleFrame;
- (UIImage *)bubbleImage;
- (UIImage *)bubbleImageHighlighted;

#pragma mark - Bubble view
+ (UIImage *)bubbleImageForType:(JSBubbleMessageType)aType;

+ (UIFont *)font;

+ (CGSize)textSizeForText:(NSString *)txt;
+ (CGSize)bubbleSizeForText:(NSString *)txt;
+ (CGSize)bubbleSizeForImage:(UIImage *)image;
+ (CGSize)imageSizeForImage;
+ (CGFloat)cellHeightForText:(NSString *)txt;
+ (CGFloat)cellHeightForImage:(UIImage *)image;

+ (int)maxCharactersPerLine;
+ (int)numberOfLinesForMessage:(NSString *)txt;

@end