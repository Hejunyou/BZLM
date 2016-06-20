//
//  NSObject+Hooker.h
//  FaFaLa
//
//  Created by eric on 16/4/8.
//  Copyright © 2016年 shengtaian.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

void mx_comon_hook_class_swizzleMethodAndStore(Class class, SEL originalSelector, SEL swizzledSelector);

@interface NSObject (Hooker)

@end
