//
//  TYSMViewController.h
//  IMUI
//
//  Created by Jele on 1/12/2020.
//

#import <UIKit/UIKit.h>
#import <XXNibBridge/XXNibBridge.h>
#import "TYSMViewClassProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface TYSMViewController : UIViewController <XXNibBridge,TYSMViewDataSourceProtocol>

@end

NS_ASSUME_NONNULL_END
