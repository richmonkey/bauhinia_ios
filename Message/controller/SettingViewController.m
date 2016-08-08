//
//  SettingViewController.m
//  Message
//
//  Created by daozhu on 14-6-16.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <gobelieve/PeerMessageDB.h>
#import "SettingViewController.h"
#import "AboutViewController.h"
#import "ProfileViewController.h"
#import "ConversationSettingViewController.h"
#import "UIView+Toast.h"
#import "APIRequest.h"
#import "MBProgressHUD.h"


#define kNetStatusSection 2
#define kNetStatusRow     0
#define kClearAllConversationSection 3

#define kClearAllContentTag  101

#define kAboutCellTag                   100

#define kProfileCellTag                 200
#define kConversationCellSettingTag     201
#define kZbarScanCellTag                202

#define kNetStatusCellTag               300

#define kClearConversationCellTag       400

#define kGreenColor         RGBCOLOR(48,176,87)
#define kRedColor           RGBCOLOR(207,6,6)

#define greenLineWidthHeight 40
#define cornerWith   40
#define redLineStartY       170
#define redLineMoveLength   140
#define scanTopBlank            120

@interface SettingViewController ()

@end

@implementation SettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.cellTitleArray = @[ @"关于",
                                 @[@"个人资讯",@"会话设置",@"Web端登录"],
                                 @"网络状态",
                                 @"清除所有对话记录"
                                ];
        [[IMService instance] addConnectionObserver:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)viewWillAppear:(BOOL)animated{
    if(self.redScanLine){
        [self.redScanLine.layer removeAllAnimations];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if (currSysVer.floatValue >= 8.0) {
        [UIView animateWithDuration:1 delay:0
                            options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse
                         animations:
                         ^{
                             if (self.redScanLine) {
                                 CGRect frame = self.redScanLine.frame;
                                 frame.origin.y += redLineMoveLength;
                                 [self.redScanLine setFrame:frame];
                             }
                         }
                         completion:nil];
    }else{
        CGRect frame = self.redScanLine.frame;
        frame.origin.y = redLineStartY + redLineMoveLength/2;
        [self.redScanLine setFrame:frame];
    }

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
    NSLog(@"%zd,%zd",indexPath.section,indexPath.row);
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
                [cell.detailTextLabel setTextColor: kGreenColor];
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
            [cell.textLabel setTextColor:kRedColor];
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
    
    NSInteger cellTag = (indexPath.section + 1) *100 + indexPath.row;
    switch (cellTag) {
        case kAboutCellTag:
        {
           AboutViewController * aboutController = [[AboutViewController alloc] init];
            
            aboutController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:aboutController animated: YES];
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
        case kConversationCellSettingTag:
        {
            
            ConversationSettingViewController * conSettingController = [[ConversationSettingViewController alloc] init];
            
            conSettingController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:conSettingController animated: YES];
        }
            break;
        case kZbarScanCellTag:
        {
            [self scan:nil];
        }
            break;
        case kNetStatusCellTag:
        {

        }
            break;
        case kClearConversationCellTag:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确认" message:@"是否清除所有聊天记录?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
            alertView.tag = kClearAllContentTag;
            [alertView show];
        }
            break;
        default:
            break;
    }
   
    
}

