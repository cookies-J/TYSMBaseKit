//
//  TYSMUserTool.h
//  TYSMBaseKit-iOS
//
//  Created by Jele Lam on 2021/8/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TYSMUserTool : NSObject

/**
 *  判断是否已登录
 */
- (BOOL)isLogin;
/**
*  保存用户信息
*/
- (void)saveUserInfo:(id)userInfo;

///退出登录
- (void)logout:(void(^)(void))completed;

/// 获取用户信息
- (id)getUserInfo;

@end

NS_ASSUME_NONNULL_END
