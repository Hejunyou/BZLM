//
//  NSString+Validate.m
//
//  Created by eric on 15/11/16.
//  Copyright © 2015年 Eric Lung. All rights reserved.
//

#import "NSString+Validate.h"

@implementation NSString (Validate)

- (BOOL)isPhoneNumber
{
    if ([self length] == 0) return NO;
    NSString *regex = @"^((13[0-9])|(147)|(177)|(15[^4,\\D])|(18[0,5-9]))\\d{8}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:self];
    return isMatch;
}

@end
