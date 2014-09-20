//
//  ProfileViewController.h
//  Message
//
//  Created by 杨朋亮 on 14-9-13.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

typedef enum {
    ProfileEditorSettingType = 0,
    ProfileEditorLoginingType
} ProfileEditorType;


@interface ProfileViewController : UIViewController <UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate>

@property (nonatomic) ProfileEditorType editorState;

- (IBAction) editorHeadAction:(id)sender;

-(IBAction) editorNameAction:(id)sender;

-(IBAction)editorStatus:(id)sender;
    

@end
