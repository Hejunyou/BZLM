//
//  AreaPickView.m
//  QCS
//
//  Created by selife on 12-8-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AreaPickView.h"

@implementation AreaManager

+ (NSArray *)areaArray
{
    static NSArray *array;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        array = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"area" ofType:@"plist"]];
    });
    return array;
}

+ (void)findAreaWithKey:(id)key inArray:(NSArray *)array completion:(void (^)(NSDictionary *area, NSUInteger idx))completion
{
    [array enumerateObjectsUsingBlock:^(NSDictionary *area, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *name = area[@"name"];
        long long areaId = [area[@"areaId"] longLongValue];
        if ([key isKindOfClass:[NSString class]]) {
            if ([key isEqualToString:name] || [key longLongValue] == areaId) {
                if (completion) completion(area, idx);
                *stop = YES;
            }
        }
        else if ([key isKindOfClass:[NSNumber class]]) {
            if ([key longLongValue] == areaId) {
                if (completion) completion(area, idx);
                *stop = YES;
            }
        }
    }];
}

+ (void)findAreasWithKeys:(NSArray *)keys completion:(void (^)(NSArray *areas, NSArray *indexs))completion
{
    NSInteger count = keys.count;
    if (count > 3) count = 3;
    NSMutableArray *areas = [NSMutableArray new];
    NSMutableArray *indexs = [NSMutableArray new];
    __block NSArray *array = [self areaArray];
    [keys enumerateObjectsUsingBlock:^(id  _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        [self findAreaWithKey:key inArray:array completion:^(NSDictionary *area, NSUInteger idx) {
            if (area) {
                [areas addObject:area];
                [indexs addObject:@(idx)];
                array = area[@"subArea"];
            }
        }];
    }];
    if (!areas.count) areas = nil;
    if (!indexs.count) indexs = nil;
    if (completion) completion(areas, indexs);
}

+ (NSString *)areaStringWithAreaIds:(NSArray *)ids
{
    __block NSString *string = @"";
    [self findAreasWithKeys:ids completion:^(NSArray *areas, NSArray *indexs) {
        [areas enumerateObjectsUsingBlock:^(NSDictionary *area, NSUInteger idx, BOOL * _Nonnull stop) {
            string = [NSString stringWithFormat:@"%@ %@", string, area[@"name"]];
        }];
    }];
    return string;
}

@end

@interface AreaPickView ()<UIPickerViewDelegate>

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIToolbar *pickerToobar;

@property (nonatomic, strong) UIBarButtonItem *titleItem;
@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) NSInteger componentCount;

@property (nonatomic, readonly) NSMutableDictionary *selectedIndexDictionary;

@property (nonatomic, strong) NSArray *initialSelections;

@property (nonatomic, copy) AreaPickViewBlock doneBlock;

@end

@implementation AreaPickView

+ (UIWindow *)keyWindow
{
    UIApplication *app = [UIApplication sharedApplication];
    UIWindow *rvc = app.keyWindow;
    if (rvc) return rvc;
    
    id delegate = app.delegate;
    if ([delegate respondsToSelector:@selector(window)]) {
        rvc = [delegate window];
    }
    return rvc;
}

+ (void)showWithTitle:(NSString *)title componentCount:(NSInteger)count initialSelection:(NSArray *)selections doneBlock:(AreaPickViewBlock)block
{
    UIView *view = [self keyWindow];
    AreaPickView *aview = [[AreaPickView alloc] initWithFrame:view.bounds];
    aview.title = title;
    aview.componentCount = count;
    aview.initialSelections = selections;
    aview.doneBlock = block;
    [view addSubview:aview];
    [aview show:YES];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    CGRect bounds = self.bounds;
    UIView *bgView = [[UIView alloc] initWithFrame:bounds];
    bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [self addSubview:bgView];
    self.backgroundView = bgView;
    bgView.alpha = 0;
    
    CGRect tframe = bounds;
    tframe.origin.y = tframe.size.height;
    tframe.size.height = 44;
    UIToolbar *pickerToobar = [[UIToolbar alloc] initWithFrame:tframe];

    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(returnButtonTouched:)];
    [cancelItem setWidth:60];

    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonTouched:)];
    [doneItem setWidth:60];
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] init];
    [spaceItem setWidth:bounds.size.width - 60 * 2 - 20];
    spaceItem.title = self.title;
    [spaceItem setEnabled:NO];
    self.titleItem = spaceItem;
    
    [pickerToobar setItems:@[cancelItem,spaceItem,doneItem]];
    [self addSubview:pickerToobar];
    self.pickerToobar = pickerToobar;
    
    CGRect pframe = bounds;
    pframe.size.height = 216;
    pframe.origin.y = tframe.origin.y + tframe.size.height;
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:pframe];
    pickerView.backgroundColor = [UIColor whiteColor];
    [pickerView setShowsSelectionIndicator:YES];
    [pickerView setDelegate:self];
    [self addSubview:pickerView];
    self.pickerView = pickerView;
    
    _selectedIndexDictionary = [NSMutableDictionary new];
}

