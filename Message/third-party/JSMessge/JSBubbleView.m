//
//  JSBubbleView.m
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


#import "JSBubbleView.h"
#import "JSMessageInputView.h"
#import "NSString+JSMessagesView.h"
#import "UIImage+JSMessagesView.h"

CGFloat const kJSAvatarSize = 50.0f;

#define kMarginTop 2.0f
#define kMarginBottom 2.0f
#define kPaddingTop 4.0f
#define kPaddingBottom 4.0f
#define kBubblePaddingRight 45.0f

@interface JSBubbleView()

- (void)setup;

+ (UIImage *)bubbleImageTypeIncoming;
+ (UIImage *)bubbleImageTypeOutgoing;

@end



@implementation JSBubbleView

#pragma mark - Setup
- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

#pragma mark - Initialization
- (id)initWithFrame:(CGRect)rect
         bubbleType:(JSBubbleMessageType)bubleType
       messageState:(MessageReceiveStateType)msgState
          mediaType:(JSBubbleMediaType)bubbleMediaType
{
    self = [super initWithFrame:rect];
    if(self) {
        [self setup];
        self.type = bubleType;
        self.mediaType = bubbleMediaType;
        self.msgStateType = msgState;
    }
    return self;
}

- (void)dealloc
{
    self.text = nil;
}

#pragma mark - Setters
- (void)setType:(JSBubbleMessageType)newType
{
    _type = newType;
    [self setNeedsDisplay];
}

- (void) setMsgStateType:(MessageReceiveStateType)type{
    _msgStateType = type;
    [self setNeedsDisplay];
}

- (void)setMediaType:(JSBubbleMediaType)newMediaType{
    _mediaType = newMediaType;
    [self setNeedsDisplay];
}

- (void)setText:(NSString *)newText
{
    _text = newText;
    [self setNeedsDisplay];
}

- (void)setData:(id)newData{
    _data = newData;
    [self setNeedsDisplay];
}

- (void)setSelectedToShowCopyMenu:(BOOL)isSelected{
    _selectedToShowCopyMenu = isSelected;
    [self setNeedsDisplay];
}

#pragma mark - Drawing
- (CGRect)bubbleFrame{
    if(self.mediaType == JSBubbleMediaTypeText){
        CGSize bubbleSize = [JSBubbleView bubbleSizeForText:self.text];
        return CGRectMake(floorf(self.type == JSBubbleMessageTypeOutgoing ? self.frame.size.width - bubbleSize.width : 0.0f),
                          floorf(kMarginTop),
                          floorf(bubbleSize.width),
                          floorf(bubbleSize.height));
    }else if (self.mediaType == JSBubbleMediaTypeImage){
        CGSize bubbleSize = [JSBubbleView imageSizeForImage:(UIImage *)self.data];
        return CGRectMake(floorf(self.type == JSBubbleMessageTypeOutgoing ? self.frame.size.width - bubbleSize.width : 10.0f),
                          floorf(kMarginTop),
                          floorf(bubbleSize.width),
                          floorf(bubbleSize.height));
    }else{
        NSLog(@"act对象消息");
        return CGRectMake(0, 0, 0, 0);
    }
    
}

- (UIImage *)bubbleImage{
    return [JSBubbleView bubbleImageForType:self.type];
}

- (UIImage *)bubbleImageHighlighted{
    return (self.type == JSBubbleMessageTypeIncoming) ? [UIImage bubbleDefaultIncomingSelected] : [UIImage bubbleDefaultOutgoingSelected];
}

- (void)drawRect:(CGRect)frame{
    [super drawRect:frame];
    
	UIImage *image = (self.selectedToShowCopyMenu) ? [self bubbleImageHighlighted] : [self bubbleImage];
    
    CGRect bubbleFrame = [self bubbleFrame];
	[image drawInRect:bubbleFrame];
    
    [self drawMsgStateSign: frame];
    
	if (self.mediaType == JSBubbleMediaTypeText)
	{
        CGSize textSize = [JSBubbleView textSizeForText:self.text];
        
        CGFloat textX = image.leftCapWidth - 3.0f + (self.type == JSBubbleMessageTypeOutgoing ? bubbleFrame.origin.x : 0.0f);
        
        CGRect textFrame = CGRectMake(textX,
                                      kPaddingTop + kMarginTop,
                                      textSize.width,
                                      textSize.height);
        
        if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending){
            UIColor* textColor = [UIColor whiteColor];
            if (self.selectedToShowCopyMenu)
                textColor = [UIColor lightTextColor];
            
            
            NSMutableParagraphStyle* paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            [paragraphStyle setAlignment:NSTextAlignmentLeft];
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            
            NSDictionary* attributes = @{NSFontAttributeName: [JSBubbleView font],
                                         NSParagraphStyleAttributeName: paragraphStyle};
            
            // change the color attribute if we are flat
            if ([JSMessageInputView inputBarStyle] == JSInputBarStyleFlat){
                NSMutableDictionary* dict = [attributes mutableCopy];
                [dict setObject:textColor forKey:NSForegroundColorAttributeName];
                attributes = [NSDictionary dictionaryWithDictionary:dict];
            }
            
            [self.text drawInRect:textFrame
                   withAttributes:attributes];
        }else{
            [self.text drawInRect:textFrame
                         withFont:[JSBubbleView font]
                    lineBreakMode:NSLineBreakByWordWrapping
                        alignment:NSTextAlignmentLeft];
        }
    }else if(self.mediaType == JSBubbleMediaTypeImage){  //media
        
        UIImage *recivedImg = (UIImage *)self.data;
        
		if (recivedImg){
            CGSize imageSize = [JSBubbleView imageSizeForImage:recivedImg];
            CGFloat imgX = image.leftCapWidth - 3.0f + (self.type == JSBubbleMessageTypeOutgoing ? bubbleFrame.origin.x : 0.0f);
            
            CGRect imageFrame = CGRectMake(imgX - 3.f,
                                           kPaddingTop,
                                           imageSize.width - kPaddingTop - kMarginTop,
                                           imageSize.height - kPaddingBottom + 2.f);
            [recivedImg drawInRect:imageFrame];
		}
	}
}

