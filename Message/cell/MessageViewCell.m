


#import "MessageViewCell.h"
#import "UIImage+JSMessagesView.h"
#import "MessageTextView.h"
#import "MessageImageView.h"
#import "MessageAudioView.h"
#import "UserPresent.h"

@implementation MessageViewCell

#pragma mark - Setup
- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.accessoryView = nil;
    
    self.imageView.image = nil;
    self.imageView.hidden = YES;
    self.textLabel.text = nil;
    self.textLabel.hidden = YES;
    self.detailTextLabel.text = nil;
    self.detailTextLabel.hidden = YES;
}


-(id)initWithType:(int)type reuseIdentifier:(NSString *)reuseIdentifier {
    self =  [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
        
        CGFloat bubbleY = 0.0f;
        CGFloat bubbleX = 0.0f;
        
        CGFloat offsetX = 0.0f;
        
        CGRect frame = CGRectMake(bubbleX - offsetX,
                                  bubbleY,
                                  self.contentView.frame.size.width - bubbleX,
                                  self.contentView.frame.size.height);
        
        switch (type) {
            case MESSAGE_AUDIO:
            {
                MessageAudioView *audioView = [[MessageAudioView alloc] initWithFrame:frame];
                self.bubbleView = audioView;
            }
                break;
            case MESSAGE_TEXT:
            {
                MessageTextView *textView = [[MessageTextView alloc] initWithFrame:frame];
                self.bubbleView = textView;
            }
                break;
            case MESSAGE_IMAGE:
            {
                MessageImageView *imageView = [[MessageImageView alloc] initWithFrame:frame];
                self.bubbleView = imageView;
            }
                break;
            default:
                self.bubbleView = nil;
                break;
        }
        
        if (self.bubbleView != nil) {
            [self.contentView addSubview:self.bubbleView];
            [self.contentView sendSubviewToBack:self.bubbleView];
            [self setBackgroundColor:[UIColor clearColor]];
        }
    }
    return self;
}

#pragma mark - Message Cell

- (void) setMessage:(IMessage *)message andDelegate:(UIViewController*)del{
    
    self.dgtController = del;
    
    BubbleMessageType msgType;
    if(message.sender == [UserPresent instance].uid){
        msgType = BubbleMessageTypeOutgoing;
    }else{
        msgType = BubbleMessageTypeIncoming;
    }
    BubbleMessageReceiveStateType state;
    if(message.isACK){
        if (message.isPeerACK) {
            state =  BubbleMessageReceiveStateClient;
        }else{
            state =  BubbleMessageReceiveStateServer;
        }
    }else{
        state =  BubbleMessageReceiveStateNone;
    }
    
    switch (message.content.type) {
        case MESSAGE_TEXT:
        {
            MessageTextView *textView = (MessageTextView*)self.bubbleView;
            textView.text = message.content.text;
            textView.type = msgType;
            textView.msgStateType = state;
        }
            break;
        case MESSAGE_IMAGE:
        {
            MessageImageView *msgImageView = (MessageImageView*)self.bubbleView;
            msgImageView.data = message.content.imageURL;
            msgImageView.type = msgType;
            msgImageView.msgStateType = state;
            [msgImageView setDelegte:self.dgtController];
        }
            break;
        case MESSAGE_AUDIO:
        {
            MessageAudioView *audioView = (MessageAudioView*)self.bubbleView;
            [audioView initializeWithMsg:message withType:msgType withMsgStateType:state];
        }
            break;
        default:
            break;
    }
}

@end