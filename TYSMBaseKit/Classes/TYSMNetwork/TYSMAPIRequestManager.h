//
//  TYSMAPIRequestManager.h
//  IMUI
//
//  Created by Jele on 3/12/2020.
//

#import <Foundation/Foundation.h>
#import "TYSMNetworking.h"
#import "TYSMAPIRequestProtocol.h"
#import "TYSMAPIModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TYSMAPIRequestManager : NSObject <TYSMAPIRequestProtocol>
+ (instancetype)shareInstance;

@property (nonatomic, strong, readonly) TYSMNetworking *manager;


- (BOOL)isLogin;

- (void)configureBaseUrl:(NSString *)baseUrl;

@end

NS_ASSUME_NONNULL_END
