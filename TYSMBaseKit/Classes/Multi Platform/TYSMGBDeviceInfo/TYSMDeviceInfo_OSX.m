//
//  TYSMDeviceInfo_OSX.m
//  TYSMDeviceInfo
//
//  Created by Luka Mirosevic on 14/03/2013.
//  Copyright (c) 2013 Goonbee. All rights reserved.
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

#include <TargetConditionals.h>

#if TARGET_OS_OSX

#import "TYSMDeviceInfo_OSX.h"

#import <Cocoa/Cocoa.h>

#import <sys/utsname.h>

#import "TYSMDeviceInfo_Common.h"
#import "TYSMDeviceInfo_Subclass.h"

static NSString * const kHardwareModelKey =                 @"hw.model";

@interface TYSMDeviceInfo ()

@property (assign, atomic, readwrite) TYSMDeviceVersion       deviceVersion;
@property (assign, atomic, readwrite) TYSMByteOrder           systemByteOrder;
@property (assign, atomic, readwrite) BOOL                  isMacAppStoreAvailable;
@property (assign, atomic, readwrite) BOOL                  isIAPAvailable;

@end

@implementation TYSMDeviceInfo

- (NSString *)description {
    return [NSString stringWithFormat:@"%@\nrawSystemInfoString: %@\nnodeName: %@\nfamily: %ld\ndeviceModel.major: %ld\ndeviceModel.minor: %ld\ncpuInfo.frequency: %.3f\ncpuInfo.numberOfCores: %ld\ncpuInfo.l2CacheSize: %.3f\npysicalMemory: %.3f\nsystemByteOrder: %ld\nscreenResolution: %.0fx%.0f\nosVersion.major: %ld\nosVersion.minor: %ld\nosVersion.patch: %ld",
        [super description],
        self.rawSystemInfoString,
        self.nodeName,
        self.family,
        (unsigned long)self.deviceVersion.major,
        (unsigned long)self.deviceVersion.minor,
        self.cpuInfo.frequency,
        (unsigned long)self.cpuInfo.numberOfCores,
        self.cpuInfo.l2CacheSize,
        self.physicalMemory,
        self.systemByteOrder,
        self.displayInfo.resolution.width,
        self.displayInfo.resolution.height,
        (unsigned long)self.osVersion.major,
        (unsigned long)self.osVersion.minor,
        (unsigned long)self.osVersion.patch
    ];
}

#pragma mark - Public API

- (instancetype)init {
    if (self = [super init]) {
        self.rawSystemInfoString = [self.class _rawSystemInfoString];
        self.family = [self.class _deviceFamily];
        self.physicalMemory = [self.class _physicalMemory];
        self.systemByteOrder = [self.class _systemByteOrder];
        self.osVersion = [self.class _osVersion];
        self.deviceVersion = [self.class _deviceVersion];
        self.isMacAppStoreAvailable = [self.class _isMacAppStoreAvailable];
        self.isIAPAvailable = [self.class _isIAPAvailable];
    }
    
    return self;
}

#pragma mark - Dynamic Properties

- (NSString *)nodeName {
    return [self.class _nodeName];
}

- (TYSMCPUInfo)cpuInfo {
    return [self.class _cpuInfo];
}

- (TYSMDisplayInfo)displayInfo {
    return [self.class _displayInfo];
}

#pragma mark - Private API

+ (struct utsname)_unameStruct {
    struct utsname systemInfo;
    uname(&systemInfo);

    return systemInfo;
}

+ (TYSMOSVersion)_osVersion {
    TYSMOSVersion osVersion;
    
    if ([[NSProcessInfo processInfo] respondsToSelector:@selector(operatingSystemVersion)]) {
        NSOperatingSystemVersion osSystemVersion = [[NSProcessInfo processInfo] operatingSystemVersion];
        
        osVersion.major = osSystemVersion.majorVersion;
        osVersion.minor = osSystemVersion.minorVersion;
        osVersion.patch = osSystemVersion.patchVersion;
    }
    else {
        SInt32 majorVersion, minorVersion, patchVersion;
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        Gestalt(gestaltSystemVersionMajor, &majorVersion);
        Gestalt(gestaltSystemVersionMinor, &minorVersion);
        Gestalt(gestaltSystemVersionBugFix, &patchVersion);
#pragma clang diagnostic pop
        
        osVersion.major = majorVersion;
        osVersion.minor = minorVersion;
        osVersion.patch = patchVersion;
    }
    
    return osVersion;
}

