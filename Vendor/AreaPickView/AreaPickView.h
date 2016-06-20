//
//  AreaPickView.h
//  QCS
//
//  Created by selife on 12-8-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AreaManager : NSObject

+ (NSArray *)areaArray;

+ (NSString *)areaStringWithAreaIds:(NSArray *)ids;

+ (void)findAreasWithKeys:(NSArray *)keys completion:(void (^)(NSArray *areas, NSArray *indexs))completion;

@end

@interface AreaPickView : UIView

typedef void (^AreaPickViewBlock)(AreaPickView *picker, NSArray *selectedIndexs, NSArray *selectedValues);

+ (void)showWithTitle:(NSString *)title componentCount:(NSInteger)count initialSelection:(NSArray *)selections doneBlock:(AreaPickViewBlock)block;

@end