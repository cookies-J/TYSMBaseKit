//
//  UIButton+TYSMWebImage.m
//  YYKit <https://github.com/ibireme/YYKit>
//
//  Created by ibireme on 15/2/23.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "UIButton+TYSMWebImage.h"
#import "TYSMWebImageOperation.h"
#import "_TYSMWebImageSetter.h"
#import "YYKitMacro.h"
#import <objc/runtime.h>

YYSYNTH_DUMMY_CLASS(UIButton_TYSMWebImage)

static inline NSNumber *UIControlStateSingle(UIControlState state) {
    if (state & UIControlStateHighlighted) return @(UIControlStateHighlighted);
    if (state & UIControlStateDisabled) return @(UIControlStateDisabled);
    if (state & UIControlStateSelected) return @(UIControlStateSelected);
    return @(UIControlStateNormal);
}

static inline NSArray *UIControlStateMulti(UIControlState state) {
    NSMutableArray *array = [NSMutableArray new];
    if (state & UIControlStateHighlighted) [array addObject:@(UIControlStateHighlighted)];
    if (state & UIControlStateDisabled) [array addObject:@(UIControlStateDisabled)];
    if (state & UIControlStateSelected) [array addObject:@(UIControlStateSelected)];
    if ((state & 0xFF) == 0) [array addObject:@(UIControlStateNormal)];
    return array;
}

static int _TYSMWebImageSetterKey;
static int _TYSMWebImageBackgroundSetterKey;


@interface _TYSMWebImageSetterDicForButton : NSObject
- (_TYSMWebImageSetter *)setterForState:(NSNumber *)state;
- (_TYSMWebImageSetter *)lazySetterForState:(NSNumber *)state;
@end

@implementation _TYSMWebImageSetterDicForButton {
    NSMutableDictionary *_dic;
    dispatch_semaphore_t _lock;
}
- (instancetype)init {
    self = [super init];
    _lock = dispatch_semaphore_create(1);
    _dic = [NSMutableDictionary new];
    return self;
}
- (_TYSMWebImageSetter *)setterForState:(NSNumber *)state {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    _TYSMWebImageSetter *setter = _dic[state];
    dispatch_semaphore_signal(_lock);
    return setter;
    
}
- (_TYSMWebImageSetter *)lazySetterForState:(NSNumber *)state {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    _TYSMWebImageSetter *setter = _dic[state];
    if (!setter) {
        setter = [_TYSMWebImageSetter new];
        _dic[state] = setter;
    }
    dispatch_semaphore_signal(_lock);
    return setter;
}
@end


@implementation UIButton (YYWebImage)

#pragma mark - image

