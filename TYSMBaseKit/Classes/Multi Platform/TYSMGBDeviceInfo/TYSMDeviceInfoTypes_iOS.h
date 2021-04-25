//
//  TYSMDeviceInfoTypes_iOS.h
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

typedef NS_ENUM(NSInteger, TYSMDeviceModel) {
    TYSMDeviceModelUnknown = 0,
    TYSMDeviceModelSimulatoriPhone,
    TYSMDeviceModelSimulatoriPad,
    TYSMDeviceModeliPhone1,
    TYSMDeviceModeliPhone3G,
    TYSMDeviceModeliPhone3GS,
    TYSMDeviceModeliPhone4,
    TYSMDeviceModeliPhone4S,
    TYSMDeviceModeliPhone5,
    TYSMDeviceModeliPhone5c,
    TYSMDeviceModeliPhone5s,
    TYSMDeviceModeliPhoneSE,
    TYSMDeviceModeliPhoneSE2,
    TYSMDeviceModeliPhone6,
    TYSMDeviceModeliPhone6Plus,
    TYSMDeviceModeliPhone6s,
    TYSMDeviceModeliPhone6sPlus,
    TYSMDeviceModeliPhone7,
    TYSMDeviceModeliPhone7Plus,
    TYSMDeviceModeliPhone8,
    TYSMDeviceModeliPhone8Plus,
    TYSMDeviceModeliPhoneX,
    TYSMDeviceModeliPhoneXR,
    TYSMDeviceModeliPhoneXS,
    TYSMDeviceModeliPhoneXSMax,
    TYSMDeviceModeliPhone11,
    TYSMDeviceModeliPhone11Pro,
    TYSMDeviceModeliPhone11ProMax,
    TYSMDeviceModeliPhone12Mini,
    TYSMDeviceModeliPhone12,
    TYSMDeviceModeliPhone12Pro,
    TYSMDeviceModeliPhone12ProMax,
    TYSMDeviceModeliPad1,
    TYSMDeviceModeliPad2,
    TYSMDeviceModeliPad3,
    TYSMDeviceModeliPad4,
    TYSMDeviceModeliPadMini1,
    TYSMDeviceModeliPadMini2,
    TYSMDeviceModeliPadMini3,
    TYSMDeviceModeliPadMini4,
    TYSMDeviceModeliPadMini5,
    TYSMDeviceModeliPadAir1,
    TYSMDeviceModeliPadAir2,
    TYSMDeviceModeliPadAir3,
    TYSMDeviceModeliPadAir4,
    TYSMDeviceModeliPadPro9p7Inch,
    TYSMDeviceModeliPadPro10p5Inch,
    TYSMDeviceModeliPadPro12p9Inch,
    TYSMDeviceModeliPadPro12p9Inch2,
    TYSMDeviceModeliPadPro11p,
    TYSMDeviceModeliPadPro11p1TB,
    TYSMDeviceModeliPadPro11pInch4,
    TYSMDeviceModeliPadPro12p9Inch3,
    TYSMDeviceModeliPadPro12p9Inch31TB,
    TYSMDeviceModeliPadPro12p9Inch4,
    TYSMDeviceModeliPad5,
    TYSMDeviceModeliPad6,
    TYSMDeviceModeliPad7,
    TYSMDeviceModeliPad8,
    TYSMDeviceModeliPod1,
    TYSMDeviceModeliPod2,
    TYSMDeviceModeliPod3,
    TYSMDeviceModeliPod4,
    TYSMDeviceModeliPod5,
    TYSMDeviceModeliPod6,
    TYSMDeviceModeliPod7
};

typedef NS_ENUM(NSInteger, TYSMDeviceDisplay) {
    TYSMDeviceDisplayUnknown = 0,
    TYSMDeviceDisplay3p5Inch,
    TYSMDeviceDisplay4Inch,
    TYSMDeviceDisplay4p7Inch,
    TYSMDeviceDisplay5p4Inch,
    TYSMDeviceDisplay5p5Inch,
    TYSMDeviceDisplay5p8Inch,
    TYSMDeviceDisplay6p1Inch,
    TYSMDeviceDisplay6p5Inch,
    TYSMDeviceDisplay6p7Inch,
    TYSMDeviceDisplay7p9Inch,
    TYSMDeviceDisplay9p7Inch,
    TYSMDeviceDisplay10p2Inch,
    TYSMDeviceDisplay10p5Inch,
    TYSMDeviceDisplay10p9Inch,
    TYSMDeviceDisplay11pInch,
    TYSMDeviceDisplay12p9Inch,
};

typedef struct {
    /**
     The display of this device.
     
     Returns TYSMDeviceDisplayUnknown on the simulator.
     */
    TYSMDeviceDisplay                                     display;
    
    /**
     The display's pixel density in ppi (pixels per inch).
     
     Returns 0 on the simulator.
     */
    CGFloat                                             pixelsPerInch;
} TYSMDisplayInfo;

/**
 Makes a TYSMDisplayInfo struct.
 */
inline static TYSMDisplayInfo TYSMDisplayInfoMake(TYSMDeviceDisplay display, CGFloat pixelsPerInch) {
    return (TYSMDisplayInfo){display, pixelsPerInch};
};
