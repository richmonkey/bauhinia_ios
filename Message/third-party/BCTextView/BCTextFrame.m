#import "BCTextFrame.h"
#import "BCTextLine.h"
#import "BCTextNode.h"
#import "BCImageNode.h"
#import "BCBlockBorder.h"
#import <CoreText/CoreText.h>


typedef enum {
	BCTextNodePlain = 0,
	BCTextNodeBold = 1,
	BCTextNodeItalic = 1 << 1,
	BCTextNodeLink = 1 << 2,
} BCTextNodeAttributes;

@interface BCTextFrame ()
- (UIFont *)fontWithAttributes:(BCTextNodeAttributes)attr;

@property (nonatomic, retain) NSMutableArray *lines;
@property (nonatomic, retain) BCTextLine *currentLine;
@end

@implementation BCTextFrame
@synthesize fontSize, height, width, lines, textColor, linkColor, delegate, indented, links, singleLine, linksInCurrentLine,maxValue,maxWidth,isSendOut;

- (id)init {
	if ((self = [super init])) {
		self.linkColor = RGBCOLOR(0, 112, 191);
	}
	
	return self;
}

+ (BCTextFrame*)textFromHTML:(NSString*)source {
    return [[[[self class] alloc] initWithHTML:source] autorelease];
}

- (id)initWithHTML:(NSString *)html {
    if (NULL == html) {
        html = @"";
    }
    
	textLengthLimit = NULL;
	textLengthCount = 0;
	
	if ((self = [self init])) {
		CFStringEncoding cfenc = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
		CFStringRef cfencstr = CFStringConvertEncodingToIANACharSetName(cfenc);
		const char *enc = CFStringGetCStringPtr(cfencstr, 0);
		// let's set our xml doc to doc because we don't want to free node
		// (which we didn't alloc) but we want to free a doc we alloced
		doc = node = (xmlNode *)htmlReadDoc((xmlChar *)[html UTF8String],
									   "",
									   enc,
									   XML_PARSE_NOERROR | XML_PARSE_NOWARNING);
	}
	
	return self;
}


- (id)initWithXmlNode:(xmlNode *)aNode {
	
	textLengthLimit = NULL;
	textLengthCount = 0;
	
	if ((self = [self init])) {
		node = aNode;
	}
	
	return self;
}

- (BOOL)touchBeganAtPoint:(CGPoint)point {
	for (NSValue *link in self.links) {
		NSArray *rects = [self.links objectForKey:link];
		for (NSValue *v in rects) {
			if (CGRectContainsPoint([v CGRectValue], point)) {
				touchingLink = link;
				if ([(NSObject *)self.delegate respondsToSelector:@selector(link: touchedInRects:)])
					[self.delegate link:link touchedInRects:rects];
				return YES;
			}
		}
	}
    return NO;
}

- (BOOL)touchEndedAtPoint:(CGPoint)point {
	if (touchingLink) {
		NSArray *rects = [self.links objectForKey:touchingLink];
		for (NSValue *v in rects) {
			if (CGRectContainsPoint([v CGRectValue], point)) {
				if ([(NSObject *)self.delegate respondsToSelector:@selector(link: touchedUpInRects:)])
                {
                    BOOL isFind = NO;
                    for (BCTextLine *line in self.lines) 
                    {
                        if (!isFind) 
                        {
                            for (BCNode *n in line.stack) 
                            {
                                
                                if (n.src == touchingLink) 
                                {
                                    
                                    NSString *url = (NSString *)touchingLink;
                                    NSString* imageName = [[url pathComponents] lastObject];
                                    
                                    NSString *strPicName = [imageName substringWithRange:NSMakeRange(2, imageName.length - 4)];
                                    
                                    if (!strPicName || !strPicName.length)
                                    {
                                        isFind = YES;
                                        break;
                                    }
                                    

                                    isFind = YES;
                                    break;
                                }
                            }                            
                        }
                    }

                    [self.delegate link:touchingLink touchedUpInRects:rects];
                }

				touchingLink = nil;
                return YES;
			}
		}
	}

    if(YES == [self.delegate respondsToSelector:@selector(noLinkTouchedInBCTextFrame:)]){
        [self.delegate noLinkTouchedInBCTextFrame:self];
    }

	touchingLink = nil;
    return NO;
}

