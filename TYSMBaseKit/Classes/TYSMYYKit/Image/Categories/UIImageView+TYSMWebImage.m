//
//  UIImageView+TYSMWebImage.m
//  YYKit <https://github.com/ibireme/YYKit>
//
//  Created by ibireme on 15/2/23.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "UIImageView+TYSMWebImage.h"
#import "TYSMWebImageOperation.h"
#import "_TYSMWebImageSetter.h"
#import "TYSMYYKitMacro.h"
#import <objc/runtime.h>

TYSMSYNTH_DUMMY_CLASS(UIImageView_TYSMWebImage)

static int _TYSMWebImageSetterKey;
static int _TYSMWebImageHighlightedSetterKey;


@implementation UIImageView (TYSMWebImage)

#pragma mark - image

- (NSURL *)tysm_imageURL {
    _TYSMWebImageSetter *setter = objc_getAssociatedObject(self, &_TYSMWebImageSetterKey);
    return setter.imageURL;
}

/*
 "setImageWithURL" is conflict to AFNetworking and SDWebImage...WTF!
 So.. We use "setImageURL:" instead.
 */
- (void)setTysm_imageURL:(NSURL *)imageURL {
    [self tysm_setImageWithURL:imageURL
              placeholder:nil
                  options:kNilOptions
                  manager:nil
                 progress:nil
                transform:nil
               completion:nil];
}

- (void)tysm_setImageWithURL:(NSURL *)imageURL placeholder:(UIImage *)placeholder {
    [self tysm_setImageWithURL:imageURL
              placeholder:placeholder
                  options:kNilOptions
                  manager:nil
                 progress:nil
                transform:nil
               completion:nil];
}

- (void)tysm_setImageWithURL:(NSURL *)imageURL options:(TYSMWebImageOptions)options {
    [self tysm_setImageWithURL:imageURL
              placeholder:nil
                  options:options
                  manager:nil
                 progress:nil
                transform:nil
               completion:nil];
}

- (void)tysm_setImageWithURL:(NSURL *)imageURL
            placeholder:(UIImage *)placeholder
                options:(TYSMWebImageOptions)options
             completion:(TYSMWebImageCompletionBlock)completion {
    [self tysm_setImageWithURL:imageURL
              placeholder:placeholder
                  options:options
                  manager:nil
                 progress:nil
                transform:nil
               completion:completion];
}

- (void)tysm_setImageWithURL:(NSURL *)imageURL
            placeholder:(UIImage *)placeholder
                options:(TYSMWebImageOptions)options
               progress:(TYSMWebImageProgressBlock)progress
              transform:(TYSMWebImageTransformBlock)transform
             completion:(TYSMWebImageCompletionBlock)completion {
    [self tysm_setImageWithURL:imageURL
              placeholder:placeholder
                  options:options
                  manager:nil
                 progress:progress
                transform:transform
               completion:completion];
}

