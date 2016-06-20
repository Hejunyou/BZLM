//
//  NSString+ByteString.h
//  FaFaLa
//
//  Created by eric on 15/10/10.
//  Copyright © 2015年 shengtaian.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ByteString)

+ (NSString *)byteStringForLength:(unsigned long long)length;

@end
