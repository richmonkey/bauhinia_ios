//
//  SystemProperty.h
//  Message
//
//  Created by 杨朋亮 on 14-9-14.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SystemProperty : NSObject

+(SystemProperty*)instance;

@property (nonatomic) NSNumber *loadAudioSetting;
@property (nonatomic) NSNumber *loadImageSetting;
@property (nonatomic) NSString *ImgBackgroundSetting;
@property (nonatomic) NSString *backgroundString;

@end
