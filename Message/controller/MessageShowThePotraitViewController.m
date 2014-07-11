//
//  MessageShowThePotraitViewController.m
//  Message
//
//  Created by daozhu on 14-7-9.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "MessageShowThePotraitViewController.h"

@interface MessageShowThePotraitViewController ()

@end

@implementation MessageShowThePotraitViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.navigationItem setTitle: @"小张"];
    // Do any additional setup after loading the view.
    UIBarButtonItem *navBarHeadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAction target:self action:@selector(onSaveAction)];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    
    UIImage *img = [UIImage imageNamed:@"potrait"];
    [imageView setImage: img];
    imageView.frame = CGRectMake(0, 0, 320, 320);
    [self.view addSubview: imageView];
    imageView.center = self.view.center;
    
    
    self.navigationItem.rightBarButtonItem = navBarHeadButton;
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) onSaveAction{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle: nil otherButtonTitles:@"存储图片", @"复制", nil];
    
    [actionSheet showInView:self.view];


}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        NSLog(@"存储");
    }else if(buttonIndex == 1){
        NSLog(@"复制");
    }
    


}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
