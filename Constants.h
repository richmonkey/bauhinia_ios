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

//Address Book contact
#define KPHONELABELDICDEFINE		@"KPhoneLabelDicDefine"
#define KPHONENUMBERDICDEFINE	@"KPhoneNumberDicDefine"
#define KPHONENAMEDICDEFINE	@"KPhoneNameDicDefine"


#define CREATE_NEW_CONVERSATION @"creat_new_conversation"



#endif
