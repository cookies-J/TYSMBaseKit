//
//  TYSM_CTMediator+HandyTools.h
//  TYSM_CTMediator
//
//  Created by casa on 2020/3/10.
//  Copyright © 2020 casa. All rights reserved.
//

#if TARGET_OS_IOS

#import "TYSM_CTMediator.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TYSM_CTMediator (HandyTools)

- (UIViewController * _Nullable)topViewController;
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)animated completion:(void (^ _Nullable )(void))completion;

@end

NS_ASSUME_NONNULL_END

#endif
