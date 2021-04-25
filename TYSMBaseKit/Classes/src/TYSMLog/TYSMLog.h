//
//  TYSMLog.h
//  TYSMBaseKit
//
//  Created by Jele on 25/4/2021.
//

#import <TYSMBaseKit/TYSM_CocoaLumberjack.h>

static const TYSM_DDLogLevel tysm_ddLogLevel = TYSM_DDLogLevelVerbose;


#define TYSMLogError(...) TYSM_DDLogError(__VA_ARGS__)

#define TYSMLogWarn(...) TYSM_DDLogWarn(__VA_ARGS__)

#define TYSMLogInfo(...) TYSM_DDLogInfo(__VA_ARGS__)

#define TYSMLogDebug(...) TYSM_DDLogDebug(__VA_ARGS__)

#define TYSMLogVerbose(...) TYSM_DDLogVerbose(__VA_ARGS__)

NS_ASSUME_NONNULL_BEGIN

@interface TYSMLog : NSObject <TYSM_DDLogFormatter>
+ (void)addLogger;
+ (void)addSysLogger;
+ (void)addFileLogger;
@end

NS_ASSUME_NONNULL_END
