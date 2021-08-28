//
//  YYTYSMCGUtilities.h
//  YYKit <https://github.com/ibireme/YYKit>
//
//  Created by ibireme on 15/2/28.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#if __has_include(<TYSMYYKit/TYSMYYKit.h>)
#import <TYSMYYKit/TYSMYYKitMacro.h>
#else
#import "TYSMYYKitMacro.h"
#endif

TYSM_EXTERN_C_BEGIN
NS_ASSUME_NONNULL_BEGIN

/// Create an `ARGB` Bitmap context. Returns NULL if an error occurs.
///
/// @discussion The function is same as UIGraphicsBeginImageContextWithOptions(),
/// but it doesn't push the context to UIGraphic, so you can retain the context for reuse.
CGContextRef _Nullable YYCGContextCreateARGBBitmapContext(CGSize size, BOOL opaque, CGFloat scale);

/// Create a `DeviceGray` Bitmap context. Returns NULL if an error occurs.
CGContextRef _Nullable YYCGContextCreateGrayBitmapContext(CGSize size, CGFloat scale);



/// Get main screen's scale.
CGFloat TYSMScreenScale();

/// Get main screen's size. Height is always larger than width.
CGSize TYSMScreenSize();



/// Convert degrees to radians.
static inline CGFloat tysm_DegreesToRadians(CGFloat degrees) {
    return degrees * M_PI / 180;
}

/// Convert radians to degrees.
static inline CGFloat tysm_RadiansToDegrees(CGFloat radians) {
    return radians * 180 / M_PI;
}



/// Get the transform rotation.
/// @return the rotation in radians [-PI,PI] ([-180°,180°])
static inline CGFloat tysm_CGAffineTransformGetRotation(CGAffineTransform transform) {
    return atan2(transform.b, transform.a);
}

/// Get the transform's scale.x
static inline CGFloat tysm_CGAffineTransformGetScaleX(CGAffineTransform transform) {
    return  sqrt(transform.a * transform.a + transform.c * transform.c);
}

/// Get the transform's scale.y
static inline CGFloat tysm_CGAffineTransformGetScaleY(CGAffineTransform transform) {
    return sqrt(transform.b * transform.b + transform.d * transform.d);
}

/// Get the transform's translate.x
static inline CGFloat tysm_CGAffineTransformGetTranslateX(CGAffineTransform transform) {
    return transform.tx;
}

/// Get the transform's translate.y
static inline CGFloat tysm_CGAffineTransformGetTranslateY(CGAffineTransform transform) {
    return transform.ty;
}

/**
 If you have 3 pair of points transformed by a same CGAffineTransform:
     p1 (transform->) q1
     p2 (transform->) q2
     p3 (transform->) q3
 This method returns the original transform matrix from these 3 pair of points.f
 
 @see http://stackoverflow.com/questions/13291796/calculate-values-for-a-cgaffinetransform-from-three-points-in-each-of-two-uiview
 */
CGAffineTransform TYSMCGAffineTransformGetFromPoints(CGPoint before[_Nonnull 3], CGPoint after[_Nonnull 3]);

/// Get the transform which can converts a point from the coordinate system of a given view to another.
CGAffineTransform TYSMCGAffineTransformGetFromViews(UIView *from, UIView *to);

/// Create a skew transform.
static inline CGAffineTransform TYSMCGAffineTransformMakeSkew(CGFloat x, CGFloat y){
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform.c = -x;
    transform.b = y;
    return transform;
}

/// Negates/inverts a UIEdgeInsets.
static inline UIEdgeInsets tysm_UIEdgeInsetsInvert(UIEdgeInsets insets) {
    return UIEdgeInsetsMake(-insets.top, -insets.left, -insets.bottom, -insets.right);
}

/// Convert CALayer's gravity string to UIViewContentMode.
UIViewContentMode TYSMCAGravityToUIViewContentMode(NSString *gravity);

/// Convert UIViewContentMode to CALayer's gravity string.
NSString *TYSMUIViewContentModeToCAGravity(UIViewContentMode contentMode);



/**
 Returns a rectangle to fit the `rect` with specified content mode.
 
 @param rect The constrant rect
 @param size The content size
 @param mode The content mode
 @return A rectangle for the given content mode.
 @discussion UIViewContentModeRedraw is same as UIViewContentModeScaleToFill.
 */