- (BOOL)touchMovedAtPoint:(CGPoint)point {
    if (touchingLink) {
        NSArray *rects = [self.links objectForKey:touchingLink];
        BOOL containPoint = NO;
        for (NSValue *v in rects) {
			if (CGRectContainsPoint([v CGRectValue], point)) {
				containPoint = YES;
                break;
			}
		}
        
        if (!containPoint) {
            if ([(NSObject *)self.delegate respondsToSelector:@selector(link: touchedUpInRects:)])
                [self.delegate link:touchingLink touchedUpInRects:rects];
            
            touchingLink = nil;
            return YES;
        }
    }
    return NO;
}

- (void)touchCancelled {
	touchingLink = nil;
}

- (void)layoutLinksInCurrentLine {
    if (NULL == linksInCurrentLine) {
        return;
    }
    
    for (NSValue* link in linksInCurrentLine) {
        BCTextLine* currentLine = self.currentLine;
        NSMutableArray *linkRectValues = [self.links objectForKey:link];
        for (int i = 0; i < linkRectValues.count; i++) {
            NSValue* linkRectValue = [linkRectValues objectAtIndex:i];
            CGRect linkRect = [linkRectValue CGRectValue];
            
            //当前行的link
            if ((NSInteger)linkRect.origin.y == (NSInteger)currentLine.y && currentLine.height > linkRect.size.height) {
                linkRect.origin.y += currentLine.height / 2 - linkRect.size.height / 2;
                [linkRectValues replaceObjectAtIndex:i withObject:[NSValue valueWithCGRect:linkRect]];
            }
        }
    }
    [linksInCurrentLine removeAllObjects];
}

- (void)pushNewline:(BCTextLine *)line {
	line.indented = self.indented;
	if (0 == self.currentLine.height) {
		self.currentLine.height = self.fontSize;
	}
	self.currentLine = line;
}

- (void)pushNewline {
    //插入新行时,对上一行的链接位置进行调整
    [self layoutLinksInCurrentLine];
    
	[self pushNewline:[[[BCTextLine alloc] initWithWidth:self.width] autorelease]];
}

- (void)addLink:(NSValue *)link forRect:(CGRect)rect {
	NSMutableArray *a = [self.links objectForKey:link];
	if (NULL == a) {
		a = [NSMutableArray array];
		[self.links setObject:a forKey:link];
	}
	
	[a addObject:[NSValue valueWithCGRect:rect]];
    
    //保存当前行的link
    [linksInCurrentLine addObject:link];
}

