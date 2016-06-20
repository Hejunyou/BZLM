//
//  UIView+ActionSheet.h
//  FaFaLa
//
//  Created by eric on 15/10/10.
//  Copyright © 2015年 shengtaian.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ActionSheet)

typedef void (^MXActionSheetBlock)(NSInteger buttonIndex);

- (void)showActionSheetWithBlock:(MXActionSheetBlock)block
                           title:(NSString *)title
               cancelButtonTitle:(NSString *)cancelButtonTitle
          destructiveButtonTitle:(NSString *)destructiveButtonTitle
                     otherTitles:(NSArray *)otherButtonTitles;

- (void)showActionSheetWithBlock:(MXActionSheetBlock)block
                           title:(NSString *)title
               cancelButtonTitle:(NSString *)cancelButtonTitle
          destructiveButtonTitle:(NSString *)destructiveButtonTitle
               otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

@end
