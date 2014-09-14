//
//  ConversationSettingViewController.m
//  Message
//
//  Created by 杨朋亮 on 14-9-14.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "ConversationSettingViewController.h"
#import "DownLoadSettingViewController.h"

#define kSetBackgroundCellTag             100
#define kRetBackgroudnCellTag              101

#define kAutoLoadPicCellTag               200
#define kAutoLoadAudioCellTag             201



@interface ConversationSettingViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSArray *cellTitleArray;

@end

@implementation ConversationSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
       [self setTitle:@"会话设置"];
        self.cellTitleArray = @[@[@"聊天背景图" ,@"重置背景图"],@[@"自动下载音频",@"自动下载图片"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    cell  = [tableView dequeueReusableCellWithIdentifier:@"simplecell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"simplecell"];
    }
    cell.tag = (indexPath.section + 1 ) * 100 + indexPath.row;
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
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
        case kSetBackgroundCellTag:
        {
//            AboutViewController * aboutController = [[AboutViewController alloc] init];
            
//            aboutController.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:aboutController animated: YES];
        }
            break;
        case kRetBackgroudnCellTag:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"  message:@"正在研发中.."  delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alert show];
        }
            break;
        case kAutoLoadPicCellTag:
        {
            DownLoadSettingViewController * downloadSetController = [[DownLoadSettingViewController alloc] init];
            
            downloadSetController.hidesBottomBarWhenPushed = YES;
            [downloadSetController setTitle:@"图片下载设置"];
            
            [self.navigationController pushViewController:downloadSetController animated: YES];
        }
            break;
        case kAutoLoadAudioCellTag:
        {
            DownLoadSettingViewController * downloadSetController = [[DownLoadSettingViewController alloc] init];
            
            downloadSetController.hidesBottomBarWhenPushed = YES;
            [downloadSetController setTitle:@"音频下载设置"];
            
            [self.navigationController pushViewController:downloadSetController animated: YES];
        }
            break;
        default:
            break;
    }
    
    
}

@end
