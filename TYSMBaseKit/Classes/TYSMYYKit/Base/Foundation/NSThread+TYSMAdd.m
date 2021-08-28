//
//  NSThread+TYSMAdd.h
//  YYKit <https://github.com/ibireme/YYKit>
//
//  Created by ibireme on 15/7/3.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "NSThread+TYSMAdd.h"
#import <CoreFoundation/CoreFoundation.h>

@interface NSThread_TYSMAdd : NSObject @end
@implementation NSThread_TYSMAdd @end

#if __has_feature(objc_arc)
#error This file must be compiled without ARC. Specify the -fno-objc-arc flag to this file.
#endif

static NSString *const TYSMNSThreadAutoleasePoolKey = @"TYSMNSThreadAutoleasePoolKey";
static NSString *const TYSMNSThreadAutoleasePoolStackKey = @"TYSMNSThreadAutoleasePoolStackKey";

static const void *tysm_PoolStackRetainCallBack(CFAllocatorRef allocator, const void *value) {
    return value;
}

static void tysm_PoolStackReleaseCallBack(CFAllocatorRef allocator, const void *value) {
    CFRelease((CFTypeRef)value);
}


static inline void TYSMAutoreleasePoolPush() {
    NSMutableDictionary *dic =  [NSThread currentThread].threadDictionary;
    NSMutableArray *poolStack = dic[TYSMNSThreadAutoleasePoolStackKey];
    
    if (!poolStack) {
        /*
         do not retain pool on push,
         but release on pop to avoid memory analyze warning
         */
        CFArrayCallBacks callbacks = {0};
        callbacks.retain = tysm_PoolStackRetainCallBack;
        callbacks.release = tysm_PoolStackReleaseCallBack;
        poolStack = (id)CFArrayCreateMutable(CFAllocatorGetDefault(), 0, &callbacks);
        dic[TYSMNSThreadAutoleasePoolStackKey] = poolStack;
        CFRelease(poolStack);
    }
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; // create
    [poolStack addObject:pool]; // push
}

static inline void TYSMAutoreleasePoolPop() {
    NSMutableDictionary *dic =  [NSThread currentThread].threadDictionary;
    NSMutableArray *poolStack = dic[TYSMNSThreadAutoleasePoolStackKey];
    [poolStack removeLastObject]; // pop
}

static void TYSMRunLoopAutoreleasePoolObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    switch (activity) {
        case kCFRunLoopEntry: {
            TYSMAutoreleasePoolPush();
        } break;
        case kCFRunLoopBeforeWaiting: {
            TYSMAutoreleasePoolPop();
            TYSMAutoreleasePoolPush();
        } break;
        case kCFRunLoopExit: {
            TYSMAutoreleasePoolPop();
        } break;
        default: break;
    }
}

static void TYSMRunloopAutoreleasePoolSetup() {
    CFRunLoopRef runloop = CFRunLoopGetCurrent();

    CFRunLoopObserverRef pushObserver;
    pushObserver = CFRunLoopObserverCreate(CFAllocatorGetDefault(), kCFRunLoopEntry,
                                           true,         // repeat
                                           -0x7FFFFFFF,  // before other observers
                                           TYSMRunLoopAutoreleasePoolObserverCallBack, NULL);
    CFRunLoopAddObserver(runloop, pushObserver, kCFRunLoopCommonModes);
    CFRelease(pushObserver);
    
    CFRunLoopObserverRef popObserver;
    popObserver = CFRunLoopObserverCreate(CFAllocatorGetDefault(), kCFRunLoopBeforeWaiting | kCFRunLoopExit,
                                          true,        // repeat
                                          0x7FFFFFFF,  // after other observers
                                          TYSMRunLoopAutoreleasePoolObserverCallBack, NULL);
    CFRunLoopAddObserver(runloop, popObserver, kCFRunLoopCommonModes);
    CFRelease(popObserver);
}

@implementation NSThread (YYAdd)

+ (void)tysm_addAutoreleasePoolToCurrentRunloop {
    if ([NSThread isMainThread]) return; // The main thread already has autorelease pool.
    NSThread *thread = [self currentThread];
    if (!thread) return;
    if (thread.threadDictionary[TYSMNSThreadAutoleasePoolKey]) return; // already added
    TYSMRunloopAutoreleasePoolSetup();
    thread.threadDictionary[TYSMNSThreadAutoleasePoolKey] = TYSMNSThreadAutoleasePoolKey; // mark the state
}

@end
