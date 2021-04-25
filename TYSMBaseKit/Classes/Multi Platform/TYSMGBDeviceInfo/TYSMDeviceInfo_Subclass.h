//
//  TYSMDeviceInfo_Subclass.h
//  TYSMDeviceInfo
//
//  Created by Luka Mirosevic on 24/03/2015.
//  Copyright (c) 2015 Luka Mirosevic. All rights reserved.
//

@interface TYSMDeviceInfo_Common ()

@property (strong, atomic, readwrite) NSString          *rawSystemInfoString;
@property (assign, atomic, readwrite) TYSMCPUInfo         cpuInfo;
@property (assign, atomic, readwrite) CGFloat           physicalMemory;
@property (assign, atomic, readwrite) TYSMOSVersion       osVersion;
@property (assign, atomic, readwrite) TYSMDeviceFamily    family;

+ (NSString *)_sysctlStringForKey:(NSString *)key;
+ (CGFloat)_sysctlCGFloatForKey:(NSString *)key;
+ (TYSMCPUInfo)_cpuInfo;
+ (CGFloat)_physicalMemory;
+ (TYSMByteOrder)_systemByteOrder;

@end
