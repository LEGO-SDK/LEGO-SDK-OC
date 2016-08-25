//
//  LGOFileManager.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/1.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOCore.h"
#import "LGOFileManager.h"

@interface LGOFileManagerRequest : LGORequest

@property(nonatomic, strong) NSString *suite;
@property(nonatomic, strong) NSString *opt;
@property(nonatomic, strong) NSString *filePath;
@property(nonatomic, strong) NSData *fileContents;

@end

@implementation LGOFileManagerRequest

@end

@interface LGOFileManagerResponse : LGOResponse

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
    return @{ @"fileContents" : fileContents != nil ? fileContents : [NSNull null] };
}

@end

@interface LGOFileManagerOperation : LGORequestable

@property(nonatomic, strong) LGOFileManagerRequest *request;

@end

@implementation LGOFileManagerOperation

- (NSString *)filePathFromRequest:(LGOFileManagerRequest *)request {
    NSString *directory = NSTemporaryDirectory();
    if ([request.suite isEqualToString:@"Document"]) {
        directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject];
    } else if ([request.suite isEqualToString:@"Caches"]) {
        directory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true) firstObject];
    }
    return [NSString stringWithFormat:@"%@/LGOFileManager/%@", directory, request.filePath];
}

- (LGOResponse *)requestSynchronize {
    LGOFileManagerResponse *response = [LGOFileManagerResponse new];
    NSString *filePath = [self filePathFromRequest:self.request];
    if ([self.request.filePath length] == 0) {
        return [[LGOResponse new] reject:[NSError errorWithDomain:@"Native.FileManager"
                                                             code:-5
                                                         userInfo:@{
                                                             NSLocalizedDescriptionKey : @"FilePath not empty."
                                                         }]];
        ;
    }

    if ([self.request.opt isEqualToString:@"read"]) {
        NSData *fileContents = [NSData dataWithContentsOfFile:filePath];
        if (fileContents != nil) {
            response.fileContents = fileContents;
            return [response accept:nil];
        } else {
            return [response reject:[NSError errorWithDomain:@"Native.FileManager"
                                                        code:-6
                                                    userInfo:@{
                                                        NSLocalizedDescriptionKey : @"Data reading fail."
                                                    }]];
            ;
        }
    } else if ([self.request.opt isEqualToString:@"update"]) {
        NSMutableArray *tmpArr = [[NSMutableArray alloc] initWithArray:[filePath componentsSeparatedByString:@"/"]];
        [tmpArr removeLastObject];
        NSString *dirPath = [tmpArr componentsJoinedByString:@"/"];

        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath
                                  withIntermediateDirectories:true
                                                   attributes:nil
                                                        error:nil];
        NSData *data = self.request.fileContents;
        if (data != nil) {
            NSError *error = nil;
            [data writeToFile:filePath options:NSDataWritingAtomic error:&error];
            if (error != nil) {
                return [response
                    reject:[NSError errorWithDomain:@"Native.FileManager"
                                               code:-7
                                           userInfo:@{NSLocalizedDescriptionKey : error.localizedDescription}]];
            }
            return [response accept:nil];

        } else {
            return [response reject:[NSError errorWithDomain:@"Native.FileManager"
                                                        code:-8
                                                    userInfo:@{
                                                        NSLocalizedDescriptionKey : @"FileContents required."
                                                    }]];
            ;
        }
    } else if ([self.request.opt isEqualToString:@"delete"]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (error != nil) {
            return
                [response reject:[NSError errorWithDomain:@"Native.FileManager"
                                                     code:-9
                                                 userInfo:@{NSLocalizedDescriptionKey : error.localizedDescription}]];
        }
        return [response accept:nil];
    } else if ([self.request.opt isEqualToString:@"check"]) {
        BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        return [response accept:@{ @"exist" : [NSNumber numberWithBool:fileExist] }];
    } else {
        return [response reject:[NSError errorWithDomain:@"Native.FileManager"
                                                    code:-10
                                                userInfo:@{
                                                    NSLocalizedDescriptionKey : @"Invalid opt value."
                                                }]];
    }
}

@end

@implementation LGOFileManager

+ (void)load {
    [[LGOCore modules] addModuleWithName:@"Native.FileManager" instance:[self new]];
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
    filePath = [filePath stringByReplacingOccurrencesOfString:@".." withString:@"."];
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
    }

    return [[LGOFileManager alloc] buildWithRequest:request];
}

@end
