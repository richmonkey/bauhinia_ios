//
//  ProgressHubBridge.m
//  Message
//
//  Created by houxh on 16/8/11.
//  Copyright © 2016年 daozhu. All rights reserved.
//

#import "ProgressHudBridge.h"
#import "MBProgressHUD.h"

@implementation ProgressHudBridge
RCT_EXPORT_MODULE();
RCT_EXPORT_METHOD(showHud)
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

RCT_EXPORT_METHOD(showTextHud:(NSString*)text)
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = text;
}

RCT_EXPORT_METHOD(hideHud)
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

RCT_EXPORT_METHOD(hideTextHud:(NSString*)text)
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    hud.labelText = text;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}


@end
