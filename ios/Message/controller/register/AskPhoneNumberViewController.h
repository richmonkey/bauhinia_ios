//
//  AskPhoneNumberViewController.h
//  Message
//
//  Created by 杨朋亮 on 14/9/14.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RCTBridge;

@interface AskPhoneNumberViewController : UIViewController <UITextFieldDelegate>
- (instancetype)initWithComponent:(NSString *)component passProps:(NSDictionary *)passProps navigatorStyle:(NSDictionary*)navigatorStyle globalProps:(NSDictionary *)globalProps bridge:(RCTBridge *)bridge;
@end
