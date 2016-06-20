//
//  NSString+TextSize.m
//  FaFaLa
//
//  Created by eric on 16/4/21.
//  Copyright © 2016年 shengtaian.com. All rights reserved.
//

#import "NSString+TextSize.h"

@implementation NSString (TextSize)

- (CGSize)mx_textSizeWithAttributes:(NSDictionary *)attributes width:(CGFloat)width
{
    NSArray *strings = [self componentsSeparatedByString:@"\n"];
    CGSize xsize = CGSizeZero;
    for (NSString *string in strings) {
        CGSize size = [string sizeWithAttributes:attributes];
        int fl = (int)(size.width / width) + 1;
        CGFloat height = size.height * fl;
        xsize.height += height + 1;
        if (size.width > xsize.width) {
            xsize.width = size.width;
        }
    }
    return xsize;
}

@end