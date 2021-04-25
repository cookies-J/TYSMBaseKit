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

// Disable legacy macros
#ifndef TYSM_DD_LEGACY_MACROS
    #define TYSM_DD_LEGACY_MACROS 0
#endif

#import "TYSM_DDLog.h"

/**
 * The constant/variable/method responsible for controlling the current log level.
 **/
#ifndef TYSM_LOG_LEVEL_DEF
    #define TYSM_LOG_LEVEL_DEF tysm_ddLogLevel
#endif

/**
 * Whether async should be used by log messages, excluding error messages that are always sent sync.
 **/
#ifndef TYSM_LOG_ASYNC_ENABLED
    #define TYSM_LOG_ASYNC_ENABLED YES
#endif

/**
 * These are the two macros that all other macros below compile into.
 * These big multiline macros makes all the other macros easier to read.
 **/
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

#define TYSM_LOG_MACRO_TO_DDLOG(tysm_ddlog, isAsynchronous, lvl, flg, ctx, atag, fnct, frmt, ...) \
        [tysm_ddlog log : isAsynchronous                                     \
             level : lvl                                                \
              flag : flg                                                \
           context : ctx                                                \
              file : __FILE__                                           \
          function : fnct                                               \
              line : __LINE__                                           \
               tag : atag                                               \
            format : (frmt), ## __VA_ARGS__]

/**
 * Define version of the macro that only execute if the log level is above the threshold.
 * The compiled versions essentially look like this:
 *
 * if (logFlagForThisLogMsg & tysm_ddLogLevel) { execute log message }
 *
 * When TYSM_LOG_LEVEL_DEF is defined as tysm_ddLogLevel.
 *
 * As shown further below, Lumberjack actually uses a bitmask as opposed to primitive log levels.
 * This allows for a great amount of flexibility and some pretty advanced fine grained logging techniques.
 *
 * Note that when compiler optimizations are enabled (as they are for your release builds),
 * the log messages above your logging threshold will automatically be compiled out.
 *
 * (If the compiler sees TYSM_LOG_LEVEL_DEF/tysm_ddLogLevel declared as a constant, the compiler simply checks to see
 *  if the 'if' statement would execute, and if not it strips it from the binary.)
 *
 * We also define shorthand versions for asynchronous and synchronous logging.
 **/
#define TYSM_LOG_MAYBE(async, lvl, flg, ctx, tag, fnct, frmt, ...) \
        do { if((lvl & flg) != 0) TYSM_LOG_MACRO(async, lvl, flg, ctx, tag, fnct, frmt, ##__VA_ARGS__); } while(0)

#define TYSM_LOG_MAYBE_TO_DDLOG(tysm_ddlog, async, lvl, flg, ctx, tag, fnct, frmt, ...) \
        do { if((lvl & flg) != 0) TYSM_LOG_MACRO_TO_DDLOG(tysm_ddlog, async, lvl, flg, ctx, tag, fnct, frmt, ##__VA_ARGS__); } while(0)

/**
 * Ready to use log macros with no context or tag.
 **/
#define TYSM_DDLogError(frmt, ...)   TYSM_LOG_MAYBE(NO,                TYSM_LOG_LEVEL_DEF, TYSM_DDLogFlagError,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define TYSM_DDLogWarn(frmt, ...)    TYSM_LOG_MAYBE(TYSM_LOG_ASYNC_ENABLED, TYSM_LOG_LEVEL_DEF, TYSM_DDLogFlagWarning, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define TYSM_DDLogInfo(frmt, ...)    TYSM_LOG_MAYBE(TYSM_LOG_ASYNC_ENABLED, TYSM_LOG_LEVEL_DEF, TYSM_DDLogFlagInfo,    0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define TYSM_DDLogDebug(frmt, ...)   TYSM_LOG_MAYBE(TYSM_LOG_ASYNC_ENABLED, TYSM_LOG_LEVEL_DEF, TYSM_DDLogFlagDebug,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define TYSM_DDLogVerbose(frmt, ...) TYSM_LOG_MAYBE(TYSM_LOG_ASYNC_ENABLED, TYSM_LOG_LEVEL_DEF, TYSM_DDLogFlagVerbose, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define TYSM_DDLogErrorToDDLog(tysm_ddlog, frmt, ...)   TYSM_LOG_MAYBE_TO_DDLOG(tysm_ddlog, NO,                TYSM_LOG_LEVEL_DEF, TYSM_DDLogFlagError,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define TYSM_DDLogWarnToDDLog(tysm_ddlog, frmt, ...)    TYSM_LOG_MAYBE_TO_DDLOG(tysm_ddlog, TYSM_LOG_ASYNC_ENABLED, TYSM_LOG_LEVEL_DEF, TYSM_DDLogFlagWarning, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define TYSM_DDLogInfoToDDLog(tysm_ddlog, frmt, ...)    TYSM_LOG_MAYBE_TO_DDLOG(tysm_ddlog, TYSM_LOG_ASYNC_ENABLED, TYSM_LOG_LEVEL_DEF, TYSM_DDLogFlagInfo,    0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define TYSM_DDLogDebugToDDLog(tysm_ddlog, frmt, ...)   TYSM_LOG_MAYBE_TO_DDLOG(tysm_ddlog, TYSM_LOG_ASYNC_ENABLED, TYSM_LOG_LEVEL_DEF, TYSM_DDLogFlagDebug,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define TYSM_DDLogVerboseToDDLog(tysm_ddlog, frmt, ...) TYSM_LOG_MAYBE_TO_DDLOG(tysm_ddlog, TYSM_LOG_ASYNC_ENABLED, TYSM_LOG_LEVEL_DEF, TYSM_DDLogFlagVerbose, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
