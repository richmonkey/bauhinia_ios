//
//  GroupSettingViewController.m
//  Message
//
//  Created by houxh on 16/8/8.
//  Copyright © 2016年 daozhu. All rights reserved.
//

#import "GroupSettingViewController.h"
#import "RCTRootView.h"
#import "RCTBundleURLProvider.h"

#import "RCTBridgeModule.h"
#import "GroupDB.h"
#import "UserDB.h"
#import "ContactDB.h"
#import "ContactViewController.h"
#import "Profile.h"
#import "RCTEventDispatcher.h"
#import "Token.h"
#import "Config.h"
#import "ProgressHudBridge.h"

@interface GroupSettingViewController ()

@property(nonatomic, weak) RCTRootView *rootView;

- (void)quitGroup;
- (void)handleClickMember:(NSNumber*)memberID;
- (void)handleBack;
- (void)loadUsers:(RCTResponseSenderBlock)callback;

@end

@interface GroupSettingViewControllerBridge : NSObject <RCTBridgeModule>
@property(nonatomic, weak) GroupSettingViewController *controller;
@end

@implementation GroupSettingViewControllerBridge


-(GroupSettingViewControllerBridge*)init {
    self = [super init];
    if (self) {

    }
    return self;
}

-(void)dealloc {

}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(quitGroup)
{
    [self.controller quitGroup];
}



RCT_EXPORT_METHOD(handleClickMember:(nonnull NSNumber*)memberID)
{
    [self.controller handleClickMember:memberID];
}


RCT_EXPORT_METHOD(handleBack)
{
    [self.controller handleBack];
}


RCT_EXPORT_METHOD(loadUsers:(RCTResponseSenderBlock)callback)
{
    [self.controller loadUsers:callback];
}


- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}


@end



@implementation GroupSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //!!!important must set when use scrollview/listview
    self.automaticallyAdjustsScrollViewInsets = NO;


    Group *group = [[GroupDB instance] loadGroup:self.groupID];
    
    if (!group) {
        NSLog(@"group id is invalid");
        return;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setObject:[NSString stringWithFormat:@"%lld", group.groupID] forKey:@"group_id"];
    [dict setObject:[NSNumber numberWithBool:group.disbanded] forKey:@"disbanded"];
    [dict setObject:[NSString stringWithFormat:@"%lld", group.masterID] forKey:@"master_id"];
    [dict setObject:group.topic forKey:@"topic"];
    [dict setObject:[NSNumber numberWithLongLong:[Token instance].uid] forKey:@"uid"];
    [dict setObject:[Token instance].accessToken forKey:@"token"];
    [dict setObject:[Config instance].sdkAPIURL forKey:@"url"];

    
    NSMutableArray *members = [NSMutableArray array];
    for (int i = 0; i < group.members.count; i++) {
        NSNumber *memberID = [group.members objectAtIndex:i];
        
        NSMutableDictionary *member = [NSMutableDictionary dictionary];
        [member setObject:memberID forKey:@"uid"];
        User *u = [[UserDB instance] loadUser:[memberID longLongValue]];
        [member setObject:u.displayName forKey:@"name"];
        
        [members addObject:member];
    }
    [dict setObject:members forKey:@"members"];
    
    if (group.masterID == [Profile instance].uid) {
        [dict setObject:[NSNumber numberWithBool:YES] forKey:@"is_master"];
    } else {
        [dict setObject:[NSNumber numberWithBool:NO] forKey:@"is_master"];
    }
    
    // Do any additional setup after loading the view.
    NSURL *jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index.ios"
                                                                           fallbackResource:nil];
    
    __weak GroupSettingViewController *wself = self;
    RCTBridgeModuleProviderBlock provider = ^NSArray<id<RCTBridgeModule>> *{
        ProgressHudBridge *hud = [ProgressHudBridge new];
        hud.view = wself.view;
        
        GroupSettingViewControllerBridge *module = [GroupSettingViewControllerBridge new];
        module.controller = wself;
        return @[module, hud];
    };

    RCTBridge *bridge = [[RCTBridge alloc] initWithBundleURL:jsCodeLocation
                                              moduleProvider:provider                                             launchOptions:nil];

    RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:bridge moduleName:@"GroupSettingIndex" initialProperties:dict];

    //self.navigationController.navigationBar.frame.size.height +
    CGFloat y = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat h = [UIScreen mainScreen].bounds.size.height - y;
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    rootView.frame = CGRectMake(0, y, w, h);
    rootView.tag = 1000;
    [self.view addSubview:rootView];
    
    self.rootView = rootView;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (group.topic.length > 0) {
        self.navigationController.navigationBar.topItem.title = group.topic;
    } else {
        self.navigationController.navigationBar.topItem.title = @"群聊";
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [[self navigationController] setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[self navigationController] setNavigationBarHidden:NO animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)quitGroup {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleClickMember:(NSNumber*)memberID {
    NSLog(@"member:%@", memberID);
    
    User *u = [[UserDB instance] loadUser:[memberID longLongValue]];
    if (!u) {
        return;
    }
    ABContact *contact = [[ContactDB instance] loadContactWithNumber:u.phoneNumber];
    if (!contact) {
        return;
    }
    IMContact *c = [[ContactDB instance] loadIMContact:contact.recordID];
    if (!c) {
        return;
    }
    
    ContactViewController *ctl = [[ContactViewController alloc] init];
    ctl.hidesBottomBarWhenPushed = YES;
    ctl.contact = c;
    [self.navigationController pushViewController:ctl animated:YES];
}


- (void)handleBack {
    [self.navigationController popViewControllerAnimated:YES];
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)loadUsers:(RCTResponseSenderBlock)callback {
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
    callback(@[groupUsers]);
}

@end