- (void)pushText:(NSString *)text withFont:(UIFont *)font link:(NSValue *)link {
    CGSize size = [text sizeWithFont:font];

	if (size.width > self.currentLine.widthRemaining) {
		NSRange spaceRange = [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
		

		// a word that needs to wrap
		if (spaceRange.location == NSNotFound || spaceRange.location == text.length - 1) {
            if (self.currentLine.widthRemaining < fontSize) {
                [self pushNewline];
            }
			
			if (size.width > self.currentLine.widthRemaining)
            {
                // word is too long even for its own line
                NSInteger length = 0;
                NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:text];
                
                CTFontRef aFont = CTFontCreateWithName((CFStringRef)font.familyName, fontSize, NULL);
                [attributedString addAttribute:(NSString*)kCTFontAttributeName value:(id)aFont range:NSMakeRange(0, text.length)];
                
                CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
                length = CTTypesetterSuggestLineBreak(typesetter, 0, self.currentLine.widthRemaining);
                [attributedString release];
                CFRelease(aFont);
                CFRelease(typesetter);
    
                NSString *firstPart = [text substringToIndex:length];
                NSInteger oldlen = length;

                size = [firstPart sizeWithFont:font];
                
                
                if ((size.width > self.currentLine.widthRemaining) && self.currentLine.widthRemaining > 0)
                {
                    //字符串转char
                    const char *cText = [text UTF8String];
                    NSInteger widthTotal = 0;
                    
                    //NSString* logStr = @"sizeChar:";
                    for (length = 0; length < [text length]; length++)
                    {
                        //取单个字符的宽度
                        char c = cText[length];
                        NSString *strChar = [NSString stringWithFormat:@"%c",c];
                        CGSize sizeChar = [strChar sizeWithFont:font];
                        //计算总宽度
                        widthTotal += sizeChar.width;

                        if (widthTotal > self.currentLine.width)
                        {
                            //超出范围则跳出
                            break;
                        }
                    }
                    //NSLog(@"logStr=%@", logStr);
                    //重新获取字符串
                    if (length > oldlen)
                        length = oldlen;
                    firstPart = [text substringToIndex:length];

                    size = [firstPart sizeWithFont:font];
                }
                
                BCTextNode *n = [[[BCTextNode alloc] initWithText:firstPart
															 font:font
															width:size.width
														   height:size.height
															 link:link != nil]
								 autorelease];
                if (NULL != link) {
                    [self addLink:link forRect:CGRectMake((self.currentLine.width - self.currentLine.widthRemaining) - 2, 
                                                          self.currentLine.y, 
                                                          n.width + 4, n.height)];
                }
                [self.currentLine addNode:n height:size.height];
                
                if (length < text.length) {
                    [self pushNewline]; //断句后插入新行, 防止单词被截断
                    [self pushText:[text substringFromIndex:length]
						  withFont:font
							  link:link];
                }
			} else {
				[self pushText:text withFont:font link:link];
			}
		} else {
			[self pushText:[text substringWithRange:NSMakeRange(0, spaceRange.location + 1)]
				  withFont:font
					  link:link];
			[self pushText:[text substringWithRange:NSMakeRange(spaceRange.location + 1, text.length - (spaceRange.location + 1))]
				  withFont:font
					  link:link];
		}
	} else {
               
		BCTextNode *n = [[[BCTextNode alloc] initWithText:text
													 font:font
													width:size.width
												   height:size.height
													 link:link != nil]
						 autorelease];
		
		if (NULL != link) {
			[self addLink:link forRect:CGRectMake((self.currentLine.width - self.currentLine.widthRemaining) - 2, 
												  self.currentLine.y, 
												  n.width + 4, n.height)];
		}
		[self.currentLine addNode:n height:size.height];
	}
}

    //暂时没有用到
- (void)pushImage:(NSString *)src linkTarget:(NSValue *)link {

	
}

//显示图片，如果没有图片则返回字符串显示
- (NSString*)pushImage:(xmlNode*)curNode link:(NSValue *)link {

    return nil;
}

- (void)pushBlockBorder {
	[self pushNewline:[[[BCBlockBorder alloc] initWithWidth:self.width] autorelease]];
}

//|| *str == '\r'
- (NSString *)stripWhitespace:(char *)str {
	char *stripped = malloc(strlen(str) + 1);
	int i = 0;
	for (; *str != '\0'; str++) {
		if (*str == ' ' || *str == '\t' || *str == '\n') {
			if (whitespaceNeeded) {
				stripped[i++] = ' ';
				whitespaceNeeded = NO;
			}
		} else {
			whitespaceNeeded = YES;
			stripped[i++] = *str;
		}
	}
	stripped[i] = '\0';
	NSString *strippedString = [NSString stringWithUTF8String:stripped];
	free(stripped);
	return strippedString;
}

