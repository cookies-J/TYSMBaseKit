//
//  UIDevice+TYSMAdd.h
//  TYSMKit <https://github.com/ibireme/TYSMKit>
//
//  Created by ibireme on 13/4/3.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Provides extensions for `UIDevice`.
 */
@interface UIDevice (TYSMAdd)


#pragma mark - Device Information
///=============================================================================
/// @name Device Information
///=============================================================================

/// Device system version (e.g. 8.1)
+ (double)tysm_systemVersion;

/// Whether the device is iPad/iPad mini.
@property (nonatomic, readonly) BOOL tysm_isPad;

/// Whether the device is a simulator.
@property (nonatomic, readonly) BOOL tysm_isSimulator;

/// Whether the device is jailbroken.
@property (nonatomic, readonly) BOOL tysm_isJailbroken;

/// Wherher the device can make phone calls.
@property (nonatomic, readonly) BOOL tysm_canMakePhoneCalls NS_EXTENSION_UNAVAILABLE_IOS("");

/// The device's machine model.  e.g. "iPhone6,1" "iPad4,6"
/// @see http://theiphonewiki.com/wiki/Models
@property (nullable, nonatomic, readonly) NSString *tysm_machineModel;

/// The device's machine model name. e.g. "iPhone 5s" "iPad mini 2"
/// @see http://theiphonewiki.com/wiki/Models
@property (nullable, nonatomic, readonly) NSString *tysm_machineModelName;

/// The System's startup time.
@property (nonatomic, readonly) NSDate *tysm_systemUptime;


#pragma mark - Network Information
///=============================================================================
/// @name Network Information
///=============================================================================

/// WIFI IP address of this device (can be nil). e.g. @"192.168.1.111"
@property (nullable, nonatomic, readonly) NSString *tysm_ipAddressWIFI;

/// Cell IP address of this device (can be nil). e.g. @"10.2.2.222"
@property (nullable, nonatomic, readonly) NSString *tysm_ipAddressCell;


/**
 Network traffic type:
 
 WWAN: Wireless Wide Area Network.
       For example: 3G/4G.
 
 WIFI: Wi-Fi.
 
 AWDL: Apple Wireless Direct Link (peer-to-peer connection).
       For exmaple: AirDrop, AirPlay, GameKit.
 */
typedef NS_OPTIONS(NSUInteger, TYSMNetworkTrafficType) {
    TYSMNetworkTrafficTypeWWANSent     = 1 << 0,
    TYSMNetworkTrafficTypeWWANReceived = 1 << 1,
    TYSMNetworkTrafficTypeWIFISent     = 1 << 2,
    TYSMNetworkTrafficTypeWIFIReceived = 1 << 3,
    TYSMNetworkTrafficTypeAWDLSent     = 1 << 4,
    TYSMNetworkTrafficTypeAWDLReceived = 1 << 5,
    
    TYSMNetworkTrafficTypeWWAN = TYSMNetworkTrafficTypeWWANSent | TYSMNetworkTrafficTypeWWANReceived,
    TYSMNetworkTrafficTypeWIFI = TYSMNetworkTrafficTypeWIFISent | TYSMNetworkTrafficTypeWIFIReceived,
    TYSMNetworkTrafficTypeAWDL = TYSMNetworkTrafficTypeAWDLSent | TYSMNetworkTrafficTypeAWDLReceived,
    
    TYSMNetworkTrafficTypeALL = TYSMNetworkTrafficTypeWWAN |
                              TYSMNetworkTrafficTypeWIFI |
                              TYSMNetworkTrafficTypeAWDL,
};

/**
 Get device network traffic bytes.
 
 @discussion This is a counter since the device's last boot time.
 Usage:
 
     uint64_t bytes = [[UIDevice currentDevice] getNetworkTrafficBytes:TYSMNetworkTrafficTypeALL];
     NSTimeInterval time = CACurrentMediaTime();
     
     uint64_t bytesPerSecond = (bytes - _lastBytes)/ (time - _lastTime);
     
     _lastBytes = bytes;
     _lastTime = time;
 
 
 @param type traffic types
 @return bytes counter.
 */
- (uint64_t)tysm_getNetworkTrafficBytes:(TYSMNetworkTrafficType)types;


#pragma mark - Disk Space
///=============================================================================
/// @name Disk Space
///=============================================================================

/// Total disk space in byte. (-1 when error occurs)
@property (nonatomic, readonly) int64_t tysm_diskSpace;

/// Free disk space in byte. (-1 when error occurs)
@property (nonatomic, readonly) int64_t tysm_diskSpaceFree;

/// Used disk space in byte. (-1 when error occurs)
@property (nonatomic, readonly) int64_t tysm_diskSpaceUsed;


#pragma mark - Memory Information
///=============================================================================
/// @name Memory Information
///=============================================================================

/// Total physical memory in byte. (-1 when error occurs)
@property (nonatomic, readonly) int64_t tysm_memoryTotal;

/// Used (active + inactive + wired) memory in byte. (-1 when error occurs)
@property (nonatomic, readonly) int64_t tysm_memoryUsed;

/// Free memory in byte. (-1 when error occurs)
@property (nonatomic, readonly) int64_t tysm_memoryFree;

/// Acvite memory in byte. (-1 when error occurs)
@property (nonatomic, readonly) int64_t tysm_memoryActive;

/// Inactive memory in byte. (-1 when error occurs)
@property (nonatomic, readonly) int64_t tysm_memoryInactive;

/// Wired memory in byte. (-1 when error occurs)
@property (nonatomic, readonly) int64_t tysm_memoryWired;

/// Purgable memory in byte. (-1 when error occurs)
@property (nonatomic, readonly) int64_t tysm_memoryPurgable;

#pragma mark - CPU Information
///=============================================================================
/// @name CPU Information
///=============================================================================

/// Avaliable CPU processor count.
@property (nonatomic, readonly) NSUInteger tysm_cpuCount;

/// Current CPU usage, 1.0 means 100%. (-1 when error occurs)
@property (nonatomic, readonly) float tysm_cpuUsage;

/// Current CPU usage per processor (array of NSNumber), 1.0 means 100%. (nil when error occurs)
@property (nullable, nonatomic, readonly) NSArray<NSNumber *> *tysm_cpuUsagePerProcessor;

@end

NS_ASSUME_NONNULL_END


#ifndef kSystemVersion
#define kSystemVersion [UIDevice tysm_systemVersion]
#endif

#ifndef kiOS6Later
#define kiOS6Later (kSystemVersion >= 6)
#endif

#ifndef kiOS7Later
#define kiOS7Later (kSystemVersion >= 7)
#endif

#ifndef kiOS8Later
#define kiOS8Later (kSystemVersion >= 8)
#endif

#ifndef kiOS9Later
#define kiOS9Later (kSystemVersion >= 9)
#endif
