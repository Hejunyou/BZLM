//
//  NSString+Null.m
//  CoffeeBreaks
//
//  Created by longminxiang on 15/10/4.
//  Copyright © 2015年 eric. All rights reserved.
//

#import "NSString+Null.h"

extern BOOL NSStringIsNil(NSString *string)
{
    if (!string || ![string isKindOfClass:[NSString class]]) return YES;
    NSString *str = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    BOOL isNil = [str isEqualToString:@""];
    return isNil;
}

@implementation NSString (Null)

@end
