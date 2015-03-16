#import <libxml/HTMLparser.h>

#define SINGLELINE_HEIGHT	20
@class BCTextLine;
@protocol BCTextFrameDelegate;


@interface BCTextFrame : NSObject {
	xmlNode *node;
	xmlNode *doc;
	CGFloat fontSize;
	NSMutableArray *lines;
	CGFloat height;
	CGFloat width;
	UIColor *textColor;
	UIColor *linkColor;
	BOOL whitespaceNeeded;
	BOOL indented;
	id delegate;
	NSMutableDictionary *links;
	NSValue *touchingLink;
    BOOL singleLine;
 
	NSNumber* textLengthLimit;
	NSUInteger textLengthCount;
	
    NSMutableArray*     linksInCurrentLine;
}
+ (BCTextFrame*)textFromHTML:(NSString*)source;
- (id)initWithHTML:(NSString *)html;
- (id)initWithXmlNode:(xmlNode *)aNode;
- (void)drawInRect:(CGRect)rect;
- (BOOL)touchBeganAtPoint:(CGPoint)point;
- (BOOL)touchEndedAtPoint:(CGPoint)point;
- (BOOL)touchMovedAtPoint:(CGPoint)point;
- (void)touchCancelled;

- (CGFloat)properWidth;
- (UIImage *)imageForURL:(NSString *)url;

- (void)setTextLengthLimit:(NSNumber*)numbInteger;

@property (nonatomic) CGFloat fontSize;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat width;
@property (nonatomic) BOOL indented;
@property (nonatomic) CGFloat maxWidth;
@property (nonatomic) CGFloat isSendOut;
@property (nonatomic) CGFloat maxValue;
@property (nonatomic, retain) NSMutableDictionary *links;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIColor *linkColor;
@property (nonatomic, assign) id delegate;
@property (nonatomic) BOOL singleLine;
@property (nonatomic, retain) NSMutableArray*     linksInCurrentLine;
@end

@protocol BCTextFrameDelegate
- (void)link:(NSValue *)link touchedInRects:(NSArray *)rects;
- (void)link:(NSValue *)link touchedUpInRects:(NSArray *)rects;

@optional

- (void)noLinkTouchedInBCTextFrame:(BCTextFrame *)_bcTxtFrame;

- (UIImage *)imageForURL:(NSString *)url;

@end

