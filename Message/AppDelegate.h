//
//  AppDelegate.h
//  Message
//
//  Created by daozhu on 14-6-16.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingViewController.h"
#import "ConversationViewController.h"
#import "MessageListTableViewController.h"
#import "ContactsController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <QuartzCore/QuartzCore.h>




#define BARBUTTON(TITLE, SELECTOR)		[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]//UIBarButtonItem
#define NUMBER(X) [NSNumber numberWithInt:X]



@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong,  nonatomic) UIViewController* viewController;
@property (strong, nonatomic) UITabBarController* tabBarController;
@end
