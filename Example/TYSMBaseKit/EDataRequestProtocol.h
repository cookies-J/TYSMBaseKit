//
//  EDataRequestProtocol.h
//  TYSMBaseKit_Example
//
//  Created by Jele Lam on 2021/8/29.
//  Copyright © 2021 cooljele@gmail.com. All rights reserved.
//

#import "TYSMAPIRequestProtocol.h"

static NSString * _Nonnull const testAPI = @"/users";

NS_ASSUME_NONNULL_BEGIN

@protocol EDataRequestProtocol <TYSMAPIRequestProtocol>
- (void)getGithubUsers:(TYSMResponseSuccessBlock)success
               failure:(TYSMResponseFailureBlock)failure;
@end

NS_ASSUME_NONNULL_END