- (void)layoutNode: (xmlNode *)n
		attributes: (BCTextNodeAttributes)attr
		linkTarget: (NSValue *)link {
    
    //NSLog(@"here is layoutNode");
    
	if (NULL == n){
		return;
	}
	
	NSUInteger _txtLenLimit = 0;
	if(NULL != textLengthLimit){
		_txtLenLimit = [textLengthLimit unsignedIntegerValue];
	}else{
		_txtLenLimit = INT_MAX;
	}
    
	BOOL bTextLengthOverflow = NO;
	UIFont *textFont = [self fontWithAttributes:attr];
	for (xmlNode *curNode = n; NULL != curNode; curNode = curNode->next) {
        

        if(textLengthCount >= _txtLenLimit){

            break;
        }
        
		if (curNode->type == XML_TEXT_NODE) {
            //UIFont *textFont = [self fontWithAttributes:attr];
			
			NSString *text = [self stripWhitespace:(char *)curNode->content];
//            text = @"ios新版本版本  功能待排\r\n\
//            1、高端阅读\r\n\
//            2、初始化增加广告图";
            NSArray *arrText = [text componentsSeparatedByString:@"\r"];
           
			if (1 == [arrText count] || 0 == [arrText count]) {
				arrText = [NSArray arrayWithObject:text];
			}
			
			for (NSString *subText in arrText) {
				//NSLog(@"subText (link %x): %@", link, subText);
				NSUInteger iTextSpace = _txtLenLimit - textLengthCount;
				NSUInteger iTextLength = [subText length];
				NSString* _pushTxt = NULL;
				if(iTextLength <= iTextSpace){
                    
					_pushTxt = subText;
					textLengthCount += (iTextLength);
            
					[self pushText: _pushTxt
						  withFont: textFont
							  link: link];
					
					if(1 < [arrText count]){
                        [self pushNewline];
					}
					
					if(textLengthCount == _txtLenLimit){
						bTextLengthOverflow = YES;
						break;
					}
					
				}else{

                    
                    BOOL bCutOff = YES;
                    if (NULL != curNode->name) {
                        if (!strcmp((char *)curNode->name, "text")) {
                            if(YES == [subText hasPrefix:@"@"] && NULL != link){
                                bCutOff = NO;
                            }
                        }
                    }
                    
                    if(YES == bCutOff){
                        NSRange r;
                        r.length = iTextSpace;
                        r.location = 0;
                        _pushTxt = [subText substringWithRange: r];

                    }else{
                        _pushTxt = subText;
                    }
                    textLengthCount += (iTextSpace);
 
					[self pushText: _pushTxt
						  withFont: textFont
							  link: link];
                    
                    if(1 < [arrText count]){
                        [self pushNewline];
					}
					
					bTextLengthOverflow = YES;
					break;
				}
			}
            
            if(YES == bTextLengthOverflow){
                break;
            }

		} else { 
            
			BCTextNodeAttributes childrenAttr = attr;
			
			if (NULL != curNode->name) {
				if (!strcmp((char *)curNode->name, "b")) {
                    //NSLog(@"find nodename b");
					childrenAttr |= BCTextNodeBold;
                    
				} else if (!strcmp((char *)curNode->name, "i")) {
                    //NSLog(@"find nodename i");
					childrenAttr |= BCTextNodeItalic;
                    
				} else if (!strcmp((char *)curNode->name, "a")) {
                    //NSLog(@"find nodename a");
					childrenAttr |= BCTextNodeLink;
                    
                    //NSLog(@"go to layoutNode");
					[self layoutNode:curNode->children
						  attributes:childrenAttr
						  linkTarget:[NSValue valueWithPointer:curNode]
					 ];
					continue;
                    
				} else if (!strcmp((char *)curNode->name, "br")) {
                    //NSLog(@"find nodename br");
					[self pushNewline];
					whitespaceNeeded = NO;
                    
				} else if (!strcmp((char *)curNode->name, "h4")) {
                    //NSLog(@"find nodename h4");
					childrenAttr |= (BCTextNodeBold | BCTextNodeItalic);
                    
                    //NSLog(@"go to layoutNode");
					[self layoutNode:curNode->children
						  attributes:childrenAttr
						  linkTarget:link];
					[self pushNewline];
					whitespaceNeeded = NO;
					continue;
                    
				} else if (!strcmp((char *)curNode->name, "p")) {
                    //NSLog(@"find nodename p");
					char *class = (char *)xmlGetProp(curNode, (xmlChar *)"class");
					if (NULL != class) {
						free(class);
					}
				} else if (!strcmp((char *)curNode->name, "div")) {
                    //NSLog(@"find nodename div");
					char *class =(char *)xmlGetProp(curNode, (xmlChar *)"class");
					if (NULL != class) {
						if (!strcmp(class, "bbc-block")) {
							[self pushBlockBorder];
							self.indented = YES;
							[self pushNewline];
                            
                            //NSLog(@"go to layoutNode");
							[self layoutNode:curNode->children
								  attributes:childrenAttr
								  linkTarget:link];
							self.indented = NO;
							[self.lines removeLastObject];
							[self pushBlockBorder];
                            
							[self pushNewline];
							whitespaceNeeded = NO;
							free(class);
							continue;
						} else {
							free(class);
						}
					} 
				} else if (!strcmp((char *)curNode->name, "img")) {
                    //NSLog(@"find nodename img");
                    NSString* text =  [self pushImage:curNode link:link];
                    if (NULL != text && [text length] > 0)
                    {
                        //返回字符串则用text模式显示
                        UIFont *textFont = [self fontWithAttributes:attr];
                        [self pushText:text
                              withFont:textFont
                                  link:link];
                        
                        textLengthCount += (1);

                        if(textLengthCount >= _txtLenLimit){
                            bTextLengthOverflow = YES;
                            break;
                        }
                    }
				}
			}

            //NSLog(@"go to layoutNode");
			[self layoutNode: curNode->children
				  attributes: childrenAttr
				  linkTarget: link];
		}
	}
    
    if(YES == bTextLengthOverflow){
        UIFont* fntExt = NULL;
        if( self.fontSize - 1 > 0){
            fntExt = [UIFont fontWithName:@"Helvetica-Oblique" size:self.fontSize-1];
        }else{
            fntExt = [UIFont fontWithName:@"Helvetica-Oblique" size:self.fontSize];
        }
        [self pushText: @" ...继续阅读"
              withFont: fntExt
                  link: NULL
         ];
    }
}

