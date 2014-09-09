//
//  MessageImageView.m
//  Message
//
//  Created by houxh on 14-9-9.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "MessageImageView.h"



@implementation MessageImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)setData:(id)newData{
    _data = newData;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)frame{
    [super drawRect:frame];
    
	UIImage *image = (self.selectedToShowCopyMenu) ? [self bubbleImageHighlighted] : [self bubbleImage];
    
    CGRect bubbleFrame = [self bubbleFrame];
	[image drawInRect:bubbleFrame];
    
    [self drawMsgStateSign: frame];
        
    if (!self.imageView) {
        self.imageView = [[UIImageView alloc] init];
        CGSize imageSize = CGSizeMake(125, 125);
        CGFloat imgX = image.leftCapWidth - 3.0f + (self.type == BubbleMessageTypeOutgoing ? bubbleFrame.origin.x : 0.0f);
        
        CGRect imageFrame = CGRectMake(imgX - 3.f,
                                       kPaddingTop,
                                       imageSize.width - kPaddingTop - kMarginTop,
                                       imageSize.height - kPaddingBottom + 2.f);
        [self.imageView setFrame:imageFrame];
        [self addSubview:self.imageView];
    }
    
    if (self.data) {
        [self.imageView setImageWithURL:[[NSURL alloc] initWithString:self.data] placeholderImage:[UIImage imageNamed:@"GroupChatRound"]];
    }
}


#pragma mark - Drawing
- (CGRect)bubbleFrame {
    CGSize bubbleSize = [BubbleView imageSizeForImage];
    return CGRectMake(floorf(self.type == BubbleMessageTypeOutgoing ? self.frame.size.width - bubbleSize.width : 10.0f),
                      floorf(kMarginTop),
                      floorf(bubbleSize.width),
                      floorf(bubbleSize.height));
    
}

@end
