//
//  UINavigationBar+BottomLine.m
//  FaFaLa
//
//  Created by eric on 15/12/3.
//  Copyright © 2015年 shengtaian.com. All rights reserved.
//

#import "UINavigationBar+BottomLine.h"

@implementation UINavigationBar (BottomLine)

- (void)hideBottomLine
{
    for (UIView *view in self.subviews) {
        if (![view isKindOfClass:[UIImageView class]]) continue;
        for (UIView *sview in view.subviews) {
            if (![sview isKindOfClass:[UIImageView class]]) continue;
            sview.hidden = YES;
        }
    }
}

@end
