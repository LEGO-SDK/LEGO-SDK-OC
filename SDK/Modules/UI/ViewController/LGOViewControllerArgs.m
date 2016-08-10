//
//  LGOViewControllerArgs.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/9.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOViewControllerArgs.h"
#import "LGOCore.h"
#import "LGOBuildFailed.h"
#import "LGOWebViewController.h"

@interface LGOArgsResponse : LGOResponse

@property (nonatomic, strong) NSDictionary *args;

@end

@implementation LGOArgsResponse

- (NSDictionary *)toDictionary{
    return self.args != nil ? self.args : @{};
}

@end

@interface LGOArgsOperation : LGORequestable

@property (nonatomic, retain) LGORequest *request;

@end

@implementation LGOArgsOperation

- (LGOResponse *)requestSynchronize{
    LGOArgsResponse *response = [LGOArgsResponse new];
    UIViewController *viewController = [self.request.context requestViewController];
    if ([viewController isKindOfClass:[LGOWebViewController class]]){
        response.args = ((LGOWebViewController*)viewController).initializeContext;
        return response;
    }
    response.args = @{};
    return response;
}

@end

@implementation LGOArgs

- (LGORequestable *)buildWithRequest:(LGORequest *)request{
    return [[LGOBuildFailed alloc] initWithErrorString:@"Not Support, use build:dictionary:context"];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context{
    LGOArgsOperation *operation = [LGOArgsOperation new];
    operation.request = [[LGORequest alloc]initWithContext:context];
    return operation;
}

@end