#pragma mark - MessageObserver
-(void) onConnectState:(int)state {
   NSIndexPath *indexPath = [NSIndexPath indexPathForRow:kNetStatusRow inSection:kNetStatusSection];
    UITableViewCell *cell  = [self.tableView cellForRowAtIndexPath:indexPath];
    switch (state) {
        case STATE_UNCONNECTED:
        {
            [cell.detailTextLabel setTextColor:kGreenColor];
            [cell.detailTextLabel setText:@"未链接.."];
            [self hideActivityView:cell];
        }
            break;
        case STATE_CONNECTING :
        {
            [cell.detailTextLabel setTextColor:kGreenColor];
            [cell.detailTextLabel setText:@""];
            [self addActivityView:cell];
        }
            break;
        case STATE_CONNECTED :
        {
            [cell.detailTextLabel setTextColor:kGreenColor];
            [cell.detailTextLabel setText:@"已链接"];
            [self hideActivityView:cell];
        }
            break;
        case STATE_CONNECTFAIL :
        {
            [cell.detailTextLabel setTextColor:kRedColor];
            [cell.detailTextLabel setText:@"未链接"];
            [self hideActivityView:cell];
        }
            break;
        default:
            break;
    }

}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == kClearAllContentTag) {
        if (buttonIndex == 0) {
        //取消
            
        }else if(buttonIndex == 1){
        //确认
          BOOL result =  [[PeerMessageDB instance] clear];
            if (result) {
                
                NSNotification* notification = [[NSNotification alloc] initWithName:CLEAR_ALL_CONVESATION object: nil userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
                
                [self.view makeToast:@"会话清理完毕" duration:0.9 position:@"center"];
            }
        }
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
        [(UIActivityIndicatorView*)cell.accessoryView stopAnimating];
        cell.accessoryView = nil;
    }
}

- (void)scan:(id)sender
{
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    
    //非全屏
    reader.edgesForExtendedLayout = UIRectEdgeAll;
    
    //隐藏底部控制按钮
    reader.showsZBarControls = NO;
    
    //设置自己定义的界面
    [self setOverlayPickerView:reader];
    ZBarImageScanner *scanner = reader.scanner;
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    [self presentViewController:reader animated:YES completion:nil];
    
}

