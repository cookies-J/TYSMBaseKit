//
//  EAPIRequestManager.m
//  TYSMBaseKit_Example
//
//  Created by Jele Lam on 2021/8/29.
//  Copyright © 2021 cooljele@gmail.com. All rights reserved.
//

#import "EAPIRequestManager.h"
#import "TYSMBaseKit/TYSMBaseKit.h"

@interface EAPIRequestManager ()
@end

@implementation EAPIRequestManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)getGithubUsers:(TYSMResponseSuccessBlock)success failure:(TYSMResponseFailureBlock)failure {
    
    @tysm_weakify(self)
    [self.manager GET:testAPI parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        !success ? : success(responseObject);
        [weak_self.manager invalidateSessionCancelingTasks:YES resetSession:YES];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ? : failure(error);
        [weak_self.manager invalidateSessionCancelingTasks:YES resetSession:YES];

    }];
}
@end
