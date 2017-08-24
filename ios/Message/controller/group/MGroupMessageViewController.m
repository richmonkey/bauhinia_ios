//
//  MGroupMessageViewController.m
//  Message
//
//  Created by houxh on 16/8/8.
//  Copyright © 2016年 daozhu. All rights reserved.
//

#import "MGroupMessageViewController.h"
#import "GroupDB.h"
#import "Token.h"
#import "UserDB.h"
#import "Profile.h"
#import "ContactDB.h"

#import <ReactNativeNavigation/RCCManager.h>
#import <ReactNativeNavigation/RCCNavigationController.h>
#import <React/RCTEventDispatcher.h>

@interface MGroupMessageViewController ()<MessageViewControllerUserDelegate>

@end

@implementation MGroupMessageViewController
- (instancetype)initWithComponent:(NSString *)component passProps:(NSDictionary *)passProps navigatorStyle:(NSDictionary*)navigatorStyle globalProps:(NSDictionary *)globalProps bridge:(RCTBridge *)bridge {
    self = [super init];
    if (self) {
        self.currentUID = [[passProps objectForKey:@"currentUID"] longLongValue];
        self.groupID = [[passProps objectForKey:@"groupID"] longLongValue];
        self.groupName = [passProps objectForKey:@"groupName"];
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}
- (void)viewDidLoad {
    
    self.userDelegate = self;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    Group *group = [[GroupDB instance] loadGroup:self.groupID];
    if (!group) {
        return;
    }
    
    //不是群组成员
    if ([group.members indexOfObject:[NSNumber numberWithLongLong:self.currentUID]] == NSNotFound) {
        CGFloat chatbarHeight = 5 * 2 + 36;
        CGRect frame = CGRectMake(0, self.view.frame.size.height - chatbarHeight, self.view.frame.size.width, chatbarHeight);
        UILabel *textView = [[UILabel alloc] initWithFrame:frame];
        textView.text = @"您不是群组的成员。";
        textView.font = [UIFont systemFontOfSize:15];
        textView.textAlignment = NSTextAlignmentCenter;
        textView.backgroundColor = RGBCOLOR(0xf5, 0xff, 0xfa);
        textView.lineBreakMode = NSLineBreakByWordWrapping;
        [self.view addSubview:textView];
        self.inputBar.hidden = YES;
        return;
    }

    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"设置"
                                                             style:UIBarButtonItemStyleDone
                                                            target:self
                                                            action:@selector(groupSetting)];
    
    self.navigationItem.rightBarButtonItem = item;

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSArray*)getContacts {
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
                if (contact.contactName.length > 0) {
                    [users addObject:@{@"id":@(u.uid), @"uid":@(u.uid), @"name":contact.contactName}];
                } else {
                    [users addObject:@{@"id":@(u.uid), @"uid":@(u.uid), @"name":u.displayName}];
                }
            }
        }
    }
    
    NSInteger index = [users indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dict = (NSDictionary*)obj;
        if ([Token instance].uid == [dict[@"uid"] longLongValue]) {
            *stop = YES;
            return YES;
        } else {
            return NO;
        }
    }];
    if (index == NSNotFound) {
        NSString *name = [Profile instance].name;
        [users addObject:@{@"id":@([Token instance].uid), @"uid":@([Token instance].uid), @"name":name}];
    }
    return users;
}

- (void)groupSetting {
    Group *group = [[GroupDB instance] loadGroup:self.groupID];
    
    if (!group) {
        NSLog(@"group id is invalid");
        return;
    }
    
    NSMutableArray *members = [NSMutableArray array];
    for (int i = 0; i < group.members.count; i++) {
        NSNumber *memberID = [group.members objectAtIndex:i];
        
        NSMutableDictionary *member = [NSMutableDictionary dictionary];
        [member setObject:memberID forKey:@"uid"];
        [member setObject:memberID forKey:@"id"];
        User *u = [[UserDB instance] loadUser:[memberID longLongValue]];
        [member setObject:u.displayName forKey:@"name"];
        
        [members addObject:member];
    }
    
    NSDictionary *g = @{@"id":@(group.groupID),
                        @"name":group.topic,
                        @"members":members,
                        @"master":@(group.masterID)
                        };
    
    
    NSArray *contacts = [self getContacts];
    NSDictionary *profile = @{@"uid":@([Token instance].uid),
                              @"gobelieveToken":[Token instance].accessToken};
    RCCNavigationController *nav = (RCCNavigationController*)self.navigationController;
    NSDictionary *body = @{@"group":g,
                           @"contacts":contacts,
                           @"profile":profile,
                           @"navigatorID":nav.componentID};
    
    RCTBridge *bridge = [[RCCManager sharedIntance] getBridge];

    [bridge.eventDispatcher sendAppEventWithName:@"group_setting" body:body];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - MessageViewControllerUserDelegate
//从本地获取用户信息, IUser的name字段为空时，显示identifier字段
- (IUser*)getUser:(int64_t)uid {
    UserDB *db = [UserDB instance];
    User *user = [db loadUser:uid];
    
    IUser *u = [[IUser alloc] init];
    u.identifier = [NSString stringWithFormat:@"%lld", uid];
    u.name = [user displayName];
    u.avatarURL = user.avatarURL;
    return u;
}
//从服务器获取用户信息
- (void)asyncGetUser:(int64_t)uid cb:(void(^)(IUser*))cb {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            UserDB *db = [UserDB instance];
            User *user = [db loadUser:uid];
            
            IUser *u = [[IUser alloc] init];
            u.identifier = [NSString stringWithFormat:@"%lld", uid];
            u.name = [user displayName];
            u.avatarURL = user.avatarURL;
            cb(u);
        });
    });
}

@end
