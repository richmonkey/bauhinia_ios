//
//  ProfileViewController.m
//  Message
//
//  Created by 杨朋亮 on 14-9-13.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "ProfileViewController.h"
#import "UIImageView+WebCache.h"


@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *headView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIButton *statusBtn;

@end

@implementation ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

- (void) editorHeadAction{

    
}

-(IBAction) editorNameAction:(id)sender{
  
    
}

-(IBAction)editorStatus:(id)sender{
    
}

@end
