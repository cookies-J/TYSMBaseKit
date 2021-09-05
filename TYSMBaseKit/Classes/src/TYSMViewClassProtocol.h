//
//  CGGViewClassProtocol.h
//  cengage
//
//  Created by Jele on 3/3/2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TYSMViewClassProtocol <NSObject>
@property (nonatomic, copy) NSString *viewClassName;

@optional
@property (nonatomic, copy) NSNumber *viewHeight;
@property (nonatomic, copy) NSNumber *viewWith;

@end

@protocol TYSMViewDataSourceProtocol <NSObject>
@property (nonatomic, copy) NSString *modelClassName;
@property (nonatomic, strong) id model;
@property (nonatomic, copy) void(^tapBlock)(id sender);
@end
NS_ASSUME_NONNULL_END
