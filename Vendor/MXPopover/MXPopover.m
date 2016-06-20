//
//  MXPopover.m
//  WuYe
//
//  Created by eric on 14/11/7.
//  Copyright (c) 2014年 ss. All rights reserved.
//

#import "MXPopover.h"
#import <Accelerate/Accelerate.h>

#pragma mark
#pragma mark === UIImage Category ===

@interface UIImage (mxp_Blur)

@end

@implementation UIImage (mxp_Blur)

- (UIImage *)mxp_applyBlurWithRadius:(CGFloat)blurRadius
                       tintColor:(UIColor *)tintColor
           saturationDeltaFactor:(CGFloat)saturationDeltaFactor
                       maskImage:(UIImage *)maskImage
{
    // Check pre-conditions.
    if (self.size.width < 1 || self.size.height < 1) {
        NSLog (@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
        return nil;
    }
    if (!self.CGImage) {
        NSLog (@"*** error: image must be backed by a CGImage: %@", self);
        return nil;
    }
    if (maskImage && !maskImage.CGImage) {
        NSLog (@"*** error: maskImage must be backed by a CGImage: %@", maskImage);
        return nil;
    }
    
    CGRect imageRect = { CGPointZero, self.size };
    UIImage *effectImage = self;
    
    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    if (hasBlur || hasSaturationChange) {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectInContext = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectInContext, 1.0, -1.0);
        CGContextTranslateCTM(effectInContext, 0, -self.size.height);
        CGContextDrawImage(effectInContext, imageRect, self.CGImage);
        
        vImage_Buffer effectInBuffer;
        effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
        effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
        
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
        
        if (hasBlur) {
            // A description of how to compute the box kernel width from the Gaussian
            // radius (aka standard deviation) appears in the SVG spec:
            // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
            //
            // For larger values of 's' (s >= 2.0), an approximation can be used: Three
            // successive box-blurs build a piece-wise quadratic convolution kernel, which
            // approximates the Gaussian kernel to within roughly 3%.
            //
            // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
            //
            // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
            //
            CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
            uint32_t radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (radius % 2 != 1) {
                radius += 1; // force radius to be odd so that the three box-blur methodology works.
            }
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
        }
        BOOL effectImageBuffersAreSwapped = NO;
        if (hasSaturationChange) {
            CGFloat s = saturationDeltaFactor;
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,  1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            if (hasBlur) {
                vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
                effectImageBuffersAreSwapped = YES;
            }
            else {
                vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            }
        }
        if (!effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // Set up output context.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.size.height);
    
    // Draw base image.
    CGContextDrawImage(outputContext, imageRect, self.CGImage);
    
    // Draw effect image.
    if (hasBlur) {
        CGContextSaveGState(outputContext);
        if (maskImage) {
            CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
        }
        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
        CGContextRestoreGState(outputContext);
    }
    
    // Add in color tint.
    if (tintColor) {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, imageRect);
        CGContextRestoreGState(outputContext);
    }
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}

@end

#pragma mark === MXContainView ===

@interface MXContainView ()

typedef void (^MXContainViewTouchedBlock)(MXContainView *mview, UITouch *touch);

@property (nonatomic, readonly) UIImageView *backgroundView;
@property (nonatomic, assign) BOOL enableTouchedDismiss;
@property (nonatomic, copy) MXContainViewTouchedBlock tblock;

@end

@implementation MXContainView
@synthesize backgroundView = _backgroundView;

- (UIImageView *)backgroundView
{
    if (!_backgroundView) {
        _backgroundView = [UIImageView new];
        [self addSubview:_backgroundView];
    }
    return _backgroundView;
}

- (BOOL)resignFirstResponder
{
    [self.subviews makeObjectsPerformSelector:@selector(resignFirstResponder)];
    return [super resignFirstResponder];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self.backgroundView setFrame:self.bounds];
}

- (void)dismiss:(void (^)(void))block
{
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    if (block) block();
}

- (void)makeBlurBackground
{
    UIWindow *keyWindow = [[UIApplication sharedApplication].delegate window];
    CGRect rect = [keyWindow bounds];
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    [keyWindow drawViewHierarchyInRect:rect afterScreenUpdates:YES];
    UIImage *capturedScreen = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *blurSnapshotImage = [capturedScreen mxp_applyBlurWithRadius:3.0f tintColor:[UIColor colorWithWhite:0.4f alpha:0.6f] saturationDeltaFactor:1.8f maskImage:nil];
    self.backgroundView.image = blurSnapshotImage;
}

