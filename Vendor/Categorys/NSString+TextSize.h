//
//  NSString+TextSize.h
//  FaFaLa
//
//  Created by eric on 16/4/21.
//  Copyright © 2016年 shengtaian.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TextSize)

- (CGSize)mx_textSizeWithAttributes:(NSDictionary *)attributes width:(CGFloat)width;

@end
