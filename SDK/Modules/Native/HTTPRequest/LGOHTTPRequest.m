//
//  LGOHTTPRequest.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/1.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "LGOCore.h"
#import "LGOHTTPRequest.h"

@interface LGOHTTPRequestObject : LGORequest

@property(nonatomic, strong) NSMutableURLRequest *nativeRequest;
@property(nonatomic, assign) BOOL showActivityIndicator;
- (void)setTimeout:(double)time;
- (void)setHeaders:(NSDictionary *)headers;

@end

@implementation LGOHTTPRequestObject

- (instancetype)initWithURLString:(NSString *)URLString {
    self = [super init];
    if (self) {
        NSURL *URL = [[NSURL alloc] initWithString:URLString];
        if (URL != nil) {
            _nativeRequest = [[NSMutableURLRequest alloc] initWithURL:URL];
        }
    }
    return self;
}

- (instancetype)initWithURLString:(NSString *)URLString data:(NSData *)data {
    self = [super init];
    if (self) {
        NSURL *URL = [[NSURL alloc] initWithString:URLString];
        if (URL != nil) {
            _nativeRequest = [[NSMutableURLRequest alloc] initWithURL:URL];
            _nativeRequest.HTTPMethod = @"POST";
            _nativeRequest.HTTPBody = data;
            _nativeRequest.HTTPShouldHandleCookies = false;
        }
    }
    return self;
}

- (void)setTimeout:(double)time {
    self.nativeRequest.timeoutInterval = time;
}

- (void)setHeaders:(NSDictionary *)headers {
    for (NSString *key in headers) {
        id val = [headers objectForKey:key];
        if ([val isKindOfClass:[NSString class]]) {
            [self.nativeRequest setValue:(NSString *)val forHTTPHeaderField:key];
        }
    }
}

@end

@interface LGOHTTPResponseObject : LGOResponse

@property(nonatomic, strong) NSString *error;
@property(nonatomic, assign) NSInteger statusCode;
@property(nonatomic, strong) NSString *responseText;
@property(nonatomic, strong) NSData *_Nullable responseData;

@end

@implementation LGOHTTPResponseObject

- (NSDictionary *)resData {
    return
        @{ @"error" : self.error != nil ? self.error : [NSNull null],
           @"statusCode" : [NSNumber numberWithInteger:self.statusCode],
           @"responseText" : self.responseText != nil ? self.responseText : [NSNull null],
           @"responseData" : ^(){
               if (self.responseData != nil){return [self.responseData base64EncodedStringWithOptions:kNilOptions];
}
return @"";
}
()
}
;
}

@end

@interface LGOHTTPOperation : LGORequestable

@property(nonatomic, strong) LGOHTTPRequestObject *request;

@end

@implementation LGOHTTPOperation

+ (NSOperationQueue *)aQueue {
    static NSOperationQueue *q;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      q = [NSOperationQueue new];
      q.maxConcurrentOperationCount = 4;
    });
    return q;
}

- (void)requestAsynchronize:(LGORequestableAsynchronizeBlock)callbackBlock {
    if (self.request.showActivityIndicator) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }

    [NSURLConnection sendAsynchronousRequest:self.request.nativeRequest
                                       queue:[LGOHTTPOperation aQueue]
                           completionHandler:^(NSURLResponse *_Nullable responseObject, NSData *_Nullable responseData,
                                               NSError *_Nullable error) {
                             
                               if (error) {
                                   callbackBlock([[LGOResponse new] reject: [NSError
                                                                             errorWithDomain:@"Native.HTTPRequest"
                                                                             code:-4
                                                                             userInfo:@{ NSLocalizedDescriptionKey: error.localizedDescription }]]);
                               }
                             if (self.request.showActivityIndicator) {
                                 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                             }
                             LGOHTTPResponseObject *returnResponse = [LGOHTTPResponseObject new];
                             returnResponse.error = error ? error.description : @"";
                             returnResponse.statusCode = [responseObject isKindOfClass:[NSHTTPURLResponse class]]
                                                             ? [(NSHTTPURLResponse *)responseObject statusCode]
                                                             : 500;
                             NSString *utf8encodedString =
                                 [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                             if (utf8encodedString != nil) {
                                 returnResponse.responseText = utf8encodedString;
                                 returnResponse.responseData = nil;
                             } else {
                                 returnResponse.responseText = @"";
                                 returnResponse.responseData = responseData;
                             }
                             callbackBlock([returnResponse accept: nil]);
                           }];
}

