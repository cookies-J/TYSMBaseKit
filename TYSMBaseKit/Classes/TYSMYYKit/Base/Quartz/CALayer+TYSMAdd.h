//
//  CALayer+TYSMAdd.h
//  YYKit <https://github.com/ibireme/YYKit>
//
//  Created by ibireme on 14/5/10.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Provides extensions for `CALayer`.
 */
@interface CALayer (TYSMAdd)

/**
 Take snapshot without transform, image's size equals to bounds.
 */
- (nullable UIImage *)tysm_snapshotImage;

/**
 Take snapshot without transform, PDF's page size equals to bounds.
 */
- (nullable NSData *)tysm_snapshotPDF;

/**
 Shortcut to set the layer's shadow
 
 @param color  Shadow Color
 @param offset Shadow offset
 @param radius Shadow radius
 */
- (void)tysm_setLayerShadow:(UIColor*)color offset:(CGSize)offset radius:(CGFloat)radius;

/**
 Remove all sublayers.
 */
- (void)tysm_removeAllSublayers;

@property (nonatomic) CGFloat tysm_left;        ///< Shortcut for frame.origin.x.
@property (nonatomic) CGFloat tysm_top;         ///< Shortcut for frame.origin.y
@property (nonatomic) CGFloat tysm_right;       ///< Shortcut for frame.origin.x + frame.size.width
@property (nonatomic) CGFloat tysm_bottom;      ///< Shortcut for frame.origin.y + frame.size.height
@property (nonatomic) CGFloat tysm_width;       ///< Shortcut for frame.size.width.
@property (nonatomic) CGFloat tysm_height;      ///< Shortcut for frame.size.height.
@property (nonatomic) CGPoint tysm_center;      ///< Shortcut for center.
@property (nonatomic) CGFloat tysm_centerX;     ///< Shortcut for center.x
@property (nonatomic) CGFloat tysm_centerY;     ///< Shortcut for center.y
@property (nonatomic) CGPoint tysm_origin;      ///< Shortcut for frame.origin.
@property (nonatomic, getter=tysm_frameSize, setter=setTysm_FrameSize:) CGSize  tysm_size; ///< Shortcut for frame.size.


@property (nonatomic) CGFloat tysm_transformRotation;     ///< key path "tranform.rotation"
@property (nonatomic) CGFloat tysm_transformRotationX;    ///< key path "tranform.rotation.x"
@property (nonatomic) CGFloat tysm_transformRotationY;    ///< key path "tranform.rotation.y"
@property (nonatomic) CGFloat tysm_transformRotationZ;    ///< key path "tranform.rotation.z"
@property (nonatomic) CGFloat tysm_transformScale;        ///< key path "tranform.scale"
@property (nonatomic) CGFloat tysm_transformScaleX;       ///< key path "tranform.scale.x"
@property (nonatomic) CGFloat tysm_transformScaleY;       ///< key path "tranform.scale.y"
@property (nonatomic) CGFloat tysm_transformScaleZ;       ///< key path "tranform.scale.z"
@property (nonatomic) CGFloat tysm_transformTranslationX; ///< key path "tranform.translation.x"
@property (nonatomic) CGFloat tysm_transformTranslationY; ///< key path "tranform.translation.y"
@property (nonatomic) CGFloat tysm_transformTranslationZ; ///< key path "tranform.translation.z"

/**
 Shortcut for transform.m34, -1/1000 is a good value.
 It should be set before other transform shortcut.
 */
@property (nonatomic) CGFloat tysm_transformDepth;

/**
 Wrapper for `contentsGravity` property.
 */
@property (nonatomic) UIViewContentMode tysm_contentMode;

/**
 Add a fade animation to layer's contents when the contents is changed.
 
 @param duration Animation duration
 @param curve    Animation curve.
 */
- (void)tysm_addFadeAnimationWithDuration:(NSTimeInterval)duration curve:(UIViewAnimationCurve)curve;

/**
 Cancel fade animation which is added with "-addFadeAnimationWithDuration:curve:".
 */
- (void)tysm_removePreviousFadeAnimation;

@end

NS_ASSUME_NONNULL_END