- (void)setTitle:(NSString *)title
{
    _title = [title copy];
    self.titleItem.title = title;
}

- (void)show:(BOOL)show
{
    CGRect frame = self.bounds;
    CGRect tframe = self.pickerToobar.frame;
    CGRect pframe = self.pickerView.frame;
    if (show) {
        pframe.origin.y = frame.size.height - pframe.size.height;
        tframe.origin.y = pframe.origin.y - tframe.size.height;
    }
    else {
        tframe.origin.y = frame.size.height;
        pframe.origin.y = tframe.origin.y + tframe.size.height;
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.pickerView.frame = pframe;
        self.pickerToobar.frame = tframe;
        self.backgroundView.alpha = show;
    } completion:^(BOOL finished) {
        if (!show) [self removeFromSuperview];
    }];
}

- (void)setComponentCount:(NSInteger)componentCount
{
    if (componentCount < 1) componentCount = 1;
    else if (componentCount > 3) componentCount = 3;
    _componentCount = componentCount;
    for (int i = 0; i < componentCount; i++) {
        self.selectedIndexDictionary[@(i)] = @(0);
    }
}

- (void)setInitialSelections:(NSArray *)initialSelections
{
    _initialSelections = initialSelections;
    
    [AreaManager findAreasWithKeys:initialSelections completion:^(NSArray *areas, NSArray *indexs) {
        for (int i = 0; i < indexs.count; i++) {
            id index = indexs[i];
            self.selectedIndexDictionary[@(i)] = index;
            [self.pickerView selectRow:[index intValue] inComponent:i animated:YES];
        }
    }];
}

- (NSArray *)areasWithComponent:(NSInteger)component
{
    if (component == 0) {
        return [AreaManager areaArray];
    }
    else if (component == 1){
        NSInteger idx = [self.selectedIndexDictionary[@(0)] integerValue];
        NSDictionary *dic = [AreaManager areaArray][idx];
        return dic[@"subArea"];
    }
    else if (component == 2){
        NSInteger idx = [self.selectedIndexDictionary[@(0)] integerValue];
        NSDictionary *dic = [AreaManager areaArray][idx];
        NSArray *array = dic[@"subArea"];
        NSInteger idx1 = [self.selectedIndexDictionary[@(1)] integerValue];
        NSDictionary *dic1 = array[idx1];
        return dic1[@"subArea"];
    }
    return nil;
}

- (NSDictionary *)areaWithComponent:(NSInteger)component index:(NSInteger)inedex
{
    NSArray *areas = [self areasWithComponent:component];
    return areas[inedex];
}

#pragma mark
#pragma mark === delegate ===

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return self.componentCount;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self areasWithComponent:component].count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSDictionary *area = [self areaWithComponent:component index:row];
    NSString *string = area[@"name"];
    return string;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectedIndexDictionary[@(component)] = @(row);
    if (component == 0) {
        if (self.componentCount > 1) {
            self.selectedIndexDictionary[@(1)] = @(0);
            [pickerView reloadComponent:1];
            [pickerView selectRow:0 inComponent:1 animated:YES];
        }
        if (self.componentCount > 2) {
            self.selectedIndexDictionary[@(2)] = @(0);
            [pickerView reloadComponent:2];
            [pickerView selectRow:0 inComponent:2 animated:YES];
        }
    }
    else if (component == 1){
        if (self.componentCount > 2) {
            self.selectedIndexDictionary[@(2)] = @(0);
            [pickerView reloadComponent:2];
            [pickerView selectRow:0 inComponent:2 animated:YES];
        }
    }
}

- (void)returnButtonTouched:(UIButton *)button
{
    [self show:NO];
}

- (void)doneButtonTouched:(UIButton *)button
{
    NSMutableArray *indexs = [NSMutableArray new];
    NSMutableArray *values = [NSMutableArray new];
    for (int i = 0; i < self.componentCount; i++) {
        id selectedIndex = self.selectedIndexDictionary[@(i)];
        [indexs addObject:selectedIndex];
        NSMutableDictionary *area = [NSMutableDictionary new];
        [area addEntriesFromDictionary:[self areaWithComponent:i index:[selectedIndex integerValue]]];
        [area removeObjectForKey:@"subArea"];
        [values addObject:area];
    }
    if (self.doneBlock) self.doneBlock(self, indexs, values);
    [self show:NO];
}

@end
