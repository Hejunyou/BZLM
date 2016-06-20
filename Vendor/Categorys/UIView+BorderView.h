//
//  UIView+BorderView.h
//  FaFaLa
//
//  Created by longminxiang on 15/9/21.
//  Copyright © 2015年 shengtaian.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger,RectEdgeType) {
    RectDefaultEdge = 0,
    RectTopEdge = 1 << 0,
    RectRightEdge = 1 << 1,
    RectBottomEdge = 1 << 2,
    RectLeftEdge = 1 << 3,
    RectAllEdge = 15
};

@interface BorderView : UIView

@property (nonatomic, copy) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) RectEdgeType edge;

@end

@interface UIView (BorderView)

@property (nonatomic, readonly) BorderView *mxBorderView;

- (void)hideBoardView;
- (void)showBoardWithColor:(UIColor *)color width:(CGFloat)width boardEdge:(RectEdgeType)edge;

@end