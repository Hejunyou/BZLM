//
//  UINavigationController+PanPop.m
//  FaFaLa
//
//  Created by longminxiang on 15/8/2.
//  Copyright (c) 2015年 shengtaian.com. All rights reserved.
//

#import "UINavigationController+PanPop.h"

@interface UINavigationController ()<UIGestureRecognizerDelegate>

@end

@implementation UINavigationController (PanPop)

- (void)addPanToPopGesture
{
    @try {
        UIScreenEdgePanGestureRecognizer *gesture = (UIScreenEdgePanGestureRecognizer *)self.interactivePopGestureRecognizer;
        NSDictionary* target = [gesture valueForKey:@"_targets"][0];
        target = [target valueForKey:@"target"];
        SEL sel = NSSelectorFromString(@"handleNavigationTransition:");
        
        UIPanGestureRecognizer *panGesture = [UIPanGestureRecognizer new];
        panGesture.delegate = self;
        [panGesture addTarget:target action:sel];
        [self.interactivePopGestureRecognizer.view addGestureRecognizer:panGesture];
        
        
    }
    @catch (NSException *exception) {}
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.viewControllers.count <= 1) return NO;
    
    if ([self.topViewController respondsToSelector:@selector(tableView:editingStyleForRowAtIndexPath:)]) {
        return NO;
    }
    
    return YES;
}

@end
