//
//  Taken from MADismissiveTextView
//  https://github.com/mikeahmarani/MADismissiveTextView
//
//  Created by Mike Ahmarani on 12-02-18.
//  Copyright (c) 2012 Mike Ahmarani. All rights reserved.
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSMessagesViewController
//
//
//  The MIT License
//  Copyright (c) 2013 Jesse Squires
//  http://opensource.org/licenses/MIT
//

#import "JSDismissiveTextView.h"

@interface JSDismissiveTextView ()

@property (strong, nonatomic) UIView *keyboardView;
@property (assign, nonatomic) CGFloat previousKeyboardY;

- (void)handleKeyboardWillShowHideNotification:(NSNotification *)notification;

@end



@implementation JSDismissiveTextView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        self.editable = YES;
        
        // FIXME: this is a hack
        // ---------------------
        // init an empty inputAccessoryView to get a reference to the keyboard when it appears
        // i.e., self.inputAccessoryView.superview <-- the keyboard (see notification handler below)
        // otherwise self.inputAccessoryView == nil, thus self.inputAccessoryView.superivew == nil
        // ---------------------
        // Can you fix this? Submit a PR! :)
        self.inputAccessoryView = [[UIView alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleKeyboardWillShowHideNotification:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleKeyboardWillShowHideNotification:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleKeyboardWillShowHideNotification:)
                                                     name:UIKeyboardDidHideNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _keyboardDelegate = nil;
    _keyboardView = nil;
}

#pragma mark - Notifications

- (void)handleKeyboardWillShowHideNotification:(NSNotification *)notification
{
    if([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
        self.keyboardView.hidden = NO;
    }
    else if([notification.name isEqualToString:UIKeyboardDidShowNotification]) {
        self.keyboardView = self.inputAccessoryView.superview;
        self.keyboardView.hidden = NO;
        
        if(self.keyboardDelegate && [self.keyboardDelegate respondsToSelector:@selector(keyboardDidShow)])
            [self.keyboardDelegate keyboardDidShow];
    }
    else if([notification.name isEqualToString:UIKeyboardDidHideNotification]) {
        self.keyboardView.hidden = NO;
        [self resignFirstResponder];
    }
}

@end
