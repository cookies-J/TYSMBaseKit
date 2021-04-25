//
//  TYSMDeviceInfo_iOS.h
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

#import "TYSMDeviceInfo_Common.h"

#import "TYSMDeviceInfoTypes_iOS.h"

@interface TYSMDeviceInfo : TYSMDeviceInfo_Common

/**
 The device version. e.g. {7, 2}.
 */
@property (assign, atomic, readonly) TYSMDeviceVersion    deviceVersion;

/**
 The human readable name for the device, e.g. "iPhone 6".
 */
@property (strong, atomic, readonly) NSString           *modelString;


/**
 The specific device model, e.g. TYSMDeviceModeliPhone6.
 */
@property (assign, atomic, readonly) TYSMDeviceModel      model;

/**
 Information about the display.
 */
@property (assign, atomic, readonly) TYSMDisplayInfo      displayInfo;

/**
 Is the device jailbroken? 
 
 You must add the `TYSMDeviceInfo/Jailbreak` subspec to your project in order to use this property.
 */
@property (assign, atomic, readonly) BOOL               isJailbroken;

@end
