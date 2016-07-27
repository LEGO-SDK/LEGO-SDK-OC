//
//  LGOWebService.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOWebService.h"
#import "LGOCore.h"
#import "LGOMIMETypes.h"

@implementation LGOWebCachePolicy

- (instancetype)initWithPolicy:(NSURLRequestCachePolicy)policy time:(int)time {
    self = [super init];
    if (self) {
        _policy = policy;
        _time = time;
    }
    return self;
}

@end

@interface LGOWebCacheURLProtocol : NSURLProtocol

@end

@implementation LGOWebCacheURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if ([[[LGOCore webCache] webService] cachedForRequest:request]) {
        return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    NSString *filePath = [[[LGOCore webCache] webService] filePathWithRequest:self.request];
    NSURL *URL = self.request.URL;
    if (filePath != nil && URL != nil) {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        id<NSURLProtocolClient> client = self.client;
        if (data != nil && client != nil) {
            NSString *MIMEType;
            NSString *ext = URL.pathExtension;
            if (ext != nil) {
                MIMEType = [LGOMIMETypes items][ext];
            }
            [client URLProtocol:self
             didReceiveResponse:[[NSHTTPURLResponse alloc] initWithURL:URL MIMEType:MIMEType expectedContentLength:data.length textEncodingName:@"UTF-8"]
             cacheStoragePolicy:NSURLCacheStorageNotAllowed];
            [client URLProtocol:self didLoadData:data];
            [client URLProtocolDidFinishLoading:self];
            [[[LGOCore webCache] webService] updateCacheWithRequest:self.request];
        }
        else if (client != nil) {
            [client URLProtocol:self didFailWithError:[NSError errorWithDomain:@"LGOWebCacheURLProtocol" code:-1 userInfo:nil]];
        }
    }
}

- (void)stopLoading {}

@end

@implementation LGOWebService

- (void)startService {
    [NSURLProtocol registerClass:[LGOWebCacheURLProtocol class]];
}

- (BOOL)cachedForRequest:(NSURLRequest *)request {
    NSString *filePath = [self filePathWithRequest:request];
    if (filePath != nil) {
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        if (exists) {
            if ([self cachePolicyForRequest:request].policy == NSURLRequestReloadIgnoringCacheData) {
                return NO;
            }
            return YES;
        }
    }
    return NO;
}

- (BOOL)experiedForRequest:(NSURLRequest *)request second:(NSNumber *)second {
    NSString *filePath = [self filePathWithRequest:request];
    if (filePath != nil) {
        NSError *err;
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&err];
        if (err == nil) {
            NSDate *date = attrs[NSFileModificationDate];
            if ([date isKindOfClass:[NSDate class]]) {
                if (fabs(date.timeIntervalSinceNow) > [second floatValue]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (void)updateCacheWithRequest:(NSURLRequest *)request {
    if ([self experiedForRequest:request second:@([self cachePolicyForRequest:request].time)]) {
        NSURL *URL = request.URL;
        if (URL != nil) {
            [[[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]] dataTaskWithURL:URL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (error == nil && data != nil) {
                    NSString *filePath = [self filePathWithRequest:request];
                    if (filePath != nil) {
                        [data writeToFile:filePath atomically:YES];
                    }
                }
            }] resume];
        }
    }
}

- (LGOWebCachePolicy *)cachePolicyForRequest:(NSURLRequest *)request {
    NSString *absoluteString = [request.URL absoluteString];
    if (absoluteString != nil) {
        for (NSString *pattern in [[LGOCore webCache] cacheConfiguration]) {
            NSNumber *value = [[LGOCore webCache] cacheConfiguration][pattern];
            NSError *err;
            NSRegularExpression *expression = [[NSRegularExpression alloc] initWithPattern:pattern options:kNilOptions error:&err];
            if (err == nil) {
                if ([expression numberOfMatchesInString:absoluteString options:NSMatchingReportCompletion range:NSMakeRange(0, absoluteString.length)] > 0) {
                    if (value.intValue < 0) {
                        return [[LGOWebCachePolicy alloc] initWithPolicy:NSURLRequestReloadIgnoringCacheData time:-1];
                    }
                    else if (value.intValue >= 0) {
                        return [[LGOWebCachePolicy alloc] initWithPolicy:NSURLRequestReturnCacheDataDontLoad time:value.intValue];
                    }
                }
            }
        }
    }
    return [[LGOWebCachePolicy alloc] initWithPolicy:NSURLRequestReturnCacheDataDontLoad time:86400];
}

- (NSString *)filePathWithRequest:(NSURLRequest *)request {
    NSString *workerPath = [[LGOCore webCache] workerPath];
    if (workerPath != nil) {
        NSURL *URL = request.URL;
        if (URL != nil) {
            NSString *host = URL.host;
            NSString *path = URL.path;
            if (host != nil && path != nil) {
                if ([host isEqualToString:@"localhost"]) {
                    return [NSString stringWithFormat:@"%@%@", workerPath, path];
                }
                if ([path isEqualToString:@"/"] || [path length] == 0) {
                    path = @"/index.html";
                }
                return [NSString stringWithFormat:@"%@%@%@", workerPath, host, path];
            }
        }
    }
    return nil;
}

@end
