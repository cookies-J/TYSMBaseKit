//
//  _TYSMWebImageSetter.m
//  YYKit <https://github.com/ibireme/YYKit>
//
//  Created by ibireme on 15/7/15.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "_TYSMWebImageSetter.h"
#import "TYSMWebImageOperation.h"
#import <libkern/OSAtomic.h>

NSString *const _TYSMWebImageFadeAnimationKey = @"TYSMWebImageFade";
const NSTimeInterval _TYSMWebImageFadeTime = 0.2;
const NSTimeInterval _TYSMWebImageProgressiveFadeTime = 0.4;


@implementation _TYSMWebImageSetter {
    dispatch_semaphore_t _lock;
    NSURL *_imageURL;
    NSOperation *_operation;
    int32_t _sentinel;
}

- (instancetype)init {
    self = [super init];
    _lock = dispatch_semaphore_create(1);
    return self;
}

- (NSURL *)imageURL {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    NSURL *imageURL = _imageURL;
    dispatch_semaphore_signal(_lock);
    return imageURL;
}

- (void)dealloc {
    OSAtomicIncrement32(&_sentinel);
    [_operation cancel];
}

- (int32_t)tysm_setOperationWithSentinel:(int32_t)sentinel
                                url:(NSURL *)imageURL
                            options:(TYSMWebImageOptions)options
                            manager:(TYSMWebImageManager *)manager
                           progress:(TYSMWebImageProgressBlock)progress
                          transform:(TYSMWebImageTransformBlock)transform
                         completion:(TYSMWebImageCompletionBlock)completion {
    if (sentinel != _sentinel) {
        if (completion) completion(nil, imageURL, TYSMWebImageFromNone, TYSMWebImageStageCancelled, nil);
        return _sentinel;
    }
    
    NSOperation *operation = [manager requestImageWithURL:imageURL options:options progress:progress transform:transform completion:completion];
    if (!operation && completion) {
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : @"YYWebImageOperation create failed." };
        completion(nil, imageURL, TYSMWebImageFromNone, TYSMWebImageStageFinished, [NSError errorWithDomain:@"com.ibireme.yykit.webimage" code:-1 userInfo:userInfo]);
    }
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if (sentinel == _sentinel) {
        if (_operation) [_operation cancel];
        _operation = operation;
        sentinel = OSAtomicIncrement32(&_sentinel);
    } else {
        [operation cancel];
    }
    dispatch_semaphore_signal(_lock);
    return sentinel;
}

- (int32_t)cancel {
    return [self cancelWithNewURL:nil];
}

- (int32_t)cancelWithNewURL:(NSURL *)imageURL {
    int32_t sentinel;
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if (_operation) {
        [_operation cancel];
        _operation = nil;
    }
    _imageURL = imageURL;
    sentinel = OSAtomicIncrement32(&_sentinel);
    dispatch_semaphore_signal(_lock);
    return sentinel;
}

+ (dispatch_queue_t)setterQueue {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.ibireme.yykit.webimage.setter", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    });
    return queue;
}

@end
