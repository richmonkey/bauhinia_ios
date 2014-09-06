//
//  APITests.m
//  Message
//
//  Created by houxh on 14-9-6.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "APIRequest.h"

@interface APITests : XCTestCase

@end

@implementation APITests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testUploadImage
{
    UIImage *img = [UIImage imageNamed:@"potrait"];
    
    __block NSString *avatarURL = nil;
    [APIRequest uploadImage:img
                    success:^(NSString *url) {
                        NSLog(@"image url:%@", url);
                        avatarURL = url;
                        CFRunLoopStop(CFRunLoopGetCurrent());
                    }
                       fail:^() {
                           NSLog(@"upload image fail");
                            CFRunLoopStop(CFRunLoopGetCurrent());
                       }];
    
    CFRunLoopRun();
}

@end
