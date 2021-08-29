//
//  TYSMModel.h
//  IMUI
//
//  Created by Jele on 1/12/2020.
//

#import "NSObject+TYSMModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TYSMErrorModel : NSObject <TYSMModel>
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, copy) NSNumber *code;
@property (nonatomic, strong) id data;
+ (TYSMErrorModel *)genCode:(NSNumber *)code msg:(NSString *)msg;
@end

@interface TYSMModel : NSObject <TYSMModel>
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSNumber *code;
@property (nonatomic, strong) id data;
@end

NS_ASSUME_NONNULL_END
