//
//  SDKPageStateManager.m
//  Sample
//
//  Created by errnull on 2019/8/28.
//  Copyright © 2019 UED Center. All rights reserved.
//

#import "SDKPageStateManager.h"

@implementation SDKPageStateManager

+ (instancetype)shareInstance {
    static SDKPageStateManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

- (void)pageDidLoad {
    NSLog(@"%s", __func__);
}

- (void)pageDidAppear {
    NSLog(@"%s", __func__);
}

- (void)pageDidDisappear {
    NSLog(@"%s", __func__);
}

- (void)pageDealloc {
    NSLog(@"%s", __func__);
}

@end