- (void)setTouchedBlock:(MXContainViewTouchedBlock)block
{
    self.tblock = block;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self resignFirstResponder];
    if (!self.enableTouchedDismiss) return;
    UITouch *touch = [touches anyObject];
    if (self.tblock) self.tblock(self, touch);
}

- (void)dealloc
{
    NSLog(@"%@ dealloc", [[self class] description]);
}

@end

#pragma mark === MXPopver ===

@interface MXPopover ()

@property (nonatomic, readonly) MXContainView *containView;
@property (nonatomic, weak) UIView *view;
@property (nonatomic, assign) MXAnimationOutType disMissType;

@end

@implementation MXPopover
@synthesize containView = _containView;

+ (instancetype)instance
{
    static id object;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object = [self new];
    });
    return object;
}

- (MXContainView *)containView
{
    if (!_containView) {
        _containView = [MXContainView new];
        __weak MXPopover *weaks = self;
        [_containView setTouchedBlock:^(MXContainView *mview, UITouch *touch) {
            [weaks performTouhcedDismiss:touch];
        }];
    };
    return _containView;
}

- (void)setView:(UIView *)view
{
    _view = view;
    if (view.superview != self.containView)
        [self.containView addSubview:view];
}

- (void)performTouhcedDismiss:(UITouch *)touch
{
    if (touch.view == self.view) return;
    [self dismissWithType:self.disMissType completion:nil];
}

- (void)fadeInContainViewInView:(UIView *)view
{
    CGRect frame = self.view.frame;
    CGRect cframe = view.bounds;
    self.containView.frame = cframe;
    self.view.frame = frame;
    [self.containView makeBlurBackground];
    [view addSubview:self.containView];
    self.containView.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.containView.alpha = 1;
    }];
}

#pragma mark
#pragma mark === animation ===

- (void)animationWithView:(UIView *)view inView:(UIView *)inView type:(MXAnimationInType)type completion:(void (^)(void))completion
{
    self.view = view;
    [self fadeInContainViewInView:inView];
    [MXAnimation animatedView:view inType:type inDuration:0.5 inDelay:0 completion:completion];
}

- (void)animationInWindowWithView:(UIView *)view type:(MXAnimationInType)type completion:(void (^)(void))completion
{
    UIApplication *app = [UIApplication sharedApplication];
    UIWindow *window = app.keyWindow;
    if (!window && [app.delegate respondsToSelector:@selector(window)]) {
        window = [app.delegate window];
    }
    [self animationWithView:view inView:window type:type completion:completion];
}

- (void)dismissWithType:(MXAnimationOutType)type completion:(void (^)(void))completion
{
    [self dismiss:completion];
    [MXAnimation animatedView:self.view out:type outDuration:0.5 outDelay:0 completion:nil];
}

- (void)dismiss:(void (^)(void))completion
{
    [UIView animateWithDuration:0.5 animations:^{
        self.containView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.containView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj != self.containView.backgroundView) {
                [obj removeFromSuperview];
            }
        }];
        [self.containView removeFromSuperview];
        if (completion) completion();
    }];
}

+ (void)popView:(UIView *)view inView:(UIView *)inView animationType:(MXAnimationInType)type completion:(void (^)(void))completion
{
    [[self instance] animationWithView:view inView:inView type:type completion:completion];
}

+ (void)popView:(UIView *)view animationType:(MXAnimationInType)type completion:(void (^)(void))completion
{
    [[self instance] animationInWindowWithView:view type:type completion:completion];
}

+ (void)dismissWithType:(MXAnimationOutType)type completion:(void (^)(void))completion
{
    [[self instance] dismissWithType:type completion:completion];
}

+ (void)dismiss:(void (^)(void))completion
{
    MXPopover *popover = [self instance];
    [popover dismissWithType:popover.disMissType completion:completion];
}

+ (void)enableTouchedDismiss:(BOOL)enable type:(MXAnimationOutType)type
{
    MXPopover *popover = [self instance];
    popover.disMissType = type;
    popover.containView.enableTouchedDismiss = enable;
}

+ (void)enableBlurBackground:(BOOL)enable
{
    MXPopover *popover = [self instance];
    popover.containView.backgroundView.hidden = !enable;
}

+ (void)slideInWithView:(UIView *)view completion:(void (^)(void))completion
{
    [[self instance] animationInWindowWithView:view type:MXAnimationSlideInLeftBottom completion:completion];
}

@end
