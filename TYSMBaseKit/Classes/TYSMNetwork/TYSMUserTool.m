//
//  TYSMUserTool.m
//  TYSMBaseKit-iOS
//
//  Created by Jele Lam on 2021/8/29.
//

#import "TYSMUserTool.h"

static NSString *const k_USER_DATA = @"k_USER_DATA";

@interface TYSMUserTool ()
@property (nonatomic, strong) id userInfo;
@end

@implementation TYSMUserTool

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id)getUserInfo {
    return _userInfo;
}

- (void)saveUserInfo:(id)userInfo {
    NSAssert([userInfo isKindOfClass:NSObject.class] == NO, @"类型出错");
    _userInfo = userInfo;
}

- (void)logout:(void (^)(void))completed {
    
    !completed ? : completed();
}


- (BOOL)isLogin {
    return NO;
}



@end
