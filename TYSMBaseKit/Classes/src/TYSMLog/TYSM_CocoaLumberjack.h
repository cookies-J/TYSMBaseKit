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
 * Welcome to CocoaLumberjack!
 *
 * The project page has a wealth of documentation if you have any questions.
 * https://github.com/CocoaLumberjack/CocoaLumberjack
 *
 * If you're new to the project you may wish to read "Getting Started" at:
 * Documentation/GettingStarted.md
 *
 * Otherwise, here is a quick refresher.
 * There are three steps to using the macros:
 *
 * Step 1:
 * Import the header in your implementation or prefix file:
 *
 * #import "CocoaLumberjack.h>
 *
 * Step 2:
 * Define your logging level in your implementation file:
 *
 * // Log levels: off, error, warn, info, verbose
 * static const TYSM_DDLogLevel tysm_ddLogLevel = TYSM_DDLogLevelVerbose;
 *
 * Step 2 [3rd party frameworks]:
 *
 * Define your TYSM_LOG_LEVEL_DEF to a different variable/function than tysm_ddLogLevel:
 *
 * // #undef TYSM_LOG_LEVEL_DEF // Undefine first only if needed
 * #define TYSM_LOG_LEVEL_DEF myLibLogLevel
 *
 * Define your logging level in your implementation file:
 *
 * // Log levels: off, error, warn, info, verbose
 * static const TYSM_DDLogLevel myLibLogLevel = TYSM_DDLogLevelVerbose;
 *
 * Step 3:
 * Replace your NSLog statements with TYSM_DDLog statements according to the severity of the message.
 *
 * NSLog(@"Fatal error, no dohickey found!"); -> TYSM_DDLogError(@"Fatal error, no dohickey found!");
 *
 * TYSM_DDLog works exactly the same as NSLog.
 * This means you can pass it multiple variables just like NSLog.
 **/

#import <Foundation/Foundation.h>

// Disable legacy macros
#ifndef TYSM_DD_LEGACY_MACROS
    #define TYSM_DD_LEGACY_MACROS 0
#endif

// Core
#import "TYSM_DDLog.h"

// Main macros
#import "TYSM_DDLogMacros.h"
#import "TYSM_DDAssertMacros.h"

// Capture ASL
#import "TYSM_DDASLLogCapture.h"

// Loggers
#import "TYSM_DDLoggerNames.h"

#import "TYSM_DDTTYLogger.h"
#import "TYSM_DDASLLogger.h"
#import "TYSM_DDFileLogger.h"
#import "TYSM_DDOSLogger.h"

// Extensions
#import "TYSM_DDContextFilterLogFormatter.h"
#import "TYSM_DDDispatchQueueLogFormatter.h"
#import "TYSM_DDMultiFormatter.h"
#import "TYSM_DDFileLogger+Buffering.h"

// CLI
#import "TYSM_CLIColor.h"

// etc
#import "TYSM_DDAbstractDatabaseLogger.h"
#import "TYSM_DDLog+LOGV.h"
#import "TYSM_DDLegacyMacros.h"
