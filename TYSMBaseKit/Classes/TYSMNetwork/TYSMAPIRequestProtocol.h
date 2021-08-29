//
//  TYSMAPIRequestProtocol.h
//  IMUI
//
//  Created by Jele on 3/12/2020.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

static int const kAPIResponseCorrect = 000;

typedef void(^TYSMResponseSuccessBlock)(id _Nonnull data);
typedef void(^TYSMResponseFailureBlock)(id _Nonnull error);

@protocol TYSMAPIRequestProtocol <NSObject>

@end

NS_ASSUME_NONNULL_END