- (void)_setImageWithURL:(NSURL *)imageURL
          forSingleState:(NSNumber *)state
             placeholder:(UIImage *)placeholder
                 options:(TYSMWebImageOptions)options
                 manager:(TYSMWebImageManager *)manager
                progress:(TYSMWebImageProgressBlock)progress
               transform:(TYSMWebImageTransformBlock)transform
              completion:(TYSMWebImageCompletionBlock)completion {
    if ([imageURL isKindOfClass:[NSString class]]) imageURL = [NSURL URLWithString:(id)imageURL];
    manager = manager ? manager : [TYSMWebImageManager sharedManager];
    
    _TYSMWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &_TYSMWebImageSetterKey);
    if (!dic) {
        dic = [_TYSMWebImageSetterDicForButton new];
        objc_setAssociatedObject(self, &_TYSMWebImageSetterKey, dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    _TYSMWebImageSetter *setter = [dic lazySetterForState:state];
    int32_t sentinel = [setter cancelWithNewURL:imageURL];
    
    dispatch_async_on_main_queue(^{
        if (!imageURL) {
            if (!(options & TYSMWebImageOptionIgnorePlaceHolder)) {
                [self setImage:placeholder forState:state.integerValue];
            }
            return;
        }
        
        // get the image from memory as quickly as possible
        UIImage *imageFromMemory = nil;
        if (manager.cache &&
            !(options & TYSMWebImageOptionUseNSURLCache) &&
            !(options & TYSMWebImageOptionRefreshImageCache)) {
            imageFromMemory = [manager.cache getImageForKey:[manager cacheKeyForURL:imageURL] withType:TYSMImageCacheTypeMemory];
        }
        if (imageFromMemory) {
            if (!(options & TYSMWebImageOptionAvoidSetImage)) {
                [self setImage:imageFromMemory forState:state.integerValue];
            }
            if(completion) completion(imageFromMemory, imageURL, TYSMWebImageFromMemoryCacheFast, TYSMWebImageStageFinished, nil);
            return;
        }
        
        
        if (!(options & TYSMWebImageOptionIgnorePlaceHolder)) {
            [self setImage:placeholder forState:state.integerValue];
        }
        
        __weak typeof(self) _self = self;
        dispatch_async([_TYSMWebImageSetter setterQueue], ^{
            TYSMWebImageProgressBlock _progress = nil;
            if (progress) _progress = ^(NSInteger receivedSize, NSInteger expectedSize) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    progress(receivedSize, expectedSize);
                });
            };
            
            __block int32_t newSentinel = 0;
            __block __weak typeof(setter) weakSetter = nil;
            TYSMWebImageCompletionBlock _completion = ^(UIImage *image, NSURL *url, TYSMWebImageFromType from, TYSMWebImageStage stage, NSError *error) {
                __strong typeof(_self) self = _self;
                BOOL setImage = (stage == TYSMWebImageStageFinished || stage == TYSMWebImageStageProgress) && image && !(options & TYSMWebImageOptionAvoidSetImage);
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL sentinelChanged = weakSetter && weakSetter.sentinel != newSentinel;
                    if (setImage && self && !sentinelChanged) {
                        [self setImage:image forState:state.integerValue];
                    }
                    if (completion) {
                        if (sentinelChanged) {
                            completion(nil, url, TYSMWebImageFromNone, TYSMWebImageStageCancelled, nil);
                        } else {
                            completion(image, url, from, stage, error);
                        }
                    }
                });
            };
            
            newSentinel = [setter tysm_setOperationWithSentinel:sentinel url:imageURL options:options manager:manager progress:_progress transform:transform completion:_completion];
            weakSetter = setter;
        });
    });
}

- (void)_cancelImageRequestForSingleState:(NSNumber *)state {
    _TYSMWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &_TYSMWebImageSetterKey);
    _TYSMWebImageSetter *setter = [dic setterForState:state];
    if (setter) [setter cancel];
}

- (NSURL *)tysm_imageURLForState:(UIControlState)state {
    _TYSMWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &_TYSMWebImageSetterKey);
    _TYSMWebImageSetter *setter = [dic setterForState:UIControlStateSingle(state)];
    return setter.imageURL;
}

- (void)tysm_setImageWithURL:(NSURL *)imageURL forState:(UIControlState)state placeholder:(UIImage *)placeholder {
    [self tysm_setImageWithURL:imageURL
                 forState:state
              placeholder:placeholder
                  options:kNilOptions
                  manager:nil
                 progress:nil
                transform:nil
               completion:nil];
}

- (void)tysm_setImageWithURL:(NSURL *)imageURL forState:(UIControlState)state options:(TYSMWebImageOptions)options {
    [self tysm_setImageWithURL:imageURL
                 forState:state
              placeholder:nil
                  options:options
                  manager:nil
                 progress:nil
                transform:nil
               completion:nil];
}

- (void)tysm_setImageWithURL:(NSURL *)imageURL
               forState:(UIControlState)state
            placeholder:(UIImage *)placeholder
                options:(TYSMWebImageOptions)options
             completion:(TYSMWebImageCompletionBlock)completion {
    [self tysm_setImageWithURL:imageURL
                 forState:state
              placeholder:placeholder
                  options:options
                  manager:nil
                 progress:nil
                transform:nil
               completion:completion];
}

- (void)tysm_setImageWithURL:(NSURL *)imageURL
               forState:(UIControlState)state
            placeholder:(UIImage *)placeholder
                options:(TYSMWebImageOptions)options
               progress:(TYSMWebImageProgressBlock)progress
              transform:(TYSMWebImageTransformBlock)transform
             completion:(TYSMWebImageCompletionBlock)completion {
    [self tysm_setImageWithURL:imageURL
                 forState:state
              placeholder:placeholder
                  options:options
                  manager:nil
                 progress:progress
                transform:transform
               completion:completion];
}

