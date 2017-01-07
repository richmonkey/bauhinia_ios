//
//  Constants.h
//  Message
//
//  Created by daozhu on 14-6-20.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#ifndef Message_Constants_h
#define Message_Constants_h

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define SETCOLOR(RED,GREEN,BLUE) [UIColor colorWithRed:RED/255 green:GREEN/255 blue:BLUE/255 alpha:1.0]

//RGB颜色
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
//RGB颜色和不透明度
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f \
alpha:(a)]

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

//Address Book contact
#define KPHONELABELDICDEFINE		@"KPhoneLabelDicDefine"
#define KPHONENUMBERDICDEFINE	@"KPhoneNumberDicDefine"
#define KPHONENAMEDICDEFINE	@"KPhoneNameDicDefine"

#define KTabBarHeight  49
#define KNavigationBarHeight 44
#define kStatusBarHeight 20
#define kSearchBarHeight 44
#define kTabBarHeight 49


//NSNotificaiton
#define CREATE_NEW_GROUP        @"create_new_group"

//from imkit
//最近发出的消息
#define LATEST_GROUP_MESSAGE       @"latest_group_message"
#define LATEST_PEER_MESSAGE        @"latest_peer_message"

//清空会话的未读消息数
#define CLEAR_PEER_NEW_MESSAGE @"clear_peer_single_conv_new_message_notify"
#define CLEAR_GROUP_NEW_MESSAGE @"clear_group_single_conv_new_message_notify"


#endif
