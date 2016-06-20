//
//  UIView+BorderView.m
//  FaFaLa
//
//  Created by longminxiang on 15/9/21.
//  Copyright © 2015年 shengtaian.com. All rights reserved.
//

#import "UIView+BorderView.h"

//画缺边矩形
void addRectToPath(CGContextRef context, CGRect rect, CGColorRef lineColor, float lineWidth, RectEdgeType edge)
{
    bool eT = NO, eR = NO,eB = NO,eL = NO;
    
    if (edge <= 0 || edge >= 15) {
        eT = eR = eB = eL = YES;
    }
    else {
        while (edge > 0) {
            RectEdgeType ed = log2(edge);
            ed = (int)pow(2, ed);
            switch (ed) {
                case RectTopEdge:eT = YES;break;
                case RectRightEdge:eR = YES;break;
                case RectBottomEdge:eB = YES;break;
                case RectLeftEdge:eL = YES;break;
                default:break;
            }
            edge -= ed;
        }
    }
    
    float fx = rect.origin.x - lineWidth;
    float fy = rect.origin.y - lineWidth;
    float fw = rect.size.width + lineWidth * 2;
    float fh = rect.size.height + lineWidth * 2;
    float fsx = fx + fw;
    float fsy = fy + fh;
    
    CGContextSetStrokeColorWithColor(context, lineColor);
    CGContextSetLineWidth(context, lineWidth);
    CGContextSaveGState(context);
    
    if (eT) {
        CGContextMoveToPoint(context, fx, fy);
        CGContextAddLineToPoint(context, fsx, fy);
    }
    if (eR) {
        CGContextMoveToPoint(context, fsx, fy);
        CGContextAddLineToPoint(context, fsx, fsy);
    }
    if (eB) {
        CGContextMoveToPoint(context, fx, fsy);
        CGContextAddLineToPoint(context, fsx, fsy);
    }
    if (eL) {
        CGContextMoveToPoint(context, fx, fy);
        CGContextAddLineToPoint(context, fx, fsy);
    }
    
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

@implementation BorderView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = [borderColor copy];
    [self setNeedsDisplay];
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    _borderWidth = borderWidth;
    [self setNeedsDisplay];
}

- (void)setEdge:(RectEdgeType)edge
{
    _edge = edge;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    rect = self.bounds;
    
    CGFloat borderWidth = self.borderWidth;
    rect = CGRectMake(borderWidth, borderWidth, rect.size.width - borderWidth * 2, rect.size.height - borderWidth *2);
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextClearRect(c, rect);
    addRectToPath(c, rect, self.borderColor.CGColor,self.borderWidth, self.edge);
    CGContextStrokePath(c);
}

@end

#define BOARDVIEW_TAG 55555

@implementation UIView (BorderView)

- (BorderView *)mxBorderView
{
    BorderView *view = (BorderView *)[self viewWithTag:BOARDVIEW_TAG];
    return view;
}

- (void)hideBoardView
{
    BorderView *view = [self mxBorderView];
    [view removeFromSuperview];
    view.hidden = YES;
    view = nil;
}

- (void)showBoardWithColor:(UIColor *)color width:(CGFloat)width boardEdge:(RectEdgeType)edge
{
    BorderView *view = [self mxBorderView];
    if (view) [view removeFromSuperview];
    view = [[BorderView alloc] initWithFrame:self.bounds];
    view.tag = BOARDVIEW_TAG;
    view.borderColor = color;
    view.borderWidth = width;
    view.edge = edge;
    [self addSubview:view];
}

@end
