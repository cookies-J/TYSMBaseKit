//
//  NSObject+TYSMAddForARC.h
//  YYKit <https://github.com/ibireme/YYKit>
//
//  Created by ibireme on 13/12/15.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <Foundation/Foundation.h>

/**
 Debug method for NSObject when using ARC.
 */
@interface NSObject (YYAddForARC)

/// Same as `retain`
- (instancetype)tysm_arcDebugRetain;

/// Same as `release`
- (oneway void)tysm_arcDebugRelease;

/// Same as `autorelease`
- (instancetype)tysm_arcDebugAutorelease;

/// Same as `retainCount`
- (NSUInteger)tysm_arcDebugRetainCount;

@end
