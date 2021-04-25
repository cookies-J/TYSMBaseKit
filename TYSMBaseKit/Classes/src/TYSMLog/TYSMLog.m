//
//  TYSMLog.m
//  TYSMBaseKit
//
//  Created by Jele on 25/4/2021.
//

#import "TYSMLog.h"
#import <objc/runtime.h>

@interface TYSMLog () <TYSM_DDLogFormatter>
@property (strong) NSDateFormatter *logDateFormatter;
@end

@implementation TYSMLog

+ (instancetype)shareInstance {
    
    id instance = objc_getAssociatedObject(self, @"shareInstance");
    
    if (!instance)
    {
        instance = [[super allocWithZone:NULL] init];

        [instance configLogDateFormatter];
    }
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self shareInstance] ;
}

- (id)copyWithZone:(struct _NSZone *)zone {
    Class selfClass = [self class];
    return [selfClass shareInstance] ;
}

- (void)configLogDateFormatter {
    self.logDateFormatter = [[NSDateFormatter alloc] init];
    [self.logDateFormatter setDateFormat:@"HH:mm:ss.SSSSSS"];
    [self.logDateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
}


+ (void)addLogger {
    
    TYSM_DDTTYLogger *logger = [TYSM_DDTTYLogger sharedInstance];
    logger.logFormatter = [self shareInstance];
    
    [TYSM_DDLog addLogger:logger];
    
}

+ (void)addSysLogger {
    TYSM_DDOSLogger *logger = [TYSM_DDOSLogger sharedInstance];

    logger.logFormatter = [self shareInstance];
    
    [TYSM_DDLog addLogger:logger];
}

+ (void)addFileLogger {
    TYSM_DDFileLogger *fileLogger = [[TYSM_DDFileLogger alloc] init];
    
    fileLogger.rollingFrequency = 60 * 60 * 24;
    
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    
    fileLogger.logFormatter = [self shareInstance];
    
    [TYSM_DDLog addLogger:fileLogger];
    
    TYSM_DDLogVerbose(@"%@",fileLogger.currentLogFileInfo.filePath);
}

- (NSString *)formatLogMessage:(TYSM_DDLogMessage *)logMessage {
    @autoreleasepool {
        
    NSString *loglevel = nil;
    switch (logMessage.flag){
        case TYSM_DDLogFlagError:
            loglevel = @"[ERROR]";
            return [NSString stringWithFormat:@"%@ | %@ | %@ | %@ | %@ | %lu | ==> %@",[self.logDateFormatter stringFromDate:logMessage.timestamp]  ,loglevel,logMessage.threadID,logMessage.queueLabel,logMessage.function,logMessage.line,logMessage.message];
            break;
        case TYSM_DDLogFlagWarning:
            loglevel = @"[WARN]";
            return [NSString stringWithFormat:@"%@ | %@ | %@ | %lu | ==> %@",[self.logDateFormatter stringFromDate:logMessage.timestamp] ,loglevel,logMessage.function,logMessage.line,logMessage.message];
            break;
        case TYSM_DDLogFlagInfo:
            loglevel = @"[INFO]";
            return [NSString stringWithFormat:@"%@ | %@ | %@ | ==> %@ ",[self.logDateFormatter stringFromDate:logMessage.timestamp] ,loglevel, logMessage.queueLabel,logMessage.message];
            break;
        case TYSM_DDLogFlagDebug:
            loglevel = @"[DEBUG]";
            break;
        case TYSM_DDLogFlagVerbose:
            loglevel = @"[VBOSE]";
            return [NSString stringWithFormat:@"%@ | %@ | %@ | %@ | %@ | %lu | ==> %@",[self.logDateFormatter stringFromDate:logMessage.timestamp] ,loglevel,logMessage.threadID,logMessage.queueLabel,logMessage.function,logMessage.line,logMessage.message];
            break;
    }

    };
    assert("unknown error");

    return @"";
}
@end
