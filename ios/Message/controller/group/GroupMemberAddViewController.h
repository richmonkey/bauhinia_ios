//
//  GroupMemberAddViewController.h
//  Message
//
//  Created by houxh on 16/8/10.
//  Copyright © 2016年 daozhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  GroupMemberAddViewControllerDelegate<NSObject>
- (void)groupMemberAdded:(NSArray*)users;
@end

@interface GroupMemberAddViewController : UIViewController
@property(nonatomic, assign) int64_t groupID;
@property(nonatomic, weak) id<GroupMemberAddViewControllerDelegate> delegate;
@end
