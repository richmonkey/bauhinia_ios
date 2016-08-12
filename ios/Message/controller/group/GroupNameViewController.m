//
//  GroupNameViewController.m
//  Message
//
//  Created by houxh on 16/8/12.
//  Copyright © 2016年 daozhu. All rights reserved.
//

#import "GroupNameViewController.h"
#import "RCTRootView.h"
#import "RCTBundleURLProvider.h"

#import "RCTBridgeModule.h"
#import "RCTEventDispatcher.h"

#import "Config.h"
#import "Token.h"
#import "ProgressHudBridge.h"


@interface GroupNameViewController ()
@property(nonatomic, assign)BOOL changed;
@property(nonatomic, weak) RCTRootView *rootView;

- (void)popViewController;
- (void)groupNameChanged:(NSString*)topic;
@end

@interface GroupNameViewControllerBridge : NSObject <RCTBridgeModule>
@property(nonatomic, weak) GroupNameViewController *controller;
@end
@implementation GroupNameViewControllerBridge

-(GroupNameViewControllerBridge*)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void)dealloc {
    NSLog(@"GroupNameViewControllerBridge dealloc");
}

RCT_EXPORT_MODULE();


RCT_EXPORT_METHOD(groupNameChanged:(NSString*)name)
{
    [self.controller groupNameChanged:name];
}


RCT_EXPORT_METHOD(popViewController)
{
    [self.controller popViewController];
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

@end


@implementation GroupNameViewController

- (void)updateGroupName {
    
    [self.rootView.bridge.eventDispatcher sendAppEventWithName:@"update"
                                                          body:@{}];

}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"完成"
                                                             style:UIBarButtonItemStyleDone
                                                            target:self
                                                            action:@selector(updateGroupName)];
    
    self.navigationItem.rightBarButtonItem = item;
    
    
    //!!!important must set when use scrollview/listview
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    NSDictionary *dict =@{@"topic":self.topic,
                          @"group_id":[NSNumber numberWithLongLong:self.groupID],
                          @"token":[Token instance].accessToken,
                          @"url":[Config instance].sdkAPIURL};
 
    // Do any additional setup after loading the view.
    NSURL *jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index.ios"
                                                                           fallbackResource:nil];

    __weak GroupNameViewController *wself = self;
    RCTBridgeModuleProviderBlock provider = ^NSArray<id<RCTBridgeModule>> *{
        ProgressHudBridge *hud = [ProgressHudBridge new];
        hud.view = wself.view;
        
        GroupNameViewControllerBridge *module = [GroupNameViewControllerBridge new];
        module.controller = wself;
        return @[module, hud];
    };
    
    RCTBridge *bridge = [[RCTBridge alloc] initWithBundleURL:jsCodeLocation
                                              moduleProvider:provider                                             launchOptions:nil];
    
    RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:bridge moduleName:@"GroupName" initialProperties:dict];
    
    
    CGFloat y = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat h = [UIScreen mainScreen].bounds.size.height - y;
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    rootView.frame = CGRectMake(0, y, w, h);
    rootView.tag = 1000;
    [self.view addSubview:rootView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.topItem.title = @"群聊名称";
    
    self.rootView = rootView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)groupNameChanged:(NSString*)topic {
    [self.delegate groupNameChanged:topic];
}

- (void)popViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
