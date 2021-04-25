//
//  TYSMMemoryCache.m
//  TYSMKit <https://github.com/ibireme/TYSMKit>
//
//  Created by ibireme on 15/2/7.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "TYSMMemoryCache.h"
#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <pthread.h>

#if __has_include("TYSMDispatchQueuePool.h")
#import "TYSMDispatchQueuePool.h"
#endif

#ifdef TYSMDispatchQueuePool_h
static inline dispatch_queue_t TYSMMemoryCacheGetReleaseQueue() {
    return TYSMDispatchQueueGetForQOS(NSQualityOfServiceUtility);
}
#else
static inline dispatch_queue_t TYSMMemoryCacheGetReleaseQueue() {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}
#endif

/**
 A node in linked map.
 Typically, you should not use this class directly.
 */
@interface _TYSMLinkedMapNode : NSObject {
    @package
    __unsafe_unretained _TYSMLinkedMapNode *_prev; // retained by dic
    __unsafe_unretained _TYSMLinkedMapNode *_next; // retained by dic
    id _key;
    id _value;
    NSUInteger _cost;
    NSTimeInterval _time;
}
@end

@implementation _TYSMLinkedMapNode
@end


/**
 A linked map used by TYSMMemoryCache.
 It's not thread-safe and does not validate the parameters.
 
 Typically, you should not use this class directly.
 */
@interface _TYSMLinkedMap : NSObject {
    @package
    CFMutableDictionaryRef _dic; // do not set object directly
    NSUInteger _totalCost;
    NSUInteger _totalCount;
    _TYSMLinkedMapNode *_head; // MRU, do not change it directly
    _TYSMLinkedMapNode *_tail; // LRU, do not change it directly
    BOOL _releaseOnMainThread;
    BOOL _releaseAsynchronously;
}

/// Insert a node at head and update the total cost.
/// Node and node.key should not be nil.
- (void)tysm_insertNodeAtHead:(_TYSMLinkedMapNode *)node;

/// Bring a inner node to header.
/// Node should already inside the dic.
- (void)tysm_bringNodeToHead:(_TYSMLinkedMapNode *)node;

/// Remove a inner node and update the total cost.
/// Node should already inside the dic.
- (void)tysm_removeNode:(_TYSMLinkedMapNode *)node;

/// Remove tail node if exist.
- (_TYSMLinkedMapNode *)tysm_removeTailNode;

/// Remove all node in background queue.
- (void)tysm_removeAll;

@end

@implementation _TYSMLinkedMap

- (instancetype)init {
    self = [super init];
    _dic = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    _releaseOnMainThread = NO;
    _releaseAsynchronously = YES;
    return self;
}

- (void)dealloc {
    CFRelease(_dic);
}

- (void)tysm_insertNodeAtHead:(_TYSMLinkedMapNode *)node {
    CFDictionarySetValue(_dic, (__bridge const void *)(node->_key), (__bridge const void *)(node));
    _totalCost += node->_cost;
    _totalCount++;
    if (_head) {
        node->_next = _head;
        _head->_prev = node;
        _head = node;
    } else {
        _head = _tail = node;
    }
}

- (void)tysm_bringNodeToHead:(_TYSMLinkedMapNode *)node {
    if (_head == node) return;
    
    if (_tail == node) {
        _tail = node->_prev;
        _tail->_next = nil;
    } else {
        node->_next->_prev = node->_prev;
        node->_prev->_next = node->_next;
    }
    node->_next = _head;
    node->_prev = nil;
    _head->_prev = node;
    _head = node;
}

- (void)tysm_removeNode:(_TYSMLinkedMapNode *)node {
    CFDictionaryRemoveValue(_dic, (__bridge const void *)(node->_key));
    _totalCost -= node->_cost;
    _totalCount--;
    if (node->_next) node->_next->_prev = node->_prev;
    if (node->_prev) node->_prev->_next = node->_next;
    if (_head == node) _head = node->_next;
    if (_tail == node) _tail = node->_prev;
}

