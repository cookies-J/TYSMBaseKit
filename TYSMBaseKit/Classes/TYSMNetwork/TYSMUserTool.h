//
//  TYSMUserTool.h
//  TYSMBaseKit-iOS
//
//  Created by Jele Lam on 2021/8/29.
//

static NSString * _Nullable const k_TYSM_USER_KEY = @"abc";

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TYSMUserTool : NSObject


/**
 *
 通过单例模式对工具类进行初始化
 *
 */
+ (instancetype)shareUser;

/**
 *
 通过单例模式对工具类进行初始化
 *
 */
+ (void)configInfo:(NSDictionary *)infoDic;

/**
 *
 用户退出登录的操作
 *
 */
+ (void)loginOut;

+ (void)configUserModel:(id)model;

@end

NS_ASSUME_NONNULL_END
