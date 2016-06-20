//
//  MXStrongObject.m
//  MXStrongObject
//
//  Created by longminxiang on 15/9/24.
//  Copyright © 2015年 eric. All rights reserved.
//

#import "MXStrongObject.h"
#import <objc/runtime.h>

#pragma mark
#pragma mark === MXStrongObjectManager ===

@interface MXStrongObjectManager : NSObject

@property (nonatomic, readonly) NSMutableArray *strongObjects;
@property (nonatomic, weak) id owner;

@end

@interface NSObject (MXStrongObjectManager)

@property (nonatomic, readonly) MXStrongObjectManager *strongObjectManager;

@end

@implementation NSObject (MXStrongObjectManager)

- (MXStrongObjectManager *)strongObjectManager
{
    MXStrongObjectManager *manager = objc_getAssociatedObject(self, _cmd);
    if (!manager) {
        manager = [MXStrongObjectManager new];
        objc_setAssociatedObject(self, _cmd, manager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return manager;
}

@end

@implementation MXStrongObjectManager
@synthesize strongObjects = _strongObjects;

- (NSMutableArray *)strongObjects
{
    if (!_strongObjects) _strongObjects = [NSMutableArray new];
    return _strongObjects;
}

- (void)addStrongObject:(id)obj owner:(__weak id)owner
{
    if (!obj || !owner) return;
    if ([self.strongObjects containsObject:obj]) return;
    [self.strongObjects addObject:obj];
    [obj strongObjectManager].owner = owner;
}

- (void)removeStrongObject:(id)obj owner:(__weak id)owner
{
    if (!obj || !owner) return;
    if (![self.strongObjects containsObject:obj]) return;
    [obj strongObjectManager].owner = nil;
    [[owner strongObjectManager].strongObjects removeObject:obj];
}

@end

#pragma mark
#pragma mark === MXStrongObject ===

@implementation NSObject (MXStrongObject)

- (void)mx_addStrongObject:(id)obj
{
    [self.strongObjectManager addStrongObject:obj owner:self];
}

- (void)mx_removeStrongObject:(id)obj
{
    [self.strongObjectManager removeStrongObject:obj owner:self];
}

- (void)mx_removeStrongObjectFromOwner
{
    if (!self.strongObjectManager.owner) return;
    [self.strongObjectManager.owner mx_removeStrongObject:self];
}

@end