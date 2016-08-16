//
//  NSObject+LGOCallable.h
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/8/11.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LGOCallable<NSObject>

@required
- (void)callWithMethodName:(NSString *)methodName userInfo:(NSDictionary<NSString *, id> *)userInfo;

@end
