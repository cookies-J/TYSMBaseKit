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

#if !__has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "TYSM_DDMultiFormatter.h"

@interface TYSM_DDMultiFormatter () {
    dispatch_queue_t _queue;
    NSMutableArray *_formatters;
}

- (TYSM_DDLogMessage *)logMessageForLine:(NSString *)line originalMessage:(TYSM_DDLogMessage *)message;

@end


@implementation TYSM_DDMultiFormatter

- (instancetype)init {
    self = [super init];

    if (self) {
        _queue = dispatch_queue_create("cocoa.lumberjack.multiformatter", DISPATCH_QUEUE_CONCURRENT);
        _formatters = [NSMutableArray new];
    }

    return self;
}

#pragma mark Processing

- (NSString *)formatLogMessage:(TYSM_DDLogMessage *)logMessage {
    __block NSString *line = logMessage->_message;

    dispatch_sync(_queue, ^{
        for (id<TYSM_DDLogFormatter> formatter in self->_formatters) {
            TYSM_DDLogMessage *message = [self logMessageForLine:line originalMessage:logMessage];
            line = [formatter formatLogMessage:message];

            if (!line) {
                break;
            }
        }
    });

    return line;
}

- (TYSM_DDLogMessage *)logMessageForLine:(NSString *)line originalMessage:(TYSM_DDLogMessage *)message {
    TYSM_DDLogMessage *newMessage = [message copy];

    newMessage->_message = line;
    return newMessage;
}

#pragma mark Formatters

- (NSArray *)formatters {
    __block NSArray *formatters;

    dispatch_sync(_queue, ^{
        formatters = [self->_formatters copy];
    });

    return formatters;
}

- (void)addFormatter:(id<TYSM_DDLogFormatter>)formatter {
    dispatch_barrier_async(_queue, ^{
        [self->_formatters addObject:formatter];
    });
}

- (void)removeFormatter:(id<TYSM_DDLogFormatter>)formatter {
    dispatch_barrier_async(_queue, ^{
        [self->_formatters removeObject:formatter];
    });
}

- (void)removeAllFormatters {
    dispatch_barrier_async(_queue, ^{
        [self->_formatters removeAllObjects];
    });
}

- (BOOL)isFormattingWithFormatter:(id<TYSM_DDLogFormatter>)formatter {
    __block BOOL hasFormatter;

    dispatch_sync(_queue, ^{
        hasFormatter = [self->_formatters containsObject:formatter];
    });

    return hasFormatter;
}

@end
