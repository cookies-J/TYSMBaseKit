//
//  EAPIRequestManager.h
//  TYSMBaseKit_Example
//
//  Created by Jele Lam on 2021/8/29.
//  Copyright © 2021 cooljele@gmail.com. All rights reserved.
//

#import <TYSMBaseKit/TYSMBaseKit.h>
#import "EDataRequestProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface EAPIRequestManager : TYSMAPIRequestManager <EDataRequestProtocol>

@end

NS_ASSUME_NONNULL_END
