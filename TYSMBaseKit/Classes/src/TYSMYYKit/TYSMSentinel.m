//
//  TYSMSentinel.m
//  TYSMKit <https://github.com/ibireme/TYSMKit>
//
//  Created by ibireme on 15/4/13.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "TYSMSentinel.h"
#import <libkern/OSAtomic.h>

@implementation TYSMSentinel {
    int32_t _value;
}

- (int32_t)tysm_value {
    return _value;
}

- (int32_t)tysm_increase {
    return OSAtomicIncrement32(&_value);
}

@end
