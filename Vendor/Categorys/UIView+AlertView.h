//
//  UIView+AlertView.h
//  FaFaLa
//
//  Created by eric on 15/10/10.
//  Copyright © 2015年 shengtaian.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AlertView)

typedef void (^MXAlertViewBlock)(NSInteger buttonIndex);

- (void)showAlertViewWithBlock:(MXAlertViewBlock)block
                         title:(NSString *)title
                       message:(NSString *)message
             cancelButtonTitle:(NSString *)cancelButtonTitle
             otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

- (void)showAlertViewWithMessage:(NSString *)message block:(MXAlertViewBlock)block;

@end
