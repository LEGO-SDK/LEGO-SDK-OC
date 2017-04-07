//
//  LGOPageStore.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 2017/4/5.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import "LGOPageStore.h"
#import "LGOPage.h"

@interface LGOPageStore ()

@property (nonatomic, copy) NSDictionary *pages;

@end

@implementation LGOPageStore

+ (LGOPageStore *)sharedStore {
    static LGOPageStore *store;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [LGOPageStore new];
    });
    return store;
}

- (void)addItem:(LGOPageRequest *)request {
    if (request == nil || request.urlPattern == nil) {
        return;
    }
    NSMutableDictionary *pages = self.pages != nil ? [self.pages mutableCopy] : [NSMutableDictionary dictionary];
    [pages setObject:request forKey:[request urlPattern]];
    self.pages = pages;
}

- (LGOPageRequest *)requestItem:(NSURL *)url {
    if (url == nil) {
        return nil;
    }
    NSString *urlString = url.absoluteString;
    for (NSString *urlPattern in self.pages) {
        NSError *error = nil;
        NSRegularExpression *exp = [NSRegularExpression regularExpressionWithPattern:urlPattern options:kNilOptions error:&error];
        if (exp != nil) {
            NSTextCheckingResult *firstMatch = [exp firstMatchInString:urlString options:NSMatchingReportCompletion range:NSMakeRange(0, urlString.length)];
            if (firstMatch != nil && NSEqualRanges(firstMatch.range, NSMakeRange(0, urlString.length))) {
                return self.pages[urlPattern];
            }
        }
    }
    return nil;
}

@end
