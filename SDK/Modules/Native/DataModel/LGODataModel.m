//
//  LGODataModel.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/1.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGODataModel.h"
#import "LGOWebView.h"
#import "LGOWebViewController.h"
#import "LGOBuildFailed.h"

// - Request
@interface LGODataModelRequest : LGORequest

@property (nonatomic, retain) NSString *opt;
@property (nonatomic, retain) NSString *dataKey;
@property (nonatomic, retain) NSString *dataValue; // AnyObject

@end

@implementation LGODataModelRequest

//- (instancetype)initWithContext:(LGORequestContext *)context opt:(NSString *)opt dataKey:(NSString *)dataKey dataValue:(NSString *)dataValue {
//    self = [super initWithContext: context];
//    if (self) {
//        _opt = opt;
//        _dataKey = dataKey;
//        _dataValue = dataValue;
//    }
//    return self;
//}

@end


// - Response
@interface LGODataModelResponse : LGOResponse

@property (nonatomic, retain) NSDictionary *dataModel;

@end



@implementation LGODataModelResponse

- (NSDictionary *) toDictionary {
    if ( [NSJSONSerialization isValidJSONObject: self.dataModel] ) {
        return self.dataModel;
    }
    return [super toDictionary];
}

@end


// - Operation

@interface LGODataModelOperation : LGORequestable

@property (nonatomic, retain) LGODataModelRequest *request;

@end



@implementation LGODataModelOperation

//- (LGOResponse *)requestSynchronize {
//    NSObject * _Nullable sender = self.request.context.sender;
    
//    if ([self.request.opt isEqual: @"read"]) {
//        if ([sender isKindOfClass: [LGOWebView class]]) {
//            LGODataModelResponse *response = [LGODataModelResponse new];
//            response.dataModel = (LGOWebView)sender.data ;
//            return [[LGODataModelResponse alloc] init]
//        }
//    }
//}

@end


// - Model

@implementation LGODataModel

@end










