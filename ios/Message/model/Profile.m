//
//  Profile.m
//  Message
//
//  Created by daozhu on 14-7-1.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "Profile.h"
#import "Token.h"
#import "UserDB.h"

@implementation Profile

+(Profile*)instance {
    static Profile *im;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!im) {
            im = [[Profile alloc] init];
            [im load];
        }
    });
    return im;
}



-(void)load {
    NSDictionary *dict = [self loadDictionary];
    if (!dict) {
        //兼容旧版本
        Token *tok = [Token instance];
        User *u = [[UserDB instance] loadUser:tok.uid];
        if (u) {
            self.phoneNumber = u.phoneNumber;
            self.uid= u.uid;
            self.avatarURL = u.avatarURL;
            self.state = u.state;
        }
    } else {
        self.uid = [[dict objectForKey:@"uid"] longLongValue];
        self.avatarURL = [dict objectForKey:@"avatar"];
        self.state = [dict objectForKey:@"state"];
        
        PhoneNumber *pn = [[PhoneNumber alloc] init];
        pn.zone = [dict objectForKey:@"zone"];
        pn.number = [dict objectForKey:@"number"];
        self.phoneNumber = pn;
        
        self.name = [dict objectForKey:@"name"];
        if (!self.name) {
            self.name = @"";
        }
        
        self.avatarURL = [dict objectForKey:@"avatar"];
        if (!self.avatarURL) {
            self.avatarURL = @"";
        }
    }
}


-(void)save {
    NSDictionary *dict = @{@"uid":@(self.uid),
                           @"avatar":self.avatarURL?self.avatarURL:@"",
                           @"state":self.state?self.state:@"",
                           @"name":self.name?self.name:@"",
                           @"zone":self.phoneNumber.zone?self.phoneNumber.zone:@"",
                           @"number":self.phoneNumber.number?self.phoneNumber.number:@""};
    
    [self storeDictionary:dict];
}


-(NSString*)getDocumentPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


- (NSDictionary*)loadDictionary {
    NSString *docPath = [self getDocumentPath];
    NSString *fullFileName = [NSString stringWithFormat:@"%@/profile", docPath];
    NSDictionary* panelLibraryContent = [NSDictionary dictionaryWithContentsOfFile:fullFileName];
    return panelLibraryContent;
}


- (void)storeDictionary:(NSDictionary*) dictionaryToStore {
    NSString *docPath = [self getDocumentPath];
    NSString *fullFileName = [NSString stringWithFormat:@"%@/profile", docPath];
    
    if (dictionaryToStore != nil) {
        [dictionaryToStore writeToFile:fullFileName atomically:YES];
    }
}


@end
