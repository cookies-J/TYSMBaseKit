//
//  TYSMTransaction.m
//  TYSMKit <https://github.com/ibireme/TYSMKit>
//
//  Created by ibireme on 15/4/18.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "TYSMTransaction.h"


@interface TYSMTransaction()
@property (nonatomic, strong) id target;
@property (nonatomic, assign) SEL selector;
@end

static NSMutableSet *transactionSet = nil;

static void TYSMRunLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    if (transactionSet.count == 0) return;
    NSSet *currentSet = transactionSet;
    transactionSet = [NSMutableSet new];
    [currentSet enumerateObjectsUsingBlock:^(TYSMTransaction *transaction, BOOL *stop) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [transaction.target performSelector:transaction.selector];
#pragma clang diagnostic pop
    }];
}

static void TYSMTransactionSetup() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        transactionSet = [NSMutableSet new];
        CFRunLoopRef runloop = CFRunLoopGetMain();
        CFRunLoopObserverRef observer;
        
        observer = CFRunLoopObserverCreate(CFAllocatorGetDefault(),
                                           kCFRunLoopBeforeWaiting | kCFRunLoopExit,
                                           true,      // repeat
                                           0xFFFFFF,  // after CATransaction(2000000)
                                           TYSMRunLoopObserverCallBack, NULL);
        CFRunLoopAddObserver(runloop, observer, kCFRunLoopCommonModes);
        CFRelease(observer);
    });
}


@implementation TYSMTransaction

+ (TYSMTransaction *)transactionWithTarget:(id)target selector:(SEL)selector{
    if (!target || !selector) return nil;
    TYSMTransaction *t = [TYSMTransaction new];
    t.target = target;
    t.selector = selector;
    return t;
}

- (void)tysm_commit {
    if (!_target || !_selector) return;
    TYSMTransactionSetup();
    [transactionSet addObject:self];
}

- (NSUInteger)tysm_hash {
    long v1 = (long)((void *)_selector);
    long v2 = (long)_target;
    return v1 ^ v2;
}

- (BOOL)tysm_isEqual:(id)object {
    if (self == object) return YES;
    if (![object isMemberOfClass:self.class]) return NO;
    TYSMTransaction *other = object;
    return other.selector == _selector && other.target == _target;
}

@end