- (_TYSMLinkedMapNode *)tysm_removeTailNode {
    if (!_tail) return nil;
    _TYSMLinkedMapNode *tail = _tail;
    CFDictionaryRemoveValue(_dic, (__bridge const void *)(_tail->_key));
    _totalCost -= _tail->_cost;
    _totalCount--;
    if (_head == _tail) {
        _head = _tail = nil;
    } else {
        _tail = _tail->_prev;
        _tail->_next = nil;
    }
    return tail;
}

- (void)tysm_removeAll {
    _totalCost = 0;
    _totalCount = 0;
    _head = nil;
    _tail = nil;
    if (CFDictionaryGetCount(_dic) > 0) {
        CFMutableDictionaryRef holder = _dic;
        _dic = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        
        if (_releaseAsynchronously) {
            dispatch_queue_t queue = _releaseOnMainThread ? dispatch_get_main_queue() : TYSMMemoryCacheGetReleaseQueue();
            dispatch_async(queue, ^{
                CFRelease(holder); // hold and release in specified queue
            });
        } else if (_releaseOnMainThread && !pthread_main_np()) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CFRelease(holder); // hold and release in specified queue
            });
        } else {
            CFRelease(holder);
        }
    }
}

@end



@implementation TYSMMemoryCache {
    pthread_mutex_t _lock;
    _TYSMLinkedMap *_lru;
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
    dispatch_async(_queue, ^{
        [self tysm__trimToCost:self->_costLimit];
        [self tysm__trimToCount:self->_countLimit];
        [self tysm__trimToAge:self->_ageLimit];
    });
}

- (void)tysm__trimToCost:(NSUInteger)costLimit {
    BOOL finish = NO;
    pthread_mutex_lock(&_lock);
    if (costLimit == 0) {
        [_lru tysm_removeAll];
        finish = YES;
    } else if (_lru->_totalCost <= costLimit) {
        finish = YES;
    }
    pthread_mutex_unlock(&_lock);
    if (finish) return;
    
    NSMutableArray *holder = [NSMutableArray new];
    while (!finish) {
        if (pthread_mutex_trylock(&_lock) == 0) {
            if (_lru->_totalCost > costLimit) {
                _TYSMLinkedMapNode *node = [_lru tysm_removeTailNode];
                if (node) [holder addObject:node];
            } else {
                finish = YES;
            }
            pthread_mutex_unlock(&_lock);
        } else {
            usleep(10 * 1000); //10 ms
        }
    }
    if (holder.count) {
        dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : TYSMMemoryCacheGetReleaseQueue();
        dispatch_async(queue, ^{
            [holder count]; // release in queue
        });
    }
}

- (void)tysm__trimToCount:(NSUInteger)countLimit {
    BOOL finish = NO;
    pthread_mutex_lock(&_lock);
    if (countLimit == 0) {
        [_lru tysm_removeAll];
        finish = YES;
    } else if (_lru->_totalCount <= countLimit) {
        finish = YES;
    }
    pthread_mutex_unlock(&_lock);
    if (finish) return;
    
    NSMutableArray *holder = [NSMutableArray new];
    while (!finish) {
        if (pthread_mutex_trylock(&_lock) == 0) {
            if (_lru->_totalCount > countLimit) {
                _TYSMLinkedMapNode *node = [_lru tysm_removeTailNode];
                if (node) [holder addObject:node];
            } else {
                finish = YES;
            }
            pthread_mutex_unlock(&_lock);
        } else {
            usleep(10 * 1000); //10 ms
        }
    }
    if (holder.count) {
        dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : TYSMMemoryCacheGetReleaseQueue();
        dispatch_async(queue, ^{
            [holder count]; // release in queue
        });
    }
}