@end

@implementation LGOHTTPRequest

- (LGORequestable *)buildWithRequest:(LGORequest *)request {
    if ([request isKindOfClass:[LGOHTTPRequestObject class]]) {
        LGOHTTPOperation *operation = [LGOHTTPOperation new];
        operation.request = (LGOHTTPRequestObject *)request;
        return operation;
    }
    return [LGORequestable rejectWithDomain:@"Native.HTTPRequest" code:-1 reason:@"Type error."];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    LGOHTTPRequestObject *_Nullable requestObject = nil;
    NSString *_Nullable URLString = [dictionary[@"URL"] isKindOfClass:[NSString class]] ? dictionary[@"URL"] : nil;
    if (!URLString){
        return [LGORequestable rejectWithDomain:@"Native.HTTPRequest" code:-2 reason:@"URL require."];
    }
    if (![URLString hasPrefix:@"http://"] && ![URLString hasPrefix:@"https://"]) {
        if ([context.requestWebView isKindOfClass:[UIWebView class]]) {
            UIWebView *webView = (UIWebView *)context.requestWebView;
            NSURL *activeURL = webView.request.URL;
            NSURL *relativeURL = [NSURL URLWithString:URLString relativeToURL:activeURL];
            if (relativeURL) {
                URLString = relativeURL.absoluteString;
            }
        }
        if ([context.requestWebView isKindOfClass:[WKWebView class]]) {
            WKWebView *webView = (WKWebView *)context.requestWebView;
            NSURL *activeURL = webView.URL;
            NSURL *relativeURL = [NSURL URLWithString:URLString relativeToURL:activeURL];
            if (relativeURL) {
                URLString = relativeURL.absoluteString;
            }
        }
    }

    NSString *_Nullable data = [dictionary[@"data"] isKindOfClass:[NSString class]] ? dictionary[@"data"] : nil;
    if (data) {
        NSData *base64Data = [[NSData alloc] initWithBase64EncodedString:data options:kNilOptions];
        if (base64Data) {
            requestObject = [[LGOHTTPRequestObject alloc] initWithURLString:URLString data:base64Data];
        } else {
            NSData *encodedData = [data dataUsingEncoding:NSUTF8StringEncoding];
            if (encodedData) {
                requestObject = [[LGOHTTPRequestObject alloc] initWithURLString:URLString data:encodedData];
            }
        }
    } else {
        requestObject = [[LGOHTTPRequestObject alloc] initWithURLString:URLString];
    }

    if (requestObject) {
        requestObject.showActivityIndicator = ^{
          NSNumber *isShow = dictionary[@"showActivityIndicator"];
          if ([isShow isKindOfClass:[NSNumber class]]) {
              return isShow.boolValue;
          }
          return NO;
        }();

        NSNumber *timeout = dictionary[@"timeout"];
        if ([timeout isKindOfClass:[NSNumber class]]) {
            [requestObject setTimeout:timeout.doubleValue];
        }

        NSDictionary *customHeaders = dictionary[@"headers"];
        if ([customHeaders isKindOfClass:[NSDictionary class]]) {
            [requestObject setHeaders:customHeaders];
        }

        LGOHTTPOperation *operation = [LGOHTTPOperation new];
        operation.request = requestObject;
        return operation;
    }

    return [LGORequestable rejectWithDomain:@"Native.HTTPRequest" code:-3 reason:@"Unknow."];
}

@end
