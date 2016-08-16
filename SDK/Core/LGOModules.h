//
//  LGOModules.h
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LGOProtocols.h"

@interface LGOModules : NSObject

@property(nonatomic, strong) NSMutableDictionary<NSString *, LGOModule *> *_Nonnull items;

- (void)addModuleWithName:(nonnull NSString *)name instance:(nonnull LGOModule *)instance;

- (nullable LGOModule *)moduleWithName:(nonnull NSString *)name;

- (nonnull NSArray<NSString *> *)allModules;

@end
