//
//  SystemProperty.m
//  Message
//
//  Created by 杨朋亮 on 14-9-14.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "SystemProperty.h"


#define  kImageSettingKey       @"autoLoadImg"
#define  kAudioSettingKey       @"autoLoadAudio"
#define  kbackImgeSettingKey    @"backgroundImg"
#define  kNameStringKey         @"nameString"

@implementation SystemProperty


+(SystemProperty*)instance {
    static SystemProperty *cfg;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!cfg) {
            cfg = [[SystemProperty alloc] init];
        }
    });
    return cfg;
}

-(id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSNumber*) loadAudioSetting{
   
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *plistPath1 = [paths objectAtIndex:0];
    NSString *filename = [plistPath1 stringByAppendingPathComponent:@"setting.plist"];
    
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:filename];
    return [settings objectForKey:kAudioSettingKey];
    
}

-(void) setLoadAudioSetting:(NSNumber *)loadAudioSetting{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"setting" ofType:@"plist"];
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    [settings setObject:loadAudioSetting forKey:kAudioSettingKey];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *plistPath1 = [paths objectAtIndex:0];
    
    //得到完整的文件名
    NSString *filename = [plistPath1 stringByAppendingPathComponent:@"setting.plist"];
    //输入写入
    [settings writeToFile:filename atomically:YES];
}

- (NSNumber*) loadImageSetting{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *plistPath1 = [paths objectAtIndex:0];
    NSString *filename = [plistPath1 stringByAppendingPathComponent:@"setting.plist"];
    
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:filename];
    return [settings objectForKey:kImageSettingKey];
    
}

-(void) setLoadImageSetting:(NSNumber *)loadImageSetting{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"setting" ofType:@"plist"];
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    [settings setObject:loadImageSetting forKey:kImageSettingKey];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *plistPath1 = [paths objectAtIndex:0];
    
    //得到完整的文件名
    NSString *filename = [plistPath1 stringByAppendingPathComponent:@"setting.plist"];
    //输入写入
    [settings writeToFile:filename atomically:YES];
    
}
- (NSString*) ImgBackgroundSetting{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *plistPath1 = [paths objectAtIndex:0];
    NSString *filename = [plistPath1 stringByAppendingPathComponent:@"setting.plist"];
    
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:filename];
    
    return [settings objectForKey:kImageSettingKey];
    
}

-(void) setImgBackgroundSetting:(NSString *) ImgStr{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"setting" ofType:@"plist"];
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    [settings setObject:ImgStr forKey:kbackImgeSettingKey];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *plistPath1 = [paths objectAtIndex:0];
    
    //得到完整的文件名
    NSString *filename = [plistPath1 stringByAppendingPathComponent:@"setting.plist"];
    //输入写入
    [settings writeToFile:filename atomically:YES];
    
}

- (NSString*) nameString{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *plistPath1 = [paths objectAtIndex:0];
    NSString *filename = [plistPath1 stringByAppendingPathComponent:@"setting.plist"];
    
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:filename];
    
    return [settings objectForKey:kNameStringKey];
    
}

-(void) setNameString:(NSString *) ImgStr{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"setting" ofType:@"plist"];
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    [settings setObject:ImgStr forKey:kNameStringKey];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *plistPath1 = [paths objectAtIndex:0];
    
    //得到完整的文件名
    NSString *filename = [plistPath1 stringByAppendingPathComponent:@"setting.plist"];
    //输入写入
    [settings writeToFile:filename atomically:YES];
    
}

@end
