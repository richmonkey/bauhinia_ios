//
//  GroupMemberRemoveViewController.h
//  Message
//
//  Created by houxh on 16/8/11.
//  Copyright © 2016年 daozhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GroupMemberRemoveViewControllerDelegate <NSObject>
- (void)groupMemberDeleted:(NSNumber*)memberID;
@end

@interface GroupMemberRemoveViewController : UIViewController
@property(nonatomic, assign) int64_t groupID;
@property(nonatomic, weak) id<GroupMemberRemoveViewControllerDelegate> delegate;
@end