- (void)tysm__trimToAge:(NSTimeInterval)ageLimit {
    BOOL finish = NO;
    NSTimeInterval now = CACurrentMediaTime();
    pthread_mutex_lock(&_lock);
    if (ageLimit <= 0) {
        [_lru tysm_removeAll];
        finish = YES;
    } else if (!_lru->_tail || (now - _lru->_tail->_time) <= ageLimit) {
        finish = YES;
    }
    pthread_mutex_unlock(&_lock);
    if (finish) return;
    
    NSMutableArray *holder = [NSMutableArray new];
    while (!finish) {
        if (pthread_mutex_trylock(&_lock) == 0) {
            if (_lru->_tail && (now - _lru->_tail->_time)> ageLimit) {
                _TYSMLinkedMapNode *node = [_lru tysm_removeTailNode];
                if (node) [holder addObject:node];
            } else {
                finish = YES;
            }
            pthread_mutex_unlock(&_lock);
        } else {
            usleep(10 * 1000); //10 ms
        }
    }
    if (holder.count) {
        dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : TYSMMemoryCacheGetReleaseQueue();
        dispatch_async(queue, ^{
            [holder count]; // release in queue
        });
    }
}

- (void)tysm__appDidReceiveMemoryWarningNotification {
    if (self.didReceiveMemoryWarningBlock) {
        self.didReceiveMemoryWarningBlock(self);
    }
    if (self.shouldRemoveAllObjectsOnMemoryWarning) {
        [self tysm_removeAllObjects];
    }
}

- (void)tysm__appDidEnterBackgroundNotification {
    if (self.didEnterBackgroundBlock) {
        self.didEnterBackgroundBlock(self);
    }
    if (self.shouldRemoveAllObjectsWhenEnteringBackground) {
        [self tysm_removeAllObjects];
    }
}

#pragma mark - public

- (instancetype)init {
    self = super.init;
    pthread_mutex_init(&_lock, NULL);
    _lru = [_TYSMLinkedMap new];
    _queue = dispatch_queue_create("com.ibireme.cache.memory", DISPATCH_QUEUE_SERIAL);
    
    _countLimit = NSUIntegerMax;
    _costLimit = NSUIntegerMax;
    _ageLimit = DBL_MAX;
    _autoTrimInterval = 5.0;
    _shouldRemoveAllObjectsOnMemoryWarning = YES;
    _shouldRemoveAllObjectsWhenEnteringBackground = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appDidReceiveMemoryWarningNotification) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appDidEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [self tysm__trimRecursively];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [_lru tysm_removeAll];
    pthread_mutex_destroy(&_lock);
}

- (NSUInteger)tysm_totalCount {
    pthread_mutex_lock(&_lock);
    NSUInteger count = _lru->_totalCount;
    pthread_mutex_unlock(&_lock);
    return count;
}

- (NSUInteger)tysm_totalCost {
    pthread_mutex_lock(&_lock);
    NSUInteger totalCost = _lru->_totalCost;
    pthread_mutex_unlock(&_lock);
    return totalCost;
}

- (BOOL)tysm_releaseOnMainThread {
    pthread_mutex_lock(&_lock);
    BOOL releaseOnMainThread = _lru->_releaseOnMainThread;
    pthread_mutex_unlock(&_lock);
    return releaseOnMainThread;
}

- (void)tysm_setReleaseOnMainThread:(BOOL)releaseOnMainThread {
    pthread_mutex_lock(&_lock);
    _lru->_releaseOnMainThread = releaseOnMainThread;
    pthread_mutex_unlock(&_lock);
}

- (BOOL)tysm_releaseAsynchronously {
    pthread_mutex_lock(&_lock);
    BOOL releaseAsynchronously = _lru->_releaseAsynchronously;
    pthread_mutex_unlock(&_lock);
    return releaseAsynchronously;
}

- (void)tysm_setReleaseAsynchronously:(BOOL)releaseAsynchronously {
    pthread_mutex_lock(&_lock);
    _lru->_releaseAsynchronously = releaseAsynchronously;
    pthread_mutex_unlock(&_lock);
}

