//
//  LGOWebView+DataModel.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/9.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOWebView+DataModel.h"

@implementation LGOWebView (DataModel)

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
        if (!jsonData) { return ; }
        NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (!jsonString) { return ; }
        jsonString = [jsonString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet new]];
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            [self stringByEvaluatingJavaScriptFromString: [NSString stringWithFormat:@"if (typeof JSDataModel != 'undefined'){JSDataModel['%@'] = JSON.parse(decodeURIComponent('%@'))}", dataKey, jsonString] ];
            [self stringByEvaluatingJavaScriptFromString: [NSString stringWithFormat:@"(typeof JSDataModelDidChanged != 'undefined') && JSDataModelDidChanged('%@') ", dataKey] ];
        }];
        
    }
    else {
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            [self stringByEvaluatingJavaScriptFromString: [NSString stringWithFormat:@"if (typeof JSDataModel != 'undefined'){JSDataModel['%@'] = '%@'} ", dataKey, dataValue] ];
            [self stringByEvaluatingJavaScriptFromString: [NSString stringWithFormat:@"(typeof JSDataModelDidChanged != 'undefined') && JSDataModelDidChanged('%@') ", dataKey] ];
        }];
    }
}

@end
