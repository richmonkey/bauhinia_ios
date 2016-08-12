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
#import "GroupMemberAddViewController.h"
#import "GroupMemberRemoveViewController.h"
#import "UserPresent.h"
#import "RCTEventDispatcher.h"

@interface GroupSettingViewController ()<GroupMemberAddViewControllerDelegate, GroupMemberRemoveViewControllerDelegate>

@property(nonatomic, weak) RCTRootView *rootView;

- (void)quitGroup;
- (void)handleAdd;
- (void)handleRemove;
- (void)handleClickMember:(NSNumber*)memberID;
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
    NSLog(@"CalendarManager dealloc");
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(quitGroup)
{
    [self.controller quitGroup];
}

RCT_EXPORT_METHOD(handleRemove)
{
    [self.controller handleRemove];
}

RCT_EXPORT_METHOD(handleAdd)
{
    [self.controller handleAdd];
}

RCT_EXPORT_METHOD(handleClickMember:(nonnull NSNumber*)memberID)
{
    [self.controller handleClickMember:memberID];
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if ([self.controller respondsToSelector:
         [anInvocation selector]])
        [anInvocation invokeWithTarget:self.controller];
    else
        [super forwardInvocation:anInvocation];
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
    
    NSMutableArray *members = [NSMutableArray array];
    for (int i = 0; i < group.members.count; i++) {
        NSNumber *memberID = [group.members objectAtIndex:i];
        
        NSMutableDictionary *member = [NSMutableDictionary dictionary];
        [member setObject:memberID forKey:@"member_id"];
        User *u = [[UserDB instance] loadUser:[memberID longLongValue]];
        [member setObject:u.displayName forKey:@"name"];
        
        [members addObject:member];
    }
    [dict setObject:members forKey:@"members"];
    
    if (group.masterID == [UserPresent instance].uid) {
        [dict setObject:[NSNumber numberWithBool:YES] forKey:@"is_master"];
    } else {
        [dict setObject:[NSNumber numberWithBool:NO] forKey:@"is_master"];
    }
    
    // Do any additional setup after loading the view.
    NSURL *jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index.ios"
                                                                           fallbackResource:nil];
    
    __weak GroupSettingViewController *wself = self;
    RCTBridgeModuleProviderBlock provider = ^NSArray<id<RCTBridgeModule>> *{
        GroupSettingViewControllerBridge *module = [GroupSettingViewControllerBridge new];
        module.controller = wself;
        return @[module];
    };

    RCTBridge *bridge = [[RCTBridge alloc] initWithBundleURL:jsCodeLocation
                                              moduleProvider:provider                                             launchOptions:nil];

    RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:bridge moduleName:@"GroupSetting" initialProperties:dict];

    
    CGFloat y = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)quitGroup {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleAdd {
    GroupMemberAddViewController *ctrl = [[GroupMemberAddViewController alloc] init];
    ctrl.groupID = self.groupID;
    ctrl.delegate = self;
    [self presentViewController:ctrl animated:YES completion:^{

    }];
}

- (void)handleRemove {
    GroupMemberRemoveViewController *ctrl = [[GroupMemberRemoveViewController alloc] init];
    ctrl.groupID = self.groupID;
    ctrl.delegate = self;
    [self presentViewController:ctrl animated:YES completion:nil];
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

- (void)groupMemberAdded:(NSArray*)users {
    NSLog(@"group member added:%@", users);
    
    NSMutableArray *groupUsers = [NSMutableArray array];
    for (NSNumber *n in users) {
        NSMutableDictionary *member = [NSMutableDictionary dictionary];
        [member setObject:n forKey:@"member_id"];
        User *u = [[UserDB instance] loadUser:[n longLongValue]];
        [member setObject:u.displayName forKey:@"name"];
        
        [groupUsers addObject:member];
        
    }
    [self.rootView.bridge.eventDispatcher sendAppEventWithName:@"member_added"
                                                          body:@{@"users": groupUsers}];
    
}

- (void)groupMemberDeleted:(NSNumber*)memberID {
    NSLog(@"group member deleted:%@", memberID);
    [self.rootView.bridge.eventDispatcher sendAppEventWithName:@"member_removed"
                                                          body:@{@"id": memberID}];
    
}


@end
