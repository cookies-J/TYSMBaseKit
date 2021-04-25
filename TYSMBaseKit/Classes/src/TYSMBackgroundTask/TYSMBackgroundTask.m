//
//  TYSMBackgroundTask.m
//  QIMSDK
//
//  Created by Jele on 16/12/2020.
//

#import "TYSMBackgroundTask.h"

@interface TYSMBackgroundTask () <UIApplicationDelegate>
@property (nonatomic, strong) NSMutableArray *backgroundTasks;
@property (nonatomic, copy) TYSMBackgroundTaskStartBlock startBlock;
@property (nonatomic, copy) TYSMBackgroundTaskEndBlock endBlock;
@end

@implementation TYSMBackgroundTask
- (instancetype)init {
    if (self = [super init]) {
//        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
//
//        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:mainQueue usingBlock:^(NSNotification * _Nonnull note) {
//            self.startBlock == nil ? : self.startBlock([self.backgroundTasks.firstObject unsignedIntegerValue]);
//        }];
//
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
//
//        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:mainQueue usingBlock:^(NSNotification * _Nonnull note) {
//            id obj = self.backgroundTasks.firstObject;
//            [self removeBackgroundIdentifier:[obj unsignedIntegerValue]];
//            [self.backgroundTasks removeObject:obj];
//        }];
//
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];

    }
    return self;
}

- (instancetype)initWithBackgroundTask:(TYSMBackgroundTaskStartBlock)start endTask:(TYSMBackgroundTaskEndBlock)end {
    if (self = [self init]) {
        self.startBlock = start;
        self.endBlock = end;
    }
    return self;
}

- (void)startMonitorBackgroundTask:(TYSMBackgroundTaskStartBlock)start endTask:(TYSMBackgroundTaskEndBlock)end {
    self.startBlock = start;
    self.endBlock = end;
}

- (void)willEnterForeground:(NSNotification *)noti {
    id obj = self.backgroundTasks.firstObject;
    [self removeBackgroundIdentifier:[obj unsignedIntegerValue]];
    [self.backgroundTasks removeObject:obj];
    !self.endBlock ? : self.endBlock(TYSMBackgroundTaskEndTypeNormal);
}

- (void)didEnterBackground:(NSNotification *)noti {
//    self.startBlock == nil ? : self.startBlock([self.backgroundTasks.firstObject unsignedIntegerValue]);
    __weak typeof (self) weakself = self;
    UIBackgroundTaskIdentifier currBGTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        id obj = weakself.backgroundTasks.firstObject;
        [weakself removeBackgroundIdentifier:[obj unsignedIntegerValue]];
        [weakself.backgroundTasks removeObject:obj];
        !weakself.endBlock ? : weakself.endBlock(TYSMBackgroundTaskEndTypeTimeout);
    }];

    if (currBGTaskId != UIBackgroundTaskInvalid) {
        [self.backgroundTasks addObject:@(currBGTaskId)];
        !self.startBlock ? : self.startBlock(currBGTaskId);
    }
}

- (void)removeBackgroundIdentifier:(UIBackgroundTaskIdentifier)bgIdentifier {
    [[UIApplication sharedApplication] endBackgroundTask:bgIdentifier];
    bgIdentifier = UIBackgroundTaskInvalid;
}

- (void)addBackgroundTask:(TYSMBackgroundTaskStartBlock)start endTask:(TYSMBackgroundTaskEndBlock)end {
    __weak typeof (self) weakself = self;
    UIBackgroundTaskIdentifier currBGTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        weakself.endBlock == nil ? : weakself.endBlock(TYSMBackgroundTaskEndTypeTimeout);
        id obj = weakself.backgroundTasks.firstObject;
        [weakself removeBackgroundIdentifier:[obj unsignedIntegerValue]];
        [weakself.backgroundTasks removeObject:obj];
    }];

    if (currBGTaskId != UIBackgroundTaskInvalid) {
        [self.backgroundTasks addObject:@(currBGTaskId)];
        self.startBlock = start;
        self.endBlock = end;
    }
    
}

- (NSTimeInterval)backgroundTimeRemaining {
    NSTimeInterval currRemaining = [UIApplication sharedApplication].backgroundTimeRemaining;
    
    return currRemaining == DBL_MAX ? 0 : currRemaining;
    
}

- (NSMutableArray *)backgroundTasks {
    if (_backgroundTasks == nil) {
        _backgroundTasks = [NSMutableArray array];
    }
    return _backgroundTasks;
}
@end
