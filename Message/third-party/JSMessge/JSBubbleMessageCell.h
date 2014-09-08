//
//  JSBubbleMessageCell.h
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
#import "JSBubbleView.h"
#import "IMessage.h"


@interface JSBubbleMessageCell : UITableViewCell
{

}

@property (nonatomic, strong) UIImageView *server;

#pragma mark - Initialization
- (id)initWithBubbleType:(JSBubbleMessageType)type
            messageState:(MessageReceiveStateType)msgState
               mediaType:(JSBubbleMediaType)mediaType
         reuseIdentifier:(NSString *)reuseIdentifier;

#pragma mark - Message cell
- (void)setMessage:(NSString *)msg;
- (void)setMedia:(id)data;
- (void)setMessageState:(IMessage *)msg;

+ (CGFloat)neededHeightForText:(NSString *)bubbleViewText;

//+ (CGFloat)neededHeightForImage:(UIImage *)bubbleViewImage;


@end