//
//  TYSMDeviceInfoTypes_Common.h
//  TYSMDeviceInfo
//
//  Created by Luka Mirosevic on 20/02/2015.
//  Copyright (c) 2015 Luka Mirosevic. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import <CoreGraphics/CoreGraphics.h>

typedef NS_ENUM(NSInteger, TYSMByteOrder) {
    TYSMByteOrderLittleEndian,
    TYSMByteOrderBigEndian,
};

typedef struct {
    /**
     Major OS version number. For e.g. 10.8.2 => 10
     */
    NSUInteger                                          major;
    
    /**
     Minor OS version number. For e.g. 10.8.2 => 8
     */
    NSUInteger                                          minor;
    
    /**
     Patch OS version number. For e.g. 10.8.2 => 2
     */
    NSUInteger                                          patch;
} TYSMOSVersion;

/**
 Makes a TYSMOSVersion struct.
 */
inline static TYSMOSVersion TYSMOSVersionMake(NSUInteger major, NSUInteger minor,  NSUInteger patch) {
    return (TYSMOSVersion){major, minor, patch};
};

/**
 Makes a TYSMOSVersion struct by parsing a NSString.
 
 e.g.   @"8.2.3"    -> TYSMOSVersionMake(8,2,3)
        @"9.1"      -> TYSMOSVersionMake(9,1,0)
 */
inline static TYSMOSVersion TYSMOSVersionFromString(NSString *versionString) {
    NSArray *components = [versionString componentsSeparatedByString:@"."];
    NSInteger major = components.count >= 1 ? [components[0] integerValue] : 0;
    NSInteger minor = components.count >= 2 ? [components[1] integerValue] : 0;
    NSInteger patch = components.count >= 3 ? [components[2] integerValue] : 0;
    
    return TYSMOSVersionMake(major, minor, patch);
}

typedef struct {
    /**
     Major device model. e.g. 13 for iMac13,2
     */
    NSUInteger                                          major;
    
    /**
     Minor device model. e.g. 2 for iMac13,2
     */
    NSUInteger                                          minor;
} TYSMDeviceVersion;

/**
 Makes a TYSMDeviceVersion struct.
 */
inline static TYSMDeviceVersion TYSMDeviceVersionMake(NSUInteger major, NSUInteger minor) {
    return (TYSMDeviceVersion){major, minor};
};

typedef struct {
    /**
     CPU frequency, in GHz.
     
     Warning: Might not be (=probably won't be) available on all iOS devices.
     */
    CGFloat                                             frequency;              // GHz (giga)
    
    /**
     Number of logical cores the CPU has.
     */
    NSUInteger                                          numberOfCores;
    
    /**
     CPU's l2 cache size, in KB.
     */
    CGFloat                                             l2CacheSize;            // KB (kibi)
} TYSMCPUInfo;

/**
 Makes a TYSMCPUInfo struct.
 */
inline static TYSMCPUInfo TYSMCPUInfoMake(CGFloat frequency, NSUInteger numberOfCores, CGFloat l2CacheSize) {
    return (TYSMCPUInfo){frequency, numberOfCores, l2CacheSize};
};

#if TARGET_OS_IPHONE
typedef NS_ENUM(NSInteger, TYSMDeviceFamily) {
    TYSMDeviceFamilyUnknown = 0,
    TYSMDeviceFamilyiPhone,
    TYSMDeviceFamilyiPad,
    TYSMDeviceFamilyiPod,
    TYSMDeviceFamilySimulator,
};
#else
typedef NS_ENUM(NSInteger, TYSMDeviceFamily) {
    TYSMDeviceFamilyUnknown = 0,
    TYSMDeviceFamilyiMac,
    TYSMDeviceFamilyiMacPro,
    TYSMDeviceFamilyMacMini,
    TYSMDeviceFamilyMacPro,
    TYSMDeviceFamilyMacBook,
    TYSMDeviceFamilyMacBookAir,
    TYSMDeviceFamilyMacBookPro,
    TYSMDeviceFamilyXserve,
};
#endif