- (void)tysm_setImageWithURL:(NSURL *)imageURL
               forState:(UIControlState)state
            placeholder:(UIImage *)placeholder
                options:(TYSMWebImageOptions)options
                manager:(TYSMWebImageManager *)manager
               progress:(TYSMWebImageProgressBlock)progress
              transform:(TYSMWebImageTransformBlock)transform
             completion:(TYSMWebImageCompletionBlock)completion {
    for (NSNumber *num in UIControlStateMulti(state)) {
        [self _setImageWithURL:imageURL
                forSingleState:num
                   placeholder:placeholder
                       options:options
                       manager:manager
                      progress:progress
                     transform:transform
                    completion:completion];
    }
}

- (void)tysm_cancelImageRequestForState:(UIControlState)state {
    for (NSNumber *num in UIControlStateMulti(state)) {
        [self _cancelImageRequestForSingleState:num];
    }
}


#pragma mark - background image

- (void)_setBackgroundImageWithURL:(NSURL *)imageURL
                    forSingleState:(NSNumber *)state
                       placeholder:(UIImage *)placeholder
                           options:(TYSMWebImageOptions)options
                           manager:(TYSMWebImageManager *)manager
                          progress:(TYSMWebImageProgressBlock)progress
                         transform:(TYSMWebImageTransformBlock)transform
                        completion:(TYSMWebImageCompletionBlock)completion {
    if ([imageURL isKindOfClass:[NSString class]]) imageURL = [NSURL URLWithString:(id)imageURL];
    manager = manager ? manager : [TYSMWebImageManager sharedManager];
    
    _TYSMWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &_TYSMWebImageBackgroundSetterKey);
    if (!dic) {
        dic = [_TYSMWebImageSetterDicForButton new];
        objc_setAssociatedObject(self, &_TYSMWebImageBackgroundSetterKey, dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    _TYSMWebImageSetter *setter = [dic lazySetterForState:state];
    int32_t sentinel = [setter cancelWithNewURL:imageURL];
    
    dispatch_async_on_main_queue(^{
        if (!imageURL) {
            if (!(options & TYSMWebImageOptionIgnorePlaceHolder)) {
                [self setBackgroundImage:placeholder forState:state.integerValue];
            }
            return;
        }
        
        // get the image from memory as quickly as possible
        UIImage *imageFromMemory = nil;
        if (manager.cache &&
            !(options & TYSMWebImageOptionUseNSURLCache) &&
            !(options & TYSMWebImageOptionRefreshImageCache)) {
            imageFromMemory = [manager.cache getImageForKey:[manager cacheKeyForURL:imageURL] withType:TYSMImageCacheTypeMemory];
        }
        if (imageFromMemory) {
            if (!(options & TYSMWebImageOptionAvoidSetImage)) {
                [self setBackgroundImage:imageFromMemory forState:state.integerValue];
            }
            if(completion) completion(imageFromMemory, imageURL, TYSMWebImageFromMemoryCacheFast, TYSMWebImageStageFinished, nil);
            return;
        }
        
        
        if (!(options & TYSMWebImageOptionIgnorePlaceHolder)) {
            [self setBackgroundImage:placeholder forState:state.integerValue];
        }
        
        __weak typeof(self) _self = self;
        dispatch_async([_TYSMWebImageSetter setterQueue], ^{
            TYSMWebImageProgressBlock _progress = nil;
            if (progress) _progress = ^(NSInteger receivedSize, NSInteger expectedSize) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    progress(receivedSize, expectedSize);
                });
            };
            
            __block int32_t newSentinel = 0;
            __block __weak typeof(setter) weakSetter = nil;
            TYSMWebImageCompletionBlock _completion = ^(UIImage *image, NSURL *url, TYSMWebImageFromType from, TYSMWebImageStage stage, NSError *error) {
                __strong typeof(_self) self = _self;
                BOOL setImage = (stage == TYSMWebImageStageFinished || stage == TYSMWebImageStageProgress) && image && !(options & TYSMWebImageOptionAvoidSetImage);
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL sentinelChanged = weakSetter && weakSetter.sentinel != newSentinel;
                    if (setImage && self && !sentinelChanged) {
                        [self setBackgroundImage:image forState:state.integerValue];
                    }
                    if (completion) {
                        if (sentinelChanged) {
                            completion(nil, url, TYSMWebImageFromNone, TYSMWebImageStageCancelled, nil);
                        } else {
                            completion(image, url, from, stage, error);
                        }
                    }
                });
            };
            
            newSentinel = [setter tysm_setOperationWithSentinel:sentinel url:imageURL options:options manager:manager progress:_progress transform:transform completion:_completion];
            weakSetter = setter;
        });
    });
}

