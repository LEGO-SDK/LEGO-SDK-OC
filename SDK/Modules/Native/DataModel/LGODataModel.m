//
//  LGODataModel.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/1.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGODataModel.h"
#import "LGOWebView.h"
#import "LGOWebView+DataModel.h"
#import "LGOWKWebView.h"
#import "LGOWKWebView+DataModel.h"
#import "LGOBuildFailed.h"

@interface LGODataModelRequest : LGORequest

@property (nonatomic, strong) NSString *opt; // update/read , defautl:read
@property (nonatomic, strong) NSString *dataKey; // Only for update
@property (nonatomic, strong) id dataValue; // Only for update

@end

@implementation LGODataModelRequest

@end

@interface LGODataModelResponse : LGOResponse

@property (nonatomic, strong) NSDictionary *dataModel;

@end

@implementation LGODataModelResponse

- (NSDictionary *) toDictionary {
    if ( [NSJSONSerialization isValidJSONObject: self.dataModel] ) {
        return self.dataModel;
    }
    return [super toDictionary];
}

@end

@interface LGODataModelOperation : LGORequestable

@property (nonatomic, strong) LGODataModelRequest *request;

@end

@implementation LGODataModelOperation

- (LGOResponse *)requestSynchronize {
    LGODataModelResponse* response = [LGODataModelResponse new];
    response.dataModel = @{};
    NSObject * _Nullable sender = self.request.context.sender;
    
    if ([self.request.opt isEqual: @"read"]) {
        if ([sender isKindOfClass: [LGOWebView class]]) {
            response.dataModel = ((LGOWebView*)sender).dataModel ;
            return response;
        }
        else if ([sender isKindOfClass: [LGOWKWebView class]]){
            response.dataModel = ((LGOWKWebView*)sender).dataModel;
            return response;
        }
    }
    else if ([self.request.opt isEqual: @"update"]) {
        if (!self.request.dataKey || self.request.dataValue == nil){ return response; }
        id dataValue = self.request.dataValue;
        if ([dataValue isKindOfClass:[NSString class]]){
            NSData* data = [((NSString*)dataValue) dataUsingEncoding:NSUTF8StringEncoding];
            if (data){
                NSError* error = nil;
                id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                if (error == nil){
                    dataValue = result;
                }
            }
        }
        if ([sender isKindOfClass: [LGOWebView class]]) {
            [((LGOWebView*)sender) updateDataModel:self.request.dataKey dataValue:dataValue];
            return response;
        }
        else if ([sender isKindOfClass: [LGOWKWebView class]]){
            [((LGOWKWebView*)sender) updateDataModel:self.request.dataKey dataValue:dataValue];
            return response;
        }
    }
    return response;
}

@end

@implementation LGODataModel

- (LGORequestable *)buildWithRequest:(LGORequest *)request{
    if ([request isKindOfClass:[LGODataModelRequest class]]){
        LGODataModelOperation *operation = [LGODataModelOperation new];
        operation.request = (LGODataModelRequest *)request;
        return operation;
    }
    return [[LGOBuildFailed alloc] initWithErrorString:@"RequestObject Downcast Failed"];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context{
    LGODataModelRequest* request = [LGODataModelRequest new];
    request.context = context;
    request.opt = [dictionary[@"opt"] isKindOfClass:[NSString class]] ? dictionary[@"opt"] : @"read";
    request.dataKey = [dictionary[@"dataKey"] isKindOfClass:[NSString class]] ? dictionary[@"dataKey"] : nil;
    request.dataValue = dictionary[@"dataValue"];
    return [self buildWithRequest:request];
}

@end










