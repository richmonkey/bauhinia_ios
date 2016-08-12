//
//  GroupNameViewController.h
//  Message
//
//  Created by houxh on 16/8/12.
//  Copyright © 2016年 daozhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GroupNameViewControllerDelegate <NSObject>
- (void)groupNameChanged:(NSString*)name;
@end

@interface GroupNameViewController : UIViewController
@property(nonatomic, assign) int64_t groupID;
@property(nonatomic, copy) NSString *topic;

@property(nonatomic, weak) id<GroupNameViewControllerDelegate> delegate;
@end
