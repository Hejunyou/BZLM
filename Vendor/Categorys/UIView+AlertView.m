//
//  UIView+AlertView.m
//  FaFaLa
//
//  Created by eric on 15/10/10.
//  Copyright © 2015年 shengtaian.com. All rights reserved.
//

#import "UIView+AlertView.h"

@implementation UIView (AlertView)

static MXAlertViewBlock _alertViewBlock;

- (void)showAlertViewWithBlock:(MXAlertViewBlock)block
                         title:(NSString *)title
                       message:(NSString *)message
             cancelButtonTitle:(NSString *)cancelButtonTitle
             otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION
{
    _alertViewBlock = block;
    UIAlertView *alertView = [UIAlertView new];
    [alertView setTitle:title];
    [alertView setMessage:message];
    [alertView setDelegate:self];
    NSInteger cancelButtonIndex = [alertView addButtonWithTitle:cancelButtonTitle];
    [alertView setCancelButtonIndex:cancelButtonIndex];
    va_list args;
    va_start(args, otherButtonTitles);
    while (otherButtonTitles) {
        [alertView addButtonWithTitle:otherButtonTitles];
        otherButtonTitles = va_arg(args, id);
    }
    va_end(args);
    [alertView show];
}

- (void)showAlertViewWithMessage:(NSString *)message block:(MXAlertViewBlock)block
{
    [self showAlertViewWithBlock:block title:nil message:message cancelButtonTitle:@"确定" otherButtonTitles:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (_alertViewBlock) _alertViewBlock(buttonIndex);
}


@end
