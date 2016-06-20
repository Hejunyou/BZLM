//
//  UIWebView+NativeScroll.m
//  FaFaLa
//
//  Created by longminxiang on 15/9/2.
//  Copyright (c) 2015年 shengtaian.com. All rights reserved.
//

#import "UIWebView+NativeScroll.h"
#import <objc/runtime.h>

void webview_class_swizzleMethodAndStore(Class class, SEL originalSelector, SEL swizzledSelector)
{
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (success) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@interface UIWebView ()<UIScrollViewDelegate>

@property (nonatomic, assign) BOOL didSupportNativeScroll;
@property (nonatomic, copy) wn_webViewBlock newScrollViewDidSetContentSizeBlock;

@end

@implementation UIWebView (NativeScroll)

const static char* didSupportNativeScrollKey = "didSupportNativeScroll";
const static char* newScrollViewDidSetContentSizeBlockKey = "newScrollViewDidSetContentSizeBlock";

- (void)setNewScrollViewDidSetContentSizeBlock:(wn_webViewBlock)newScrollViewDidSetContentSizeBlock
{
    objc_setAssociatedObject(self, newScrollViewDidSetContentSizeBlockKey, newScrollViewDidSetContentSizeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (wn_webViewBlock)newScrollViewDidSetContentSizeBlock
{
    return objc_getAssociatedObject(self, newScrollViewDidSetContentSizeBlockKey);
}

- (BOOL)didSupportNativeScroll
{
    id ns = objc_getAssociatedObject(self, didSupportNativeScrollKey);
    return [ns boolValue];
}

- (void)setDidSupportNativeScroll:(BOOL)didSupportNativeScroll
{
    objc_setAssociatedObject(self, didSupportNativeScrollKey, @(didSupportNativeScroll), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIScrollView *)newScrollView
{
    if (!self.didSupportNativeScroll) return nil;
    UIScrollView *scrollView = objc_getAssociatedObject(self, _cmd);
    if (scrollView) return scrollView;
    scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    scrollView.alwaysBounceVertical = YES;
    scrollView.delegate = self;
    scrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:scrollView];
    objc_setAssociatedObject(self, _cmd, scrollView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return scrollView;
}

- (void)supportNativeScroll
{
    if (self.didSupportNativeScroll) return;
    self.didSupportNativeScroll = YES;
    
    self.scrollView.scrollEnabled = NO;
    [self.newScrollView addSubview:self.scrollView];
    [self.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        webview_class_swizzleMethodAndStore([self class], @selector(setFrame:), @selector(wn_setFrame:));
        SEL dea = NSSelectorFromString(@"dealloc");
        webview_class_swizzleMethodAndStore([self class], dea, @selector(wn_dealloc));
        webview_class_swizzleMethodAndStore([self class], @selector(scrollViewWillBeginDragging:), @selector(wn_scrollViewWillBeginDragging:));
        webview_class_swizzleMethodAndStore([self class], @selector(scrollViewDidEndDragging:willDecelerate:), @selector(wn_scrollViewDidEndDragging:willDecelerate:));
        webview_class_swizzleMethodAndStore([self class], @selector(scrollViewDidScroll:), @selector(wn_scrollViewDidScroll:));
        webview_class_swizzleMethodAndStore([self class], @selector(scrollViewDidEndDecelerating:), @selector(wn_scrollViewDidEndDecelerating:));
    });
}

- (void)wn_setFrame:(CGRect)frame
{
    [self wn_setFrame:frame];
    frame.origin = CGPointZero;
    self.newScrollView.frame = frame;
}

- (void)wn_scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.newScrollView) {
        [self wn_scrollViewWillBeginDragging:self.scrollView];
    }
}

- (void)wn_scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == self.newScrollView) {
        [self wn_scrollViewDidEndDragging:self.scrollView willDecelerate:decelerate];
    }
}

- (void)wn_scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.newScrollView) {
        [self wn_scrollViewDidScroll:self.scrollView];
    }
}

- (void)wn_scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.newScrollView) {
        [self wn_scrollViewDidEndDecelerating:self.scrollView];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.scrollView && [keyPath isEqualToString:@"contentSize"]) {
        CGSize contentSize = self.scrollView.contentSize;
        
        CGRect frame = self.scrollView.frame;
        frame.size = contentSize;
        self.scrollView.frame = frame;
        
        self.newScrollView.contentSize = contentSize;
        if (self.newScrollViewDidSetContentSizeBlock) self.newScrollViewDidSetContentSizeBlock(self);
    }
}

- (void)wn_dealloc
{
    if (self.didSupportNativeScroll) {
        [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
        self.newScrollView.delegate = nil;
    }
    [self wn_dealloc];
}

@end
