//
//  UIWebView+NativeScroll.h
//  FaFaLa
//
//  Created by longminxiang on 15/9/2.
//  Copyright (c) 2015年 shengtaian.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebView (NativeScroll)

typedef void (^wn_webViewBlock)(UIWebView *webView);

@property (nonatomic, readonly) UIScrollView *newScrollView;

- (void)supportNativeScroll;

- (void)setNewScrollViewDidSetContentSizeBlock:(wn_webViewBlock)newScrollViewDidSetContentSizeBlock;

@end
