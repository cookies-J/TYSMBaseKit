//
//  CGGViewClassProtocol.h
//  cengage
//
//  Created by Jele on 3/3/2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CGGViewClassProtocol <NSObject>
@property (nonatomic, copy) NSString *viewClassName;
@end

@protocol CGGViewDataSourceProtocol <NSObject>
@property (nonatomic, copy) NSString *modelClassName;
@property (nonatomic, strong) id model;
@end
NS_ASSUME_NONNULL_END
