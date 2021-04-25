//
//  TYSMCache.m
//  TYSMKit <https://github.com/ibireme/TYSMKit>
//
//  Created by ibireme on 15/2/13.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "TYSMCache.h"
#import "TYSMMemoryCache.h"
#import "TYSMDiskCache.h"

@implementation TYSMCache

- (instancetype) init {
    NSLog(@"Use \"initWithName\" or \"initWithPath\" to create TYSMCache instance.");
    return [self initWithPath:@""];
}

- (instancetype)initWithName:(NSString *)name {
    if (name.length == 0) return nil;
    NSString *cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [cacheFolder stringByAppendingPathComponent:name];
    return [self initWithPath:path];
}

- (instancetype)initWithPath:(NSString *)path {
    if (path.length == 0) return nil;
    TYSMDiskCache *diskCache = [[TYSMDiskCache alloc] initWithPath:path];
    if (!diskCache) return nil;
    NSString *name = [path lastPathComponent];
    TYSMMemoryCache *memoryCache = [TYSMMemoryCache new];
    memoryCache.name = name;
    
    self = [super init];
    _name = name;
    _diskCache = diskCache;
    _memoryCache = memoryCache;
    return self;
}

+ (instancetype)cacheWithName:(NSString *)name {
	return [[self alloc] initWithName:name];
}

+ (instancetype)cacheWithPath:(NSString *)path {
    return [[self alloc] initWithPath:path];
}

- (BOOL)tysm_containsObjectForKey:(NSString *)key {
    return [_memoryCache tysm_containsObjectForKey:key] || [_diskCache tysm_containsObjectForKey:key];
}

- (void)tysm_containsObjectForKey:(NSString *)key withBlock:(void (^)(NSString *key, BOOL contains))block {
    if (!block) return;
    
    if ([_memoryCache tysm_containsObjectForKey:key]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            block(key, YES);
        });
    } else  {
        [_diskCache tysm_containsObjectForKey:key withBlock:block];
    }
}

- (id<NSCoding>)tysm_objectForKey:(NSString *)key {
    id<NSCoding> object = [_memoryCache tysm_objectForKey:key];
    if (!object) {
        object = [_diskCache tysm_objectForKey:key];
        if (object) {
            [_memoryCache tysm_setObject:object forKey:key];
        }
    }
    return object;
}

- (void)tysm_objectForKey:(NSString *)key withBlock:(void (^)(NSString *key, id<NSCoding> object))block {
    if (!block) return;
    id<NSCoding> object = [_memoryCache tysm_objectForKey:key];
    if (object) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            block(key, object);
        });
    } else {
        [_diskCache tysm_objectForKey:key withBlock:^(NSString *key, id<NSCoding> object) {
            if (object && ![_memoryCache tysm_objectForKey:key]) {
                [_memoryCache tysm_setObject:object forKey:key];
            }
            block(key, object);
        }];
    }
}

- (void)tysm_setObject:(id<NSCoding>)object forKey:(NSString *)key {
    [_memoryCache tysm_setObject:object forKey:key];
    [_diskCache tysm_setObject:object forKey:key];
}

- (void)tysm_setObject:(id<NSCoding>)object forKey:(NSString *)key withBlock:(void (^)(void))block {
    [_memoryCache tysm_setObject:object forKey:key];
    [_diskCache tysm_setObject:object forKey:key withBlock:block];
}

- (void)tysm_removeObjectForKey:(NSString *)key {
    [_memoryCache tysm_removeObjectForKey:key];
    [_diskCache tysm_removeObjectForKey:key];
}

- (void)tysm_removeObjectForKey:(NSString *)key withBlock:(void (^)(NSString *key))block {
    [_memoryCache tysm_removeObjectForKey:key];
    [_diskCache tysm_removeObjectForKey:key withBlock:block];
}

- (void)tysm_removeAllObjects {
    [_memoryCache tysm_removeAllObjects];
    [_diskCache tysm_removeAllObjects];
}

- (void)tysm_removeAllObjectsWithBlock:(void(^)(void))block {
    [_memoryCache tysm_removeAllObjects];
    [_diskCache tysm_removeAllObjectsWithBlock:block];
}

- (void)tysm_removeAllObjectsWithProgressBlock:(void(^)(int removedCount, int totalCount))progress
                                 endBlock:(void(^)(BOOL error))end {
    [_memoryCache tysm_removeAllObjects];
    [_diskCache tysm_removeAllObjectsWithProgressBlock:progress endBlock:end];
    
}

- (NSString *)tysm_description {
    if (_name) return [NSString stringWithFormat:@"<%@: %p> (%@)", self.class, self, _name];
    else return [NSString stringWithFormat:@"<%@: %p>", self.class, self];
}

@end
