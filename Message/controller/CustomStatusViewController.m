//
//  CustomStatusViewController.m
//  Message
//
//  Created by daozhu on 14-6-16.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#define kDefineStatusCellSection 0
#define kDefineStatusCellRow     0

#define kStatusListCellsSection 1

#define kClearStatusCellSection 2
#define kClearSelfDefineStatusCellRow  0


#import "CustomStatusViewController.h"

@interface CustomStatusViewController ()

@end

@implementation CustomStatusViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNavigationButtons];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"customStatus" ofType:@"plist"];
    self.statusArray = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height -(KNavigationBarHeight + KTabBarHeight));
    self.tableView  = [[UITableView alloc] initWithFrame:rect style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.view addSubview:self.tableView];
}

- (void)viewDidAppear:(BOOL)animated{
  
}

-(void)viewDidDisappear:(BOOL)animated{
  
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == kDefineStatusCellSection) {
        return 1;
    }else if(section == kStatusListCellsSection){
        return [self.statusArray count];
    }else if(section == kClearSelfDefineStatusCellRow){
        return 1;
    }
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    NSLog(@"%d,%d",indexPath.section,indexPath.row);
    if (indexPath.section != kClearStatusCellSection) {
        if(indexPath.section == kDefineStatusCellSection && indexPath.row == kDefineStatusCellRow){
            cell  = [tableView dequeueReusableCellWithIdentifier:@"definestatuscell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"definestatuscell"];
            }
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell.textLabel setText: self.currentStatus];
            
        }else{
            cell  = [tableView dequeueReusableCellWithIdentifier:@"simplecell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"simplecell"];
            }
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            
            if ([self.currentStatus isEqualToString:[self.statusArray objectAtIndex:indexPath.row]]) {
               [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            }
            
            [cell.textLabel setText:[self.statusArray objectAtIndex:indexPath.row]];
        }
        
    }else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"clearCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"clearcell"];
            [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
            [cell.textLabel setTextColor:[UIColor redColor]];
            [cell.textLabel setText:@"重置自定义状态"];
        }
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == kDefineStatusCellSection ) {
        return @"自定义状态";
    }else if(section == kStatusListCellsSection){
        return @"选择一个状态";
    }
    return  nil;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == kStatusListCellsSection) {
        self.currentStatus = [self.statusArray objectAtIndex:indexPath.row];
        [tableView reloadData];
    }
}

-(void) setNavigationButtons{
    
    self.title = @"自定义状态";
    
    UIBarButtonItem *editorDoneButton = [[UIBarButtonItem alloc] initWithTitle:@"编辑"
                                                                         style:UIBarButtonItemStyleDone
                                                                        target:self
                                                                        action:@selector(editorAction)];
    self.navigationItem.leftBarButtonItem = editorDoneButton;
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewStatus)];
    
    
    self.navigationItem.rightBarButtonItem = addButton;
    
}

#pragma mark - Action

-(void)editorAction{

    
}

-(void)addNewStatus{


}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
