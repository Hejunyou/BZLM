//
//  MXPopover.h
//  WuYe
//
//  Created by eric on 14/11/7.
//  Copyright (c) 2014年 ss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MXAnimation.h"

@interface MXContainView : UIView

@end

@interface MXPopover : NSObject

+ (void)enableTouchedDismiss:(BOOL)enable type:(MXAnimationOutType)type;

+ (void)enableBlurBackground:(BOOL)enable;

+ (void)popView:(UIView *)view inView:(UIView *)inView animationType:(MXAnimationInType)type completion:(void (^)(void))completion;

+ (void)popView:(UIView *)view animationType:(MXAnimationInType)type completion:(void (^)(void))completion;

+ (void)slideInWithView:(UIView *)view completion:(void (^)(void))completion;

+ (void)dismissWithType:(MXAnimationOutType)type completion:(void (^)(void))completion;

+ (void)dismiss:(void (^)(void))completion;

@end