
//
//  TYSMYYKit.h
//  YYKit <https://github.com/ibireme/YYKit>
//
//  Created by ibireme on 13/3/30.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <Foundation/Foundation.h>

#if __has_include(<TYSMYYKit/TYSMYYKit.h>)

FOUNDATION_EXPORT double TYSMKitVersionNumber;
FOUNDATION_EXPORT const unsigned char TYSMKitVersionString[];


#import <TYSMYYKit/YYKitMacro.h>
#import <TYSMYYKit/TYSMKitMacro.h>>
#import <TYSMYYKit/NSObject+TYSMAdd.h>
#import <TYSMYYKit/NSObject+TYSMAddForKVO.h>
#import <TYSMYYKit/NSObject+TYSMAddForARC.h>
#import <TYSMYYKit/NSString+TYSMAdd.h>
#import <TYSMYYKit/NSNumber+TYSMAdd.h>
#import <TYSMYYKit/NSData+TYSMAdd.h>
#import <TYSMYYKit/NSArray+TYSMAdd.h>
#import <TYSMYYKit/NSDictionary+TYSMAdd.h>
#import <TYSMYYKit/NSDate+TYSMAdd.h>
#import <TYSMYYKit/NSNotificationCenter+TYSMAdd.h>
#import <TYSMYYKit/NSKeyedUnarchiver+TYSMAdd.h>
#import <TYSMYYKit/NSTimer+TYSMAdd.h>
#import <TYSMYYKit/NSBundle+TYSMAdd.h>
#import <TYSMYYKit/NSThread+TYSMAdd.h>

#import <TYSMYYKit/UIColor+TYSMAdd.h>
#import <TYSMYYKit/UIImage+TYSMAdd.h>
#import <TYSMYYKit/UIControl+YYAdd.h>
#import <TYSMYYKit/UIBarButtonItem+TYSMAdd.h>
#import <TYSMYYKit/UIGestureRecognizer+TYSMAdd.h>
#import <TYSMYYKit/UIView+TYSMAdd.h>
#import <TYSMYYKit/UIScrollView+TYSMAdd.h>
#import <TYSMYYKit/UITableView+TYSMAdd.h>
#import <TYSMYYKit/UITextField+TYSMAdd.h>
#import <TYSMYYKit/UIScreen+TYSMAdd.h>
#import <TYSMYYKit/UIDevice+TYSMAdd.h>
#import <TYSMYYKit/UIApplication+TYSMAdd.h>
#import <TYSMYYKit/UIFont+TYSMAdd.h>
#import <TYSMYYKit/UIBezierPath+TYSMAdd.h>

#import <TYSMYYKit/CALayer+TYSMAdd.h>
#import <TYSMYYKit/TYSMCGUtilities.h>

#import <TYSMYYKit/NSObject+TYSMModel.h>
#import <TYSMYYKit/TYSMClassInfo.h>

#import <TYSMYYKit/YYCache.h>
#import <TYSMYYKit/YYMemoryCache.h>
#import <TYSMYYKit/YYDiskCache.h>
#import <TYSMYYKit/YYKVStorage.h>

#import <TYSMYYKit/TYSMImage.h>
#import <TYSMYYKit/TYSMFrameImage.h>
#import <TYSMYYKit/TYSMSpriteSheetImage.h>
#import <TYSMYYKit/TYSMAnimatedImageView.h>
#import <TYSMYYKit/TYSMImageCoder.h>
#import <TYSMYYKit/TYSMImageCache.h>
#import <TYSMYYKit/TYSMWebImageOperation.h>
#import <TYSMYYKit/TYSMWebImageManager.h>
#import <TYSMYYKit/UIImageView+TYSMWebImage.h>
#import <TYSMYYKit/UIButton+TYSMWebImage.h>
#import <TYSMYYKit/MKAnnotationView+TYSMWebImage.h>
#import <TYSMYYKit/CALayer+TYSMWebImage.h>

#import <TYSMYYKit/TYSMLabel.h>
#import <TYSMYYKit/TYSMTextView.h>
#import <TYSMYYKit/TYSMTextAttribute.h>
#import <TYSMYYKit/TYSMTextArchiver.h>
#import <TYSMYYKit/TYSMTextParser.h>
#import <TYSMYYKit/YYTextUtilities.h>
#import <TYSMYYKit/YYTextRunDelegate.h>
#import <TYSMYYKit/YYTextRubyAnnotation.h>
#import <TYSMYYKit/NSAttributedString+YYText.h>
#import <TYSMYYKit/NSParagraphStyle+YYText.h>
#import <TYSMYYKit/UIPasteboard+YYText.h>
#import <TYSMYYKit/YYTextLayout.h>
#import <TYSMYYKit/YYTextLine.h>
#import <TYSMYYKit/YYTextInput.h>
#import <TYSMYYKit/YYTextDebugOption.h>
#import <TYSMYYKit/YYTextContainerView.h>
#import <TYSMYYKit/YYTextSelectionView.h>
#import <TYSMYYKit/YYTextMagnifier.h>
#import <TYSMYYKit/YYTextEffectWindow.h>
#import <TYSMYYKit/YYTextKeyboardManager.h>

