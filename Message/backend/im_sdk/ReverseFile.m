//
//  ReverseFile.m
//  Message
//
//  Created by houxh on 14-7-22.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "ReverseFile.h"

@implementation ReverseFile
-(id)initWithFD:(int)fd {
    self = [super init];
    if (self) {
        self.pos = (int)lseek(fd, 0, SEEK_END);
        self.fd = fd;
    }
    return self;
}

-(void)dealloc {
    close(self.fd);
}

-(int)read:(char*)p length:(int)len {
    int n = pread(self.fd, p, len, self.pos - len);
    self.pos = self.pos - len;
    return n;
}
@end
