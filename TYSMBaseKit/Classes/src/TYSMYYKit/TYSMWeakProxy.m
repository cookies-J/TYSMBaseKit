//
//  TYSMWeakProxy.m
//  TYSMKit <https://github.com/ibireme/TYSMKit>
//
//  Created by ibireme on 14/10/18.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "TYSMWeakProxy.h"


@implementation TYSMWeakProxy

- (instancetype)initWithTarget:(id)target {
    _target = target;
    return self;
}

+ (instancetype)proxyWithTarget:(id)target {
    return [[TYSMWeakProxy alloc] initWithTarget:target];
}

- (id)tysm_forwardingTargetForSelector:(SEL)selector {
    return _target;
}

- (void)tysm_forwardInvocation:(NSInvocation *)invocation {
    void *null = NULL;
    [invocation setReturnValue:&null];
}

- (NSMethodSignature *)tysm_methodSignatureForSelector:(SEL)selector {
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

- (BOOL)tysm_respondsToSelector:(SEL)aSelector {
    return [_target respondsToSelector:aSelector];
}

- (BOOL)tysm_isEqual:(id)object {
    return [_target isEqual:object];
}

- (NSUInteger)tysm_hash {
    return [_target hash];
}

- (Class)tysm_superclass {
    return [_target superclass];
}

- (Class)tysm_class {
    return [_target class];
}

- (BOOL)tysm_isKindOfClass:(Class)aClass {
    return [_target isKindOfClass:aClass];
}

- (BOOL)tysm_isMemberOfClass:(Class)aClass {
    return [_target isMemberOfClass:aClass];
}

- (BOOL)tysm_conformsToProtocol:(Protocol *)aProtocol {
    return [_target conformsToProtocol:aProtocol];
}

- (BOOL)tysm_isProxy {
    return YES;
}

- (NSString *)tysm_description {
    return [_target description];
}

- (NSString *)tysm_debugDescription {
    return [_target debugDescription];
}

@end
