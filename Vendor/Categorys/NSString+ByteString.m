//
//  NSString+ByteString.m
//  FaFaLa
//
//  Created by eric on 15/10/10.
//  Copyright © 2015年 shengtaian.com. All rights reserved.
//

#import "NSString+ByteString.h"

@implementation NSString (ByteString)

+ (NSString *)byteStringForLength:(unsigned long long)length
{
    NSString *string;
    if (length / 1000 <= 0) {
        string = [NSString stringWithFormat:@"%lld bit",length];
    }
    else {
        if (length / 1000000 <= 0) {
            float d = (float)length / 1000;
            string = [NSString stringWithFormat:@"%.2f KB",d];
        }
        else {
            float d = (float)length / 1000000;
            string = [NSString stringWithFormat:@"%.2f MB",d];
        }
    }
    return string;
}

@end