- (void)drawInRect:(CGRect)rect {
	for (BCTextLine *line in self.lines) {
		if (line.y > rect.size.height) {
			return;
		}
		
		[line drawAtPoint:CGPointMake(rect.origin.x, rect.origin.y + line.y) textColor:self.textColor linkColor:self.linkColor];
        if (singleLine) {
            break;
        }
	}
}

- (BCTextLine *)currentLine {
	return [self.lines lastObject];
}

- (void)setCurrentLine:(BCTextLine *)aLine {
	aLine.y = self.currentLine.y + self.currentLine.height;
	[self.lines addObject:aLine];
}

- (void)setTextLengthLimit:(NSNumber*)numbInteger{
	if(NULL != textLengthLimit){
		[textLengthLimit release];
		textLengthLimit = NULL;
	}
	
	if(NULL != numbInteger){
		textLengthLimit = [numbInteger retain];
	}
}

- (void)setWidth:(CGFloat)aWidth {
	textLengthCount = 0;
	
	self.links = [NSMutableDictionary dictionary];
	width = aWidth;
	self.lines = [NSMutableArray array];
    self.linksInCurrentLine = [NSMutableArray array];
	self.currentLine = [[[BCTextLine alloc] initWithWidth:width] autorelease];
    //NSLog(@"go to layoutNode");
	[self layoutNode: node
		  attributes: BCTextNodePlain
		  linkTarget: nil];
	height = self.currentLine.y + self.currentLine.height;
    
    //调整最后一行
    [self layoutLinksInCurrentLine];
}

- (void)dealloc {
	if (NULL != doc){
		xmlFreeDoc((xmlDoc *)doc);
	}
	node = NULL;
	self.links = nil;
	self.textColor = nil;
	self.linkColor = nil;
	self.lines = nil;
	self.currentLine = nil;
    self.linksInCurrentLine = nil;
	if(NULL != textLengthLimit){
		[textLengthLimit release];
		textLengthLimit = NULL;
	}
	[super dealloc];
}

- (CGFloat)fontSize {
	if (!fontSize) {
		fontSize = 12;
	}
	return fontSize;
}

