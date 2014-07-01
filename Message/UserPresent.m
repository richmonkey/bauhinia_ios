//
//  UserPresent.m
//  Message
//
//  Created by daozhu on 14-7-1.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "UserPresent.h"

@implementation UserPresent


+(UserPresent*)instance {
  static UserPresent *im;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    if (!im) {
      im = [[UserPresent alloc] init];
    }
  });
  return im;
}

-(id)init{
  if (self = [super init]) {
    
  }
  return self;
}


@end
