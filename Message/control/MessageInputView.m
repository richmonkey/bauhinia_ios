
#import "MessageInputView.h"
#import "NSString+JSMessagesView.h"
#import "UIImage+JSMessagesView.h"

#define SEND_BUTTON_WIDTH 70.0f

#define INPUT_HEIGHT 46.0f

@interface MessageInputView ()

- (void)setup;
- (void)setupTextView;

@end



@implementation MessageInputView

#pragma mark - Initialization
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        [self setup];
    }
    return self;
}

- (void)dealloc
{
    self.textView = nil;
    self.sendButton = nil;
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
    
    {
        self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
        CGRect frame = self.frame;
        double x = frame.size.width - 60.0;
        double y = (frame.size.height - 26.0)/2;
        double width = 60.0;
        double height = 26.0;
        self.sendButton.enabled = NO;
        self.sendButton.frame = CGRectMake(x, y, width, height);
        self.sendButton.hidden = YES;
        NSString *title = @"发送";
        [self.sendButton setTitle:title forState:UIControlStateNormal];
        [self.sendButton setTitle:title forState:UIControlStateHighlighted];
        [self.sendButton setTitle:title forState:UIControlStateDisabled];
        self.sendButton.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin);
        
        [self addSubview:self.sendButton];
    }

    {
        self.recordButton = [UIButton buttonWithType:UIButtonTypeSystem];
        
        CGRect frame = self.frame;
        double x = frame.size.width - 60.0;
        double y = (frame.size.height - 26.0)/2;
        double width = 60.0;
        double height = 26.0;

        self.recordButton.enabled = NO;
        self.recordButton.frame = CGRectMake(x, y, width, height);
        
        NSString *title = @"录音";
        [self.recordButton setTitle:title forState:UIControlStateNormal];
        [self.recordButton setTitle:title forState:UIControlStateHighlighted];
        [self.recordButton setTitle:title forState:UIControlStateDisabled];
        self.recordButton.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin);
        
        [self addSubview:self.recordButton];
    }

    {
        // set up the image and button frame
		UIImage* image = [UIImage imageNamed:@"PhotoIcon"];
        CGRect frame = self.frame;
		CGRect buttonFrame = CGRectMake(4, 0, image.size.width, image.size.height);
		CGFloat yHeight = (frame.size.height - buttonFrame.size.height) / 2.0f;
		buttonFrame.origin.y = yHeight;
		
		// make the button
		self.mediaButton = [[UIButton alloc] initWithFrame:buttonFrame];
		[self.mediaButton setBackgroundImage:image forState:UIControlStateNormal];
		[self addSubview:self.mediaButton];
    }

    {
        CGRect frame = self.frame;
        CGRect viewFrame = self.frame;
        viewFrame = CGRectMake(0, 0, frame.size.width-60, frame.size.height);
        self.recordingView = [[UIView alloc] initWithFrame:viewFrame];

        
        CGRect labelFrame = CGRectMake(100, 0, 160, 26);
        labelFrame.origin.y = (frame.size.height - labelFrame.size.height)/2;
        self.slipLabel = [[UILabel alloc] initWithFrame:labelFrame];
        [self.slipLabel setFont:[UIFont systemFontOfSize:15.0f]];
        self.slipLabel.text = @"滑动取消 <";
        [self.recordingView addSubview:self.slipLabel];
        
        CGRect maskFrame = CGRectMake(0, 0, 70, frame.size.height);
        UIImageView *maskView = [[UIImageView alloc] initWithImage:[UIImage inputBar]];
        maskView.frame = maskFrame;
        [self.recordingView addSubview:maskView];
        
        labelFrame = CGRectMake(8, 0, 60, 26);
        labelFrame.origin.y = (frame.size.height - labelFrame.size.height)/2;
        self.timerLabel = [[UILabel alloc] initWithFrame:labelFrame];
        [self.recordingView addSubview:self.timerLabel];
        
        [self addSubview:self.recordingView];
        self.recordingView.hidden = YES;
    }
}

- (void)slipLabelFrame:(double)x {
    CGRect frame = self.frame;
    CGRect labelFrame = CGRectMake(100, 0, 160, 26);
    labelFrame.origin.y = (frame.size.height - labelFrame.size.height)/2;
    labelFrame.origin.x += x;
    self.slipLabel.frame = labelFrame;
}

- (void)resetLabelFrame {
    CGRect frame = self.frame;
    CGRect labelFrame = CGRectMake(100, 0, 160, 26);
    labelFrame.origin.y = (frame.size.height - labelFrame.size.height)/2;
    self.slipLabel.frame = labelFrame;
}

- (void)setupTextView
{
    CGFloat width = self.frame.size.width - SEND_BUTTON_WIDTH - 26;
    CGFloat height = [MessageInputView textViewLineHeight];
    CGRect frame = self.frame;
    
    double x = 34.0;
    double y = (frame.size.height - height)/2;

    
    self.textView = [[UITextView  alloc] initWithFrame:CGRectMake(x, y, width, height)];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textView.backgroundColor = [UIColor clearColor];
    [self.textView setFont:[UIFont systemFontOfSize:16]];
    self.textView.layer.borderColor = [[UIColor colorWithWhite:.8 alpha:1.0] CGColor];
    self.textView.layer.borderWidth = 0.65f;
    self.textView.layer.cornerRadius = 6.0f;


    [self addSubview:self.textView];
}


#pragma mark - Message input view
+ (CGFloat)textViewLineHeight
{
    return 30.0f; // for fontSize 16.0f
}

+ (CGFloat)maxLines
{
    return 4.0f;
}

+ (CGFloat)maxHeight
{
    return ([MessageInputView maxLines] + 1.0f) * [MessageInputView textViewLineHeight];
}

@end