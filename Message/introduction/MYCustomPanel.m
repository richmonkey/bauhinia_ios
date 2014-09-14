//
//  MYCustomPanel.m
//  MYBlurIntroductionView-Example
//
//  Created by Matthew York on 10/17/13.
//  Copyright (c) 2013 Matthew York. All rights reserved.
//

#import "MYCustomPanel.h"
#import "MYBlurIntroductionView.h"

@implementation MYCustomPanel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Interaction Methods
//Override them if you want them!

-(void)panelDidAppear{
    NSLog(@"Panel Did Appear");
    
//    [self.parentIntroductionView setEnabled:NO];
}

-(void)panelDidDisappear{
    NSLog(@"Panel Did Disappear");
    
    //Maybe here you want to reset the panel in case someone goes backward and the comes back to your panel
}

#pragma mark Outlets



- (IBAction)didPressEnable:(id)sender {
   //Enable introducitonview
//    [self.parentIntroductionView setEnabled:YES];
    [self.parentIntroductionView didPressSkipButton];
}


@end
