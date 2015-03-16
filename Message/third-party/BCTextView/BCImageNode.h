#import "BCNode.h"

@interface BCImageNode : BCNode {
	UIImage *image;
    
    //设置与图像原本高宽不同的高度或宽度.
    NSInteger imageWidth;
    NSInteger imageHeight;
}
@property (nonatomic) NSInteger imageWidth;
@property (nonatomic) NSInteger imageHeight;

- (id)initWithImage:(UIImage *)img link:(BOOL)isLink;
@property (nonatomic, retain) UIImage *image;

@end

