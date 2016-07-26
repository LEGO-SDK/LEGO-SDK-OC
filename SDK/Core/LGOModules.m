//
//  LGOModules.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOModules.h"
#import "LGOCheck.h"

@implementation LGOModules

- (instancetype)init
{
    self = [super init];
    if (self) {
        _items = [@{
                    @"Native.Check": [LGOCheck new]
                   } mutableCopy];
    }
    return self;
}

- (void)addModuleWithName:(NSString *)name instance:(LGOModule *)instance {
    [_items setObject:instance forKey:name];
}

- (LGOModule *)moduleWithName:(NSString *)name {
    return _items[name];
}

- (NSArray<NSString *> *)allModules {
    return [_items allKeys];
}

@end
