//
//  LGOWKWebView+DataModel.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/9.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <objc/runtime.h>
#import "LGOWKWebView+DataModel.h"

static int kDataModelIdentifierKey;

@implementation WKWebView (DataModel)

- (void)updateDataModel:(NSString *)dataKey dataValue:(id)dataValue{
    id oldValue = [self.dataModel valueForKey:dataKey];
    [self.dataModel setValue:dataValue forKey:dataKey];
    if (![NSJSONSerialization isValidJSONObject:self.dataModel]){
        self.dataModel[dataKey] = oldValue;
    }
    else {
        [self notifyDataModelDidChanged:dataKey dataValue:dataValue];
    }
}

- (void)notifyDataModelDidChanged:(NSString *)dataKey dataValue:(id)dataValue{
    if (self.loading) { return ; }
    if ([NSJSONSerialization isValidJSONObject:dataValue]){
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dataValue options:kNilOptions error:nil];
        if (jsonData == nil) { return ; }
        NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (jsonString == nil) { return ; }
        jsonString = [jsonString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet new]];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self evaluateJavaScript:[NSString stringWithFormat:@"if (typeof JSDataModel != 'undefined'){JSDataModel['%@'] = JSON.parse(decodeURIComponent('%@'))}", dataKey, jsonString] completionHandler:^(id _Nullable _, NSError * _Nullable error) {
                [self evaluateJavaScript:[NSString stringWithFormat:@"(typeof JSDataModelDidChanged != 'undefined') && JSDataModelDidChanged('%@') ", dataKey] completionHandler:nil];
            }];
        }];
    }
    else {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self evaluateJavaScript:[NSString stringWithFormat:@"if (typeof JSDataModel != 'undefined'){JSDataModel['%@'] = '%@'} ", dataKey, dataValue] completionHandler:^(id _Nullable _, NSError * _Nullable error) {
                [self evaluateJavaScript:[NSString stringWithFormat:@"(typeof JSDataModelDidChanged != 'undefined') && JSDataModelDidChanged('%@') ", dataKey] completionHandler:nil];
            }];
        }];
    }
}

- (NSMutableDictionary *)dataModel {
    if (objc_getAssociatedObject(self, &kDataModelIdentifierKey) == nil) {
        [self setDataModel:[NSMutableDictionary dictionary]];
    }
    return objc_getAssociatedObject(self, &kDataModelIdentifierKey);
}

- (void)setDataModel:(NSMutableDictionary *)dataModel {
    objc_setAssociatedObject(self, &kDataModelIdentifierKey, dataModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
