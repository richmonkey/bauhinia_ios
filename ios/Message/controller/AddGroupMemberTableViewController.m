//
//  AddGroupMemberTableViewController.m
//  Message
//
//  Created by houxh on 15/3/18.
//  Copyright (c) 2015年 daozhu. All rights reserved.
//

#import "AddGroupMemberTableViewController.h"
#import "User.h"
#import "ContactDB.h"
#import "Profile.h"
#import "MBProgressHUD.h"
#import <gobelieve/IMHttpApi.h>
#import <gobelieve/IMessage.h>
#import <gobelieve/GroupMessageDB.h>

#import "UIApplication+Util.h"
#import "UIView+Toast.h"
#import "GroupDB.h"

@interface AddGroupMemberTableViewController ()
@property(nonatomic, copy) NSString *groupName;
@property(nonatomic) NSArray *users;
@property(nonatomic) NSMutableSet *selectedUsers;
@end

@implementation AddGroupMemberTableViewController
- (id)initWithGroupName:(NSString*)groupName {
    self = [super init];
    if (self) {
        self.groupName = groupName;
        
        self.users = [NSMutableArray array];
        self.selectedUsers = [NSMutableSet set];
     
    }
    return self;
}

-(void)loadData{
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
    
    self.users = [dict allValues];

}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"创建"
                                                             style:UIBarButtonItemStyleDone
                                                            target:self
                                                            action:@selector(createGroup)];
    
    self.navigationItem.rightBarButtonItem = item;
    
    [self loadData];
}

- (void)createGroup {
    if ([self.selectedUsers count] == 0) {
        [self.view makeToast:@"请选择群组成员!" duration:1.0f position:@"center"];
        return;
    }
    
    NSLog(@"craete group...");
    
    int64_t uid = [Profile instance].uid;
    [self.selectedUsers addObject:[NSNumber numberWithLongLong:uid]];
    NSArray *members = [self.selectedUsers allObjects];
    
    UIWindow *foreWindow  = [[UIApplication sharedApplication] foregroundWindow];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:foreWindow animated:YES];
    
    [IMHttpAPI createGroup:self.groupName master:uid members:members
                   success:^(int64_t groupID) {
                       [hud hide:NO];
                       NSLog(@"new group id:%lld", groupID);
                       [self dismissViewControllerAnimated:YES completion:nil];
                   }
                      fail:^ {
                          [hud hide:NO];
                          [self.view makeToast:@"群组创建失败" duration:1.0f position:@"center"];
                      }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.users count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    User *u = [self.users objectAtIndex:indexPath.row];
    cell.textLabel.text = u.displayName;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)path {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:path];
    
    User *u = [self.users objectAtIndex:path.row];
    NSNumber *uid = [NSNumber numberWithLongLong:u.uid];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedUsers removeObject:uid];
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedUsers addObject:uid];
    }
}

@end
