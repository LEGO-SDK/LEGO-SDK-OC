//
//  LGODataModel.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/1.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOBuildFailed.h"
#import "LGODataModel.h"
#import "LGOWKWebView+DataModel.h"
#import "LGOWebView+DataModel.h"

@interface LGODataModelRequest : LGORequest

@property(nonatomic, strong) NSString *opt;      // update/read , defautl:read
@property(nonatomic, strong) NSString *dataKey;  // Only for update
@property(nonatomic, strong) id dataValue;       // Only for update

@end

@implementation LGODataModelRequest

@end

@interface LGODataModelResponse : LGOResponse

@property(nonatomic, strong) NSDictionary *dataModel;

@end

@implementation LGODataModelResponse

- (NSDictionary *)resData {
    if ([NSJSONSerialization isValidJSONObject:self.dataModel]) {
        return self.dataModel;
    }
    return [super resData];
}

@end

@interface LGODataModelOperation : LGORequestable

@property(nonatomic, strong) LGODataModelRequest *request;

@end

@implementation LGODataModelOperation

- (LGOResponse *)requestSynchronize {
    LGODataModelResponse *response = [LGODataModelResponse new];
    response.dataModel = @{};
    NSObject *_Nullable sender = self.request.context.sender;

    if ([self.request.opt isEqual:@"read"]) {
        if ([sender isKindOfClass:[UIWebView class]]) {
            response.dataModel = ((UIWebView *)sender).dataModel;
            return [response accept:nil];
        } else if ([sender isKindOfClass:[WKWebView class]]) {
            response.dataModel = ((WKWebView *)sender).dataModel;
            return [response accept:nil];
        }
    
    } else if ([self.request.opt isEqual:@"update"]) {
        if (!self.request.dataKey || self.request.dataValue == nil) {
            return [[LGOResponse new] reject: [NSError errorWithDomain:@"Native.DataModel" code:-2 userInfo: @{ NSLocalizedDescriptionKey: @"DataKey & DataValue require." }]];
        }
        id dataValue = self.request.dataValue;
        if ([dataValue isKindOfClass:[NSString class]]) {
            NSData *data = [((NSString *)dataValue) dataUsingEncoding:NSUTF8StringEncoding];
            if (data) {
                NSError *error = nil;
                id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                if (error == nil) {
                    dataValue = result;
                }
                else {
                    return [[LGOResponse new] reject: [NSError errorWithDomain:@"Native.DataModel" code:-3 userInfo: @{ NSLocalizedDescriptionKey: @"JSON parse error." }]];
                }
            }
            else {
                return [[LGOResponse new] reject: [NSError errorWithDomain:@"Native.DataModel" code:-4 userInfo: @{ NSLocalizedDescriptionKey: @"Data utf8 encode error." }]];
            }
        }
        else {
            return [[LGOResponse new] reject: [NSError errorWithDomain:@"Native.DataModel" code:-5 userInfo: @{ NSLocalizedDescriptionKey: @"Data Type error." }]];
        }
        if ([sender isKindOfClass:[UIWebView class]]) {
            [((UIWebView *)sender) updateDataModel:self.request.dataKey dataValue:dataValue];
            return [response accept: nil];
        } else if ([sender isKindOfClass:[WKWebView class]]) {
            [((WKWebView *)sender) updateDataModel:self.request.dataKey dataValue:dataValue];
            return [response accept: nil];
        }
    }
    else {
        return [[LGOResponse new] reject: [NSError errorWithDomain:@"Native.DataModel" code:-6 userInfo: @{ NSLocalizedDescriptionKey: @"Invalid opt value." }]];
    }
    return [[LGOResponse new] reject: [NSError errorWithDomain:@"Native.DataModel" code:-7 userInfo: @{ NSLocalizedDescriptionKey: @"Invalid webview." }]];
}

@end

@implementation LGODataModel

- (LGORequestable *)buildWithRequest:(LGORequest *)request {
    if ([request isKindOfClass:[LGODataModelRequest class]]) {
        LGODataModelOperation *operation = [LGODataModelOperation new];
        operation.request = (LGODataModelRequest *)request;
        return operation;
    }
    return [LGORequestable rejectWithDomain:@"Native.DataModel" code:-1 reason:@"Type error."];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    LGODataModelRequest *request = [LGODataModelRequest new];
    request.context = context;
    request.opt = [dictionary[@"opt"] isKindOfClass:[NSString class]] ? dictionary[@"opt"] : @"read";
    request.dataKey = [dictionary[@"dataKey"] isKindOfClass:[NSString class]] ? dictionary[@"dataKey"] : nil;
    request.dataValue = dictionary[@"dataValue"];
    return [self buildWithRequest:request];
}

@end
