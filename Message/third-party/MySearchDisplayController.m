//
//  MySearchDisplayController.m
//  Message
//
//  Created by daozhu on 14-7-22.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "MySearchDisplayController.h"

@implementation MySearchDisplayController

- (void)setActive:(BOOL)visible animated:(BOOL)animated
{
    [super setActive: visible animated: animated];
    
    [self.searchContentsController.navigationController setNavigationBarHidden: NO animated: NO];
}

@end
