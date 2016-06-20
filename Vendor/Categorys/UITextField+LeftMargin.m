//
//  UITextField+LeftMargin.m
//  FaFaLa
//
//  Created by longminxiang on 15/12/9.
//  Copyright © 2015年 shengtaian.com. All rights reserved.
//

#import "UITextField+LeftMargin.h"

@implementation UITextField (LeftMargin)

- (void)setLeftMargin:(float)left
{
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, left, 0)];
    [leftView setBackgroundColor:[UIColor clearColor]];
    [self setLeftViewMode:UITextFieldViewModeAlways];
    [self setLeftView:leftView];
}

@end
