//
//  TYSMDiskCache.m
//  TYSMKit <https://github.com/ibireme/TYSMKit>
//
//  Created by ibireme on 15/2/11.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "TYSMDiskCache.h"
#import "TYSMKVStorage.h"
#import "NSString+TYSMAdd.h"
#import "UIDevice+TYSMAdd.h"
#import <objc/runtime.h>
#import <time.h>

#define Lock() dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER)
#define Unlock() dispatch_semaphore_signal(self->_lock)

static const int extended_data_key;

/// Free disk space in bytes.
static int64_t _TYSMDiskSpaceFree() {
    NSError *error = nil;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) return -1;
    int64_t space =  [[attrs objectForKey:NSFileSystemFreeSize] longLongValue];
    if (space < 0) space = -1;
    return space;
}


/// weak reference for all instances
static NSMapTable *_globalInstances;
static dispatch_semaphore_t _globalInstancesLock;

static void _TYSMDiskCacheInitGlobal() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _globalInstancesLock = dispatch_semaphore_create(1);
        _globalInstances = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:0];
    });
}

static TYSMDiskCache *_TYSMDiskCacheGetGlobal(NSString *path) {
    if (path.length == 0) return nil;
    _TYSMDiskCacheInitGlobal();
    dispatch_semaphore_wait(_globalInstancesLock, DISPATCH_TIME_FOREVER);
    id cache = [_globalInstances objectForKey:path];
    dispatch_semaphore_signal(_globalInstancesLock);
    return cache;
}

static void _TYSMDiskCacheSetGlobal(TYSMDiskCache *cache) {
    if (cache.path.length == 0) return;
    _TYSMDiskCacheInitGlobal();
    dispatch_semaphore_wait(_globalInstancesLock, DISPATCH_TIME_FOREVER);
    [_globalInstances setObject:cache forKey:cache.path];
    dispatch_semaphore_signal(_globalInstancesLock);
}



@implementation TYSMDiskCache {
    TYSMKVStorage *_kv;
    dispatch_semaphore_t _lock;
    dispatch_queue_t _queue;
}

- (void)tysm__trimRecursively {
    __weak typeof(self) _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_autoTrimInterval * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        __strong typeof(_self) self = _self;
        if (!self) return;
        [self tysm__trimInBackground];
        [self tysm__trimRecursively];
    });
}

- (void)tysm__trimInBackground {
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        if (!self) return;
        Lock();
        [self tysm__trimToCost:self.costLimit];
        [self tysm__trimToCount:self.countLimit];
        [self tysm__trimToAge:self.ageLimit];
        [self tysm__trimToFreeDiskSpace:self.freeDiskSpaceLimit];
        Unlock();
    });
}

- (void)tysm__trimToCost:(NSUInteger)costLimit {
    if (costLimit >= INT_MAX) return;
    [_kv tysm_removeItemsToFitSize:(int)costLimit];
    
}

- (void)tysm__trimToCount:(NSUInteger)countLimit {
    if (countLimit >= INT_MAX) return;
    [_kv tysm_removeItemsToFitCount:(int)countLimit];
}

- (void)tysm__trimToAge:(NSTimeInterval)ageLimit {
    if (ageLimit <= 0) {
        [_kv tysm_removeAllItems];
        return;
    }
    long timestamp = time(NULL);
    if (timestamp <= ageLimit) return;
    long age = timestamp - ageLimit;
    if (age >= INT_MAX) return;
    [_kv tysm_removeItemsEarlierThanTime:(int)age];
}

- (void)tysm__trimToFreeDiskSpace:(NSUInteger)targetFreeDiskSpace {
    if (targetFreeDiskSpace == 0) return;
    int64_t totalBytes = [_kv tysm_getItemsSize];
    if (totalBytes <= 0) return;
    int64_t diskFreeBytes = _TYSMDiskSpaceFree();
    if (diskFreeBytes < 0) return;
    int64_t needTrimBytes = targetFreeDiskSpace - diskFreeBytes;
    if (needTrimBytes <= 0) return;
    int64_t costLimit = totalBytes - needTrimBytes;
    if (costLimit < 0) costLimit = 0;
    [self tysm__trimToCost:(int)costLimit];
}

