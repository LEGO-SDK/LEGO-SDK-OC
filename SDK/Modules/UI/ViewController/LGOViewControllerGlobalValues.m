//
//  LGOViewControllerGlobalValues.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/5.
//  Copyright © 2016年 UED Center. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "LGOViewControllerGlobalValues.h"

static NSDictionary<NSString*, LGOViewControllerInitializeBlock>* _LGOViewControllerMapping;
static NSNumber * _token;

@implementation LGOViewControllerGlobalValues

+ (NSDictionary<NSString*, LGOViewControllerInitializeBlock>*)LGOViewControllerMapping{
    @synchronized (_token) {
        _LGOViewControllerMapping = @{};
    }
    return _LGOViewControllerMapping;
}

@end


@implementation UIViewController (LGO)

- (void)lgo_dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end