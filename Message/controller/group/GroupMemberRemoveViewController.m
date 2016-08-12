//
//  GroupMemberRemoveViewController.m
//  Message
//
//  Created by houxh on 16/8/11.
//  Copyright © 2016年 daozhu. All rights reserved.
//

#import "GroupMemberRemoveViewController.h"
#import "RCTRootView.h"
#import "RCTBundleURLProvider.h"
#import "RCTBridgeModule.h"

#import "GroupDB.h"
#import "UserDB.h"
#import "Config.h"
#import "Token.h"
#import "MBProgressHUD.h"
#import "ProgressHudBridge.h"


@interface GroupMemberRemoveViewController ()
- (void)handleDismiss;
- (void)groupMemberDeleted:(NSNumber*)memberID;
@end


@interface GroupMemberRemoveViewControllerBridge : NSObject <RCTBridgeModule>
@property(nonatomic, weak) GroupMemberRemoveViewController *controller;
@end

@implementation GroupMemberRemoveViewControllerBridge

-(GroupMemberRemoveViewControllerBridge*)init {
    self = [super init];
    if (self) {

    }
    return self;
}

-(void)dealloc {
    NSLog(@"GroupMemberRemoveViewControllerBridge dealloc");
}

RCT_EXPORT_MODULE();


RCT_EXPORT_METHOD(handleDismiss)
{
    [self.controller handleDismiss];
}

RCT_EXPORT_METHOD(groupMemberDeleted:(nonnull NSNumber*)memberID)
{
    [self.controller groupMemberDeleted:(NSNumber*)memberID];
}


- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

@end



@implementation GroupMemberRemoveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Group *group = [[GroupDB instance] loadGroup:self.groupID];
    
    if (!group) {
        NSLog(@"group id is invalid");
        return;
    }
    
    
    
    NSMutableArray *groupUsers = [NSMutableArray array];
    for (NSNumber *n in group.members) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        [dict setObject:n forKey:@"uid"];
        
        User *u = [[UserDB instance] loadUser:[n longLongValue]];

        
        [dict setObject:u.displayName forKey:@"name"];
        [dict setObject:@NO forKey:@"selected"];
        
        [groupUsers addObject:dict];
    }
    

    NSDictionary *props = @{@"users":groupUsers,
                            @"group_id":[NSNumber numberWithLongLong:self.groupID],
                            @"token":[Token instance].accessToken,
                            @"url":[Config instance].sdkAPIURL};


    // Do any additional setup after loading the view.
    NSURL *jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index.ios"
                                                                           fallbackResource:nil];
    
    
    __weak GroupMemberRemoveViewController *wself = self;
    RCTBridgeModuleProviderBlock provider = ^NSArray<id<RCTBridgeModule>> *{
        ProgressHudBridge *hud = [ProgressHudBridge new];
        hud.view = wself.view;
        
        GroupMemberRemoveViewControllerBridge *module = [GroupMemberRemoveViewControllerBridge new];
        module.controller = wself;
        return @[module, hud];
    };
    
    RCTBridge *bridge = [[RCTBridge alloc] initWithBundleURL:jsCodeLocation
                                              moduleProvider:provider                                             launchOptions:nil];
    
    RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:bridge
                                                     moduleName:@"GroupMemberRemove"
                                              initialProperties:props];
    


    
    
    CGFloat y = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat h = [UIScreen mainScreen].bounds.size.height - y;
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    rootView.frame = CGRectMake(0, y, w, h);
    rootView.tag = 1000;
    [self.view addSubview:rootView];
    
    self.view.backgroundColor = [UIColor whiteColor];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleDismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)groupMemberDeleted:(NSNumber*)memberID {
    [self.delegate groupMemberDeleted:memberID];
}

@end
