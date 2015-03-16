#import "BCImageNode.h"


@implementation BCImageNode
@synthesize image;
@synthesize imageWidth, imageHeight;

- (id)initWithImage:(UIImage *)img link:(BOOL)isLink {
	if ((self = [super init])) {
		self.image = img;
		self.link = isLink;
        imageWidth = img.size.width;
        imageHeight = img.size.height;
	}
	return self;
}

- (void)dealloc {
	self.image = nil;
	[super dealloc];
}

- (CGFloat)width {
	return imageWidth;
}

- (CGFloat)height {
	return imageHeight;
}

- (void)drawAtPoint:(CGPoint)point {
    CGRect rect = CGRectMake(point.x, point.y, imageWidth, imageHeight);
    [self.image drawInRect:rect];
    
}



@end


