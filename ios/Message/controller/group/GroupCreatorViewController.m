//
//  GroupCreatorViewController.m
//  Message
//
//  Created by houxh on 2017/1/15.
//  Copyright © 2017年 daozhu. All rights reserved.
//

#import "GroupCreatorViewController.h"
#import <React/RCTRootView.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTBridgeModule.h>

#import "UserDB.h"
#import "ContactDB.h"
#import "Config.h"
#import "Token.h"

@interface GroupCreatorViewController ()<RCTBridgeModule>

@end

@implementation GroupCreatorViewController
RCT_EXPORT_MODULE();


RCT_EXPORT_METHOD(finish) {
    [self.delegate onGroupCreateCanceled];
}

RCT_EXPORT_METHOD(finishWithGroupID:(NSString*)groupID name:(NSString*)name) {
    NSLog(@"group id:%@", groupID);
    [self.delegate onGroupCreated:[groupID longLongValue] name:name];
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    //!!!important must set when use scrollview/listview
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    NSMutableArray *users = [NSMutableArray array];
    NSArray *contacts = [ContactDB instance].contactsArray;
    
    for (IMContact *contact in contacts) {
        for (User *u in contact.users) {
            NSInteger index = [users indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary *dict = (NSDictionary*)obj;
                if (u.uid == [dict[@"uid"] longLongValue]) {
                    *stop = YES;
                    return YES;
                } else {
                    return NO;
                }
            }];
            if (index == NSNotFound) {
                [users addObject:@{@"uid":@(u.uid), @"name":u.displayName}];
            }
        }
    }

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithLongLong:[Token instance].uid] forKey:@"uid"];
    [dict setObject:[Token instance].accessToken forKey:@"token"];
    [dict setObject:[Config instance].sdkAPIURL forKey:@"url"];
    [dict setObject:users forKey:@"users"];
    
    // Do any additional setup after loading the view.
    NSURL *jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index.ios"
                                                                           fallbackResource:nil];
    GroupCreatorViewController *wself = self;
    RCTBridgeModuleProviderBlock provider = ^NSArray<id<RCTBridgeModule>> *{
         return @[wself];
    };
    
    RCTBridge *bridge = [[RCTBridge alloc] initWithBundleURL:jsCodeLocation
                                              moduleProvider:provider
                                               launchOptions:nil];
    
    RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:bridge moduleName:@"GroupCreatorIndex" initialProperties:dict];
    
    //self.navigationController.navigationBar.frame.size.height +
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
