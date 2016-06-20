//
//  UILabel+TextSize.h
//  FaFaLa
//
//  Created by eric on 16/4/21.
//  Copyright © 2016年 shengtaian.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (TextSize)

- (void)mx_sizeToFitWithText;

- (void)mx_sizeToFitWithTextWidth:(CGFloat)width;

- (void)mx_sizeToFitWithTextWidth:(CGFloat)width minHeight:(CGFloat)minHeight;

@end