- (void)setOverlayPickerView:(ZBarReaderViewController *)reader{
    //清除原有控件
    for (UIView *temp in [reader.view subviews]) {
        for (UIButton *button in [temp subviews]) {
            if ([button isKindOfClass:[UIButton class]]) {
                [button removeFromSuperview];
            }
        }
        
        for (UIToolbar *toolbar in [temp subviews]) {
            if ([toolbar isKindOfClass:[UIToolbar class]]) {
                [toolbar setHidden:YES];
                [toolbar removeFromSuperview];
            }
        }
    }
    
    //画中间的基准线
    self.redScanLine = [[UIView alloc] initWithFrame:CGRectMake(45, redLineStartY, 230, 2)];
    self.redScanLine.backgroundColor = [UIColor redColor];
    [reader.view addSubview:self.redScanLine];
   
    //|--
    UIView *cornerTL = [[UIView alloc] initWithFrame:CGRectMake(cornerWith, scanTopBlank, greenLineWidthHeight, 1)];
    cornerTL.backgroundColor = [UIColor greenColor];
    [reader.view addSubview:cornerTL];
    //||-
    UIView *cornerLT = [[UIView alloc] initWithFrame:CGRectMake(cornerWith, scanTopBlank, 1, greenLineWidthHeight)];
    cornerLT.backgroundColor = [UIColor greenColor];
    [reader.view addSubview:cornerLT];
    //--|
    UIView *cornerTR = [[UIView alloc] initWithFrame:CGRectMake(320 - greenLineWidthHeight - cornerWith, scanTopBlank, greenLineWidthHeight, 1)];
    cornerTR.backgroundColor = [UIColor greenColor];
    [reader.view addSubview:cornerTR];
    //-||
    UIView *cornerRT = [[UIView alloc] initWithFrame:CGRectMake(320-cornerWith-1, scanTopBlank, 1, greenLineWidthHeight)];
    cornerRT.backgroundColor = [UIColor greenColor];
    [reader.view addSubview:cornerRT];
    //|__
    UIView *cornerBL = [[UIView alloc] initWithFrame:CGRectMake(cornerWith, 360-1, greenLineWidthHeight, 1)];
    cornerBL.backgroundColor = [UIColor greenColor];
    [reader.view addSubview:cornerBL];
    //||_
    UIView *cornerLB = [[UIView alloc] initWithFrame:CGRectMake(cornerWith, 360-greenLineWidthHeight-1, 1, greenLineWidthHeight)];
    cornerLB.backgroundColor = [UIColor greenColor];
    [reader.view addSubview:cornerLB];
    //__|
    UIView *cornerBR = [[UIView alloc] initWithFrame:CGRectMake(320-greenLineWidthHeight- cornerWith, 360-1, greenLineWidthHeight, 1)];
    cornerBR.backgroundColor = [UIColor greenColor];
    [reader.view addSubview:cornerBR];
    //_||
    UIView *cornerRB = [[UIView alloc] initWithFrame:CGRectMake(320-cornerWith-1, 360-greenLineWidthHeight-1, 1, greenLineWidthHeight)];
    cornerRB.backgroundColor = [UIColor greenColor];
    [reader.view addSubview:cornerRB];
    
    
    //最上部view
    UIView* upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, scanTopBlank)];
    upView.alpha = 0.8;
    upView.backgroundColor = [UIColor blackColor];
    [reader.view addSubview:upView];
    
    //用于说明的label
    UILabel * labIntroudction= [[UILabel alloc] init];
    labIntroudction.backgroundColor = [UIColor clearColor];
    labIntroudction.frame=CGRectMake(15, 60, 290, 50);
    [labIntroudction setFont:[UIFont systemFontOfSize:16.0f]];
    labIntroudction.numberOfLines=2;
    labIntroudction.textColor=[UIColor whiteColor];
    labIntroudction.text=@"将二维码图像置于矩形方框内，离手机摄像头10CM左右，系统会自动识别。";
    [upView addSubview:labIntroudction];
    
    //左侧的view
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, scanTopBlank, 40, 280)];
    leftView.alpha = 0.8;
    leftView.backgroundColor = [UIColor blackColor];
    [reader.view addSubview:leftView];
    
    //右侧的view
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(320 - 40, scanTopBlank, 40, 280)];
    
    rightView.alpha = 0.8;
    
    rightView.backgroundColor = [UIColor blackColor];
    
    [reader.view addSubview:rightView];
    
    //底部view
    UIView * downView = [[UIView alloc] initWithFrame:CGRectMake(0, 360, 320, 120)];
    downView.alpha = 0.8;
    downView.backgroundColor = [UIColor blackColor];
    [reader.view addSubview:downView];
    
    //用于取消操作的button
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cancelButton.alpha = 0.9;
    [cancelButton setFrame:CGRectMake(20, 390, 280, 40)];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [cancelButton addTarget:self action:@selector(dismissOverlayView:)forControlEvents:UIControlEventTouchUpInside];
    [reader.view addSubview:cancelButton];
}


#pragma mark - ZBarReaderDelegate

- (void) readerControllerDidFailToRead: (ZBarReaderController*) reader
                             withRetry: (BOOL) retry{
    
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    id<NSFastEnumeration> results = [info objectForKey:ZBarReaderControllerResults];
    ZBarSymbol * symbol;
    for(symbol in results)
        break;
    
    NSString *text = symbol.data;
  
    if(self.redScanLine){
        [self.redScanLine.layer removeAllAnimations];
        [self.redScanLine setHidden:YES];
    }
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView: picker.view];
    [picker.view addSubview:hud];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.detailsLabelText = @"正在登录..";
    [hud setDetailsLabelFont:[UIFont systemFontOfSize:16.0f]];
    [hud show:YES];
    
    [APIRequest webIMlogin:text
                        success:^{
                            NSLog(@"web login success");
                            [hud hide:YES];
                            [picker.view makeToast:@"WebIM登录成功!" duration:0.9 position:@"center"];
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.8 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                [picker dismissViewControllerAnimated:YES completion:nil];
                            });
                        }
                           fail:^{
                               NSLog(@"web login fail");
                               [hud hide:YES];
                               [picker.view makeToast:@"WebIM登录失败!" duration:0.9 position:@"center"];
                               dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.8 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                   [picker dismissViewControllerAnimated:YES completion:nil];
                               });
                           }];
}

//取消button方法
- (void)dismissOverlayView:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