#import <TYSMYYKit/YYReachability.h>
#import <TYSMYYKit/YYGestureRecognizer.h>
#import <TYSMYYKit/YYFileHash.h>
#import <TYSMYYKit/YYKeychain.h>
#import <TYSMYYKit/YYWeakProxy.h>
#import <TYSMYYKit/YYTimer.h>
#import <TYSMYYKit/YYTransaction.h>
#import <TYSMYYKit/TYSMAsyncLayer.h>
#import <TYSMYYKit/YYSentinel.h>
#import <TYSMYYKit/TYSMDispatchQueuePool.h>
#import <TYSMYYKit/TYSMThreadSafeArray.h>
#import <TYSMYYKit/TYSMThreadSafeDictionary.h>

#else
/// Foundation
#import "TYSMYYKitMacro.h"
#import "YYKitMacro.h"
#import "NSObject+TYSMAdd.h"
#import "NSObject+TYSMAddForKVO.h"
#import "NSObject+TYSMAddForARC.h"
#import "NSString+TYSMAdd.h"
#import "NSNumber+TYSMAdd.h"
#import "NSData+TYSMAdd.h"
#import "NSArray+TYSMAdd.h"
#import "NSDictionary+TYSMAdd.h"
#import "NSDate+TYSMAdd.h"
#import "NSNotificationCenter+TYSMAdd.h"
#import "NSKeyedUnarchiver+TYSMAdd.h"
#import "NSTimer+TYSMAdd.h"
#import "NSBundle+TYSMAdd.h"
#import "NSThread+TYSMAdd.h"
/// UIKit
#import "UIColor+TYSMAdd.h"
#import "UIImage+TYSMAdd.h"
#import "UIControl+TYSMAdd.h"
#import "UIBarButtonItem+TYSMAdd.h"
#import "UIGestureRecognizer+TYSMAdd.h"
#import "UIView+TYSMAdd.h"
#import "UIScrollView+TYSMAdd.h"
#import "UITableView+TYSMAdd.h"
#import "UITextField+TYSMAdd.h"
#import "UIScreen+TYSMAdd.h"
#import "UIDevice+TYSMAdd.h"
#import "UIApplication+TYSMAdd.h"
#import "UIFont+TYSMAdd.h"
#import "UIBezierPath+TYSMAdd.h"
// QuartZ
#import "CALayer+TYSMAdd.h"
#import "TYSMCGUtilities.h"
/// Model
#import "NSObject+TYSMModel.h"
#import "TYSMClassInfo.h"
/// Cache
#import "YYCache.h"
#import "YYMemoryCache.h"
#import "YYDiskCache.h"
#import "YYKVStorage.h"
///// Image
#import "TYSMImage.h"
#import "TYSMFrameImage.h"
#import "TYSMSpriteSheetImage.h"
#import "TYSM_AnimatedImageView.h"
#import "TYSMImageCoder.h"
#import "TYSMImageCache.h"
#import "TYSMWebImageOperation.h"
#import "TYSMWebImageManager.h"
#import "UIImageView+TYSMWebImage.h"
#import "UIButton+TYSMWebImage.h"
#import "MKAnnotationView+TYSMWebImage.h"
#import "CALayer+TYSMWebImage.h"
///// Text
#import "TYSMLabel.h"
#import "TYSMTextView.h"
#import "TYSMTextAttribute.h"
#import "TYSMTextArchiver.h"
#import "TYSMTextParser.h"
#import "YYTextUtilities.h"
#import "YYTextRunDelegate.h"
#import "YYTextRubyAnnotation.h"
#import "NSAttributedString+YYText.h"
#import "NSParagraphStyle+YYText.h"
#import "UIPasteboard+YYText.h"
#import "YYTextLayout.h"
#import "YYTextLine.h"
#import "YYTextInput.h"
#import "YYTextDebugOption.h"
#import "YYTextContainerView.h"
#import "YYTextSelectionView.h"
#import "YYTextMagnifier.h"
#import "YYTextEffectWindow.h"
#import "YYTextKeyboardManager.h"

#import "YYReachability.h"
#import "YYGestureRecognizer.h"
#import "YYFileHash.h"
#import "YYKeychain.h"
#import "YYWeakProxy.h"
#import "TYSMTimer.h"
#import "YYTransaction.h"
#import "TYSMAsyncLayer.h"
#import "YYSentinel.h"
#import "TYSMDispatchQueuePool.h"
#import "TYSMThreadSafeArray.h"
#import "TYSMThreadSafeDictionary.h"

#endif
