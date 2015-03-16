//
//  Util.m
//  imkit
//
//  Created by 杨朋亮 on 15/3/15.
//  Copyright (c) 2015年 beetle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StringUtil.h"

@implementation StringUtil

+ (NSString *)runsForString:(NSString *)str
{
    NSMutableString *mString = [NSMutableString stringWithString:str];
    NSString *temp;
    NSError *error = nil;
//    NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    
//    NSString *regulaStr = @"\\bhttps?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
    
    NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if (error == nil)
    {
        NSArray *arrayOfAllMatches = [regex matchesInString:mString
                                                    options:0
                                                      range:NSMakeRange(0, [mString length])];
        
        for (NSTextCheckingResult *match in arrayOfAllMatches)
        {
            NSString* substringForMatch = [mString substringWithRange:match.range];
            NSString *replaceString = [NSString stringWithFormat:@"<a href=\"%@\" >%@</a>",substringForMatch,substringForMatch];
           temp = [mString stringByReplacingOccurrencesOfString:substringForMatch
                                               withString:replaceString];
            mString = [NSMutableString stringWithString:temp];
        }
    }else{
        return [NSString stringWithString:mString];
    }
    if (temp) {
        return [NSString stringWithString:temp];
    }else{
        return str;
    }
}

@end