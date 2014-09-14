//
//  MainTabBarController.m
//  Message
//
//  Created by houxh on 14-7-20.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "MainTabBarController.h"
#import "SettingViewController.h"
#import "CustomStatusViewController.h"
#import "MessageListViewController.h"
#import "ContactListTableViewController.h"
#import "Token.h"
#import "IMService.h"
#import "UserPresent.h"
#import "Reachability.h"
#import "APIRequest.h"

@interface MainTabBarController ()
@property(atomic) Reachability *reach;
@property(nonatomic)dispatch_source_t refreshTimer;
@property(nonatomic)int refreshFailCount;
@end

@implementation MainTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CustomStatusViewController* conversationController = [[CustomStatusViewController alloc] init];
    conversationController.title = @"状态";
    
    conversationController.tabBarItem.title = @"状态";
    conversationController.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarIconStatusOn"];
    conversationController.tabBarItem.image = [UIImage imageNamed:@"TabBarIconStatusOff"];
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:conversationController];
    
    ContactListTableViewController* contactViewController = [[ContactListTableViewController alloc] init];
    contactViewController.title = @"通讯录";
    
    contactViewController.tabBarItem.title = @"通讯录";
    contactViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"IconContactTemplate"];
    contactViewController.tabBarItem.image = [UIImage imageNamed:@"IconContactTemplate"];

    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:contactViewController];
    
    MessageListViewController* msgController = [[MessageListViewController alloc] init];
    msgController.title = @"对话";
    msgController.tabBarItem.title = @"对话";
    msgController.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarIconChats"];
    msgController.tabBarItem.image = [UIImage imageNamed:@"TabBarIconChatsOff"];
    
    UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:msgController];
    
    SettingViewController* settingController = [[SettingViewController alloc] init];
    settingController.title = @"设置";
    settingController.tabBarItem.title = @"设置";
    settingController.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarIconSettingsOn"];
    settingController.tabBarItem.image = [UIImage imageNamed:@"TabBarIconSettingsOff"];
    
    UINavigationController *nav4 = [[UINavigationController alloc] initWithRootViewController:settingController];
    
    
    self.viewControllers = [NSArray arrayWithObjects: nav1, nav2, nav3, nav4, nil];
    self.selectedIndex = 1;
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    self.refreshTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_event_handler(self.refreshTimer, ^{
        [self refreshAccessToken];
    });
    
    [self startRefreshTimer];
    [[IMService instance] start:[UserPresent instance].uid];
    
    self.reach = [Reachability reachabilityWithHostname:@"www.message.im"];
    self.reach.reachableBlock = ^(Reachability*reach) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[IMService instance] start:[UserPresent instance].uid];
        });
    };
    
    self.reach.unreachableBlock = ^(Reachability*reach) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[IMService instance] stop];
        });
    };
    
    [self.reach startNotifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)appDidEnterBackground {
    [[IMService instance] stop];
    [self stopRefreshTimer];
}

-(void)appWillEnterForeground {
    [[IMService instance] start:[UserPresent instance].uid];
    [self startRefreshTimer];
}


-(void)refreshAccessToken {
    Token *token = [Token instance];
    [APIRequest refreshAccessToken:token.refreshToken
                           success:^(NSString *accessToken, NSString *refreshToken, int expireTimestamp) {
                               token.accessToken = accessToken;
                               token.refreshToken = refreshToken;
                               token.expireTimestamp = expireTimestamp;
                               [token save];
                               [self prepareTimer];
                               
                           }
                              fail:^{
                                  self.refreshFailCount = self.refreshFailCount + 1;
                                  int64_t timeout;
                                  if (self.refreshFailCount > 60) {
                                      timeout = 60*NSEC_PER_SEC;
                                  } else {
                                      timeout = (int64_t)self.refreshFailCount*NSEC_PER_SEC;
                                  }
                                  
                                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, timeout), dispatch_get_main_queue(), ^{
                                      [self prepareTimer];
                                  });
                                  
                              }];
}

-(void)prepareTimer {
    Token *token = [Token instance];
    int now = time(NULL);
    if (now >= token.expireTimestamp - 1) {
        dispatch_time_t w = dispatch_walltime(NULL, 0);
        dispatch_source_set_timer(self.refreshTimer, w, DISPATCH_TIME_FOREVER, 0);
    } else {
        dispatch_time_t w = dispatch_walltime(NULL, (token.expireTimestamp - now - 1)*NSEC_PER_SEC);
        dispatch_source_set_timer(self.refreshTimer, w, DISPATCH_TIME_FOREVER, 0);
    }
}


-(void)startRefreshTimer {
    [self prepareTimer];
    dispatch_resume(self.refreshTimer);
}

-(void)stopRefreshTimer {
    dispatch_suspend(self.refreshTimer);
}

@end