- (void)tysm_setImageWithURL:(NSURL *)imageURL
            placeholder:(UIImage *)placeholder
                options:(TYSMWebImageOptions)options
                manager:(TYSMWebImageManager *)manager
               progress:(TYSMWebImageProgressBlock)progress
              transform:(TYSMWebImageTransformBlock)transform
             completion:(TYSMWebImageCompletionBlock)completion {
    if ([imageURL isKindOfClass:[NSString class]]) imageURL = [NSURL URLWithString:(id)imageURL];
    manager = manager ? manager : [TYSMWebImageManager sharedManager];
    
    _TYSMWebImageSetter *setter = objc_getAssociatedObject(self, &_TYSMWebImageSetterKey);
    if (!setter) {
        setter = [_TYSMWebImageSetter new];
        objc_setAssociatedObject(self, &_TYSMWebImageSetterKey, setter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    int32_t sentinel = [setter cancelWithNewURL:imageURL];
    
    tysm_dispatch_async_on_main_queue(^{
        if ((options & TYSMWebImageOptionSetImageWithFadeAnimation) &&
            !(options & TYSMWebImageOptionAvoidSetImage)) {
            if (!self.highlighted) {
                [self.layer removeAnimationForKey:_TYSMWebImageFadeAnimationKey];
            }
        }
        
        if (!imageURL) {
            if (!(options & TYSMWebImageOptionIgnorePlaceHolder)) {
                self.image = placeholder;
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
                self.image = imageFromMemory;
            }
            if(completion) completion(imageFromMemory, imageURL, TYSMWebImageFromMemoryCacheFast, TYSMWebImageStageFinished, nil);
            return;
        }
        
        if (!(options & TYSMWebImageOptionIgnorePlaceHolder)) {
            self.image = placeholder;
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
                        BOOL showFade = ((options & TYSMWebImageOptionSetImageWithFadeAnimation) && !self.highlighted);
                        if (showFade) {
                            CATransition *transition = [CATransition animation];
                            transition.duration = stage == TYSMWebImageStageFinished ? _TYSMWebImageFadeTime : _TYSMWebImageProgressiveFadeTime;
                            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                            transition.type = kCATransitionFade;
                            [self.layer addAnimation:transition forKey:_TYSMWebImageFadeAnimationKey];
                        }
                        self.image = image;
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

- (void)tysm_cancelCurrentImageRequest {
    _TYSMWebImageSetter *setter = objc_getAssociatedObject(self, &_TYSMWebImageSetterKey);
    if (setter) [setter cancel];
}


#pragma mark - highlighted image

- (NSURL *)tysm_highlightedImageURL {
    _TYSMWebImageSetter *setter = objc_getAssociatedObject(self, &_TYSMWebImageHighlightedSetterKey);
    return setter.imageURL;
}

- (void)setTysm_highlightedImageURL:(NSURL *)imageURL {
    [self tysm_setHighlightedImageWithURL:imageURL
                         placeholder:nil
                             options:kNilOptions
                             manager:nil
                            progress:nil
                           transform:nil
                          completion:nil];
}

- (void)tysm_setHighlightedImageWithURL:(NSURL *)imageURL placeholder:(UIImage *)placeholder {
    [self tysm_setHighlightedImageWithURL:imageURL
                         placeholder:placeholder
                             options:kNilOptions
                             manager:nil
                            progress:nil
                           transform:nil
                          completion:nil];
}

- (void)tysm_setHighlightedImageWithURL:(NSURL *)imageURL options:(TYSMWebImageOptions)options {
    [self tysm_setHighlightedImageWithURL:imageURL
                         placeholder:nil
                             options:options
                             manager:nil
                            progress:nil
                           transform:nil
                          completion:nil];
}

- (void)tysm_setHighlightedImageWithURL:(NSURL *)imageURL
                       placeholder:(UIImage *)placeholder
                           options:(TYSMWebImageOptions)options
                        completion:(TYSMWebImageCompletionBlock)completion {
    [self tysm_setHighlightedImageWithURL:imageURL
                         placeholder:placeholder
                             options:options
                             manager:nil
                            progress:nil
                           transform:nil
                          completion:completion];
}

- (void)tysm_setHighlightedImageWithURL:(NSURL *)imageURL
                       placeholder:(UIImage *)placeholder
                           options:(TYSMWebImageOptions)options
                          progress:(TYSMWebImageProgressBlock)progress
                         transform:(TYSMWebImageTransformBlock)transform
                        completion:(TYSMWebImageCompletionBlock)completion {
    [self tysm_setHighlightedImageWithURL:imageURL
                         placeholder:placeholder
                             options:options
                             manager:nil
                            progress:progress
                           transform:nil
                          completion:completion];
}

- (void)tysm_setHighlightedImageWithURL:(NSURL *)imageURL
                       placeholder:(UIImage *)placeholder
                           options:(TYSMWebImageOptions)options
                           manager:(TYSMWebImageManager *)manager
                          progress:(TYSMWebImageProgressBlock)progress
                         transform:(TYSMWebImageTransformBlock)transform
                        completion:(TYSMWebImageCompletionBlock)completion {
    if ([imageURL isKindOfClass:[NSString class]]) imageURL = [NSURL URLWithString:(id)imageURL];
    manager = manager ? manager : [TYSMWebImageManager sharedManager];
    
    _TYSMWebImageSetter *setter = objc_getAssociatedObject(self, &_TYSMWebImageHighlightedSetterKey);
    if (!setter) {
        setter = [_TYSMWebImageSetter new];
        objc_setAssociatedObject(self, &_TYSMWebImageHighlightedSetterKey, setter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    int32_t sentinel = [setter cancelWithNewURL:imageURL];
    
    tysm_dispatch_async_on_main_queue(^{
        if ((options & TYSMWebImageOptionSetImageWithFadeAnimation) &&
            !(options & TYSMWebImageOptionAvoidSetImage)) {
            if (self.highlighted) {
                [self.layer removeAnimationForKey:_TYSMWebImageFadeAnimationKey];
            }
        }
        if (!imageURL) {
            if (!(options & TYSMWebImageOptionIgnorePlaceHolder)) {
                self.highlightedImage = placeholder;
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
                self.highlightedImage = imageFromMemory;
            }
            if(completion) completion(imageFromMemory, imageURL, TYSMWebImageFromMemoryCacheFast, TYSMWebImageStageFinished, nil);
            return;
        }
        
        if (!(options & TYSMWebImageOptionIgnorePlaceHolder)) {
            self.highlightedImage = placeholder;
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
                BOOL showFade = ((options & TYSMWebImageOptionSetImageWithFadeAnimation) && self.highlighted);
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL sentinelChanged = weakSetter && weakSetter.sentinel != newSentinel;
                    if (setImage && self && !sentinelChanged) {
                        if (showFade) {
                            CATransition *transition = [CATransition animation];
                            transition.duration = stage == TYSMWebImageStageFinished ? _TYSMWebImageFadeTime : _TYSMWebImageProgressiveFadeTime;
                            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                            transition.type = kCATransitionFade;
                            [self.layer addAnimation:transition forKey:_TYSMWebImageFadeAnimationKey];
                        }
                        self.highlightedImage = image;
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

- (void)tysm_cancelCurrentHighlightedImageRequest {
    _TYSMWebImageSetter *setter = objc_getAssociatedObject(self, &_TYSMWebImageHighlightedSetterKey);
    if (setter) [setter cancel];
}

@end
