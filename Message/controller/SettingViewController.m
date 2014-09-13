//
//  SettingViewController.m
//  Message
//
//  Created by daozhu on 14-6-16.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "SettingViewController.h"
#import "AboutViewController.h"
#import "ProfileViewController.h"


#define kNetStatusSection 2
#define kNetStatusRow     0
#define kClearAllConversationSection 3


#define kAboutCellTag                   100
#define kTellFriendCellTag              101

#define kProfileCellTag                 200
#define kAccountCellTag                 201
#define kConversationCellSettingTag     202
#define knotificationCellTag            203

#define kNetStatusCellTag               300
#define kSystemStatusCellTag            301

#define kClearConversationCellTag       400

@interface SettingViewController ()

@end

@implementation SettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.cellTitleArray = @[ @[@"关于",@"告诉朋友"],
                                 @[@"个人资讯",@"账号",@"对话设置",@"通知"],
                                 @[@"网络状态",@"系统状态"],
                                 @"清除所有对话记录"
                                ];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - KTabBarHeight - KNavigationBarHeight - kStatusBarHeight);
    self.tableView = [[UITableView alloc] initWithFrame:rect style: UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    
}

- (void)viewDidAppear:(BOOL)animated{

}

-(void)viewDidDisappear:(BOOL)animated{

}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return [self.cellTitleArray count];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   
    id array = [self.cellTitleArray objectAtIndex:section];
    if ([array isKindOfClass:[NSString class]]) {
        return 1;
    }else if([array isKindOfClass:[NSArray class]]){
        return [(NSArray*)array count];
    }
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    UITableViewCell *cell = nil;
    NSLog(@"%d,%d",indexPath.section,indexPath.row);
    if (indexPath.section != kClearAllConversationSection) {
        if(indexPath.section == kNetStatusSection && indexPath.row == kNetStatusRow){
            cell  = [tableView dequeueReusableCellWithIdentifier:@"statuscell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"statuscell"];
            }
            cell.tag = (indexPath.section + 1) * 100 + indexPath.row;
            [cell.detailTextLabel setTextColor:[UIColor greenColor]];
            [cell.detailTextLabel setText:@"状态"];
        }else{
            cell  = [tableView dequeueReusableCellWithIdentifier:@"simplecell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"simplecell"];
            }
            cell.tag = (indexPath.section + 1 ) * 100 + indexPath.row;
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
        
    }else if(indexPath.section == kClearAllConversationSection){
        cell = [tableView dequeueReusableCellWithIdentifier:@"clearCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"clearcell"];
            cell.tag = (indexPath.section + 1) * 100 + indexPath.row;
            [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
            [cell.textLabel setTextColor:[UIColor redColor]];
        }
    }
    
    id array = [self.cellTitleArray objectAtIndex:indexPath.section];
    if ([array isKindOfClass:[NSString class]]) {
        [cell.textLabel setText: array];
    }else if([array isKindOfClass:[NSArray class]]){
        [cell.textLabel setText: [array objectAtIndex:indexPath.row]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
     [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    int cellTag = (indexPath.section + 1) *100 + indexPath.row;
    switch (cellTag) {
        case kAboutCellTag:
        {
           AboutViewController * aboutController = [[AboutViewController alloc] init];
            
            aboutController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:aboutController animated: YES];
        }
            break;
        case kTellFriendCellTag:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"  message:@"正在研发中.."  delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alert show];
        }
            break;
        case kProfileCellTag:
        {
            ProfileViewController * profileController = [[ProfileViewController alloc] init];
            
            profileController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:profileController animated: YES];
        }
            break;
        case kAccountCellTag:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"  message:@"正在研发中.."  delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alert show];
        }
            break;
        case kConversationCellSettingTag:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"  message:@"正在研发中.."  delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alert show];
        }
            break;
        case knotificationCellTag:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"  message:@"正在研发中.."  delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alert show];
        }
            break;
        case kNetStatusCellTag:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"  message:@"正在研发中.."  delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alert show];
        }
            break;
        case kSystemStatusCellTag:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"  message:@"正在研发中.."  delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alert show];
        }
            break;
        case kClearConversationCellTag:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"  message:@"正在研发中.."  delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alert show];
        }
            break;
        default:
            break;
    }
   
    
}



#pragma mark - UITableViewDelegate


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
