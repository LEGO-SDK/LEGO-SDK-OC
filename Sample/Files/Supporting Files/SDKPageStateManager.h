//
//  SDKPageStateManager.h
//  Sample
//
//  Created by errnull on 2019/8/28.
//  Copyright © 2019 UED Center. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LGOPageStateProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface SDKPageStateManager : NSObject<LGOPageStateProtocol>

+ (instancetype)shareInstance;

@end

NS_ASSUME_NONNULL_END
