//
//  UIImageView+Letters.m
//
//  Created by Tom Bachant on 6/17/14.
//  Copyright (c) 2014 Tom Bachant. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "UIImageView+Letters.h"

@implementation UIImageView (Letters)

- (void)setImageWithString:(NSString *)string {
    [self setImageWithString:string color:nil];
}

- (void)setImageWithString:(NSString *)string color:(UIColor *)color {
    
    //
    // Set up a temporary view to contain the text label
    //
    UIView *tempView = [[UIView alloc] initWithFrame:self.bounds];
    
    UILabel *letterLabel = [[UILabel alloc] initWithFrame:self.bounds];
    letterLabel.textAlignment = NSTextAlignmentCenter;
    letterLabel.backgroundColor = [UIColor clearColor];
    letterLabel.textColor = [UIColor whiteColor];
    letterLabel.adjustsFontSizeToFitWidth = YES;
    letterLabel.minimumScaleFactor = 8.0f / 65.0f;
    letterLabel.font = [self fontForLetterLabel];
    [tempView addSubview:letterLabel];
    
    NSMutableString *displayString = [NSMutableString stringWithString:@""];
    
    NSArray *words = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([words count]) {
        NSString *firstWord = words[0];
        if ([firstWord length]) {
            [displayString appendString:[firstWord substringWithRange:NSMakeRange(0, 1)]];
        }
        
        if ([words count] >= 2) {
            NSString *lastWord = words[[words count] - 1];
            if ([lastWord length]) {
                [displayString appendString:[lastWord substringWithRange:NSMakeRange(0, 1)]];
            }
        }
    }
    letterLabel.text = [displayString uppercaseString];
    
    //
    // Set the background color
    //
    tempView.backgroundColor = color ? color : [self randomColor:[displayString uppercaseString]];
    
    //
    // Return an image instance of the temporary view
    //
    self.image = [self imageSnapshotFromView:tempView];
}

#pragma mark - Helpers

- (UIFont *)fontForLetterLabel {
    return [UIFont systemFontOfSize:CGRectGetWidth(self.bounds) * 0.48];
}

- (UIColor *)randomColor:(NSString*)str {
    NSArray * colors = @[
                         UIColorFromRGB(0xE74C3C),
                         UIColorFromRGB(0xC0392B),
                         UIColorFromRGB(0x2ECC71),
                         UIColorFromRGB(0x27AE60),
                         UIColorFromRGB(0x3498DB),
                         UIColorFromRGB(0x2980B9),
                         UIColorFromRGB(0x1ABC9C),
                         UIColorFromRGB(0x16A085),
                         UIColorFromRGB(0x9B59B6),
                         UIColorFromRGB(0x8E44AD),
                         UIColorFromRGB(0xF1C40F),
                         UIColorFromRGB(0xF39C12),
                         UIColorFromRGB(0xE67E22),
                         UIColorFromRGB(0xD35400),
                         UIColorFromRGB(0x95A5A6),
                         UIColorFromRGB(0x7F8C8D),
                         UIColorFromRGB(0xBCB0D1),
                         UIColorFromRGB(0xBDC3C7),
                         UIColorFromRGB(0x34495E),
                         UIColorFromRGB(0x6C3E50)
                         ];
    int index = 0;
    if (str.length == 2) {
       index = ([str characterAtIndex:0] + [str characterAtIndex:1]) % 20;
    }else{
        index = [str characterAtIndex:0] % 20;
    }
    return [colors objectAtIndex:index];
}

- (UIImage *)imageSnapshotFromView:(UIView *)inputView {
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    CGSize size = self.bounds.size;
    if (self.contentMode == UIViewContentModeScaleToFill ||
        self.contentMode == UIViewContentModeScaleAspectFill ||
        self.contentMode == UIViewContentModeScaleAspectFit ||
        self.contentMode == UIViewContentModeRedraw)
    {
        size.width = floorf(size.width * scale) / scale;
        size.height = floorf(size.height * scale) / scale;
    }
    
    UIGraphicsBeginImageContextWithOptions(size, YES, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, -self.bounds.origin.x, -self.bounds.origin.y);
    
    [inputView.layer renderInContext:context];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return snapshot;
}

@end
