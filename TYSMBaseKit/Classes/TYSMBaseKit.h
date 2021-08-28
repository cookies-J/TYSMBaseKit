//
//  TYSMBaseKit.h
//  Pods
//
//  Created by Jele on 24/4/2021.
//

#ifndef TYSMBaseKit_h
#define TYSMBaseKit_h

/// 日志
#import <TYSMBaseKit/TYSMLog.h>
/// 设备信息
#import <TYSMBaseKit/TYSMDeviceInfo.h>

 
#if TARGET_OS_IOS
/// 集成 YYKit   去除部分冗余
#import <TYSMBaseKit/TYSMYYKit.h>
/// UIKit 控制器集
#import <TYSMBaseKit/ViewControllers.h>
/// UIKit 视图集
#import <TYSMBaseKit/TYSMViews.h>

/// 工具类

/// 计时器
#import <TYSMBaseKit/TYSMSDKTimer.h>
/// 后台任务
#import <TYSMBaseKit/TYSMBackgroundTask.h>
/// 路由组件
#import <TYSMBaseKit/TYSM_CTMediator.h>
#endif

#endif /* TYSMBaseKit_h */
