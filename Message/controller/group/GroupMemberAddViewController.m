//
//  GroupMemberAddViewController.m
//  Message
//
//  Created by houxh on 16/8/10.
//  Copyright © 2016年 daozhu. All rights reserved.
//

#import "GroupMemberAddViewController.h"
#import "RCTRootView.h"
#import "RCTBundleURLProvider.h"
#import "RCTBridgeModule.h"
#import "ContactDB.h"
#import "UserDB.h"
#import "GroupDB.h"
#import "MBProgressHud.h"
#import "Token.h"
#import "Config.h"
#import "ProgressHudBridge.h"

@interface GroupMemberAddViewController ()
@property(nonatomic) NSArray *groupUsers;

- (void)handleDismiss;
- (void)groupMemberAdded:(NSArray*)users;
@end


@interface GroupMemberAddViewControllerBridge : NSObject <RCTBridgeModule>
@property(nonatomic, weak) GroupMemberAddViewController *controller;
@end
@implementation GroupMemberAddViewControllerBridge

-(GroupMemberAddViewControllerBridge*)init {
    self = [super init];
    if (self) {

    }
    return self;
}

-(void)dealloc {
    NSLog(@"GroupMemberAddViewControllerBridge dealloc");
}

RCT_EXPORT_MODULE();


RCT_EXPORT_METHOD(handleDismiss)
{
    [self.controller handleDismiss];
}

RCT_EXPORT_METHOD(groupMemberAdded:(NSArray*)users)
{
    [self.controller groupMemberAdded:users];
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

@end




@implementation GroupMemberAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //!!!important must set when use scrollview/listview
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *contacts = [[ContactDB instance] contactsArray];
    if([contacts count] == 0) {
        return;
    }
    
    for (IMContact *contact in contacts) {
        NSString *string = contact.contactName;
        if ([contact.users count] > 0) {
            User *user = [contact.users objectAtIndex:0];
            NSLog(@"name:%@ state:%@", string, user.state);
        }
        
        for (User *u in contact.users) {
            u.contactName = contact.contactName;
            [dict setObject:u forKey:[NSNumber numberWithLongLong:u.uid]];
        }
    }
    
    NSArray *users = [dict allValues];
    
    Group *group = [[GroupDB instance] loadGroup:self.groupID];
    
    if (!group) {
        NSLog(@"group id is invalid");
        return;
    }
    
    
    
    NSMutableArray *groupUsers = [NSMutableArray array];
    for (User *u in users) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        NSNumber *n = [NSNumber numberWithLongLong:u.uid];
        [dict setObject:n forKey:@"uid"];
        [dict setObject:u.displayName forKey:@"name"];
        
        if ([group.members indexOfObject:n] != NSNotFound) {
            [dict setObject:@YES forKey:@"is_member"];
            [dict setObject:@YES forKey:@"selected"];
        } else {
            [dict setObject:@NO forKey:@"is_member"];
            [dict setObject:@NO forKey:@"selected"];
        }
        
        [groupUsers addObject:dict];
    }


    
    self.groupUsers = groupUsers;
    
    NSDictionary *props = @{@"users":groupUsers,
                            @"group_id":[NSNumber numberWithLongLong:self.groupID],
                            @"token":[Token instance].accessToken,
                            @"url":[Config instance].sdkAPIURL};
    
    // Do any additional setup after loading the view.
    NSURL *jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index.ios"
                                                                           fallbackResource:nil];
    
    
    __weak GroupMemberAddViewController *wself = self;
    RCTBridgeModuleProviderBlock provider = ^NSArray<id<RCTBridgeModule>> *{
        ProgressHudBridge *hud = [ProgressHudBridge new];
        hud.view = wself.view;
        
        GroupMemberAddViewControllerBridge *module = [GroupMemberAddViewControllerBridge new];
        module.controller = wself;
        return @[module, hud];
    };
    
    RCTBridge *bridge = [[RCTBridge alloc] initWithBundleURL:jsCodeLocation
                                              moduleProvider:provider                                             launchOptions:nil];
    
    RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:bridge moduleName:@"GroupMemberAdd" initialProperties:props];
    

    
    //self.navigationController.navigationBar.frame.size.height +
    CGFloat y = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat h = [UIScreen mainScreen].bounds.size.height - y;
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    rootView.frame = CGRectMake(0, y, w, h);
    rootView.tag = 1000;
    [self.view addSubview:rootView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    GroupMemberAddViewControllerBridge *b = [rootView.bridge moduleForName:@"GroupMemberAddViewControllerBridge"];
    NSLog(@"GroupMemberAddViewControllerBridge:%@", b);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)handleDismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)groupMemberAdded:(NSArray*)users {
    [self.delegate groupMemberAdded:users];
}

@end
