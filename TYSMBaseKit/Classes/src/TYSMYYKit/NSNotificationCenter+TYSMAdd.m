//
//  NSNotificationCenter+TYSMAdd.m
//  TYSMKit <https://github.com/ibireme/TYSMKit>
//
//  Created by ibireme on 13/8/24.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "NSNotificationCenter+TYSMAdd.h"
#include <pthread.h>
#import "TYSMKitMacro.h"

TYSMSYNTH_DUMMY_CLASS(NSNotificationCenter_YYAdd)


@implementation NSNotificationCenter (TYSMAdd)

- (void)tysm_postNotificationOnMainThread:(NSNotification *)notification {
    if (pthread_main_np()) return [self postNotification:notification];
    [self tysm_postNotificationOnMainThread:notification waitUntilDone:NO];
}

- (void)tysm_postNotificationOnMainThread:(NSNotification *)notification waitUntilDone:(BOOL)wait {
    if (pthread_main_np()) return [self postNotification:notification];
    [[self class] performSelectorOnMainThread:@selector(_yy_postNotification:) withObject:notification waitUntilDone:wait];
}

- (void)tysm_postNotificationOnMainThreadWithName:(NSString *)name object:(id)object {
    if (pthread_main_np()) return [self postNotificationName:name object:object userInfo:nil];
    [self tysm_postNotificationOnMainThreadWithName:name object:object userInfo:nil waitUntilDone:NO];
}

- (void)tysm_postNotificationOnMainThreadWithName:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo {
    if (pthread_main_np()) return [self postNotificationName:name object:object userInfo:userInfo];
    [self tysm_postNotificationOnMainThreadWithName:name object:object userInfo:userInfo waitUntilDone:NO];
}

- (void)tysm_postNotificationOnMainThreadWithName:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo waitUntilDone:(BOOL)wait {
    if (pthread_main_np()) return [self postNotificationName:name object:object userInfo:userInfo];
    NSMutableDictionary *info = [[NSMutableDictionary allocWithZone:nil] initWithCapacity:3];
    if (name) [info setObject:name forKey:@"name"];
    if (object) [info setObject:object forKey:@"object"];
    if (userInfo) [info setObject:userInfo forKey:@"userInfo"];
    [[self class] performSelectorOnMainThread:@selector(_yy_postNotificationName:) withObject:info waitUntilDone:wait];
}

+ (void)_yy_postNotification:(NSNotification *)notification {
    [[self defaultCenter] postNotification:notification];
}

+ (void)_yy_postNotificationName:(NSDictionary *)info {
    NSString *name = [info objectForKey:@"name"];
    id object = [info objectForKey:@"object"];
    NSDictionary *userInfo = [info objectForKey:@"userInfo"];
    
    [[self defaultCenter] postNotificationName:name object:object userInfo:userInfo];
}

@end
