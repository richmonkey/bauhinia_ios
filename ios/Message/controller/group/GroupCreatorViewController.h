//
//  GroupCreatorController.h
//  Message
//
//  Created by houxh on 2017/1/15.
//  Copyright © 2017年 daozhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GroupCreatorViewControllerDelegate <NSObject>
-(void)onGroupCreated:(int64_t)gid name:(NSString*)name;
-(void)onGroupCreateCanceled;
@end

@interface GroupCreatorViewController : UIViewController

@property(nonatomic, weak) id<GroupCreatorViewControllerDelegate> delegate;
@end
