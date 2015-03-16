#import "BCTextFrame.h"

@protocol BCTextViewDelegate;
@interface BCTextView : UIView  {
	BCTextFrame *textFrame;
	NSArray *linkHighlights;
    
    id delegate;
    
    UIEdgeInsets contentInset;
    
    NSString* textToSelect;
    BOOL shouldSelectText;
    
}

- (id)initWithHTML:(NSString *)html;

- (void)setFrameWithoutLayout:(CGRect)newFrame;

- (void)handleLongPress:(id)sender;

@property (nonatomic) CGFloat fontSize;
@property (nonatomic, retain) BCTextFrame *textFrame;
@property (nonatomic, assign) id delegate;
@property (nonatomic) UIEdgeInsets contentInset;
@property (nonatomic, copy) NSString* textToSelect;
@property (nonatomic) BOOL shouldSelectText;
@end

@protocol BCTextViewDelegate <NSObject>

@optional
- (void)didClickAtLink:(NSString*)url;
- (void)didClickAtImageLink:(NSString*)url;
- (void)didClickAtURLLink:(NSString*)urlString inBCTextView:(BCTextView*)bcTextView;

- (void)didClickAtNotLinkAreaInBCTextView:(BCTextView*)_bcTxtView;

@end