CGRect tysm_CGRectFitWithContentMode(CGRect rect, CGSize size, UIViewContentMode mode);

/// Returns the center for the rectangle.
static inline CGPoint tysm_CGRectGetCenter(CGRect rect) {
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

/// Returns the area of the rectangle.
static inline CGFloat tysm_CGRectGetArea(CGRect rect) {
    if (CGRectIsNull(rect)) return 0;
    rect = CGRectStandardize(rect);
    return rect.size.width * rect.size.height;
}

/// Returns ttysm_CGFloatFromPixelwo points.
static inline CGFloat tysm_CGPointGetDistanceToPoint(CGPoint p1, CGPoint p2) {
    return sqrt((p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y));
}

/// Returns the minmium distance between a point to a rectangle.
static inline CGFloat tysm_CGPointGetDistanceToRect(CGPoint p, CGRect r) {
    r = CGRectStandardize(r);
    if (CGRectContainsPoint(r, p)) return 0;
    CGFloat distV, distH;
    if (CGRectGetMinY(r) <= p.y && p.y <= CGRectGetMaxY(r)) {
        distV = 0;
    } else {
        distV = p.y < CGRectGetMinY(r) ? CGRectGetMinY(r) - p.y : p.y - CGRectGetMaxY(r);
    }
    if (CGRectGetMinX(r) <= p.x && p.x <= CGRectGetMaxX(r)) {
        distH = 0;
    } else {
        distH = p.x < CGRectGetMinX(r) ? CGRectGetMinX(r) - p.x : p.x - CGRectGetMaxX(r);
    }
    return MAX(distV, distH);
}



/// Convert point to pixel.
static inline CGFloat tysm_CGFloatToPixel(CGFloat value) {
    return value * TYSMScreenScale();
}

/// Convert pixel to point.
static inline CGFloat tysm_CGFloatFromPixel(CGFloat value) {
    return value / TYSMScreenScale();
}



/// floor point value for pixel-aligned
static inline CGFloat tysm_CGFloatPixelFloor(CGFloat value) {
    CGFloat scale = TYSMScreenScale();
    return floor(value * scale) / scale;
}

/// round point value for pixel-aligned
static inline CGFloat tysm_CGFloatPixelRound(CGFloat value) {
    CGFloat scale = TYSMScreenScale();
    return round(value * scale) / scale;
}

/// ceil point value for pixel-aligned
static inline CGFloat tysm_CGFloatPixelCeil(CGFloat value) {
    CGFloat scale = TYSMScreenScale();
    return ceil(value * scale) / scale;
}

/// round point value to .5 pixel for path stroke (odd pixel line width pixel-aligned)
static inline CGFloat tysm_CGFloatPixelHalf(CGFloat value) {
    CGFloat scale = TYSMScreenScale();
    return (floor(value * scale) + 0.5) / scale;
}



/// floor point value for pixel-aligned
static inline CGPoint tysm_CGPointPixelFloor(CGPoint point) {
    CGFloat scale = TYSMScreenScale();
    return CGPointMake(floor(point.x * scale) / scale,
                       floor(point.y * scale) / scale);
}

/// round point value for pixel-aligned
static inline CGPoint tysm_CGPointPixelRound(CGPoint point) {
    CGFloat scale = TYSMScreenScale();
    return CGPointMake(round(point.x * scale) / scale,
                       round(point.y * scale) / scale);
}

/// ceil point value for pixel-aligned
static inline CGPoint tysm_CGPointPixelCeil(CGPoint point) {
    CGFloat scale = TYSMScreenScale();
    return CGPointMake(ceil(point.x * scale) / scale,
                       ceil(point.y * scale) / scale);
}

/// round point value to .5 pixel for path stroke (odd pixel line width pixel-aligned)
static inline CGPoint tysm_CGPointPixelHalf(CGPoint point) {
    CGFloat scale = TYSMScreenScale();
    return CGPointMake((floor(point.x * scale) + 0.5) / scale,
                       (floor(point.y * scale) + 0.5) / scale);
}



/// floor point value for pixel-aligned
static inline CGSize tysm_CGSizePixelFloor(CGSize size) {
    CGFloat scale = TYSMScreenScale();
    return CGSizeMake(floor(size.width * scale) / scale,
                      floor(size.height * scale) / scale);
}

/// round point value for pixel-aligned
static inline CGSize tysm_CGSizePixelRound(CGSize size) {
    CGFloat scale = TYSMScreenScale();
    return CGSizeMake(round(size.width * scale) / scale,
                      round(size.height * scale) / scale);
}

/// ceil point value for pixel-aligned
static inline CGSize CGSizePixelCeil(CGSize size) {
    CGFloat scale = TYSMScreenScale();
    return CGSizeMake(ceil(size.width * scale) / scale,
                      ceil(size.height * scale) / scale);
}

/// round point value to .5 pixel for path stroke (odd pixel line width pixel-aligned)
static inline CGSize tysm_CGSizePixelHalf(CGSize size) {
    CGFloat scale = TYSMScreenScale();
    return CGSizeMake((floor(size.width * scale) + 0.5) / scale,
                       (floor(size.height * scale) + 0.5) / scale);
}



/// floor point value for pixel-aligned
static inline CGRect tysm_CGRectPixelFloor(CGRect rect) {
    CGPoint origin = tysm_CGPointPixelCeil(rect.origin);
    CGPoint corner = tysm_CGPointPixelFloor(CGPointMake(rect.origin.x + rect.size.width,
                                                   rect.origin.y + rect.size.height));
    CGRect ret = CGRectMake(origin.x, origin.y, corner.x - origin.x, corner.y - origin.y);
    if (ret.size.width < 0) ret.size.width = 0;
    if (ret.size.height < 0) ret.size.height = 0;
    return ret;
}

/// round point value for pixel-aligned
static inline CGRect tysm_CGRectPixelRound(CGRect rect) {
    CGPoint origin = tysm_CGPointPixelRound(rect.origin);
    CGPoint corner = tysm_CGPointPixelRound(CGPointMake(rect.origin.x + rect.size.width,
                                                  rect.origin.y + rect.size.height));
    return CGRectMake(origin.x, origin.y, corner.x - origin.x, corner.y - origin.y);
}

/// ceil point value for pixel-aligned
static inline CGRect tysm_CGRectPixelCeil(CGRect rect) {
    CGPoint origin = tysm_CGPointPixelFloor(rect.origin);
    CGPoint corner = tysm_CGPointPixelCeil(CGPointMake(rect.origin.x + rect.size.width,
                                                   rect.origin.y + rect.size.height));
    return CGRectMake(origin.x, origin.y, corner.x - origin.x, corner.y - origin.y);
}

/// round point value to .5 pixel for path stroke (odd pixel line width pixel-aligned)
static inline CGRect tysm_CGRectPixelHalf(CGRect rect) {
    CGPoint origin = tysm_CGPointPixelHalf(rect.origin);
    CGPoint corner = tysm_CGPointPixelHalf(CGPointMake(rect.origin.x + rect.size.width,
                                                  rect.origin.y + rect.size.height));
    return CGRectMake(origin.x, origin.y, corner.x - origin.x, corner.y - origin.y);
}



/// floor UIEdgeInset for pixel-aligned
static inline UIEdgeInsets tysm_UIEdgeInsetPixelFloor(UIEdgeInsets insets) {
    insets.top = tysm_CGFloatPixelFloor(insets.top);
    insets.left = tysm_CGFloatPixelFloor(insets.left);
    insets.bottom = tysm_CGFloatPixelFloor(insets.bottom);
    insets.right = tysm_CGFloatPixelFloor(insets.right);
    return insets;
}

/// ceil UIEdgeInset for pixel-aligned
static inline UIEdgeInsets tysm_UIEdgeInsetPixelCeil(UIEdgeInsets insets) {
    insets.top = tysm_CGFloatPixelCeil(insets.top);
    insets.left = tysm_CGFloatPixelCeil(insets.left);
    insets.bottom = tysm_CGFloatPixelCeil(insets.bottom);
    insets.right = tysm_CGFloatPixelCeil(insets.right);
    return insets;
}

// main screen's scale
#ifndef kScreenScale
#define kScreenScale TYSMScreenScale()
#endif

// main screen's size (portrait)
#ifndef kScreenSize
#define kScreenSize TYSMScreenSize()
#endif

// main screen's width (portrait)
#ifndef kScreenWidth
#define kScreenWidth TYSMScreenSize().width
#endif

// main screen's height (portrait)
#ifndef kScreenHeight
#define kScreenHeight TYSMScreenSize().height
#endif

NS_ASSUME_NONNULL_END
TYSM_EXTERN_C_END
