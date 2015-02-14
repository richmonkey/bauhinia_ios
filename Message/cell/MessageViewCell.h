
#import <UIKit/UIKit.h>
#import "BubbleView.h"
#import "IMessage.h"



@interface MessageViewCell : UITableViewCell
{
    
}
@property (strong, nonatomic) BubbleView *bubbleView;
@property (weak, nonatomic) UIViewController *dgtController;

-(id)initWithType:(int)type reuseIdentifier:(NSString *)reuseIdentifier;

- (void) setMessage:(IMessage *)message;
- (void) copy:(id)sender;
- (void) handleMenuWillHideNotification:(NSNotification *)notification;
- (void) handleMenuWillShowNotification:(NSNotification *)notification;
@end