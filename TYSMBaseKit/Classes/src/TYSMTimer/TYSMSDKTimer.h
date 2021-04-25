//
//  TYSMTimer.h
//  Pods-TYSMTimer_Example
//
//  Created by jele lam on 24/9/2020.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^TYSMSDKTimerSuspendBlock)(NSString *timerId);
typedef void(^TYSMSDKTimerResumeBlock)(NSString *timerId);
typedef void(^TYSMSDKTimerCancelBlock)(NSString *timerId);

@interface TYSMSDKTimer : NSObject

/// 创建计时器，在 Block 回调
/// @return 返回一个时间的 ID 字符串
/// @param start 多少秒后开始
/// @param interval 间隔多少秒执行
/// @param countInterval 总需执行多少秒，从正式开始后计算
/// @param repeats YES:在 countInterval 秒内重复执行 NO:只执行一次
/// @param async YES:主线程 NO:子线程
/// @param completion 每隔 interval 秒回调一次
//+ (NSString *)timerWithStartTime:(NSTimeInterval)start interval:(NSTimeInterval)interval count:(NSTimeInterval)countInterval repeats:(BOOL)repeats mainQueue:(BOOL)async completion:(void (^)(NSTimeInterval interval))completion;

/// 创建时间，执行指定的 target selector
/// @return 返回一个时间的 ID 字符串
/// @param target 指定的 target
/// @param selector 指定的 selector
/// @param start 多少秒后开始
/// @param interval 间隔多少秒执行
/// @param countInterval 总需执行多少秒，从正式开始后计算
/// @param repeats YES:在 countInterval 秒内重复执行 NO:只执行一次
/// @param async YES:主线程 NO:子线程
//+ (NSString *)timerWithTarget:(id)target selector:(SEL)selector StartTime:(NSTimeInterval)start interval:(NSTimeInterval)interval count:(NSTimeInterval)countInterval repeats:(BOOL)repeats mainQueue:(BOOL)async;

//+(NSString *)timerWithStartTime:(NSTimeInterval)start interval:(NSTimeInterval)interval count:(NSTimeInterval)countInterval repeats:(BOOL)repeats mainQueue:(BOOL)async completionId:(void (^)(NSTimeInterval interval,NSString *timeId))completion;

+(NSString *)timerWithTimerId:(NSString *)timerId interval:(NSTimeInterval)interval count:(NSTimeInterval)countInterval repeats:(BOOL)repeats mainQueue:(BOOL)async completionId:(void (^)(NSTimeInterval interval,NSString *timeId))completion;

+ (void)getTimerStatus:(TYSMSDKTimerResumeBlock)resumeBlock
suspend:(TYSMSDKTimerSuspendBlock)suspendBlock
cancel:(TYSMSDKTimerCancelBlock)cancelBlock;

@property (copy) TYSMSDKTimerResumeBlock resumeBlock;
@property (copy) TYSMSDKTimerSuspendBlock suspendBlock;
@property (copy) TYSMSDKTimerCancelBlock cancelBlock;

/// 立刻结束
/// @param timerID 创建的时间 ID 字符串
+ (void)cancel:(NSString *)timerID;

/// 暂停时钟
/// @param timerId 时间 id
+ (void)suspend:(NSString *)timerId;

/// 恢复时钟
/// @param timerId 时间 id
+ (void)resume:(NSString *)timerId;

+ (NSDictionary *)getCurrentTimers;
@end

NS_ASSUME_NONNULL_END
