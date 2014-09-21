//
//  ConversationSettingViewController.m
//  Message
//  Created by 杨朋亮 on 14-9-14.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "ConversationSettingViewController.h"
#import "DownLoadSettingViewController.h"
#import "UIImage+Resize.h"
#import "SystemProperty.h"
#import "UIView+Toast.h"

#define kSetBackgroundCellTag             100
#define kRetBackgroudnCellTag             101
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
        self.cellTitleArray = @[
  @[@"聊天背景图" ,@"重置背景图"],
  @[@"自动下载音频",@"自动下载图片"]];
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
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate  = self;
            picker.allowsEditing = NO;
            picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            [self presentViewController:picker animated:YES completion:NULL];
        }
            break;
        case kRetBackgroudnCellTag:
        {
            [[SystemProperty instance] setBackgroundString:@""];
            [self.view makeToast:@"背景图设置成功!" duration:1.0 position:@"bottom"];
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


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    NSLog(@"Chose image!  Details:  %@", image);
    CGSize size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    UIImage *sizeImg = [image resizedImage:size interpolationQuality: kCGInterpolationDefault];
   
    // Create path.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"bk.png"];
    
    // Save image.
    [UIImagePNGRepresentation(sizeImg) writeToFile:filePath atomically:YES];
    [[SystemProperty instance] setBackgroundString:filePath];
    
    [self.view makeToast:@"背景图设置成功!" duration:1.0 position:@"bottom"];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}

@end
