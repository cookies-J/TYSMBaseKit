//
//  TYSMBackgroundTask.h
//  QIMSDK
//
//  Created by Jele on 16/12/2020.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, TYSMBackgroundTaskEndType) {
    TYSMBackgroundTaskEndTypeNormal = 1 << 0,
    TYSMBackgroundTaskEndTypeTimeout = 1 << 1
};
typedef void(^TYSMBackgroundTaskStartBlock)(UIBackgroundTaskIdentifier identifier);
typedef void(^TYSMBackgroundTaskEndBlock)(TYSMBackgroundTaskEndType type);

NS_ASSUME_NONNULL_BEGIN

@interface TYSMBackgroundTask : NSObject

/// 查询可在后台运行的剩余时间，不推荐频繁查询。
/// 先执行 - (void)addBackgroundTask:(TYSMBackgroundTaskStartBlock)start endTask:(TYSMBackgroundTaskEndBlock)end
@property (nonatomic, assign, readonly) NSTimeInterval backgroundTimeRemaining;

/// 顾名思义
/// @param start 开始背景任务
/// @param end 停止背景任务，用于前台或者时间到
- (void)addBackgroundTask:(TYSMBackgroundTaskStartBlock)start
                  endTask:(TYSMBackgroundTaskEndBlock)end;

- (instancetype)initWithBackgroundTask:(TYSMBackgroundTaskStartBlock)start
                               endTask:(TYSMBackgroundTaskEndBlock)end;

- (void)startMonitorBackgroundTask:(TYSMBackgroundTaskStartBlock)start
endTask:(TYSMBackgroundTaskEndBlock)end;
@end

NS_ASSUME_NONNULL_END
