//
//  MYViewController.m
//
//  Created by Matthew York on 10/16/13.
//  Copyright (c) 2013 Matthew York. All rights reserved.
//

#import "IntroductionViewController.h"
#import "MYCustomPanel.h"

#import "AskPhoneNumberViewController.h"
#import "AppDelegate.h"
#import "Token.h"
#import "MainTabBarController.h"


@interface IntroductionViewController ()

@end

@implementation IntroductionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated{
    [self buildIntro];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Build MYBlurIntroductionView

-(void)buildIntro{
    UIView *headerView = [[NSBundle mainBundle] loadNibNamed:@"header" owner:nil options:nil][0];
    MYIntroductionPanel *panel1 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) title:@"欢迎使用MESSAGE" description:@"让距离不在遥远!" image:[UIImage imageNamed:@"HeaderImage.png"] header:headerView];
   
    UIView *headerViewtow = [[NSBundle mainBundle] loadNibNamed:@"header" owner:nil options:nil][0];
    MYIntroductionPanel *panel2 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) title:@"说句知心话" description:@"语音骚扰下" image:[UIImage imageNamed:@"ForkImage.png"] header:headerViewtow];
    
    MYIntroductionPanel *panel3 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) nibNamed:@"TestPanel3"];
    
    MYCustomPanel *panel4 = [[MYCustomPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) nibNamed:@"MYCustomPanel"];
    
    NSArray *panels = @[panel1, panel2, panel3, panel4];
    
    MYBlurIntroductionView *introductionView = [[MYBlurIntroductionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    introductionView.theDelegate = self;
    
    introductionView.BackgroundImageView.image = [UIImage imageNamed:@"pgyfy-1.png"];
    
    
    [introductionView setBackgroundColor:[UIColor colorWithRed:190.0f/255.0f green:175.0f/255.0f blue:113.0f/255.0f alpha:0]];
    
    [introductionView buildIntroductionWithPanels:panels];
    
    [self.view addSubview:introductionView];
}

#pragma mark - MYIntroduction Delegate 

-(void)introduction:(MYBlurIntroductionView *)introductionView didChangeToPanel:(MYIntroductionPanel *)panel withIndex:(NSInteger)panelIndex{
    NSLog(@"Introduction did change to panel %d", panelIndex);
    
    //You can edit introduction view properties right from the delegate method!

}

-(void)introduction:(MYBlurIntroductionView *)introductionView didFinishWithType:(MYFinishType)finishType {
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    Token *token = [Token instance];
    if (token.accessToken) {
        UITabBarController *tabController = [[MainTabBarController alloc] init];
        delegate.tabBarController = tabController;
        delegate.window.rootViewController = tabController;
        
    } else {
        AskPhoneNumberViewController *ctl = [[AskPhoneNumberViewController alloc] init];
        UINavigationController * navCtr = [[UINavigationController alloc] initWithRootViewController: ctl];

        delegate.window.rootViewController = navCtr;
    }
    
}

@end