- (void)_cancelBackgroundImageRequestForSingleState:(NSNumber *)state {
    _TYSMWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &_TYSMWebImageBackgroundSetterKey);
    _TYSMWebImageSetter *setter = [dic setterForState:state];
    if (setter) [setter cancel];
}

- (NSURL *)tysm_backgroundImageURLForState:(UIControlState)state {
    _TYSMWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &_TYSMWebImageBackgroundSetterKey);
    _TYSMWebImageSetter *setter = [dic setterForState:UIControlStateSingle(state)];
    return setter.imageURL;
}

- (void)tysm_setBackgroundImageWithURL:(NSURL *)imageURL forState:(UIControlState)state placeholder:(UIImage *)placeholder {
    [self tysm_setBackgroundImageWithURL:imageURL
                           forState:state
                        placeholder:placeholder
                            options:kNilOptions
                            manager:nil
                           progress:nil
                          transform:nil
                         completion:nil];
}

- (void)tysm_setBackgroundImageWithURL:(NSURL *)imageURL forState:(UIControlState)state options:(TYSMWebImageOptions)options {
    [self tysm_setBackgroundImageWithURL:imageURL
                           forState:state
                        placeholder:nil
                            options:options
                            manager:nil
                           progress:nil
                          transform:nil
                         completion:nil];
}

- (void)tysm_setBackgroundImageWithURL:(NSURL *)imageURL
               forState:(UIControlState)state
            placeholder:(UIImage *)placeholder
                options:(TYSMWebImageOptions)options
             completion:(TYSMWebImageCompletionBlock)completion {
    [self tysm_setBackgroundImageWithURL:imageURL
                           forState:state
                        placeholder:placeholder
                            options:options
                            manager:nil
                           progress:nil
                          transform:nil
                         completion:completion];
}

- (void)tysm_setBackgroundImageWithURL:(NSURL *)imageURL
               forState:(UIControlState)state
            placeholder:(UIImage *)placeholder
                options:(TYSMWebImageOptions)options
               progress:(TYSMWebImageProgressBlock)progress
              transform:(TYSMWebImageTransformBlock)transform
             completion:(TYSMWebImageCompletionBlock)completion {
    [self tysm_setBackgroundImageWithURL:imageURL
                           forState:state
                        placeholder:placeholder
                            options:options
                            manager:nil
                           progress:progress
                          transform:transform
                         completion:completion];
}

- (void)tysm_setBackgroundImageWithURL:(NSURL *)imageURL
               forState:(UIControlState)state
            placeholder:(UIImage *)placeholder
                options:(TYSMWebImageOptions)options
                manager:(TYSMWebImageManager *)manager
               progress:(TYSMWebImageProgressBlock)progress
              transform:(TYSMWebImageTransformBlock)transform
             completion:(TYSMWebImageCompletionBlock)completion {
    for (NSNumber *num in UIControlStateMulti(state)) {
        [self _setBackgroundImageWithURL:imageURL
                          forSingleState:num
                             placeholder:placeholder
                                 options:options
                                 manager:manager
                                progress:progress
                               transform:transform
                              completion:completion];
    }
}

- (void)tysm_cancelBackgroundImageRequestForState:(UIControlState)state {
    for (NSNumber *num in UIControlStateMulti(state)) {
        [self _cancelBackgroundImageRequestForSingleState:num];
    }
}

@end
