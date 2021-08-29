//
//  TYSMAPIRequestManager.m
//  IMUI
//
//  Created by Jele on 3/12/2020.
//

#import "TYSMAPIRequestManager.h"
#import "TYSMModel.h"
#import <objc/objc.h>
#import <objc/runtime.h>
#import "NSString+TYSMAdd.h"
#import "TYSMUserTool.h"

#pragma mark - API


static NSString *kUserToken;

@interface TYSMAPIRequestManager ()
@property (nonatomic, strong) TYSMNetworking *manager;
@property (nonatomic, strong) TYSMUserTool *userTool;
@end

@implementation TYSMAPIRequestManager

#pragma mark - singleton

+ (instancetype)shareInstance {
    
    id instance = objc_getAssociatedObject(self, @"shareInstance");
    
    if (!instance)
    {
        instance = [[super allocWithZone:NULL] init];
        objc_setAssociatedObject(self, @"shareInstance", instance, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self shareInstance] ;
}

- (id)copyWithZone:(struct _NSZone *)zone {
    Class selfClass = [self class];
    return [selfClass shareInstance] ;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userTool = [[TYSMUserTool alloc] init];

    }
    return self;
}

#pragma mark - base url
- (void)configureBaseUrl:(NSString *)baseUrl {
    self.manager = [[TYSMNetworking alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
}

- (void)configureToken:(NSString *)token {
    kUserToken = token;
}

- (void)connfigureRequestSerializer {
    
    AFHTTPRequestSerializer *requestSerializer =  [AFJSONRequestSerializer serializer];

    self.manager.requestSerializer = requestSerializer;
    
    self.manager.responseSerializer = [AFJSONResponseSerializer serializer];
}

- (BOOL)isLogin {
    return NO;
}

#pragma mark - Protocol


#pragma mark - private method

- (TYSMModel *)coverModel:(id)data API:(NSString *)name {
    NSAssert(data, @"请检查服务器响应的消息数据");
    TYSMModel *model = [TYSMModel tysm_modelWithJSON:data];

    return model;
}
@end
