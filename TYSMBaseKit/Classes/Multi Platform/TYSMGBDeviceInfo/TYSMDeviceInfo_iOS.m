//
//  TYSMDeviceInfo_iOS.m
//  TYSMDeviceInfo
//
//  Created by Luka Mirosevic on 11/10/2012.
//  Copyright (c) 2013 Goonbee. All Rights Reserved.
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

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

#import "TYSMDeviceInfo_iOS.h"

#import <UIKit/UIKit.h>

#import <sys/utsname.h>
#import "dlfcn.h"

#import "TYSMDeviceInfo_Common.h"
#import "TYSMDeviceInfo_Subclass.h"

@interface TYSMDeviceInfo ()

@property (assign, atomic, readwrite) TYSMDeviceVersion       deviceVersion;
@property (strong, atomic, readwrite) NSString              *modelString;
@property (assign, atomic, readwrite) TYSMDeviceModel         model;
@property (assign, atomic, readwrite) TYSMDisplayInfo         displayInfo;

@end

@implementation TYSMDeviceInfo

#pragma mark - Custom Accessors

- (BOOL)isJailbroken {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"You have to include the Jailbreak subspec in order to access this property. Add `pod 'TYSMDeviceInfo/Jailbreak'` to your Podfile." userInfo:nil];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@\nrawSystemInfoString: %@\nmodel: %ld\nfamily: %ld\ndisplay: %ld\nppi: %ld\ndeviceVersion.major: %ld\ndeviceVersion.minor: %ld\nosVersion.major: %ld\nosVersion.minor: %ld\nosVersion.patch: %ld\ncpuInfo.frequency: %.3f\ncpuInfo.numberOfCores: %ld\ncpuInfo.l2CacheSize: %.3f\npysicalMemory: %.3f",
            [super description],
            self.rawSystemInfoString,
            (long)self.model,
            (long)self.family,
            (long)self.displayInfo.display,
            (unsigned long)self.displayInfo.pixelsPerInch,
            (unsigned long)self.deviceVersion.major,
            (unsigned long)self.deviceVersion.minor,
            (unsigned long)self.osVersion.major,
            (unsigned long)self.osVersion.minor,
            (unsigned long)self.osVersion.patch,
            self.cpuInfo.frequency,
            (unsigned long)self.cpuInfo.numberOfCores,
            self.cpuInfo.l2CacheSize,
            self.physicalMemory
        ];
}

#pragma mark - Public API

- (instancetype)init {
    if (self = [super init]) {
        // system info string
        self.rawSystemInfoString = [self.class _rawSystemInfoString];
        
        // device version
        self.deviceVersion = [self.class _deviceVersion];
        
        // model nuances
        NSArray *modelNuances = [self.class _modelNuances];
        self.family = [modelNuances[0] integerValue];
        self.model = [modelNuances[1] integerValue];
        self.modelString = modelNuances[2];
        self.displayInfo = TYSMDisplayInfoMake([modelNuances[3] integerValue], [modelNuances[4] doubleValue]);
        
        // iOS version
        self.osVersion = [self.class _osVersion];
        
        // RAM
        self.physicalMemory = [self.class _physicalMemory];
        
        // CPU info
        self.cpuInfo = [self.class _cpuInfo];
    }
    
    return self;
}

#pragma mark - Dynamic Properties

// none yet

#pragma mark - Private API

