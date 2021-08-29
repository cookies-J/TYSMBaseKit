//
//  TYSMModel.m
//  IMUI
//
//  Created by Jele on 1/12/2020.
//

#import "TYSMModel.h"


@implementation TYSMErrorModel

+ (TYSMErrorModel *)genCode:(NSNumber *)code msg:(NSString *)msg {
    TYSMErrorModel *model = [[TYSMErrorModel alloc] init];
    model.code = code;
    model.msg = msg;
    return model;
}

@end

@implementation TYSMModel
+(NSDictionary<NSString *,id> *)tysm_modelCustomPropertyMapper {
    return @{
        @"message" : @"msg"
    };
}
@end
