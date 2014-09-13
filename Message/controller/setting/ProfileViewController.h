//
//  ProfileViewController.h
//  Message
//
//  Created by 杨朋亮 on 14-9-13.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@interface ProfileViewController : UIViewController <UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (IBAction) editorHeadAction:(id)sender;

-(IBAction) editorNameAction:(id)sender;

-(IBAction)editorStatus:(id)sender;
    

@end
