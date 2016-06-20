//
//  UIView+XibView.m
//  FaFaLa
//
//  Created by longminxiang on 15/8/25.
//  Copyright (c) 2015年 shengtaian.com. All rights reserved.
//

#import "UIView+XibView.h"

@implementation UIView (XibView)

+ (id)xibView
{
    @try {
        NSArray *viewArray = [[NSBundle mainBundle] loadNibNamed:[[self class] description] owner:nil options:nil];
        for (id object in viewArray) {
            if ([object isKindOfClass:[self class]]) {
                return object;
            }
        }
        return nil;
    }
    @catch (NSException *exception) {
        return nil;
    }
}

@end