- (BOOL)tysm_containsObjectForKey:(id)key {
    if (!key) return NO;
    pthread_mutex_lock(&_lock);
    BOOL contains = CFDictionaryContainsKey(_lru->_dic, (__bridge const void *)(key));
    pthread_mutex_unlock(&_lock);
    return contains;
}

- (id)tysm_objectForKey:(id)key {
    if (!key) return nil;
    pthread_mutex_lock(&_lock);
    _TYSMLinkedMapNode *node = CFDictionaryGetValue(_lru->_dic, (__bridge const void *)(key));
    if (node) {
        node->_time = CACurrentMediaTime();
        [_lru tysm_bringNodeToHead:node];
    }
    pthread_mutex_unlock(&_lock);
    return node ? node->_value : nil;
}

- (void)tysm_setObject:(id)object forKey:(id)key {
    [self tysm_setObject:object forKey:key withCost:0];
}

- (void)tysm_setObject:(id)object forKey:(id)key withCost:(NSUInteger)cost {
    if (!key) return;
    if (!object) {
        [self tysm_removeObjectForKey:key];
        return;
    }
    pthread_mutex_lock(&_lock);
    _TYSMLinkedMapNode *node = CFDictionaryGetValue(_lru->_dic, (__bridge const void *)(key));
    NSTimeInterval now = CACurrentMediaTime();
    if (node) {
        _lru->_totalCost -= node->_cost;
        _lru->_totalCost += cost;
        node->_cost = cost;
        node->_time = now;
        node->_value = object;
        [_lru tysm_bringNodeToHead:node];
    } else {
        node = [_TYSMLinkedMapNode new];
        node->_cost = cost;
        node->_time = now;
        node->_key = key;
        node->_value = object;
        [_lru tysm_insertNodeAtHead:node];
    }
    if (_lru->_totalCost > _costLimit) {
        dispatch_async(_queue, ^{
            [self tysm_trimToCost:_costLimit];
        });
    }
    if (_lru->_totalCount > _countLimit) {
        _TYSMLinkedMapNode *node = [_lru tysm_removeTailNode];
        if (_lru->_releaseAsynchronously) {
            dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : TYSMMemoryCacheGetReleaseQueue();
            dispatch_async(queue, ^{
                [node class]; //hold and release in queue
            });
        } else if (_lru->_releaseOnMainThread && !pthread_main_np()) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [node class]; //hold and release in queue
            });
        }
    }
    pthread_mutex_unlock(&_lock);
}

- (void)tysm_removeObjectForKey:(id)key {
    if (!key) return;
    pthread_mutex_lock(&_lock);
    _TYSMLinkedMapNode *node = CFDictionaryGetValue(_lru->_dic, (__bridge const void *)(key));
    if (node) {
        [_lru tysm_removeNode:node];
        if (_lru->_releaseAsynchronously) {
            dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : TYSMMemoryCacheGetReleaseQueue();
            dispatch_async(queue, ^{
                [node class]; //hold and release in queue
            });
        } else if (_lru->_releaseOnMainThread && !pthread_main_np()) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [node class]; //hold and release in queue
            });
        }
    }
    pthread_mutex_unlock(&_lock);
}

- (void)tysm_removeAllObjects {
    pthread_mutex_lock(&_lock);
    [_lru tysm_removeAll];
    pthread_mutex_unlock(&_lock);
}

- (void)tysm_trimToCount:(NSUInteger)count {
    if (count == 0) {
        [self tysm_removeAllObjects];
        return;
    }
    [self tysm__trimToCount:count];
}

- (void)tysm_trimToCost:(NSUInteger)cost {
    [self tysm__trimToCost:cost];
}

- (void)tysm_trimToAge:(NSTimeInterval)age {
    [self tysm__trimToAge:age];
}

- (NSString *)tysm_description {
    if (_name) return [NSString stringWithFormat:@"<%@: %p> (%@)", self.class, self, _name];
    else return [NSString stringWithFormat:@"<%@: %p>", self.class, self];
}

@end
