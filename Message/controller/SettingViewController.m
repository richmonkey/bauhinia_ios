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

#import "ConversationSettingViewController.h"


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
                                 @[@"个人资讯",@"账号",@"会话设置",@"通知"],
                                 @[@"网络状态",@"系统状态"],
                                 @"清除所有对话记录"
                                ];
        [[IMService instance] addMessageObserver:self];
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
            [cell.detailTextLabel setFont:[UIFont systemFontOfSize:16.0f]];
            cell.tag = (indexPath.section + 1) * 100 + indexPath.row;
            if ([[IMService instance] connectState] != STATE_CONNECTED) {
                [self addActivityView:cell];
            }else{
                [cell.detailTextLabel setTextColor:[UIColor greenColor]];
                [cell.detailTextLabel setText:@"已链接"];
            }
            
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
            profileController.editorState = ProfileEditorSettingType;
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
            
            ConversationSettingViewController * conSettingController = [[ConversationSettingViewController alloc] init];
            
            conSettingController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:conSettingController animated: YES];
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

#pragma mark - MessageObserver
-(void)onPeerMessage:(IMMessage*)msg{

}

//服务器ack
-(void)onPeerMessageACK:(int)msgLocalID uid:(int64_t)uid{
    
}
//接受方ack
-(void)onPeerMessageRemoteACK:(int)msgLocalID uid:(int64_t)uid{
    
}

-(void)onPeerMessageFailure:(int)msgLocalID uid:(int64_t)uid{
    
}

//用户连线状态
-(void)onOnlineState:(int64_t)uid state:(BOOL)on{
    
}

//对方正在输入
-(void)onPeerInputing:(int64_t)uid{
    
}

-(void) onConnectState:(int)state {
   NSIndexPath *indexPath = [NSIndexPath indexPathForRow:kNetStatusSection inSection:kNetStatusRow];
    UITableViewCell *cell  = [self.tableView cellForRowAtIndexPath:indexPath];
    switch (state) {
        case STATE_UNCONNECTED:
        {
            [cell.detailTextLabel setTextColor:[UIColor greenColor]];
            [cell.detailTextLabel setText:@"未链接.."];
            [self hideActivityView:cell];
        }
            break;
        case STATE_CONNECTING :
        {
            [cell.detailTextLabel setTextColor:[UIColor greenColor]];
            [cell.detailTextLabel setText:@""];
            [self addActivityView:cell];
        }
            break;
        case STATE_CONNECTED :
        {
            [cell.detailTextLabel setTextColor:[UIColor greenColor]];
            [cell.detailTextLabel setText:@"已链接"];
            [self hideActivityView:cell];
        }
            break;
        case STATE_CONNECTFAIL :
        {
            [cell.detailTextLabel setTextColor:[UIColor redColor]];
            [cell.detailTextLabel setText:@"未链接"];
            [self hideActivityView:cell];
        }
            break;
        default:
            break;
    }

}

#pragma mark - UITableViewDelegate



-(void) addActivityView:(UITableViewCell*)cell{
    if (cell.accessoryView&& [cell.accessoryView isKindOfClass:[UIActivityIndicatorView class]]){
        [cell.accessoryView setHidden:NO];
        [(UIActivityIndicatorView*)cell.accessoryView startAnimating]; // 开始旋转
    }else{
        UIActivityIndicatorView *testActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        cell.accessoryView = testActivityIndicator;
        testActivityIndicator.color = [UIColor grayColor];
        [testActivityIndicator startAnimating]; // 开始旋转
        [testActivityIndicator setHidesWhenStopped:YES];
    }
}

-(void)hideActivityView:(UITableViewCell*)cell{
    if(cell.accessoryView&&[cell.accessoryView isKindOfClass:[UIActivityIndicatorView class]]){
        [(UIActivityIndicatorView*)cell stopAnimating];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
