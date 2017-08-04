//
//  LGOPack.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/8/15.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <SSZipArchive/SSZipArchive.h>
#import <CommonCrypto/CommonDigest.h>
#import "LGOPack.h"
#import "LGOCore.h"
#import "LGOPackRSA.h"

@implementation LGOPack

static NSDictionary *sharedPublicKeys;

+ (void)load {
    [[LGOCore modules] addModuleWithName:@"WebView.Pack" instance:[self new]];
}

+ (void)setPublicKey:(NSString *)publicKey forDomain:(NSString *)domain {
    NSMutableDictionary *mutable = [sharedPublicKeys mutableCopy] ?: [NSMutableDictionary dictionary];
    if (publicKey != nil && domain != nil) {
        [mutable setObject:publicKey forKey:domain];
    }
    sharedPublicKeys = [mutable copy];
}

+ (void)setPublicKey:(NSString *)publicKey forURI:(NSString *)URI {
    NSMutableDictionary *mutable = [sharedPublicKeys mutableCopy] ?: [NSMutableDictionary dictionary];
    if (publicKey != nil && URI != nil) {
        [mutable setObject:publicKey forKey:URI];
    }
    sharedPublicKeys = [mutable copy];
}

+ (void)createFileServerWithURL:(NSURL *)URL
                  progressBlock:(LGOPackFileServerProgressBlock)progressBlock
                completionBlock:(LGOPackFileServerCreatedBlock)completionBlock {
    if ([LGOCore whiteList].count > 0 && [[LGOCore whiteList] indexOfObject:[self requestTmpPath:URL]] == NSNotFound) {
        [[LGOCore whiteList] addObject:[[NSURL fileURLWithPath:[self requestTmpPath:URL]] absoluteString]];
    }
    NSString *documentHash = [NSString stringWithContentsOfFile:[self requestLocalHashPath:URL]
                                                       encoding:NSUTF8StringEncoding
                                                          error:NULL];
    if (documentHash != nil) {
        [self cloneFromPath:[self requestDocumentPath:URL] toPath:[self requestTmpPath:URL]];
        completionBlock([[NSURL fileURLWithPath:[self requestTmpPath:URL]] absoluteString]);
        [self updateFileServerWithURL:URL localHash:documentHash completionBlock:nil];
    }
    else {
        NSString *bundleFile = [[NSBundle mainBundle] pathForResource:[URL lastPathComponent] ofType:@""];
        if (bundleFile != nil) {
            [SSZipArchive unzipFileAtPath:bundleFile toDestination:[self requestDocumentPath:URL] progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {
                if (progressBlock) {
                    progressBlock((double)entryNumber / (double)total);
                }
            } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
                if (error == nil) {
                    NSString *md5 = [self requestMD5WithData:[NSData dataWithContentsOfFile:bundleFile]];
                    [md5 writeToFile:[self requestLocalHashPath:URL]
                          atomically:YES
                            encoding:NSUTF8StringEncoding
                               error:NULL];
                    [self cloneFromPath:[self requestDocumentPath:URL] toPath:[self requestTmpPath:URL]];
                    completionBlock([[NSURL fileURLWithPath:[self requestTmpPath:URL]] absoluteString]);
                    [self updateFileServerWithURL:URL localHash:md5 completionBlock: completionBlock];
                }
            }];
        }
        else {
            [self updateFileServerWithURL:URL localHash:nil completionBlock: completionBlock];
        }
    }
}