-(void) drawMsgStateSign:(CGRect) frame{
    UIImage *msgSignImg = nil;
    switch (_msgStateType) {
        case MessageReceiveStateNone:
        {
            msgSignImg = [UIImage imageNamed:@"CheckDoubleLight"];
        }
            break;
        case MessageReceiveStateClient:
        {
            msgSignImg = [UIImage imageNamed:@"CheckDoubleGreen"];
        }
            break;
        case MessageReceiveStateServer:
        {
            msgSignImg = [UIImage imageNamed:@"CheckSingleGreen"];
        }
            break;
        default:
            break;
    }
    
    CGFloat imgX = frame.size.width - msgSignImg.size.width;
    CGRect msgStateSignRect = CGRectMake(imgX, frame.size.height -  kPaddingBottom - msgSignImg.size.height, msgSignImg.size.width , msgSignImg.size.height);
    
    [msgSignImg drawInRect:msgStateSignRect];
    
}

#pragma mark - Bubble view
+ (UIImage *)bubbleImageForType:(JSBubbleMessageType)aType
{
    switch (aType) {
        case JSBubbleMessageTypeIncoming:
            return [self bubbleImageTypeIncoming];
            
        case JSBubbleMessageTypeOutgoing:
            return [self bubbleImageTypeOutgoing];
            
        default:
            return nil;
    }
}

+ (UIImage *)bubbleImageTypeIncoming{
    return [UIImage bubbleDefaultIncoming];
}

+ (UIImage *)bubbleImageTypeOutgoing{
    return [UIImage bubbleDefaultOutgoing];
}

+ (UIFont *)font{
    return [UIFont systemFontOfSize:14.0f];
}

+ (CGSize)textSizeForText:(NSString *)txt{
    CGFloat width = [UIScreen mainScreen].applicationFrame.size.width * 0.75f;
    CGFloat height = MAX([JSBubbleView numberOfLinesForMessage:txt],
                         [txt numberOfLines]) * [JSMessageInputView textViewLineHeight];
    
    return [txt sizeWithFont:[JSBubbleView font]
           constrainedToSize:CGSizeMake(width - kJSAvatarSize, height + kJSAvatarSize)
               lineBreakMode:NSLineBreakByWordWrapping];
}

+ (CGSize)bubbleSizeForText:(NSString *)txt
{
	CGSize textSize = [JSBubbleView textSizeForText:txt];
	return CGSizeMake(textSize.width + kBubblePaddingRight,
                      textSize.height + kPaddingTop + kPaddingBottom);
}

+ (CGSize)bubbleSizeForImage:(UIImage *)image{
    CGSize imageSize = [JSBubbleView imageSizeForImage:image];
	return CGSizeMake(imageSize.width,
                      imageSize.height);
}

+ (CGSize)imageSizeForImage:(UIImage *)image{
    CGFloat width = [UIScreen mainScreen].applicationFrame.size.width * 0.75f;
    CGFloat height = 130.f;
    
    return CGSizeMake(width - kJSAvatarSize, height + kJSAvatarSize);
    
}

+ (CGFloat)cellHeightForText:(NSString *)txt
{
    return [JSBubbleView bubbleSizeForText:txt].height + kMarginTop + kMarginBottom;
}

+ (CGFloat)cellHeightForImage:(UIImage *)image{
    return [JSBubbleView bubbleSizeForImage:image].height + kMarginTop + kMarginBottom;
}

+ (int)maxCharactersPerLine
{
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? 34 : 109;
}

+ (int)numberOfLinesForMessage:(NSString *)txt
   {
    return (txt.length / [JSBubbleView maxCharactersPerLine]) + 1;
}

@end