- (UIFont *)regularFont {
	return [UIFont fontWithName:@"Helvetica" size:self.fontSize];
}

- (UIFont *)boldFont {
	return [UIFont fontWithName:@"Helvetica-Bold" size:self.fontSize];
}

- (UIFont *)italicFont {
	return [UIFont fontWithName:@"Helvetica-Oblique" size:self.fontSize];
}

- (UIFont *)boldItalicFont {
	return [UIFont fontWithName:@"Helvetica-BoldOblique" size:self.fontSize];
}

- (UIFont *)fontWithAttributes:(BCTextNodeAttributes)attr {
	if (attr & BCTextNodeItalic && attr & BCTextNodeBold) {
		return [self boldItalicFont];
	} else if (attr & BCTextNodeItalic) {
		return [self italicFont];
	} else if (attr & BCTextNodeBold) {
		return [self boldFont];
	} else {
		return [self regularFont];
	}
}

- (CGFloat)properWidth {
    if (self.lines.count != 1) {
        return self.width;
        //return maxValue;
    }
    //NSLog(@"properWidth = %4.1f,self.currentLine.width = %4.1f,self.currentLine.widthRemaining = %4.1f",self.currentLine.width - self.currentLine.widthRemaining,self.currentLine.width,self.currentLine.widthRemaining);
    return self.currentLine.width - self.currentLine.widthRemaining;
}

//Objective C 程序实现在图片上添加文字
-(UIImage *)addText:(UIImage *)img text:(NSString *)text1 
{ 
    //get image width and height 
    int w = img.size.width;
    int h = img.size.height; 

    
//    这里可以重新画图，自定义（上面图片，下面文字）
    UIGraphicsBeginImageContext(CGSizeMake(w, h));
    [img drawInRect:CGRectMake(0,0,w,h)];
    
    CGSize size = [text1 sizeWithFont:[UIFont systemFontOfSize:10.0f]
                         constrainedToSize:CGSizeMake(w, h)];
    
    [text1 drawInRect:CGRectMake(w-size.width-10, h-size.height-10, size.width, size.height )
             withFont:[UIFont systemFontOfSize:10.0f]
        lineBreakMode:NSLineBreakByCharWrapping
            alignment:NSTextAlignmentLeft];
    
   
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
    
}

//Objective C 程序实现在图片上添加文字
-(UIImage *)addText:(UIImage *)img text:(NSString *)text1 withPicSize:(NSString *)picSize
{ 
    //get image width and height 
    int w = img.size.width; 
    int h = img.size.height; 
    
    //    这里可以重新画图，自定义（上面图片，下面文字）
    UIGraphicsBeginImageContext(CGSizeMake(w, h));
    [img drawInRect:CGRectMake(0,0,w,h)];
    CGSize size;
    
    if (text1 && [text1 length]) {
        size = [text1 sizeWithFont:[UIFont systemFontOfSize:10.0f]
                        constrainedToSize:CGSizeMake(w, h)];
        
        [text1 drawInRect:CGRectMake(w-size.width-10, h-size.height-10, size.width, size.height)
                 withFont:[UIFont systemFontOfSize:10.0f]
            lineBreakMode:NSLineBreakByCharWrapping
                alignment:NSTextAlignmentLeft];
    }

    if (picSize && [picSize length]) {
        size = [picSize sizeWithFont:[UIFont systemFontOfSize:10.0f]
                   constrainedToSize:CGSizeMake(w, h)];
        
        [picSize drawInRect:CGRectMake(w-size.width-10, 10, size.width, size.height)
                   withFont:[UIFont systemFontOfSize:10.0f]
              lineBreakMode:NSLineBreakByCharWrapping
                  alignment:NSTextAlignmentLeft];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
    
}


- (UIImage *)imageForURL:(NSString *)url {
	return nil;
}

- (CGFloat)height {
    if (!singleLine) {
        return height;
    } else {
        if (lines.count == 0) {
            return 0;
        }
        return [[lines objectAtIndex:0] height];
    }
}

@end