+ (void)updateFileServerWithURL:(NSURL *)URL localHash:(NSString *)localHash completionBlock:(LGOPackFileServerCreatedBlock)completionBlock {
    NSString *remoteHashURLString = [NSString stringWithFormat:@"%@?_t=%f", [[URL URLByAppendingPathExtension:@"hash"] absoluteString], [[NSDate date] timeIntervalSince1970]];
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:remoteHashURLString] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data != nil) {
            NSString *remoteHash = nil;
            if (URL.host != nil && [self requestPublicKey:URL] != nil) {
                NSString *encodedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (encodedString != nil) {
                    remoteHash = [LGOPackRSA decryptString:encodedString publicKey:[self requestPublicKey:URL]];
                }
            }
            if (remoteHash != nil && remoteHash.length == 32 && ![localHash isEqualToString:remoteHash]) {
                [[[NSURLSession sharedSession] downloadTaskWithURL:URL completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    if (error == nil && location != nil) {
                        NSError *err;
                        [[NSFileManager defaultManager] createDirectoryAtPath:[self requestPackageCachePath:URL] withIntermediateDirectories:YES attributes:nil error:NULL];
                        [[NSFileManager defaultManager] removeItemAtPath:[self requestPackageCachePath:URL]
                                                                   error:NULL];
                        [[NSFileManager defaultManager] copyItemAtPath:[location path]
                                                                toPath:[self requestPackageCachePath:URL]
                                                                 error:&err];
                        if (err == nil) {
                            NSString *downloadedHash = [self requestMD5WithData:[NSData dataWithContentsOfFile:[self requestPackageCachePath:URL]]];
                            if ([downloadedHash isEqualToString:remoteHash]) {
                                [SSZipArchive unzipFileAtPath:[self requestPackageCachePath:URL] toDestination:[self requestDocumentPath:URL] progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) { } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
                                    if (error == nil) {
                                        [downloadedHash writeToFile:[self requestLocalHashPath:URL]
                                                         atomically:YES
                                                           encoding:NSUTF8StringEncoding
                                                              error:NULL];
                                        [self cloneFromPath:[self requestDocumentPath:URL] toPath:[self requestTmpPath:URL]];
                                        if (completionBlock) {
                                            completionBlock([[NSURL fileURLWithPath:[self requestTmpPath:URL]] absoluteString]);
                                        }
                                    }
                                }];
                            }
                        }
                    }
                }] resume];
            }
        }
    }] resume];
}

+ (void)cloneFromPath:(NSString *)fromPath toPath:(NSString *)toPath {
    [[NSFileManager defaultManager] removeItemAtPath:toPath error:NULL];
    [[NSFileManager defaultManager] createDirectoryAtPath:toPath withIntermediateDirectories:YES attributes:nil error:NULL];
    for (NSString *currentPath in [[NSFileManager defaultManager] enumeratorAtPath:fromPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@", toPath, currentPath] error:NULL];
        [[NSFileManager defaultManager] copyItemAtPath:[NSString stringWithFormat:@"%@/%@", fromPath, currentPath]
                                                toPath:[NSString stringWithFormat:@"%@/%@", toPath, currentPath]
                                                 error:NULL];
    }
}

+ (NSString *)requestPublicKey:(NSURL *)URL {
    for (NSString *aKey in sharedPublicKeys) {
        if ([URL.absoluteString hasPrefix:aKey]) {
            return sharedPublicKeys[aKey];
        }
    }
    for (NSString *aKey in sharedPublicKeys) {
        if ([URL.host isEqualToString:aKey]) {
            return sharedPublicKeys[aKey];
        }
    }
    return nil;
}

+ (NSString *)requestLocalHashPath:(NSURL *)URL {
    NSString *appVersionString = [NSString stringWithFormat:@".%@.%@",
                                  [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"],
                                  [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"]];
    return [NSString stringWithFormat:@"%@/.lgopack%@.hash", [self requestDocumentPath:URL], appVersionString];
}

+ (NSString *)requestCacheKey:(NSURL *)URL {
    return [self requestMD5WithString:[[URL.absoluteString componentsSeparatedByString:@"?"] firstObject]];
}

+ (NSString *)requestPackageCachePath:(NSURL *)URL {
    return [NSString stringWithFormat:@"%@/LGOPack/%@.zip",
            NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject,
            [self requestCacheKey:URL]];
}

+ (NSString *)requestDocumentPath:(NSURL *)URL {
    return [NSString stringWithFormat:@"%@/LGOPack/%@",
            NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject,
            [self requestCacheKey:URL]];
}

+ (NSString *)requestTmpPath:(NSURL *)URL {
    return [NSString stringWithFormat:@"%@/LGOPack/%@",
            NSTemporaryDirectory(),
            [self requestCacheKey:URL]];
}

+ (NSString *)requestMD5WithString:(NSString *)str
{
    const char* input = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    return [digest lowercaseString];
}

+ (NSString *)requestMD5WithData:(NSData *)data {
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for (int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return [ret lowercaseString];
}

@end