- (NSString *)tysm__filenameForKey:(NSString *)key {
    NSString *filename = nil;
    if (_customFileNameBlock) filename = _customFileNameBlock(key);
    if (!filename) filename = key.tysm_md5String;
    return filename;
}

- (void)tysm__appWillBeTerminated {
    Lock();
    _kv = nil;
    Unlock();
}

#pragma mark - public

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"TYSMDiskCache init error" reason:@"TYSMDiskCache must be initialized with a path. Use 'initWithPath:' or 'initWithPath:inlineThreshold:' instead." userInfo:nil];
    return [self initWithPath:@"" inlineThreshold:0];
}

- (instancetype)initWithPath:(NSString *)path {
    return [self initWithPath:path inlineThreshold:1024 * 20]; // 20KB
}

- (instancetype)initWithPath:(NSString *)path
             inlineThreshold:(NSUInteger)threshold {
    self = [super init];
    if (!self) return nil;
    
    TYSMDiskCache *globalCache = _TYSMDiskCacheGetGlobal(path);
    if (globalCache) return globalCache;
    
    TYSMKVStorageType type;
    if (threshold == 0) {
        type = TYSMKVStorageTypeFile;
    } else if (threshold == NSUIntegerMax) {
        type = TYSMKVStorageTypeSQLite;
    } else {
        type = TYSMKVStorageTypeMixed;
    }
    
    TYSMKVStorage *kv = [[TYSMKVStorage alloc] initWithPath:path type:type];
    if (!kv) return nil;
    
    _kv = kv;
    _path = path;
    _lock = dispatch_semaphore_create(1);
    _queue = dispatch_queue_create("com.ibireme.cache.disk", DISPATCH_QUEUE_CONCURRENT);
    _inlineThreshold = threshold;
    _countLimit = NSUIntegerMax;
    _costLimit = NSUIntegerMax;
    _ageLimit = DBL_MAX;
    _freeDiskSpaceLimit = 0;
    _autoTrimInterval = 60;
    
    [self tysm__trimRecursively];
    _TYSMDiskCacheSetGlobal(self);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appWillBeTerminated) name:UIApplicationWillTerminateNotification object:nil];
    return self;
}

- (BOOL)tysm_containsObjectForKey:(NSString *)key {
    if (!key) return NO;
    Lock();
    BOOL contains = [_kv tysm_itemExistsForKey:key];
    Unlock();
    return contains;
}

- (void)tysm_containsObjectForKey:(NSString *)key withBlock:(void(^)(NSString *key, BOOL contains))block {
    if (!block) return;
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        BOOL contains = [self tysm_containsObjectForKey:key];
        block(key, contains);
    });
}

- (id<NSCoding>)tysm_objectForKey:(NSString *)key {
    if (!key) return nil;
    Lock();
    TYSMKVStorageItem *item = [_kv tysm_getItemForKey:key];
    Unlock();
    if (!item.value) return nil;
    
    id object = nil;
    if (_customUnarchiveBlock) {
        object = _customUnarchiveBlock(item.value);
    } else {
        @try {
            object = [NSKeyedUnarchiver unarchiveObjectWithData:item.value];
        }
        @catch (NSException *exception) {
            // nothing to do...
        }
    }
    if (object && item.extendedData) {
        [TYSMDiskCache setExtendedData:item.extendedData toObject:object];
    }
    return object;
}

- (void)tysm_objectForKey:(NSString *)key withBlock:(void(^)(NSString *key, id<NSCoding> object))block {
    if (!block) return;
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        id<NSCoding> object = [self tysm_objectForKey:key];
        block(key, object);
    });
}

- (void)tysm_setObject:(id<NSCoding>)object forKey:(NSString *)key {
    if (!key) return;
    if (!object) {
        [self tysm_removeObjectForKey:key];
        return;
    }
    
    NSData *extendedData = [TYSMDiskCache getExtendedDataFromObject:object];
    NSData *value = nil;
    if (_customArchiveBlock) {
        value = _customArchiveBlock(object);
    } else {
        @try {
            value = [NSKeyedArchiver archivedDataWithRootObject:object];
        }
        @catch (NSException *exception) {
            // nothing to do...
        }
    }
    if (!value) return;
    NSString *filename = nil;
    if (_kv.type != TYSMKVStorageTypeSQLite) {
        if (value.length > _inlineThreshold) {
            filename = [self tysm__filenameForKey:key];
        }
    }
    
    Lock();
    [_kv tysm_saveItemWithKey:key value:value filename:filename extendedData:extendedData];
    Unlock();
}

