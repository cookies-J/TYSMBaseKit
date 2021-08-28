//
//  NSObject+TYSMAddForARC.m
//  YYKit <https://github.com/ibireme/YYKit>
//
//  Created by ibireme on 13/12/15.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "NSObject+TYSMAddForARC.h"

@interface NSObject_TYSMAddForARC : NSObject @end
@implementation NSObject_TYSMAddForARC @end

#if __has_feature(objc_arc)
#error This file must be compiled without ARC. Specify the -fno-objc-arc flag to this file.
#endif


@implementation NSObject (YYAddForARC)

- (instancetype)tysm_arcDebugRetain {
    return [self retain];
}

- (oneway void)tysm_arcDebugRelease {
    [self release];
}

- (instancetype)tysm_arcDebugAutorelease {
    return [self autorelease];
}

- (NSUInteger)tysm_arcDebugRetainCount {
    return [self retainCount];
}

@end
