#import "BCNode.h"


@implementation BCNode
@synthesize link;

@synthesize src;

- (CGFloat)width {
	return 0;
}

- (CGFloat)height {
	return 0;
}

- (void)dealloc {
	self.src = nil;
	[super dealloc];
}

@end