+ (TYSMDisplayInfo)_displayInfo {
    CGSize displaySize = CGDisplayScreenSize(kCGDirectMainDisplay); // CGMainDisplayID()
    CGFloat displayAreaMm = displaySize.width * displaySize.height;
    
    NSScreen *mainScreen = [NSScreen mainScreen];
    CGFloat width = (CGFloat)CGDisplayPixelsWide(kCGDirectMainDisplay) * mainScreen.backingScaleFactor;
    CGFloat height = (CGFloat)CGDisplayPixelsHigh(kCGDirectMainDisplay) * mainScreen.backingScaleFactor;
    CGFloat pixelCount = width * height;
    
    CGFloat pixelsPerMm = sqrt(pixelCount / displayAreaMm);
    CGFloat pixelsPerInch = pixelsPerMm * 25.4;
    
    return TYSMDisplayInfoMake(
        mainScreen.frame.size, pixelsPerInch
    );
}

+ (TYSMDeviceFamily)_deviceFamily {
    NSString *systemInfoString = [self _rawSystemInfoString];
    
    if ([systemInfoString hasPrefix:@"iMacPro"]) {
        return TYSMDeviceFamilyiMacPro;
    }
    else if ([systemInfoString hasPrefix:@"iMac"]) {
        return TYSMDeviceFamilyiMac;
    }
    else if ([systemInfoString hasPrefix:@"Macmini"]) {
        return TYSMDeviceFamilyMacMini;
    }
    else if ([systemInfoString hasPrefix:@"MacPro"]) {
        return TYSMDeviceFamilyMacPro;
    }
    else if ([systemInfoString hasPrefix:@"MacBookPro"]) {
        return TYSMDeviceFamilyMacBookPro;
    }
    else if ([systemInfoString hasPrefix:@"MacBookAir"]) {
        return TYSMDeviceFamilyMacBookAir;
    }
    else if ([systemInfoString hasPrefix:@"MacBook"]) {
        return TYSMDeviceFamilyMacBook;
    }
    else if ([systemInfoString hasPrefix:@"Xserve"]) {
        return TYSMDeviceFamilyXserve;
    }
    else {
        return TYSMDeviceFamilyUnknown;
    }
}

+ (TYSMDeviceVersion)_deviceVersion {
    NSString *systemInfoString = [self _rawSystemInfoString];
    
    NSUInteger positionOfFirstInteger = [systemInfoString rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location;
    NSUInteger positionOfComma = [systemInfoString rangeOfString:@","].location;
    
    NSUInteger major = 0;
    NSUInteger minor = 0;
    
    if (positionOfComma != NSNotFound) {
        major = [[systemInfoString substringWithRange:NSMakeRange(positionOfFirstInteger, positionOfComma - positionOfFirstInteger)] integerValue];
        minor = [[systemInfoString substringFromIndex:positionOfComma + 1] integerValue];
    }
    
    return TYSMDeviceVersionMake(major, minor);
}

+ (NSString *)_rawSystemInfoString {
    return [TYSMDeviceInfo_Common _sysctlStringForKey:kHardwareModelKey];
}

+ (NSString *)_nodeName {
    return [NSString stringWithCString:[self _unameStruct].nodename encoding:NSUTF8StringEncoding];
}

+ (BOOL)_isMacAppStoreAvailable {
    TYSMOSVersion osVersion = [self _osVersion];
    
    return ((osVersion.minor >= 7) ||
            (osVersion.minor == 6 && osVersion.patch >=  6));
}

+ (BOOL)_isIAPAvailable {
    TYSMOSVersion osVersion = [self _osVersion];
    
    return (osVersion.minor >= 7);
}

@end

#endif
