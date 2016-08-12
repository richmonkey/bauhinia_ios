//
//  Config.m
//  Message
//
//  Created by houxh on 14-7-7.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "Config.h"

@implementation Config
+(Config*)instance {
    static Config *cfg;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!cfg) {
            cfg = [[Config alloc] init];
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
#if 1
-(NSString*)URL {
    return @"http://bauhinia.gobelieve.io";
}

-(NSString*)downloadURL {
    return [[self URL] stringByAppendingString:@"/download"];
}

-(NSString*)sdkAPIURL {
    return @"http://api.gobelieve.io";
}

-(NSString*)sdkHost {
    return @"imnode.gobelieve.io";
}
#else

-(NSString*)URL {
    return @"http://192.168.1.101";
}

-(NSString*)downloadURL {
    return [[self URL] stringByAppendingString:@"/download"];
}

-(NSString*)sdkAPIURL {
    return @"http://192.168.1.101:23002";
}

-(NSString*)sdkHost {
    return @"192.168.1.101";
}
#endif
@end
