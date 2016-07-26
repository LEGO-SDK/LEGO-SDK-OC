//
//  LGOBuildFailed.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOBuildFailed.h"
#import "LGOProtocols.h"

@interface LGOBuildFailedResponse : LGOResponse

@property (nonatomic, copy) NSString *error;

@end

@implementation LGOBuildFailedResponse

- (instancetype)init {
    self = [super init];
    if (self) {
        _error = @"Unknown Error";
    }
    return self;
}

- (NSDictionary *)toDictionary {
    return @{
             @"succeed": @(false),
             @"error": self.error,
             };
}

@end

@implementation LGOBuildFailed

- (LGOResponse *)requestSynchronize {
    LGOBuildFailedResponse *response = [[LGOBuildFailedResponse alloc] init];
    response.error = self.error;
    return response;
}

@end
