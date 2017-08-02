//
//  AppDelegate.m
//  Message
//
//  Created by daozhu on 14-6-16.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "AppDelegate.h"

#import <gobelieve/IMService.h>
#import <gobelieve/IMHttpAPI.h>
#import <gobelieve/PeerMessageHandler.h>
#import <gobelieve/GroupMessageHandler.h>
#import <gobelieve/GroupMessageDB.h>
#import <gobelieve/PeerMessageDB.h>
#import "Token.h"
#import "Profile.h"
#import "Config.h"
#import "APIRequest.h"
#import "MainTabBarController.h"
#import "AskPhoneNumberViewController.h"
#import "ContactListTableViewController.h"
#import "SettingViewController.h"
#import "CustomStatusViewController.h"
#import "ConversationViewController.h"
#import "MGroupMessageViewController.h"
#import "RCCManager.h"

#import <React/RCTBundleURLProvider.h>


@implementation AppDelegate

-(NSString*)getDocumentPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //配置im server地址
    NSString *path = [self getDocumentPath];
    NSString *peerPath = [NSString stringWithFormat:@"%@/peer", path];
    [[PeerMessageDB instance] setDbPath:peerPath];
    
    NSString *groupPath = [NSString stringWithFormat:@"%@/group", path];
    [[GroupMessageDB instance] setDbPath:groupPath];
    
    [IMHttpAPI instance].apiURL = [Config instance].sdkAPIURL;
    [IMService instance].host = [Config instance].sdkHost;
#if TARGET_IPHONE_SIMULATOR
    [IMService instance].deviceID = @"7C8A8F5B-E5F4-4797-8758-05367D2A4D61";
    NSLog(@"device id:%@", @"7C8A8F5B-E5F4-4797-8758-05367D2A4D61");
#else
    [IMService instance].deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSLog(@"device id:%@", [[[UIDevice currentDevice] identifierForVendor] UUIDString]);
#endif

    [IMService instance].peerMessageHandler = [PeerMessageHandler instance];
    [IMService instance].groupMessageHandler = [GroupMessageHandler instance];
    [[IMService instance] startRechabilityNotifier];
    
   [[RCCManager sharedIntance] registerComponent:@"chat.GroupChat" class:[MGroupMessageViewController class]];
    

    
    //创建bridge对象
    NSURL *jsCodeLocation;
    jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index.ios" fallbackResource:nil];
    // jsCodeLocation = [NSURL URLWithString:@"http://192.168.0.101:8081/index.ios.bundle"];
    [[RCCManager sharedInstance] initBridgeWithBundleURL:jsCodeLocation];

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    application.statusBarHidden = NO;
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    
    Token *token = [Token instance];
    if (token.accessToken) {
        UITabBarController *tabController = [[MainTabBarController alloc] init];
        self.tabBarController = tabController;
        self.window.rootViewController = tabController;
    }else{
        AskPhoneNumberViewController *ctl = [[AskPhoneNumberViewController alloc] init];
        UINavigationController * navCtr = [[UINavigationController alloc] initWithRootViewController: ctl];
        self.window.rootViewController = navCtr;
    }
    
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}


- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didRegisterForRemoteNotificationsWithDeviceToken"
                                                        object:deviceToken];


}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"register remote notification error:%@", error);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"will enter foreground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
