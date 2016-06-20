//
//  UILabel+TextSize.m
//  FaFaLa
//
//  Created by eric on 16/4/21.
//  Copyright © 2016年 shengtaian.com. All rights reserved.
//

#import "UILabel+TextSize.h"
#import "NSString+TextSize.h"
#import <objc/runtime.h>

@implementation UILabel (TextSize)

- (void)mx_sizeToFitWithTextWidth:(CGFloat)width
{
    [self mx_sizeToFitWithTextWidth:width minHeight:0];
}

- (void)mx_sizeToFitWithText
{
    [self mx_sizeToFitWithTextWidth:0];
}

- (void)mx_sizeToFitWithTextWidth:(CGFloat)width minHeight:(CGFloat)minHeight
{
    if (!self.attributedText.length) return;
    NSRange range;
    NSDictionary *atts = [self.attributedText attributesAtIndex:0 effectiveRange:&range];
    CGRect tframe = self.frame;
    if (width > CGFLOAT_MIN) {
        tframe.size.width = width;
    }
    CGSize size = [self.text mx_textSizeWithAttributes:atts width:tframe.size.width];
    if (size.height < minHeight) {
        size.height = minHeight;
    }
    for (NSLayoutConstraint *constraint in self.constraints ) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            constraint.constant = size.height;
            break;
        }
    }
    tframe.size.height = size.height;
    self.frame = tframe;
}

@end
