//
//  MessageListTableViewController.m
//  Message
//
//  Created by daozhu on 14-6-19.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "MessageListTableViewController.h"
#import "MsgViewController.h"
#import "MessageDB.h"
#import "IMessage.h"

@interface MessageListTableViewController ()

@end

@implementation MessageListTableViewController

-(id)init{
  self = [super init];
  if (self) {
    self.conversations = [[NSMutableArray alloc] init];
    ConversationIterator * iterator =  [[MessageDB instance] newConversationIterator];
    
    Conversation * conversation = [iterator next];
    while (conversation) {
      [self.conversations addObject:conversation];
      conversation = [iterator next];
    }
    
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  table_ = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
	table_.delegate = self;
	table_.dataSource = self;
	table_.scrollEnabled = YES;
	table_.showsVerticalScrollIndicator = NO;
	table_.separatorStyle = UITableViewCellSeparatorStyleNone;
  //	table_.backgroundColor = [UIColor clearColor];
  table_.separatorColor = [UIColor colorWithRed:208.0/255.0 green:208.0/255.0 blue:208.0/255.0 alpha:1.0];
  table_.frame = CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height - 44);
	[self.view addSubview:table_];
  //	[self.view sendSubviewToBack:table_];
  
  
  //    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
  //      self.edgesForExtendedLayout = UIRectEdgeNone;
  // Uncomment the following line to preserve selection between presentations.
  // self.clearsSelectionOnViewWillAppear = NO;
  
  // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
  // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  // Return the number of sections.
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  // Return the number of rows in the section.
  return [self.conversations count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuse"];
  
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuse"];
  }
  Conversation * covn =   (Conversation*)[self.conversations objectAtIndex:indexPath.row];
  [cell.textLabel setText: covn.cid];
  // Configure the cell...
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  MsgViewController* msg = [[MsgViewController alloc] init];
  UINavigationController* navigation = [[UINavigationController alloc] initWithRootViewController:msg];
  navigation.view.backgroundColor = [UIColor grayColor];
  navigation.navigationBarHidden = NO;
  [self presentViewController:navigation animated:YES completion:nil];
  
}
/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

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
