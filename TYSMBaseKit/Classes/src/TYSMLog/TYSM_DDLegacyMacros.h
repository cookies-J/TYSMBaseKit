// Software License Agreement (BSD License)
//
// Copyright (c) 2010-2020, Deusty, LLC
// All rights reserved.
//
// Redistribution and use of this software in source and binary forms,
// with or without modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
//
// * Neither the name of Deusty nor the names of its contributors may be used
//   to endorse or promote products derived from this software without specific
//   prior written permission of Deusty, LLC.

/**
 * Legacy macros used for 1.9.x backwards compatibility.
 *
 * Imported by default when importing a TYSM_DDLog.h directly and TYSM_DD_LEGACY_MACROS is not defined and set to 0.
 **/
#if TYSM_DD_LEGACY_MACROS

#warning CocoaLumberjack 1.9.x legacy macros enabled. \
Disable legacy macros by importing CocoaLumberjack.h or TYSM_DDLogMacros.h instead of TYSM_DDLog.h or add `#define TYSM_DD_LEGACY_MACROS 0` before importing TYSM_DDLog.h.

#ifndef TYSM_LOG_LEVEL_DEF
    #define TYSM_LOG_LEVEL_DEF tysm_ddLogLevel
#endif

#define TYSM_LOG_FLAG_ERROR    TYSM_DDLogFlagError
#define TYSM_LOG_FLAG_WARN     TYSM_DDLogFlagWarning
#define TYSM_LOG_FLAG_INFO     TYSM_DDLogFlagInfo
#define TYSM_LOG_FLAG_DEBUG    TYSM_DDLogFlagDebug
#define TYSM_LOG_FLAG_VERBOSE  TYSM_DDLogFlagVerbose

#define TYSM_LOG_LEVEL_OFF     TYSM_DDLogLevelOff
#define TYSM_LOG_LEVEL_ERROR   TYSM_DDLogLevelError
#define TYSM_LOG_LEVEL_WARN    TYSM_DDLogLevelWarning
#define TYSM_LOG_LEVEL_INFO    TYSM_DDLogLevelInfo
#define TYSM_LOG_LEVEL_DEBUG   TYSM_DDLogLevelDebug
#define TYSM_LOG_LEVEL_VERBOSE TYSM_DDLogLevelVerbose
#define TYSM_LOG_LEVEL_ALL     TYSM_DDLogLevelAll

#define TYSM_LOG_ASYNC_ENABLED YES

#define TYSM_LOG_ASYNC_ERROR    ( NO && TYSM_LOG_ASYNC_ENABLED)
#define TYSM_LOG_ASYNC_WARN     (YES && TYSM_LOG_ASYNC_ENABLED)
#define TYSM_LOG_ASYNC_INFO     (YES && TYSM_LOG_ASYNC_ENABLED)
#define TYSM_LOG_ASYNC_DEBUG    (YES && TYSM_LOG_ASYNC_ENABLED)
#define TYSM_LOG_ASYNC_VERBOSE  (YES && TYSM_LOG_ASYNC_ENABLED)

#define TYSM_LOG_MACRO(isAsynchronous, lvl, flg, ctx, atag, fnct, frmt, ...) \
        [TYSM_DDLog log : isAsynchronous                                     \
             level : lvl                                                \
              flag : flg                                                \
           context : ctx                                                \
              file : __FILE__                                           \
          function : fnct                                               \
              line : __LINE__                                           \
               tag : atag                                               \
            format : (frmt), ## __VA_ARGS__]

#define TYSM_LOG_MAYBE(async, lvl, flg, ctx, fnct, frmt, ...)                       \
        do { if((lvl & flg) != 0) TYSM_LOG_MACRO(async, lvl, flg, ctx, nil, fnct, frmt, ##__VA_ARGS__); } while(0)

#define TYSM_LOG_OBJC_MAYBE(async, lvl, flg, ctx, frmt, ...) \
        TYSM_LOG_MAYBE(async, lvl, flg, ctx, __PRETTY_FUNCTION__, frmt, ## __VA_ARGS__)

#define TYSM_DDLogError(frmt, ...)   TYSM_LOG_OBJC_MAYBE(TYSM_LOG_ASYNC_ERROR,   TYSM_LOG_LEVEL_DEF, TYSM_LOG_FLAG_ERROR,   0, frmt, ##__VA_ARGS__)
#define TYSM_DDLogWarn(frmt, ...)    TYSM_LOG_OBJC_MAYBE(TYSM_LOG_ASYNC_WARN,    TYSM_LOG_LEVEL_DEF, TYSM_LOG_FLAG_WARN,    0, frmt, ##__VA_ARGS__)
#define TYSM_DDLogInfo(frmt, ...)    TYSM_LOG_OBJC_MAYBE(TYSM_LOG_ASYNC_INFO,    TYSM_LOG_LEVEL_DEF, TYSM_LOG_FLAG_INFO,    0, frmt, ##__VA_ARGS__)
#define TYSM_DDLogDebug(frmt, ...)   TYSM_LOG_OBJC_MAYBE(TYSM_LOG_ASYNC_DEBUG,   TYSM_LOG_LEVEL_DEF, TYSM_LOG_FLAG_DEBUG,   0, frmt, ##__VA_ARGS__)
#define TYSM_DDLogVerbose(frmt, ...) TYSM_LOG_OBJC_MAYBE(TYSM_LOG_ASYNC_VERBOSE, TYSM_LOG_LEVEL_DEF, TYSM_LOG_FLAG_VERBOSE, 0, frmt, ##__VA_ARGS__)

#endif
