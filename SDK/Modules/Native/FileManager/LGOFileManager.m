//
//  LGOFileManager.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/1.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOBuildFailed.h"
#import "LGOCore.h"
#import "LGOFileManager.h"

@interface LGOFileManager ()

+ (NSArray *)protecting;

@end

@interface LGOFileManagerRequest : LGORequest

@property(nonatomic, strong) NSString *suite;
@property(nonatomic, strong) NSString *opt;
@property(nonatomic, strong) NSString *filePath;
@property(nonatomic, strong) NSData *fileContents;

@end

@implementation LGOFileManagerRequest

@end

@interface LGOFileManagerResponse : LGOResponse

@property(nonatomic, assign) BOOL optSucceed;
@property(nonatomic, strong) NSData *fileContents;

@end

@implementation LGOFileManagerResponse

+ (NSString *)stringFromFileContent:(NSData *)fileContent {
    NSString *utf8Str = [[NSString alloc] initWithData:fileContent encoding:NSUTF8StringEncoding];
    if (utf8Str != nil) {
        return utf8Str;
    } else {
        NSString *base64Str = [fileContent base64EncodedStringWithOptions:kNilOptions];
        if (base64Str != nil) {
            return base64Str;
        }
        return nil;
    }
}

- (NSDictionary *)resData {
    NSString *fileContents = [LGOFileManagerResponse stringFromFileContent:self.fileContents];
    return @{
        @"optSucceed" : [NSNumber numberWithBool:self.optSucceed],
        @"fileContents" : fileContents ? fileContents : [NSNull null]
    };
}

@end

@interface LGOFileManagerOperation : LGORequestable

@property(nonatomic, strong) LGOFileManagerRequest *request;

@end

@implementation LGOFileManagerOperation

- (BOOL)checkPermission {
    NSString *requestPath = self.request.filePath;
    while ([requestPath rangeOfString:@"//"].location != NSNotFound) {
        requestPath = [requestPath stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
    }
    NSString *targetPath = [NSString stringWithFormat:@"/%@/%@", self.request.suite, requestPath];
    for (NSString *item in [LGOFileManager protecting]) {
        if ([targetPath.lowercaseString hasPrefix:item.lowercaseString]) {
            return NO;
        }
    }
    return YES;
}

- (NSString *)filePathFromRequest:(LGOFileManagerRequest *)request {
    NSString *directory = NSTemporaryDirectory();
    if ([request.suite isEqualToString:@"Document"]) {
        directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject];
    } else if ([request.suite isEqualToString:@"Caches"]) {
        directory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true) firstObject];
    }
    return [NSString stringWithFormat:@"%@/%@", directory, request.filePath];
}

- (LGOResponse *)requestSynchronize {
    LGOFileManagerResponse *response = [LGOFileManagerResponse new];
    response.optSucceed = false;
    NSString *filePath = [self filePathFromRequest:self.request];

    if (![self checkPermission]) {
        return [[LGOResponse new] reject:[NSError errorWithDomain:@"Native.FileManager"
                                                             code:-4
                                                         userInfo:@{
                                                             NSLocalizedDescriptionKey : @"Check permission fail."
                                                         }]];
    }

    if ([self.request.filePath length] == 0) {
        return [[LGOResponse new] reject:[NSError errorWithDomain:@"Native.FileManager"
                                                             code:-5
                                                         userInfo:@{
                                                             NSLocalizedDescriptionKey : @"FilePath not empty."
                                                         }]];
        ;
    }

    if ([self.request.opt isEqualToString:@"Read"]) {
        NSData *fileContents = [NSData dataWithContentsOfFile:filePath];
        if (fileContents != nil) {
            response.optSucceed = YES;
            response.fileContents = fileContents;
        } else {
            return [[LGOResponse new] reject:[NSError errorWithDomain:@"Native.FileManager"
                                                                 code:-6
                                                             userInfo:@{
                                                                 NSLocalizedDescriptionKey : @"Data reading fail."
                                                             }]];
            ;
        }
    } else if ([self.request.opt isEqualToString:@"Write"]) {
        NSMutableArray *tmpArr = [[NSMutableArray alloc] initWithArray:[filePath componentsSeparatedByString:@"/"]];
        [tmpArr removeLastObject];
        NSString *dirPath = [tmpArr componentsJoinedByString:@"/"];

        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath
                                  withIntermediateDirectories:true
                                                   attributes:nil
                                                        error:nil];
        NSData *data = self.request.fileContents;
        if (data != nil) {
            [data writeToFile:filePath options:NSDataWritingAtomic error:nil];
        } else {
            return [[LGOResponse new] reject:[NSError errorWithDomain:@"Native.FileManager"
                                                                 code:-7
                                                             userInfo:@{
                                                                 NSLocalizedDescriptionKey : @"FileContents not empty."
                                                             }]];
            ;
        }
        response.optSucceed = YES;
    } else if ([self.request.opt isEqualToString:@"Delete"]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        response.optSucceed = YES;
    } else if ([self.request.opt isEqualToString:@"Check"]) {
        response.optSucceed = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    }
    return [response accept:nil];
}

@end

@implementation LGOFileManager

static NSArray<NSString *> *protecting;

+ (NSArray *)protecting {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      protecting = @[ @"/Caches/LGOCache/" ];
    });
    return protecting;
}

+ (void)configureProtecting:(NSArray *)array {
    if (array == nil) {
        return;
    }
    protecting = array;
}

- (LGORequestable *)buildWithRequest:(LGORequest *)request {
    if ([request isKindOfClass:[LGOFileManagerRequest class]]) {
        LGOFileManagerOperation *operation = [LGOFileManagerOperation new];
        operation.request = (LGOFileManagerRequest *)request;
        return operation;
    }
    return [LGORequestable rejectWithDomain:@"Native.FileManager" code:-1 reason:@"Type error."];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context {
    LGOFileManagerRequest *request = [[LGOFileManagerRequest alloc] initWithContext:context];
    NSString *suite = [dictionary[@"suite"] isKindOfClass:[NSString class]] ? dictionary[@"suite"] : nil;
    NSString *opt = [dictionary[@"opt"] isKindOfClass:[NSString class]] ? dictionary[@"opt"] : nil;
    NSString *filePath = [dictionary[@"filePath"] isKindOfClass:[NSString class]] ? dictionary[@"filePath"] : nil;
    NSString *contentString =
        [dictionary[@"fileContents"] isKindOfClass:[NSString class]] ? dictionary[@"fileContents"] : nil;

    if (!suite || !opt || !filePath) {
        return
            [LGORequestable rejectWithDomain:@"Native.FileManager" code:-2 reason:@"Suite && opt && filePath require."];
    }
    request.suite = suite;
    request.opt = opt;
    request.filePath = filePath;
    if (contentString) {
        request.fileContents = ^(NSString *contentString) {
          NSData *fileContents = [[NSData alloc] initWithBase64EncodedString:contentString options:kNilOptions];
          if (fileContents) {
              return fileContents;
          } else {
              return [contentString dataUsingEncoding:NSUTF8StringEncoding];
          }
        }(contentString);
    } else {
        return [LGORequestable rejectWithDomain:@"Native.FileManager" code:-3 reason:@"FileContents type error."];
    }

    return [[LGOFileManager alloc] buildWithRequest:request];
}

@end
