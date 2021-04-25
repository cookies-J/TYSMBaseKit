//
//  TYSMKit.h
//  TYSMKit <https://github.com/ibireme/TYSMKit>
//
//  Created by ibireme on 13/3/30.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <Foundation/Foundation.h>

#if __has_include(<TYSMKit/TYSMKit.h>)

FOUNDATION_EXPORT double TYSMKitVersionNumber;
FOUNDATION_EXPORT const unsigned char TYSMKitVersionString[];

#import <TYSMKit/TYSMKitMacro.h>
#import <TYSMKit/NSObject+TYSMAdd.h>
#import <TYSMKit/NSObject+TYSMAddForKVO.h>
#import <TYSMKit/NSObject+TYSMAddForARC.h>
#import <TYSMKit/NSString+TYSMAdd.h>
#import <TYSMKit/NSNumber+TYSMAdd.h>
#import <TYSMKit/NSData+TYSMAdd.h>
#import <TYSMKit/NSArray+TYSMAdd.h>
#import <TYSMKit/NSDictionary+TYSMAdd.h>
#import <TYSMKit/NSDate+TYSMAdd.h>
#import <TYSMKit/NSNotificationCenter+TYSMAdd.h>
#import <TYSMKit/NSKeyedUnarchiver+TYSMAdd.h>
#import <TYSMKit/NSTimer+TYSMAdd.h>
#import <TYSMKit/NSBundle+TYSMAdd.h>
#import <TYSMKit/NSThread+TYSMAdd.h>

#import <TYSMKit/UIColor+TYSMAdd.h>
#import <TYSMKit/UIImage+TYSMAdd.h>
#import <TYSMKit/UIControl+TYSMAdd.h>
#import <TYSMKit/UIBarButtonItem+TYSMAdd.h>
#import <TYSMKit/UIGestureRecognizer+TYSMAdd.h>
#import <TYSMKit/UIView+TYSMAdd.h>
#import <TYSMKit/UIScrollView+TYSMAdd.h>
#import <TYSMKit/UITableView+TYSMAdd.h>
#import <TYSMKit/UITextField+TYSMAdd.h>
#import <TYSMKit/UIScreen+TYSMAdd.h>
#import <TYSMKit/UIDevice+TYSMAdd.h>
#import <TYSMKit/UIApplication+TYSMAdd.h>
#import <TYSMKit/UIFont+TYSMAdd.h>
#import <TYSMKit/UIBezierPath+TYSMAdd.h>

#import <TYSMKit/CALayer+TYSMAdd.h>
#import <TYSMKit/TYSMCGUtilities.h>

#import <TYSMKit/NSObject+TYSMModel.h>
#import <TYSMKit/TYSMClassInfo.h>

#import <TYSMKit/TYSMCache.h>
#import <TYSMKit/TYSMMemoryCache.h>
#import <TYSMKit/TYSMDiskCache.h>
#import <TYSMKit/TYSMKVStorage.h>

#import <TYSMKit/TYSMImage.h>
#import <TYSMKit/TYSMFrameImage.h>
#import <TYSMKit/TYSMSpriteSheetImage.h>
#import <TYSMKit/TYSMAnimatedImageView.h>
#import <TYSMKit/TYSMImageCoder.h>
#import <TYSMKit/TYSMImageCache.h>
#import <TYSMKit/TYSMWebImageOperation.h>
#import <TYSMKit/TYSMWebImageManager.h>
#import <TYSMKit/UIImageView+TYSMWebImage.h>
#import <TYSMKit/UIButton+TYSMWebImage.h>
#import <TYSMKit/MKAnnotationView+TYSMWebImage.h>
#import <TYSMKit/CALayer+TYSMWebImage.h>

#import <TYSMKit/TYSMLabel.h>
#import <TYSMKit/TYSMTextView.h>
#import <TYSMKit/TYSMTextAttribute.h>
#import <TYSMKit/TYSMTextArchiver.h>
#import <TYSMKit/TYSMTextParser.h>
#import <TYSMKit/TYSMTextUtilities.h>
#import <TYSMKit/TYSMTextRunDelegate.h>
#import <TYSMKit/TYSMTextRubyAnnotation.h>
#import <TYSMKit/NSAttributedString+TYSMText.h>
#import <TYSMKit/NSParagraphStyle+TYSMText.h>
#import <TYSMKit/UIPasteboard+TYSMText.h>
#import <TYSMKit/TYSMTextLayout.h>
#import <TYSMKit/TYSMTextLine.h>
#import <TYSMKit/TYSMTextInput.h>
#import <TYSMKit/TYSMTextDebugOption.h>
#import <TYSMKit/TYSMTextContainerView.h>
#import <TYSMKit/TYSMTextSelectionView.h>
#import <TYSMKit/TYSMTextMagnifier.h>
#import <TYSMKit/TYSMTextEffectWindow.h>
#import <TYSMKit/TYSMTextKeyboardManager.h>

