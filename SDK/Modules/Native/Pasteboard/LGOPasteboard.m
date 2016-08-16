//
//  LGOPasteboard.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/3.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOBuildFailed.h"
#import "LGOCore.h"
#import "LGOPasteboard.h"

@interface LGOPasteboardRequest : LGORequest

@property(nonatomic, strong) NSString *opt;  // update/read/delete
@property(nonatomic, strong) NSString *_Nullable string;

@end

@implementation LGOPasteboardRequest

@end

@interface LGOPasteboardResponse : LGOResponse

@property(nonatomic, strong) NSString *_Nullable string;

@end

@implementation LGOPasteboardResponse

- (NSDictionary *)resData {
    return @{ @"string" : self.string ? self.string : [NSNull null] };
}

@end

@interface LGOPasteboardOperation : LGORequestable

@property(nonatomic, strong) LGOPasteboardRequest *request;

@end

@implementation LGOPasteboardOperation

- (LGOResponse *)requestSynchronize {
    LGOPasteboardResponse *response = [LGOPasteboardResponse new];

    if ([[self.request opt] isEqualToString:@"read"]) {
        response.string = [UIPasteboard generalPasteboard].string;
        return response;
    } else if ([[self.request opt] isEqualToString:@"update"]) {
        if (self.request.string) {
            [UIPasteboard generalPasteboard].string = self.request.string;
        }
    } else if ([[self.request opt] isEqualToString:@"delete"]) {
        [UIPasteboard generalPasteboard].string = @"";
    }
    response.string = nil;
    return [response accept: nil];
}

@end

@implementation LGOPasteboard

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    LGOPasteboardRequest *request = [LGOPasteboardRequest new];
    if ([dictionary[@"opt"] isKindOfClass:[NSString class]]) {
        request.opt = (NSString *)dictionary[@"opt"];
    } else {
        request.opt = @"read";
    }

    if ([dictionary[@"string"] isKindOfClass:[NSString class]]) {
        request.string = (NSString *)dictionary[@"string"];
    }

    LGOPasteboardOperation *operation = [LGOPasteboardOperation new];
    operation.request = request;
    return operation;
}

- (LGORequestable *)buildWithRequest:(LGORequest *)request {
    if ([request isKindOfClass:[LGOPasteboardRequest class]]) {
        LGOPasteboardOperation *operation = [LGOPasteboardOperation new];
        operation.request = (LGOPasteboardRequest *)request;
        return operation;
    }
    return [LGORequestable rejectWithDomain:@"Native.Pasteboard" code:-1 reason:@"Type error."];
}

@end
