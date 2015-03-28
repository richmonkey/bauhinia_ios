//
//  AppDelegate.m
//  Message
//
//  Created by daozhu on 14-6-16.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "AppDelegate.h"

#import <imsdk/IMService.h>
#import <imkit/IMHttpAPI.h>
#import <imkit/PeerMessageHandler.h>
#import <imkit/GroupMessageHandler.h>
#import <imkit/MessageDB.h>
#import "Token.h"
#import "UserPresent.h"
#import "Config.h"
#import "MainTabBarController.h"
#import "AskPhoneNumberViewController.h"
#import "APIRequest.h"

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
    [MessageDB setDBPath:path];
    [IMHttpAPI instance].apiURL = [Config instance].sdkAPIURL;
    [IMService instance].host = [Config instance].sdkHost;
    [IMService instance].deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [IMService instance].peerMessageHandler = [PeerMessageHandler instance];
    [IMService instance].groupMessageHandler = [GroupMessageHandler instance];
    [[IMService instance] startRechabilityNotifier];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    application.statusBarHidden = NO;
    
    
    Token *token = [Token instance];
    if (token.accessToken) {
        [IMHttpAPI instance].accessToken = [Token instance].accessToken;
        [IMService instance].token = [Token instance].accessToken;
        NSLog(@"access token:%@", [Token instance].accessToken);
        UITabBarController *tabController = [[MainTabBarController alloc] init];
        self.tabBarController = tabController;
        self.window.rootViewController = tabController;
    }else{
        AskPhoneNumberViewController *ctl = [[AskPhoneNumberViewController alloc] init];
        UINavigationController * navCtr = [[UINavigationController alloc] initWithRootViewController: ctl];
        self.window.rootViewController = navCtr;
    }
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeNewsstandContentAvailability)];

    return YES;
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString* newToken = [deviceToken description];
	newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.deviceToken = newToken;
    
    Token *token = [Token instance];
    if (token.uid > 0) {
        [IMHttpAPI bindDeviceToken:self.deviceToken
                            success:^{
                                NSLog(@"bind device token success");
                            }
                               fail:^{
                                   NSLog(@"bind device token fail");
                               }];
    }
    NSLog(@"device token is: %@:%@", deviceToken, newToken);
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
    // 清除图标数字
    application.applicationIconBadgeNumber = 0;
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