+ (NSString *)_rawSystemInfoString {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
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

+ (NSArray *)_modelNuances {
    TYSMDeviceFamily family = TYSMDeviceFamilyUnknown;
    TYSMDeviceModel model = TYSMDeviceModelUnknown;
    NSString *modelString = @"Unknown Device";
    TYSMDeviceDisplay display = TYSMDeviceDisplayUnknown;
    CGFloat pixelsPerInch = 0;
    
    // Simulator
    if (TARGET_IPHONE_SIMULATOR) {
        family = TYSMDeviceFamilySimulator;
        BOOL iPadScreen = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
        model = iPadScreen ? TYSMDeviceModelSimulatoriPad : TYSMDeviceModelSimulatoriPhone;
        modelString = iPadScreen ? @"iPad Simulator": @"iPhone Simulator";
        display = TYSMDeviceDisplayUnknown;
        pixelsPerInch = 0;
    }
    // Actual device
    else {
        TYSMDeviceVersion deviceVersion = [self _deviceVersion];
        NSString *systemInfoString = [self _rawSystemInfoString];
        
        
        NSDictionary *familyManifest = @{
            @"iPhone": @(TYSMDeviceFamilyiPhone),
            @"iPad": @(TYSMDeviceFamilyiPad),
            @"iPod": @(TYSMDeviceFamilyiPod),
        };
        
        NSDictionary *modelManifest = @{
            @"iPhone": @{
                // 1st Gen
                @[@1, @1]: @[@(TYSMDeviceModeliPhone1), @"iPhone 1", @(TYSMDeviceDisplay3p5Inch), @163],

                // 3G
                @[@1, @2]: @[@(TYSMDeviceModeliPhone3G), @"iPhone 3G", @(TYSMDeviceDisplay3p5Inch), @163],

                // 3GS
                @[@2, @1]: @[@(TYSMDeviceModeliPhone3GS), @"iPhone 3GS", @(TYSMDeviceDisplay3p5Inch), @163],

                // 4
                @[@3, @1]: @[@(TYSMDeviceModeliPhone4), @"iPhone 4", @(TYSMDeviceDisplay3p5Inch), @326],
                @[@3, @2]: @[@(TYSMDeviceModeliPhone4), @"iPhone 4", @(TYSMDeviceDisplay3p5Inch), @326],
                @[@3, @3]: @[@(TYSMDeviceModeliPhone4), @"iPhone 4", @(TYSMDeviceDisplay3p5Inch), @326],

                // 4S
                @[@4, @1]: @[@(TYSMDeviceModeliPhone4S), @"iPhone 4S", @(TYSMDeviceDisplay3p5Inch), @326],

                // 5
                @[@5, @1]: @[@(TYSMDeviceModeliPhone5), @"iPhone 5", @(TYSMDeviceDisplay4Inch), @326],
                @[@5, @2]: @[@(TYSMDeviceModeliPhone5), @"iPhone 5", @(TYSMDeviceDisplay4Inch), @326],

                // 5c
                @[@5, @3]: @[@(TYSMDeviceModeliPhone5c), @"iPhone 5c", @(TYSMDeviceDisplay4Inch), @326],
                @[@5, @4]: @[@(TYSMDeviceModeliPhone5c), @"iPhone 5c", @(TYSMDeviceDisplay4Inch), @326],

                // 5s
                @[@6, @1]: @[@(TYSMDeviceModeliPhone5s), @"iPhone 5s", @(TYSMDeviceDisplay4Inch), @326],
                @[@6, @2]: @[@(TYSMDeviceModeliPhone5s), @"iPhone 5s", @(TYSMDeviceDisplay4Inch), @326],

                // 6 Plus
                @[@7, @1]: @[@(TYSMDeviceModeliPhone6Plus), @"iPhone 6 Plus", @(TYSMDeviceDisplay5p5Inch), @401],

                // 6
                @[@7, @2]: @[@(TYSMDeviceModeliPhone6), @"iPhone 6", @(TYSMDeviceDisplay4p7Inch), @326],
                
                // 6s
                @[@8, @1]: @[@(TYSMDeviceModeliPhone6s), @"iPhone 6s", @(TYSMDeviceDisplay4p7Inch), @326],
                
                // 6s Plus
                @[@8, @2]: @[@(TYSMDeviceModeliPhone6sPlus), @"iPhone 6s Plus", @(TYSMDeviceDisplay5p5Inch), @401],
                
                // SE
                @[@8, @4]: @[@(TYSMDeviceModeliPhoneSE), @"iPhone SE", @(TYSMDeviceDisplay4Inch), @326],
                
                // 7
                @[@9, @1]: @[@(TYSMDeviceModeliPhone7), @"iPhone 7", @(TYSMDeviceDisplay4p7Inch), @326],
                @[@9, @3]: @[@(TYSMDeviceModeliPhone7), @"iPhone 7", @(TYSMDeviceDisplay4p7Inch), @326],
                
                // 7 Plus
                @[@9, @2]: @[@(TYSMDeviceModeliPhone7Plus), @"iPhone 7 Plus", @(TYSMDeviceDisplay5p5Inch), @401],
                @[@9, @4]: @[@(TYSMDeviceModeliPhone7Plus), @"iPhone 7 Plus", @(TYSMDeviceDisplay5p5Inch), @401],
                
                // 8
                @[@10, @1]: @[@(TYSMDeviceModeliPhone8), @"iPhone 8", @(TYSMDeviceDisplay4p7Inch), @326],
                @[@10, @4]: @[@(TYSMDeviceModeliPhone8), @"iPhone 8", @(TYSMDeviceDisplay4p7Inch), @326],

                // 8 Plus
                @[@10, @2]: @[@(TYSMDeviceModeliPhone8Plus), @"iPhone 8 Plus", @(TYSMDeviceDisplay5p5Inch), @401],
                @[@10, @5]: @[@(TYSMDeviceModeliPhone8Plus), @"iPhone 8 Plus", @(TYSMDeviceDisplay5p5Inch), @401],
                
                // X
                @[@10, @3]: @[@(TYSMDeviceModeliPhoneX), @"iPhone X", @(TYSMDeviceDisplay5p8Inch), @458],
                @[@10, @6]: @[@(TYSMDeviceModeliPhoneX), @"iPhone X", @(TYSMDeviceDisplay5p8Inch), @458],

                // XR
                @[@11, @8]: @[@(TYSMDeviceModeliPhoneXR), @"iPhone XR", @(TYSMDeviceDisplay6p1Inch), @326],

                // XS
                @[@11, @2]: @[@(TYSMDeviceModeliPhoneXS), @"iPhone XS", @(TYSMDeviceDisplay5p8Inch), @458],

                // XS Max
                @[@11, @4]: @[@(TYSMDeviceModeliPhoneXSMax), @"iPhone XS Max", @(TYSMDeviceDisplay6p5Inch), @458],
                @[@11, @6]: @[@(TYSMDeviceModeliPhoneXSMax), @"iPhone XS Max", @(TYSMDeviceDisplay6p5Inch), @458],
                
                // 11
                @[@12, @1]: @[@(TYSMDeviceModeliPhone11), @"iPhone 11", @(TYSMDeviceDisplay6p1Inch), @326],

                // 11 Pro
                @[@12, @3]: @[@(TYSMDeviceModeliPhone11Pro), @"iPhone 11 Pro", @(TYSMDeviceDisplay5p8Inch), @458],

                // 11 Pro Max
                @[@12, @5]: @[@(TYSMDeviceModeliPhone11ProMax), @"iPhone 11 Pro Max", @(TYSMDeviceDisplay6p5Inch), @458],

                // SE 2
                @[@12, @8]: @[@(TYSMDeviceModeliPhoneSE2), @"iPhone SE 2", @(TYSMDeviceDisplay4p7Inch), @326],

                // 12 mini
                @[@13, @1]: @[@(TYSMDeviceModeliPhone12Mini), @"iPhone 12 mini", @(TYSMDeviceDisplay5p4Inch), @476],

                // 12
                @[@13, @2]: @[@(TYSMDeviceModeliPhone12), @"iPhone 12", @(TYSMDeviceDisplay6p1Inch), @460],

                // 12 Pro
                @[@13, @3]: @[@(TYSMDeviceModeliPhone12Pro), @"iPhone 12 Pro", @(TYSMDeviceDisplay6p1Inch), @460],

                // 12 Pro Max
                @[@13, @4]: @[@(TYSMDeviceModeliPhone12ProMax), @"iPhone 12 Pro Max", @(TYSMDeviceDisplay6p7Inch), @458],
            },
            @"iPad": @{
                // 1
                @[@1, @1]: @[@(TYSMDeviceModeliPad1), @"iPad 1", @(TYSMDeviceDisplay9p7Inch), @132],

                // 2
                @[@2, @1]: @[@(TYSMDeviceModeliPad2), @"iPad 2", @(TYSMDeviceDisplay9p7Inch), @132],
                @[@2, @2]: @[@(TYSMDeviceModeliPad2), @"iPad 2", @(TYSMDeviceDisplay9p7Inch), @132],
                @[@2, @3]: @[@(TYSMDeviceModeliPad2), @"iPad 2", @(TYSMDeviceDisplay9p7Inch), @132],
                @[@2, @4]: @[@(TYSMDeviceModeliPad2), @"iPad 2", @(TYSMDeviceDisplay9p7Inch), @132],

                // mini
                @[@2, @5]: @[@(TYSMDeviceModeliPadMini1), @"iPad mini 1", @(TYSMDeviceDisplay7p9Inch), @163],
                @[@2, @6]: @[@(TYSMDeviceModeliPadMini1), @"iPad mini 1", @(TYSMDeviceDisplay7p9Inch), @163],
                @[@2, @7]: @[@(TYSMDeviceModeliPadMini1), @"iPad mini 1", @(TYSMDeviceDisplay7p9Inch), @163],

                // 3
                @[@3, @1]: @[@(TYSMDeviceModeliPad3), @"iPad 3", @(TYSMDeviceDisplay9p7Inch), @264],
                @[@3, @2]: @[@(TYSMDeviceModeliPad3), @"iPad 3", @(TYSMDeviceDisplay9p7Inch), @264],
                @[@3, @3]: @[@(TYSMDeviceModeliPad3), @"iPad 3", @(TYSMDeviceDisplay9p7Inch), @264],

                // 4
                @[@3, @4]: @[@(TYSMDeviceModeliPad4), @"iPad 4", @(TYSMDeviceDisplay9p7Inch), @264],
                @[@3, @5]: @[@(TYSMDeviceModeliPad4), @"iPad 4", @(TYSMDeviceDisplay9p7Inch), @264],
                @[@3, @6]: @[@(TYSMDeviceModeliPad4), @"iPad 4", @(TYSMDeviceDisplay9p7Inch), @264],

                // Air
                @[@4, @1]: @[@(TYSMDeviceModeliPadAir1), @"iPad Air 1", @(TYSMDeviceDisplay9p7Inch), @264],
                @[@4, @2]: @[@(TYSMDeviceModeliPadAir1), @"iPad Air 1", @(TYSMDeviceDisplay9p7Inch), @264],
                @[@4, @3]: @[@(TYSMDeviceModeliPadAir1), @"iPad Air 1", @(TYSMDeviceDisplay9p7Inch), @264],

                // mini 2
                @[@4, @4]: @[@(TYSMDeviceModeliPadMini2), @"iPad mini 2", @(TYSMDeviceDisplay7p9Inch), @326],
                @[@4, @5]: @[@(TYSMDeviceModeliPadMini2), @"iPad mini 2", @(TYSMDeviceDisplay7p9Inch), @326],
                @[@4, @6]: @[@(TYSMDeviceModeliPadMini2), @"iPad mini 2", @(TYSMDeviceDisplay7p9Inch), @326],

                // mini 3
                @[@4, @7]: @[@(TYSMDeviceModeliPadMini3), @"iPad mini 3", @(TYSMDeviceDisplay7p9Inch), @326],
                @[@4, @8]: @[@(TYSMDeviceModeliPadMini3), @"iPad mini 3", @(TYSMDeviceDisplay7p9Inch), @326],
                @[@4, @9]: @[@(TYSMDeviceModeliPadMini3), @"iPad mini 3", @(TYSMDeviceDisplay7p9Inch), @326],
                
                // mini 4
                @[@5, @1]: @[@(TYSMDeviceModeliPadMini4), @"iPad mini 4", @(TYSMDeviceDisplay7p9Inch), @326],
                @[@5, @2]: @[@(TYSMDeviceModeliPadMini4), @"iPad mini 4", @(TYSMDeviceDisplay7p9Inch), @326],

                // Air 2
                @[@5, @3]: @[@(TYSMDeviceModeliPadAir2), @"iPad Air 2", @(TYSMDeviceDisplay9p7Inch), @264],
                @[@5, @4]: @[@(TYSMDeviceModeliPadAir2), @"iPad Air 2", @(TYSMDeviceDisplay9p7Inch), @264],
                
                // Pro 12.9-inch
                @[@6, @7]: @[@(TYSMDeviceModeliPadPro12p9Inch), @"iPad Pro 12.9-inch", @(TYSMDeviceDisplay12p9Inch), @264],
                @[@6, @8]: @[@(TYSMDeviceModeliPadPro12p9Inch), @"iPad Pro 12.9-inch", @(TYSMDeviceDisplay12p9Inch), @264],
                
                // Pro 9.7-inch
                @[@6, @3]: @[@(TYSMDeviceModeliPadPro9p7Inch), @"iPad Pro 9.7-inch", @(TYSMDeviceDisplay9p7Inch), @264],
                @[@6, @4]: @[@(TYSMDeviceModeliPadPro9p7Inch), @"iPad Pro 9.7-inch", @(TYSMDeviceDisplay9p7Inch), @264],
                
                // iPad 5th Gen, 2017
                @[@6, @11]: @[@(TYSMDeviceModeliPad5), @"iPad 2017", @(TYSMDeviceDisplay9p7Inch), @264],
                @[@6, @12]: @[@(TYSMDeviceModeliPad5), @"iPad 2017", @(TYSMDeviceDisplay9p7Inch), @264],

                // Pro 12.9-inch, 2017
                @[@7, @1]: @[@(TYSMDeviceModeliPadPro12p9Inch2), @"iPad Pro 12.9-inch 2017", @(TYSMDeviceDisplay12p9Inch), @264],
                @[@7, @2]: @[@(TYSMDeviceModeliPadPro12p9Inch2), @"iPad Pro 12.9-inch 2017", @(TYSMDeviceDisplay12p9Inch), @264],
                
                // Pro 10.5-inch, 2017
                @[@7, @3]: @[@(TYSMDeviceModeliPadPro10p5Inch), @"iPad Pro 10.5-inch 2017", @(TYSMDeviceDisplay10p5Inch), @264],
                @[@7, @4]: @[@(TYSMDeviceModeliPadPro10p5Inch), @"iPad Pro 10.5-inch 2017", @(TYSMDeviceDisplay10p5Inch), @264],
                
                // iPad 6th Gen, 2018
                @[@7, @5]: @[@(TYSMDeviceModeliPad6), @"iPad 2018", @(TYSMDeviceDisplay9p7Inch), @264],
                @[@7, @6]: @[@(TYSMDeviceModeliPad6), @"iPad 2018", @(TYSMDeviceDisplay9p7Inch), @264],
                
                // iPad 7th Gen, 2019
                @[@7, @11]: @[@(TYSMDeviceModeliPad7), @"iPad 2019", @(TYSMDeviceDisplay10p2Inch), @264],
                @[@7, @12]: @[@(TYSMDeviceModeliPad7), @"iPad 2019", @(TYSMDeviceDisplay10p2Inch), @264],

                // iPad Pro 3rd Gen 11-inch, 2018
                @[@8, @1]: @[@(TYSMDeviceModeliPadPro11p), @"iPad Pro 3rd Gen (11 inch, WiFi)", @(TYSMDeviceDisplay11pInch), @264],
                @[@8, @3]: @[@(TYSMDeviceModeliPadPro11p), @"iPad Pro 3rd Gen (11 inch, WiFi+Cellular)", @(TYSMDeviceDisplay11pInch), @264],

                // iPad Pro 3rd Gen 11-inch 1TB, 2018
                @[@8, @2]: @[@(TYSMDeviceModeliPadPro11p1TB), @"iPad Pro 3rd Gen (11 inch, 1TB, WiFi)", @(TYSMDeviceDisplay11pInch), @264],
                @[@8, @4]: @[@(TYSMDeviceModeliPadPro11p1TB), @"iPad Pro 3rd Gen (11 inch, 1TB, WiFi+Cellular)", @(TYSMDeviceDisplay11pInch), @264],

                // iPad Pro 3rd Gen 12.9-inch, 2018
                @[@8, @5]: @[@(TYSMDeviceModeliPadPro12p9Inch3), @"iPad Pro 3rd Gen (12.9 inch, WiFi)", @(TYSMDeviceDisplay12p9Inch), @264],
                @[@8, @7]: @[@(TYSMDeviceModeliPadPro12p9Inch3), @"iPad Pro 3rd Gen (12.9 inch, WiFi+Cellular)", @(TYSMDeviceDisplay12p9Inch), @264],

                // iPad Pro 3rd Gen 12.9-inch 1TB, 2018
                @[@8, @6]: @[@(TYSMDeviceModeliPadPro12p9Inch31TB), @"iPad Pro 3rd Gen (12.9 inch, 1TB, WiFi)", @(TYSMDeviceDisplay12p9Inch), @264],
                @[@8, @8]: @[@(TYSMDeviceModeliPadPro12p9Inch31TB), @"iPad Pro 3rd Gen (12.9 inch, 1TB, WiFi+Cellular)", @(TYSMDeviceDisplay12p9Inch), @264],
                
                // iPad Pro 4rd Gen 11-inch, 2020
                @[@8, @9]: @[@(TYSMDeviceModeliPadPro11pInch4), @"iPad Pro 4rd Gen (11 inch, WiFi)", @(TYSMDeviceDisplay11pInch), @264],
                @[@8, @10]: @[@(TYSMDeviceModeliPadPro11pInch4), @"iPad Pro 4rd Gen (11 inch, WiFi+Cellular)", @(TYSMDeviceDisplay11pInch), @264],

                // iPad Pro 4rd Gen 12.9-inch, 2020
                @[@8, @11]: @[@(TYSMDeviceModeliPadPro12p9Inch4), @"iPad Pro 4rd Gen (12.9 inch, WiFi)", @(TYSMDeviceDisplay12p9Inch), @264],
                @[@8, @12]: @[@(TYSMDeviceModeliPadPro12p9Inch4), @"iPad Pro 4rd Gen (12.9 inch, WiFi+Cellular)", @(TYSMDeviceDisplay12p9Inch), @264],

                // mini 5
                @[@11, @1]: @[@(TYSMDeviceModeliPadMini5), @"iPad mini 5", @(TYSMDeviceDisplay7p9Inch), @326],
                @[@11, @2]: @[@(TYSMDeviceModeliPadMini5), @"iPad mini 5", @(TYSMDeviceDisplay7p9Inch), @326],
                
                // Air 3
                @[@11, @3]: @[@(TYSMDeviceModeliPadAir3), @"iPad Air 3", @(TYSMDeviceDisplay10p5Inch), @264],
                @[@11, @4]: @[@(TYSMDeviceModeliPadAir3), @"iPad Air 3", @(TYSMDeviceDisplay10p5Inch), @264],

                // iPad 8th Gen, 2020
                @[@11, @6]: @[@(TYSMDeviceModeliPad8), @"iPad 2020", @(TYSMDeviceDisplay10p2Inch), @264],
                @[@11, @7]: @[@(TYSMDeviceModeliPad8), @"iPad 2020", @(TYSMDeviceDisplay10p2Inch), @264],

                // Air 4
                @[@13, @1]: @[@(TYSMDeviceModeliPadAir4), @"iPad Air 4", @(TYSMDeviceDisplay10p9Inch), @264],
                @[@13, @2]: @[@(TYSMDeviceModeliPadAir4), @"iPad Air 4", @(TYSMDeviceDisplay10p9Inch), @264],
            },
            @"iPod": @{
                // 1st Gen
                @[@1, @1]: @[@(TYSMDeviceModeliPod1), @"iPod Touch 1", @(TYSMDeviceDisplay3p5Inch), @163],

                // 2nd Gen
                @[@2, @1]: @[@(TYSMDeviceModeliPod2), @"iPod Touch 2", @(TYSMDeviceDisplay3p5Inch), @163],

                // 3rd Gen
                @[@3, @1]: @[@(TYSMDeviceModeliPod3), @"iPod Touch 3", @(TYSMDeviceDisplay3p5Inch), @163],

                // 4th Gen
                @[@4, @1]: @[@(TYSMDeviceModeliPod4), @"iPod Touch 4", @(TYSMDeviceDisplay3p5Inch), @326],

                // 5th Gen
                @[@5, @1]: @[@(TYSMDeviceModeliPod5), @"iPod Touch 5", @(TYSMDeviceDisplay4Inch), @326],

                // 6th Gen
                @[@7, @1]: @[@(TYSMDeviceModeliPod6), @"iPod Touch 6", @(TYSMDeviceDisplay4Inch), @326],
                
                // 7th Gen
                @[@9, @1]: @[@(TYSMDeviceModeliPod7), @"iPod Touch 7", @(TYSMDeviceDisplay4Inch), @326],
            },
        };
        
        for (NSString *familyString in familyManifest) {
            if ([systemInfoString hasPrefix:familyString]) {
                family = [familyManifest[familyString] integerValue];
                
                NSArray *modelNuances = modelManifest[familyString][@[@(deviceVersion.major), @(deviceVersion.minor)]];
                if (modelNuances) {
                    model = [modelNuances[0] integerValue];
                    modelString = modelNuances[1];
                    display = [modelNuances[2] integerValue];
                    pixelsPerInch = [modelNuances[3] doubleValue];
                }
                break;
            }
        }
    }
    
    return @[@(family), @(model), modelString, @(display), @(pixelsPerInch)];
}

+ (TYSMOSVersion)_osVersion {
    NSInteger majorVersion = 0;
    NSInteger minorVersion = 0;
    NSInteger patchVersion = 0;
    
    NSArray *decomposedOSVersion = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if (decomposedOSVersion.count > 0) majorVersion = [decomposedOSVersion[0] integerValue];
    if (decomposedOSVersion.count > 1) minorVersion = [decomposedOSVersion[1] integerValue];
    if (decomposedOSVersion.count > 2) patchVersion = [decomposedOSVersion[2] integerValue];
    
    return TYSMOSVersionMake(majorVersion, minorVersion, patchVersion);
}

@end

#endif
