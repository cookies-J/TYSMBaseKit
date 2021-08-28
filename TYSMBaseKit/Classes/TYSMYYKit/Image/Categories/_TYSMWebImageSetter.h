//
//  _TYSMWebImageSetter.h
//  YYKit <https://github.com/ibireme/YYKit>
//
//  Created by ibireme on 15/7/15.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#if __has_include(<TYSMYYKit/TYSMYYKit.h>)
#import <TYSMYYKit/YYWebImageManager.h>
#else
#import "TYSMWebImageManager.h"
#endif

NS_ASSUME_NONNULL_BEGIN

extern NSString *const _TYSMWebImageFadeAnimationKey;
extern const NSTimeInterval _TYSMWebImageFadeTime;
extern const NSTimeInterval _TYSMWebImageProgressiveFadeTime;

/**
 Private class used by web image categories.
 Typically, you should not use this class directly.
 */
@interface _TYSMWebImageSetter : NSObject
/// Current image url.
@property (nullable, nonatomic, readonly) NSURL *imageURL;
/// Current sentinel.
@property (nonatomic, readonly) int32_t sentinel;

/// Create new operation for web image and return a sentinel value.
- (int32_t)tysm_setOperationWithSentinel:(int32_t)sentinel
                                url:(nullable NSURL *)imageURL
                            options:(TYSMWebImageOptions)options
                            manager:(TYSMWebImageManager *)manager
                           progress:(nullable TYSMWebImageProgressBlock)progress
                          transform:(nullable TYSMWebImageTransformBlock)transform
                         completion:(nullable TYSMWebImageCompletionBlock)completion;

/// Cancel and return a sentinel value. The imageURL will be set to nil.
- (int32_t)cancel;

/// Cancel and return a sentinel value. The imageURL will be set to new value.
- (int32_t)cancelWithNewURL:(nullable NSURL *)imageURL;

/// A queue to set operation.
+ (dispatch_queue_t)setterQueue;

@end

NS_ASSUME_NONNULL_END