#import <TYSMKit/TYSMReachability.h>
#import <TYSMKit/TYSMGestureRecognizer.h>
#import <TYSMKit/TYSMFileHash.h>
#import <TYSMKit/TYSMKeychain.h>
#import <TYSMKit/TYSMWeakProxy.h>
#import <TYSMKit/TYSMTimer.h>
#import <TYSMKit/TYSMTransaction.h>
#import <TYSMKit/TYSMAsyncLayer.h>
#import <TYSMKit/TYSMSentinel.h>
#import <TYSMKit/TYSMDispatchQueuePool.h>
#import <TYSMKit/TYSMThreadSafeArray.h>
#import <TYSMKit/TYSMThreadSafeDictionary.h>

#else

#import "TYSMKitMacro.h"
#import "NSObject+TYSMAdd.h"
#import "NSObject+TYSMAddForKVO.h"
//#import "NSObject+TYSMAddForARC.h"
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
//#import "NSThread+TYSMAdd.h"

//#import "UIColor+TYSMAdd.h"
//#import "UIImage+TYSMAdd.h"
//#import "UIControl+TYSMAdd.h"
//#import "UIBarButtonItem+TYSMAdd.h"
//#import "UIGestureRecognizer+TYSMAdd.h"
//#import "UIView+TYSMAdd.h"
//#import "UIScrollView+TYSMAdd.h"
//#import "UITableView+TYSMAdd.h"
//#import "UITextField+TYSMAdd.h"
#import "UIScreen+TYSMAdd.h"
#import "UIDevice+TYSMAdd.h"
#import "UIApplication+TYSMAdd.h"
//#import "UIFont+TYSMAdd.h"
//#import "UIBezierPath+TYSMAdd.h"

//#import "CALayer+TYSMAdd.h"
//#import "TYSMCGUtilities.h"

#import "NSObject+TYSMModel.h"
#import "TYSMClassInfo.h"

#import "TYSMCache.h"
#import "TYSMMemoryCache.h"
#import "TYSMDiskCache.h"
#import "TYSMKVStorage.h"

//#import "TYSMImage.h"
//#import "TYSMFrameImage.h"
//#import "TYSMSpriteSheetImage.h"
//#import "TYSMAnimatedImageView.h"
//#import "TYSMImageCoder.h"
//#import "TYSMImageCache.h"
//#import "TYSMWebImageOperation.h"
//#import "TYSMWebImageManager.h"
//#import "UIImageView+TYSMWebImage.h"
//#import "UIButton+TYSMWebImage.h"
//#import "MKAnnotationView+TYSMWebImage.h"
//#import "CALayer+TYSMWebImage.h"

//#import "TYSMLabel.h"
//#import "TYSMTextView.h"
//#import "TYSMTextAttribute.h"
//#import "TYSMTextArchiver.h"
//#import "TYSMTextParser.h"
//#import "TYSMTextUtilities.h"
//#import "TYSMTextRunDelegate.h"
//#import "TYSMTextRubyAnnotation.h"
//#import "NSAttributedString+TYSMText.h"
//#import "NSParagraphStyle+TYSMText.h"
//#import "UIPasteboard+TYSMText.h"
//#import "TYSMTextLayout.h"
//#import "TYSMTextLine.h"
//#import "TYSMTextInput.h"
//#import "TYSMTextDebugOption.h"
//#import "TYSMTextContainerView.h"
//#import "TYSMTextSelectionView.h"
//#import "TYSMTextMagnifier.h"
//#import "TYSMTextEffectWindow.h"
//#import "TYSMTextKeyboardManager.h"

#import "TYSMReachability.h"
//#import "TYSMGestureRecognizer.h"
#import "TYSMFileHash.h"
#import "TYSMKeychain.h"
#import "TYSMWeakProxy.h"
#import "TYSMTimer.h"
#import "TYSMTransaction.h"
#import "TYSMAsyncLayer.h"
#import "TYSMSentinel.h"
#import "TYSMDispatchQueuePool.h"
#import "TYSMThreadSafeArray.h"
#import "TYSMThreadSafeDictionary.h"

#endif
