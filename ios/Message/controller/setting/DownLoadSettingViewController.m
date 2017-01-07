//
//  DownLoadSettingViewController.m
//  Message
//
//  Created by 杨朋亮 on 14-9-14.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "DownLoadSettingViewController.h"
#import "SystemProperty.h"


#define kNeverAutoCellTag             100
#define kWifiAutoCellTag              101
#define kAllCanAutoCellTag            102


@interface DownLoadSettingViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong,nonatomic) NSArray *cellTitleArray;

@end

@implementation DownLoadSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.cellTitleArray = @[@"永不",@"WIFI下",@"WIFI和手机卡网络下"];
        
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
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.cellTitleArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = nil;
    NSLog(@"%zd,%zd",indexPath.section,indexPath.row);
    
    cell  = [tableView dequeueReusableCellWithIdentifier:@"simplecell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"simplecell"];
    }
    cell.tag = (indexPath.section + 1 ) * 100 + indexPath.row;
    
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    if (self.type == kSetAudioType) {
        int index = [[[SystemProperty instance] loadAudioSetting] intValue];
        if (indexPath.row == index) {
           [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
        
    }else if(self.type == kSetImageTpye){
        int index = [[[SystemProperty instance] loadImageSetting] intValue];
        if (indexPath.row == index) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    }
    
    [cell.textLabel setText: [self.cellTitleArray objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger selecteIndex = indexPath.row;
    
    if (self.type == kSetAudioType) {
        [[SystemProperty instance] setLoadAudioSetting:[NSNumber numberWithInt:selecteIndex]];
    }else if(self.type == kSetImageTpye){
        [[SystemProperty instance] setLoadImageSetting:[NSNumber numberWithInt:selecteIndex]];
    }
    
    [self.tableview reloadData];
    
}

@end
