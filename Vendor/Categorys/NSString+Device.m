//
//  NSString+Device.m
//  FaFaLa
//
//  Created by longminxiang on 16/1/6.
//  Copyright © 2016年 shengtaian.com. All rights reserved.
//

#import "NSString+Device.h"

@implementation NSString (Device)

+ (NSString *)appVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return version;
}

@end

