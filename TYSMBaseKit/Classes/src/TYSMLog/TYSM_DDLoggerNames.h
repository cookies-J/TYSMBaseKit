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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *TYSM_DDLoggerName NS_EXTENSIBLE_STRING_ENUM;

FOUNDATION_EXPORT TYSM_DDLoggerName const TYSM_DDLoggerNameOS NS_SWIFT_NAME(TYSM_DDLoggerName.os);     // TYSM_DDOSLogger
FOUNDATION_EXPORT TYSM_DDLoggerName const TYSM_DDLoggerNameFile NS_SWIFT_NAME(TYSM_DDLoggerName.file); // TYSM_DDFileLogger

FOUNDATION_EXPORT TYSM_DDLoggerName const TYSM_DDLoggerNameTTY NS_SWIFT_NAME(TYSM_DDLoggerName.tty);   // TYSM_DDTTYLogger

API_DEPRECATED("Use TYSM_DDOSLogger instead", macosx(10.4, 10.12), ios(2.0, 10.0), watchos(2.0, 3.0), tvos(9.0, 10.0))
FOUNDATION_EXPORT TYSM_DDLoggerName const TYSM_DDLoggerNameASL NS_SWIFT_NAME(TYSM_DDLoggerName.asl);   // TYSM_DDASLLogger

NS_ASSUME_NONNULL_END
