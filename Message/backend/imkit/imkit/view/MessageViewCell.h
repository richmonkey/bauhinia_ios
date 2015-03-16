
#import <UIKit/UIKit.h>
#import "BubbleView.h"
#import "IMessage.h"


@interface MessageViewCell : UITableViewCell
{
    
}
@property (strong, nonatomic) BubbleView *bubbleView;
@property (weak, nonatomic) UIViewController *dgtController;

-(id)initWithMessage:(IMessage *)message withBubbleMessageType: (BubbleMessageType)bubbleMessageType reuseIdentifier:(NSString *)reuseIdentifier;

-(void)initializeWithMessage:(IMessage *)message withBubbleMessageType: (BubbleMessageType)bubbleMessageType;

@end