- (void)tysm_setObject:(id<NSCoding>)object forKey:(NSString *)key withBlock:(void(^)(void))block {
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        [self tysm_setObject:object forKey:key];
        if (block) block();
    });
}

- (void)tysm_removeObjectForKey:(NSString *)key {
    if (!key) return;
    Lock();
    [_kv tysm_removeItemForKey:key];
    Unlock();
}

- (void)tysm_removeObjectForKey:(NSString *)key withBlock:(void(^)(NSString *key))block {
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        [self tysm_removeObjectForKey:key];
        if (block) block(key);
    });
}

- (void)tysm_removeAllObjects {
    Lock();
    [_kv tysm_removeAllItems];
    Unlock();
}

- (void)tysm_removeAllObjectsWithBlock:(void(^)(void))block {
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        [self tysm_removeAllObjects];
        if (block) block();
    });
}

- (void)tysm_removeAllObjectsWithProgressBlock:(void(^)(int removedCount, int totalCount))progress
                                 endBlock:(void(^)(BOOL error))end {
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        if (!self) {
            if (end) end(YES);
            return;
        }
        Lock();
        [_kv tysm_removeAllItemsWithProgressBlock:progress endBlock:end];
        Unlock();
    });
}

- (NSInteger)tysm_totalCount {
    Lock();
    int count = [_kv tysm_getItemsCount];
    Unlock();
    return count;
}

- (void)tysm_totalCountWithBlock:(void(^)(NSInteger totalCount))block {
    if (!block) return;
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        NSInteger totalCount = [self tysm_totalCount];
        block(totalCount);
    });
}

- (NSInteger)tysm_totalCost {
    Lock();
    int count = [_kv tysm_getItemsSize];
    Unlock();
    return count;
}

- (void)tysm_totalCostWithBlock:(void(^)(NSInteger totalCost))block {
    if (!block) return;
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        NSInteger totalCost = [self tysm_totalCost];
        block(totalCost);
    });
}

- (void)tysm_trimToCount:(NSUInteger)count {
    Lock();
    [self tysm__trimToCount:count];
    Unlock();
}

- (void)tysm_trimToCount:(NSUInteger)count withBlock:(void(^)(void))block {
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        [self tysm_trimToCount:count];
        if (block) block();
    });
}

- (void)tysm_trimToCost:(NSUInteger)cost {
    Lock();
    [self tysm__trimToCost:cost];
    Unlock();
}

- (void)tysm_trimToCost:(NSUInteger)cost withBlock:(void(^)(void))block {
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        [self tysm_trimToCost:cost];
        if (block) block();
    });
}

- (void)tysm_trimToAge:(NSTimeInterval)age {
    Lock();
    [self tysm__trimToAge:age];
    Unlock();
}

- (void)tysm_trimToAge:(NSTimeInterval)age withBlock:(void(^)(void))block {
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        [self tysm_trimToAge:age];
        if (block) block();
    });
}

+ (NSData *)getExtendedDataFromObject:(id)object {
    if (!object) return nil;
    return (NSData *)objc_getAssociatedObject(object, &extended_data_key);
}

+ (void)setExtendedData:(NSData *)extendedData toObject:(id)object {
    if (!object) return;
    objc_setAssociatedObject(object, &extended_data_key, extendedData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)tysm_description {
    if (_name) return [NSString stringWithFormat:@"<%@: %p> (%@:%@)", self.class, self, _name, _path];
    else return [NSString stringWithFormat:@"<%@: %p> (%@)", self.class, self, _path];
}

- (BOOL)tysm_errorLogsEnabled {
    Lock();
    BOOL enabled = _kv.errorLogsEnabled;
    Unlock();
    return enabled;
}

- (void)tysm_setErrorLogsEnabled:(BOOL)errorLogsEnabled {
    Lock();
    _kv.errorLogsEnabled = errorLogsEnabled;
    Unlock();
}

@end
