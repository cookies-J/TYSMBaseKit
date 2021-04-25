//
//  TYSMSentinel.h
//  TYSMKit <https://github.com/ibireme/TYSMKit>
//
//  Created by ibireme on 15/4/13.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 TYSMSentinel is a thread safe incrementing counter. 
 It may be used in some multi-threaded situation.
 */
@interface TYSMSentinel : NSObject

/// Returns the current value of the counter.
@property (readonly) int32_t value;

/// tysm_increase the value atomically.
/// @return The new value.
- (int32_t)tysm_increase;

@end

NS_ASSUME_NONNULL_END