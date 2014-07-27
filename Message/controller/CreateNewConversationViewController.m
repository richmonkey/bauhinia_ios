//
//  CreateNewConversationViewController.m
//  Message
//
//  Created by daozhu on 14-7-13.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "CreateNewConversationViewController.h"
#import "pinyin.h"
#import "LevelDB.h"
#import "TAHttpOperation.h"
#import "Config.h"
#import "UserDB.h"
#import "Token.h"
#import "IMessage.h"
#import "MessageViewController.h"

@interface CreateNewConversationViewController ()
@property (nonatomic) NSArray *contacts;
@property (nonatomic) NSMutableArray *filteredArray;
@property (nonatomic) NSMutableArray *sectionArray;

@property (nonatomic) UITableView *tableView;
@property (nonatomic) UISearchDisplayController *searchDC;
@property (nonatomic) UISearchBar *searchBar;
@property (nonatomic) UINavigationController *aBPersonNav;
@end

@implementation CreateNewConversationViewController

- (id)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.navigationItem setTitle:@"选择联系人"];
    
    self.navigationItem.rightBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@"取消"
    
                                                                           style:UIBarButtonItemStyleBordered
                                                                          target:self
                                                                          action:@selector(cancelBtnAction:)] ;

}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
	[super viewDidDisappear:animated];
}


- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (aTableView == self.tableView) {
        IMContact *contact = [self.contacts objectAtIndex:indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:CREATE_NEW_CONVERSATION object: contact];
        [self dismissViewControllerAnimated:NO completion:nil];
    }else{
        IMContact *contact = [self.filteredArray objectAtIndex:indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:CREATE_NEW_CONVERSATION object: contact];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    
}


#pragma mark - Action

- (void)cancelBtnAction:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark NEW PERSON DELEGATE METHODS
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
