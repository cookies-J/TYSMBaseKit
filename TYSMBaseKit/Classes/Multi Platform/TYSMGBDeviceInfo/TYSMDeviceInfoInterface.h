//
//  TYSMDeviceInfoInterface.h
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

#import "TYSMDeviceInfoTypes_Common.h"

@class TYSMDeviceInfo;

@protocol TYSMDeviceInfoInterface <NSObject>
@required

/**
 Returns information about the device the current app is running on.
 */
+ (TYSMDeviceInfo *)deviceInfo;

/**
 Check if the OS version is equal to or higher than version.
 */
- (BOOL)isOperatingSystemAtLeastOSVersion:(TYSMOSVersion)version;

/**
 Check if the OS version is equal to or higher than versionString, where versionString gets parsed into a TYSMOSVersion. 
 
 e.g.   @"8.2.3"    -> TYSMOSVersionMake(8,2,3)
        @"9.1"      -> TYSMOSVersionMake(9,1,0)
 */
- (BOOL)isOperatingSystemAtLeastVersion:(NSString *)versionString;

@end
