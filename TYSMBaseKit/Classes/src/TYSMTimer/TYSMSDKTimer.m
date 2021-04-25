//
//  TYSMTimer.m
//  Pods-TYSMTimer_Example
//
//  Created by jele lam on 24/9/2020.
//

#import "TYSMSDKTimer.h"
#import "TYSMThreadSafeDictionary.h"

@implementation TYSMSDKTimer
static int i = 0;

// 创建保存timer的容器
static TYSMThreadSafeDictionary *timers;
//dispatch_semaphore_t sem;

+(void)initialize{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timers = [TYSMThreadSafeDictionary dictionary];
//        sem = dispatch_semaphore_create(1);
    });
}

+(NSString *)timerWithTarget:(id)target selector:(SEL)selector StartTime:(NSTimeInterval)start interval:(NSTimeInterval)interval count:(NSTimeInterval)countInterval repeats:(BOOL)repeats mainQueue:(BOOL)async {
    if (!target || !selector) {
        return nil;
    }
    
    return [self timerWithStartTime:start interval:interval count:countInterval repeats:repeats mainQueue:async completion:^(NSTimeInterval interval) {
        if ([target respondsToSelector:selector]) {
            [target performSelector:selector];
        }
    }];
}

+(NSString *)timerWithStartTime:(NSTimeInterval)start interval:(NSTimeInterval)interval count:(NSTimeInterval)countInterval repeats:(BOOL)repeats mainQueue:(BOOL)async completion:(void (^)(NSTimeInterval))completion {
    if (!completion || start < 0 ||  interval <= 0) {
        return nil;
    }
    // 创建定时器
    dispatch_queue_t queue = !async ? dispatch_queue_create("tysm_gcd_timer_queue", NULL) : dispatch_get_main_queue();
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue );
    // 设置时间,从 start 秒之后开始，interval 秒一次
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, start * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0);
//    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    NSString *timerId = [NSString stringWithFormat:@"TimerID: %d",i++];
    __block NSTimeInterval reverseInterval = countInterval;
    timers[timerId]=timer;
    
//    dispatch_semaphore_signal(sem);
    // 回调
    dispatch_source_set_event_handler(timer, ^{
        if (completion) {
            completion(reverseInterval--);
        }
        // 不重复执行就取消timer 或者计数 <= 0
        if (repeats == NO ||
            reverseInterval < 0) {
            [self cancel:timerId];
        }
    });
    dispatch_resume(timer);
    
    return timerId;
}

+(NSString *)timerWithStartTime:(NSTimeInterval)start interval:(NSTimeInterval)interval count:(NSTimeInterval)countInterval repeats:(BOOL)repeats mainQueue:(BOOL)async completionId:(nonnull void (^)(NSTimeInterval, NSString * _Nonnull))completion {
    if (!completion || start < 0 ||  interval <= 0) {
        return nil;
    }
    // 创建定时器
    dispatch_queue_t queue = !async ? dispatch_queue_create("tysm_gcd_timer_queue", NULL) : dispatch_get_main_queue();
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue );
    // 设置时间,从 start 秒之后开始，interval 秒一次
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, start * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0);
//    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    NSString *timerId = [NSString stringWithFormat:@"TimerID: %d",i++];
    __block NSTimeInterval reverseInterval = countInterval;
    timers[timerId]=timer;
    
//    dispatch_semaphore_signal(sem);
    // 回调
    dispatch_source_set_event_handler(timer, ^{
        if (completion) {
            completion(reverseInterval--,timerId);
        }
        // 不重复执行就取消timer 或者计数 <= 0
        if (repeats == NO ||
            reverseInterval < 0) {
            [self cancel:timerId];
        }
    });
    dispatch_resume(timer);

    return timerId;
}

+(NSString *)timerWithTimerId:(NSString *)timerId interval:(NSTimeInterval)interval count:(NSTimeInterval)countInterval repeats:(BOOL)repeats mainQueue:(BOOL)async completionId:(void (^)(NSTimeInterval interval,NSString *timeId))completion {
    if (!completion ||  interval <= 0) {
        return nil;
    }
    // 创建定时器
    dispatch_queue_t queue = !async ? dispatch_queue_create("tysm_gcd_timer_queue", NULL) : dispatch_get_main_queue();
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue );
    // 设置时间,从 start 秒之后开始，interval 秒一次
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0);
//    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    __block NSTimeInterval reverseInterval = countInterval;
    timers[timerId] = timer;
//    TYSM_DDLogVerbose(@"timer join => %s\n", [timerId UTF8String]);

//    dispatch_semaphore_signal(sem);
    // 回调
    dispatch_source_set_event_handler(timer, ^{
        if (completion) {
            completion(reverseInterval--,timerId);
        }
        // 不重复执行就取消timer 或者计数 <= 0
        if (repeats == NO ||
            reverseInterval < 0) {
            [TYSMSDKTimer cancel:timerId];
        }
    });
    [TYSMSDKTimer resume:timerId];
    
    return timerId;
}

+ (void)cancel:(NSString *)timerID{
    @synchronized (self) {
        if (!timerID || timerID.length <= 0) {
            return;
        }
        //    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        dispatch_source_t timer = timers[timerID];
        if (timer) {
            dispatch_source_cancel(timer);
            [timers removeObjectForKey:timerID];
//            TYSM_DDLogVerbose(@"timer remove => %s\n", [timerID UTF8String]);
        }
        
        if (timers.count > 0) {
//            TYSM_DDLogVerbose(@"current timer %@",timers);
        }
    };
//    dispatch_semaphore_signal(sem);
}

+ (void)suspend:(NSString *)timerId {
    @synchronized (self) {
        if (!timerId || timerId.length <= 0) {
            return;
        }
        dispatch_source_t timer = timers[timerId];
        if (timer) {
            dispatch_suspend(timer);
//            TYSM_DDLogVerbose(@"timer suspend => %s\n", [timerId UTF8String]);
        }
    }
}

+ (void)resume:(NSString *)timerId {
    @synchronized (self) {
        if (!timerId || timerId.length <= 0) {
            return;
        }
        dispatch_source_t timer = timers[timerId];
        if (timer) {
            dispatch_resume(timer);
            
//            TYSM_DDLogVerbose(@"timer resume => %s\n", [timerId UTF8String]);
        }
    };
}

+ (NSDictionary *)getCurrentTimers {
    return timers.copy;
}

+ (void)getTimerStatus:(TYSMSDKTimerResumeBlock)resumeBlock suspend:(TYSMSDKTimerSuspendBlock)suspendBlock cancel:(TYSMSDKTimerCancelBlock)cancelBlock {
    
}
@end
