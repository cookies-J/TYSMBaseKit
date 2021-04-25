//
//  TYSMDeviceInfoTypes_Common.h
//  TYSMDeviceInfo
//
//  Created by Luka Mirosevic on 20/02/2015.
//  Copyright (c) 2015 Luka Mirosevic. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TYSMDeviceInfoTypes_Common.h"
#import "TYSMDeviceInfoInterface.h"

#pragma mark - Public

@interface TYSMDeviceInfo_Common : NSObject <TYSMDeviceInfoInterface>

/**
 The raw system info string, e.g. "iPhone7,2".
 */
@property (strong, atomic, readonly) NSString           *rawSystemInfoString;

/**
 The device family. e.g. TYSMDeviceFamilyiPhone.
 */
@property (assign, atomic, readonly) TYSMDeviceFamily     family;

/**
 Information about the CPU.
 */
@property (assign, atomic, readonly) TYSMCPUInfo          cpuInfo;

/**
 Amount of physical memory (RAM) available to the system, in GB.
 */
@property (assign, atomic, readonly) CGFloat            physicalMemory;         // GB (gibi)

/**
 Information about the system's OS. e.g. {10, 8, 2}.
 */
@property (assign, atomic, readonly) TYSMOSVersion        osVersion;

@end
