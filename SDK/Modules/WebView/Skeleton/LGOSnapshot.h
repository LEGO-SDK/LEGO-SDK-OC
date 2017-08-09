//
//  LGOSnapshot.h
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 2017/8/9.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import "LGOCore.h"
#import "LGOWKWebView.h"
#import <WebKit/WebKit.h>

@interface LGOSkeletonSnapshot : NSObject

+ (NSString *)snapshotCacheKey:(NSURL *)URL;
+ (NSString *)snapshotCachePath:(NSURL *)URL;
+ (BOOL)snapshotExists:(NSURL *)URL;

@end

@interface LGOSkeletonSnapshotRequest : LGORequest

@property (nonatomic, copy) NSString *targetURL;
@property (nonatomic, copy) NSString *snapshotURL;

@end

@interface LGOSkeletonSnapshotOperation : LGORequestable<WKNavigationDelegate>

@property (nonatomic, strong) LGOSkeletonSnapshotRequest *request;
@property (nonatomic, strong) WKWebView *webView;

@end
